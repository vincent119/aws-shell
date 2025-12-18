
pu_set_org() {
  #echo "Select organization environment"
  PS3="Select organization environment: "
  items=("v16team 1" "IMtream 2" "Alas 3")
  select item in "${items[@]}" Quit
  do
    case $REPLY in
        1) export PULUMI_ORGANIZATION="v16team";break;;
        2) export PULUMI_ORGANIZATION="IMtream";break;;
        3) export PULUMI_ORGANIZATION="Alas";break;;
        *) echo "Ooops - unknown choice $REPLY";;
    esac
  done
  echo "Set organization to " $PULUMI_ORGANIZATION
  pulumi org set-default $PULUMI_ORGANIZATION
}