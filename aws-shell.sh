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
  elif [[ $ENV == "dev" ]];then
    export AWS_REGION="ap-east-1"
    echo "environment is Dev"
    echo "AWS Region is Hong Kong"
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
    "TargetGroups[].[TargetGroupName,Protocol,Port,VpcId,HealthCheckProtocol,HealthCheckPort,HealthCheckEnabled,HealthCheckIntervalSeconds,HealthCheckTimeoutSeconds,HealthyThresholdCount,UnhealthyThresholdCount,HealthCheckPath,TargetType,Matcher.HttpCode]"  \
    --output text | column -t    
}
aws_fw_Rule() {
aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupName,vpc:VpcId,sg:GroupId }" --output table
}
