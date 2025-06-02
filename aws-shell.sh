ec2_list() {
  aws ec2 describe-instances \
  --query "Reservations[].Instances[].[{Name: join(',',Tags[?Key=='Name'].Value),Env: join(',',Tags[?Key=='Environment'].Value), ID: InstanceId, Platform: PlatformDetails, IP: PrivateIpAddress, Type: InstanceType, AZ: Placement.AvailabilityZone}]|[][]|sort_by(@, &Env)" \
  --no-paginate --region ${AWS_REGION} --output table
}

aws_region_all_name(){
  fmt="%-16s%-4s%-25s\n"
  for i in $(aws ec2 describe-regions  --all-regions  --query 'Regions[].RegionName' --output text)
  do 
    printf "$fmt" "'$i" "=>" "$(aws ssm get-parameter --name /aws/service/global-infrastructure/regions/$i/longName --query "Parameter.Value" --output text)',"
  done
}

aws_region_All(){
  aws ec2 describe-regions --all-regions --query "Regions[].{Name:RegionName}" --output table
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
    "TargetGroups[].[TargetGroupArn,TargetGroupName,Protocol,Port,HealthCheckProtocol,HealthCheckPort,HealthCheckEnabled,HealthCheckIntervalSeconds,HealthCheckTimeoutSeconds,HealthyThresholdCount,UnhealthyThresholdCount,HealthCheckPath,TargetType,Matcher.HttpCode]" --output table
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
aws route53 list-resource-record-sets --hosted-zone-id $rid --query 'ResourceRecordSets[*].{Name:Name,Type:Type,TTL:TTL,Value:ResourceRecords[0].Value}'  --output table
}
aws_keypair_list() {
   aws ec2  describe-key-pairs --output table
}
aws_waf_list() {
  aws  wafv2  list-web-acls --scope  REGIONAL  --query 'WebACLs[*].{Id:Id,Name:Name,ARN:ARN}' --output table
}

aws_cf_distributions() {
  aws cloudfront list-distributions --output table --query 'DistributionList.Items[*].[Id,Origins.Items[0].DomainName]'
}

# aws_cf_distributions_conf() {
#   rid=$1
#   aws cloudfront get-distribution --id $rid
# }

awsACMlist(){
  aws acm list-certificates --query "CertificateSummaryList[*].{ARN:CertificateArn,DomainName:DomainName,Status:Status}"  --output table
}
awsEcrList(){
  aws ecr describe-repositories --query "repositories[*].{repositoryName:repositoryName,repositoryUri:repositoryUri}" --output table
}

awsEcrCreateRepository(){
  clear
  echo -n "Enter ECR Repository Name : "
  read ReposName
  ecr_name=$(echo "$ReposName" | tr '[:upper:]' '[:lower:]')
  aws ecr create-repository  --repository-name $ecr_name \
    --image-scanning-configuration scanOnPush=true
}

aws_ec2_instance_list(){
  aws ec2 describe-instance-types --no-paginate  --filters Name=current-generation,Values=true --query "InstanceTypes[*].{InstanceType_name: InstanceType,vcpus: VCpuInfo.DefaultVCpus, memory_in_mib: MemoryInfo.SizeInMiB}" --output table
}
awsEc2List(){
  aws ec2 describe-instances --query "Reservations[].Instances[].{Name:Tags[?Key==\`Name\`].Value|[0],InstanceId:InstanceId,ImageId:ImageId,InstanceType:InstanceType,KeyName:KeyName,PrivateIpAddress:PrivateIpAddress,PublicIpAddress:PublicIpAddress,State:State.Name}" --output table
}
awsEc2IamList(){
  aws ec2 describe-iam-instance-profile-associations --query "IamInstanceProfileAssociations[].{InstanceId:InstanceId,IamInstanceProfileARN:IamInstanceProfile.Arn,IamInstanceProfileID:IamInstanceProfile.Id}" --output table
}
awsIamUserList(){
  aws iam list-users --query "Users[].{UserName:UserName,UserId:UserId,Arn:Arn}" --output table
}
awsIamPolicyList(){
  aws iam list-policies --output table --query "Policies[].{PolicyName:PolicyName,PolicyId:PolicyId,Arn:Arn}"
}
awsIamRoleList(){
  aws iam list-roles --output table --query "Roles[].{RoleName:RoleName,Arn:Arn}"
}
awsIamRoleGet(){
  RoleName=$1
aws iam get-role --role-name $RoleName
}
awsIamInstanceProfileList(){
 aws iam list-instance-profiles --query "InstanceProfiles[*].{InstanceProfileName:InstanceProfileName,Arn:Arn,Roles:Roles[*].{RoleName:RoleName,Arn:Arn}}" --output table
}
awsSsmConnect(){
   SSMSSION=$1

   aws ssm start-session  --target $SSMSSION --region ${AWS_REGION}
}

zbgssst(){
  fmt="%-16s%-4s%-25s\t"
  ssss=""
  for i in $(aws ec2 describe-regions --all-regions --query "Regions[].{Name:RegionName}" --output text|awk '{printf "%s ",$1}')
  do 
    echo $i
    #bbb="$fmt" """$i"  "$(aws ssm get-parameter --name /aws/service/global-infrastructure/regions/$i/longName --query "Parameter.Value" --output text)"""
    aaa="$i $(aws ec2 describe-availability-zones --region $i --query "AvailabilityZones[*].{RegionName:RegionName,ZoneName:ZoneName,ZoneId:ZoneId}" --output text)"
    #$ssss=$ssss $bbb
    bbb="$bbb $aaa"
  done

  declare -a options=($bbb);
  generateDialog "options"  "${options[@]}"

  read choice
  # Do something after getting their choice
  clear
  echo $choice
  echo $(aws ssm get-parameter --name /aws/service/global-infrastructure/regions/$choice/longName --query "Parameter.Value" --output text)
  # Generates a dialog with ordered instructions
  # declare -a instructions=("Turn on the computer" "Check WiFi is enabled" "Go to GitHub" "Star cool repositories");
  # generateDialog "instructions" "GitHub Instructions" "${instructions[@]}"
}

LibPATH="/Users/vincent/Documents/git_home/vin/aws-shell"

. $LibPATH/aws-region-change.sh
. $LibPATH/rds.sh
. $LibPATH/crypto.sh
. $LibPATH/pulumi.sh
. $LibPATH/menu.sh