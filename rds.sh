
RDSengineVersions(){
  clear
  echo "RDS engine mariadb,mysql,postgres,aurora-mysql,aurora-postgresql"
  echo -n "Enter RDS engine Name: "
  read engineName
  aws rds describe-db-engine-versions --engine $engineName \
  --query "*[].EngineVersion" --output table
}

RDSDBInstanceClass(){
  clear
  echo "RDS engine mariadb,mysql,postgres,aurora-mysql,aurora-postgresql"
  echo -n "Enter RDS engine Name: "
  read engineName
  echo -n "Enter RDS engine version: "
  read 
  ecr_name=$(echo "$engineName" | tr '[:upper:]' '[:lower:]')
  aws rds describe-orderable-db-instance-options --engine $engineName --engine-version 15.3 \
    --query "*[].{DBInstanceClass:DBInstanceClass,StorageType:StorageType}|[?StorageType=='gp2']|[].{DBInstanceClass:DBInstanceClass}" \
    --output table
}
