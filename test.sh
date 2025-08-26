#!/bin/bash

aws_region_all_name(){
  fmt="%-16s%-4s%-25s\n"
  for i in $(aws ec2 describe-regions  --all-regions  --query 'Regions[].RegionName' --output text)
  do 
    printf "$fmt" "'$i" "=>" "$(aws ssm get-parameter --name /aws/service/global-infrastructure/regions/$i/longName --query "Parameter.Value" --output text)',"
  done
}


aws_region_all_name

test00(){
  selections=(
  "Selection A"
  "Selection B"
  "Selection C"
  )

  choose_from_menu "Please make a choice:" selected_choice "${selections[@]}"
  echo "Selected choice: $selected_choice"
}