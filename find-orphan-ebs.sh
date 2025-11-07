#!/usr/bin/env bash
# 嚴格模式：遇錯即停、未定義變數即錯、管線錯誤視為錯
set -Eeuo pipefail


AGE_DAYS="${2:-7}"

if [ -z "$AWS_REGION" ]; then
  echo "用法：$(basename "$0") <aws-region> [age-days]" 1>&2
  exit 1
fi

for cmd in aws kubectl jq grep sort date; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "缺少相依工具：$cmd" 1>&2
    exit 2
  }
done

if LC_ALL=C grep -q $'\r' "$0"; then
  echo "偵測到 CRLF 換行，請先：sed -i '' -e 's/\r$//' $0  或  dos2unix $0" 1>&2
fi

to_epoch() {
  iso="$1"
  if date -u -d "$iso" +%s >/dev/null 2>&1; then
    date -u -d "$iso" +%s
  else
    # macOS：去掉毫秒與 Z，轉為 +0000
    trimmed="${iso%Z}+0000"
    trimmed="${trimmed%%.*}+0000"
    date -u -j -f "%Y-%m-%dT%H:%M:%S%z" "$trimmed" +%s
  fi
}


PV_FILE="$(mktemp -t k8s_pv_vids.XXXXXX)"
kubectl get pv -o json \
  | jq -r '.items[] | select(.spec.csi.driver=="ebs.csi.aws.com") | .spec.csi.volumeHandle' \
  | sort -u > "$PV_FILE"

AWS_JSON="$(aws ec2 describe-volumes \
  --region "$AWS_REGION" \
  --filters "Name=status,Values=available" \
  --output json)"

JQ_FILTER=$(cat <<'JQ'
  .Volumes[]
  | {
      id: .VolumeId,
      size: .Size,
      az: .AvailabilityZone,
      create: .CreateTime,
      name: (.Tags // [] | map(select(.Key=="Name") | .Value) | first // ""),
      tags: (.Tags // [])
    }
  | select(
      ( [ .tags[]? | .Key | tostring ] | map(startswith("kubernetes.io/")) | any )
      or
      ( ((.name // "") | ascii_downcase) | contains("pvc") )
    )
  | @base64
JQ
)

CANDIDATES="$(printf '%s' "$AWS_JSON" | jq -r "$JQ_FILTER")"

OUT_FILE="${OUT_FILE:-orphan-ebs-${AWS_REGION}-$(date -u +%Y%m%dT%H%M%SZ).csv}"

echo "VolumeId,SizeGiB,AZ,CreateTime,AgeDays,InK8sPV,NameTag,DeleteCmd" | tee "$OUT_FILE" >/dev/null
NOW_EPOCH="$(date -u +%s)"

# 用 while 逐筆處理候選（base64 一行一筆，避免 IFS/空白問題）
echo "$CANDIDATES" | while IFS= read -r enc; do
  [ -z "$enc" ] && continue
  obj="$(printf '%s' "$enc" | base64 -d)"

  vol_id="$(printf '%s' "$obj" | jq -r '.id')"
  size="$(printf '%s' "$obj" | jq -r '.size')"
  az="$(printf '%s' "$obj" | jq -r '.az')"
  create="$(printf '%s' "$obj" | jq -r '.create')"
  name="$(printf '%s' "$obj" | jq -r '.name')"

  create_epoch="$(to_epoch "$create")"
  age_days="$(( (NOW_EPOCH - create_epoch) / 86400 ))"

  # 是否仍在 l
  if grep -Fxq "$vol_id" "$PV_FILE"; then
    in_k8s="yes"    # PV 還在，視為非孤立
  else
    in_k8s="no"     # 不在 PV，可能是孤立
  fi

  # 僅列：不在 PV 且年齡 >= 閾值 的可刪候選
  if [ "$in_k8s" = "no" ] && [ "$age_days" -ge "$AGE_DAYS" ]; then
    del="aws ec2 delete-volume --region '$AWS_REGION' --volume-id '$vol_id'"
    # CSV：以雙引號包起避免逗號/空白
    printf '"%s","%s","%s","%s","%s","%s","%s","%s"\n' \
      "$vol_id" "$size" "$az" "$create" "$age_days" "$in_k8s" "$name" "$del" | tee -a "$OUT_FILE" >/dev/null
  fi
done
echo "已輸出：$OUT_FILE"
rm -f "$PV_FILE"
