ec2_list() {
  aws ec2 describe-instances \
  --query "Reservations[].Instances[].[{Name: join(',',Tags[?Key=='Name'].Value),Env: join(',',Tags[?Key=='Environment'].Value), ID: InstanceId, Platform: PlatformDetails, IP: PrivateIpAddress, Type: InstanceType, AZ: Placement.AvailabilityZone}]|[][]|sort_by(@, &Env)" \
  --no-paginate --region ${AWS_REGION} --output table
}

aws_region_All(){
aws ec2 describe-regions \
    --all-regions \
    --query "Regions[].{Name:RegionName}" \
    --output table
}

aws_region_set(){
  ENV=$1
  if [[ $ENV == "uat" ]];then
    export AWS_REGION="ap-northeast-1"
    echo "environment is UAT"
    echo "AWS Region is Tokyo"
    echo "AWS_REGION=ap-northeast-1"
  elif [[ $ENV == "dev" ]];then
    export AWS_REGION="ap-east-1"
    echo "environment is Dev"
    echo "AWS Region is Hong Kong"
    echo "AWS_REGION=ap-east-1"
  elif [[ $ENV == "prod" ]];then
    export AWS_REGION="ap-southeast-1"
    echo "environment is Master"
    echo "AWS Region is Sigapore"
    echo "AWS_REGION=ap-southeast-1"
  fi


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
