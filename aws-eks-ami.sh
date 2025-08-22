
AwsEksAmiQuery(){
  clear
  echo "AWS EKS AMI Query"
  echo -n "Enter K8s version exp 1.30: "
  read clusterVersion
  aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amazon-eks-node-al2023-x86_64-standard-${clusterVersion}-*" \
    --query 'reverse(sort_by(Images, &CreationDate))[].{
        Name: Name,
        ImageId: ImageId,
        Architecture: Architecture,
        PlatformDetails: PlatformDetails,
        ImageOwnerAlias: ImageOwnerAlias,
        Hypervisor: Hypervisor,
        CreationDate: CreationDate
    }' \
    --output table
}