#!/bin/zsh

function awsRegion() {
  check_fzf
  check_gawk

  current_profile="${AWS_PROFILE:-default}"
  aws_config_file="$HOME/.aws/config"

  if [ ! -f "$aws_config_file" ]; then
    echo "AWS config not found: $aws_config_file"
    exit 1
  fi

  profiles_data=$(awk '
    BEGIN { current = "" }
    /^\[.*\]$/ {
      current = $0
      gsub(/^\[|\]$/, "", current)
    }
    current != "" && /^[[:space:]]*region[[:space:]]*=/ {
      region = $0
      sub(/^[[:space:]]*region[[:space:]]*=[[:space:]]*/, "", region)
      printf("%s %s\n", current, region)
    }
  ' "$aws_config_file")

  if [ -z "$profiles_data" ]; then
    echo "No profiles found in AWS config."
    exit 1
  fi

  local -a options
  for line in ${(f)profiles_data}; do
    profile=$(echo "$line" | awk '{print $1}')
    region=$(echo "$line" | awk '{print $2}')
    if [[ "$profile" == "$current_profile" ]]; then
      options+=("\033[1;32m-> $profile ($region) (current)\033[0m")
    else
      options+=("   $profile ($region)")
    fi
  done

  selected=$(printf "%b\n" "Current AWS Profile: $current_profile" "${options[@]}" | \
    fzf --ansi --prompt="Select AWS Profile: " --cycle --height=100% --layout=reverse --info=inline --border \
        --header-lines=1 \
        --bind 'ctrl-/:change-preview-window(50%|hidden|)' \
        --color='fg+:#95cc5a,bg:#000000,hl+:#4aa4c2' \
        --color='info:#afaf87,prompt:#ff79c6,pointer:#a4c770' \
        --color='marker:#87ff00,spinner:#34c747,header:#87afaf')

  # 清除 ANSI 顏色碼
  clean_selected=$(echo "$selected" | sed -E 's/\x1B\[[0-9;]*m//g')

  selected_profile=$(echo "$clean_selected" | sed -E 's/^-> //;s/ \(current\)//;s/^ *//;s/ \([^)]*\)//')
  selected_region=$(echo "$clean_selected" | sed -E 's/^.*\(([^\)]+)\).*$/\1/')

  if [ -n "$selected_profile" ] && [ -n "$selected_region" ]; then
    echo "Selected Profile: $selected_profile"
    echo "Selected Region: $selected_region"
    export AWS_PROFILE="$selected_profile"
    export AWS_REGION="$selected_region"
    export AWS_DEFAULT_REGION="$selected_region"
  else
    echo "Keeping the current configuration: $current_profile"
  fi
}

function check_fzf() {
  if ! command -v fzf &> /dev/null; then
    echo "fzf is not installed. Please install it using 'brew install fzf'."
    exit 1
  fi
}

function check_gawk() {
  if ! command -v gawk &> /dev/null; then
    echo "gawk is not installed. Please install it using 'brew install gawk'."
    exit 1
  fi
}