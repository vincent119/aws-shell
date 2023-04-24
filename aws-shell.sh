ec2_list() {
  aws ec2 describe-instances \
  --query "Reservations[].Instances[].[{Name: join(',',Tags[?Key=='Name'].Value),Env: join(',',Tags[?Key=='Environment'].Value), ID: InstanceId, Platform: PlatformDetails, IP: PrivateIpAddress, Type: InstanceType, AZ: Placement.AvailabilityZone}]|[][]|sort_by(@, &Env)" \
  --no-paginate --region ${AWS_REGION} --output table
}

aws_region_all_name(){
  fmt="%-16s%-4s%-25s\n"
  for i in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)
  do 
    printf "$fmt" "'$i" "=>" "$(aws ssm get-parameter --name /aws/service/global-infrastructure/regions/$i/longName --query "Parameter.Value" --output text)',"
  done

}

aws_region_All(){
aws ec2 describe-regions \
    --all-regions \
    --query "Regions[].{Name:RegionName}" \
    --output table
}

aws_region_set(){
  ENV=$1
  if [[ -z $ENV ]];then
    echo "environment list...."
    echo "uat,dev,prod,im"
  fi
  if [[ $ENV == "uat" ]];then
    export AWS_REGION="ap-northeast-1"
    export AWS_PROFILE="uat-profile"
    echo "environment is UAT"
    echo "AWS Region is Tokyo"
    echo "AWS_REGION=ap-northeast-1"
  elif [[ $ENV == "dev" ]];then
    export AWS_REGION="ap-east-1"
    export AWS_PROFILE="default"
    echo "environment is Dev"
    echo "AWS Region is Hong Kong"
    echo "AWS_REGION=ap-east-1"
  elif [[ $ENV == "prod" ]];then
    export AWS_REGION="ap-southeast-1"
    export AWS_PROFILE="prod-profile"
    echo "environment is Master"
    echo "AWS Region is Sigapore"
    echo "AWS_REGION=ap-southeast-1"
  elif [[ $ENV == "im" ]];then
    export AWS_REGION="ap-east-1"
    export AWS_PROFILE="im-profile"
    echo "environment is IM-devops"
    echo "AWS Region is Hong Kong"
    echo "AWS_REGION=ap-east-1"
  fi


}
aws_ec2_instance_list(){
  aws ec2 describe-instance-types --no-paginate  --filters Name=current-generation,Values=true --query "InstanceTypes[*].{InstanceType_name: InstanceType,vcpus: VCpuInfo.DefaultVCpus, memory_in_mib: MemoryInfo.SizeInMiB}" --output table
}
aws_az_list() {
  aws ec2 describe-availability-zones --region $AWS_REGION --query "AvailabilityZones[*].{RegionName:RegionName,ZoneName:ZoneName,ZoneId:ZoneId}" --output table
}
aws_rule(){
aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0' \
    --query "SecurityGroups[*].{Name:GroupName,vpc:VpcId,sg:GroupId }" --output table
}
aws_elb_Get() {
   aws elbv2 describe-load-balancers --query \
   "LoadBalancers[].[LoadBalancerName,AvailabilityZones[0].ZoneName,AvailabilityZones[0].SubnetId,AvailabilityZones[1].ZoneName,AvailabilityZones[1].SubnetId]" --output table

}
aws_elb_Tag() {
    aws elbv2 describe-target-groups --query \
    "TargetGroups[].[TargetGroupArn,TargetGroupName,Protocol,Port,HealthCheckProtocol,HealthCheckPort,HealthCheckEnabled,HealthCheckIntervalSeconds,HealthCheckTimeoutSeconds,HealthyThresholdCount,UnhealthyThresholdCount,HealthCheckPath,TargetType,Matcher.HttpCode]"  \
    --output table     
}
aws_fw_Rule() {
aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupName,vpc:VpcId,sg:GroupId }" --output table
}

aws_ecr_list(){
aws ecr describe-repositories --output table --query 'repositories[].[repositoryName,repositoryUri]'
}

aws_route53_list_host_zone() {
aws route53 list-hosted-zones --output table --query 'HostedZones[*].[Name,Id]'
}
aws_route53_list_record() {
rid=$1
aws route53 list-resource-record-sets   --hosted-zone-id $rid --query 'ResourceRecordSets[*].[Name, Type, TTL, ResourceRecords[0].Value]'  --output text
}
aws_keypair_list() {
   aws ec2  describe-key-pairs --output table
}
