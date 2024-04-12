user="agent"
PAT=**************************
organization=*******************
poolId=10
#"self-host"
agentName="agent03"
agentId=1

USED_SPACE=$(df --output=used -h /dev/sda1 | tr -dc '0-9')
SPACE_CK=$(($USED_SPACE))

#Get list Agent:
curl -s --request GET -u ${user}:${PAT}  \
     --url "https://dev.azure.com/${organization}/_apis/distributedtask/pools/${poolId}/agents?api-version=7.0" \
     -H "Content-Type: application/json" | jq '.' > /root/script_docker_prune/agentlist.txt
#Get Agent Name and ID
jq -r '.value[] | [.name, .id] | @csv' /root/script_docker_prune/agentlist.txt | sed 's/"//g' > /root/script_docker_prune/agentidtmp.txt
#Get Aget ID
while IFS="," read -r AGENT_NAME AGENT_ID
do
  if [ "${AGENT_NAME}" = "${agentName}" ]; then
    export agentId=${AGENT_ID}
#    echo "Agent ID: ${AGENT_ID}"
  fi;
done < /root/script_docker_prune/agentidtmp.txt

#Get aget info
curl -s --request GET -u ${user}:${PAT}  \
     --url "https://dev.azure.com/${organization}/_apis/distributedtask/pools/${poolId}/agents/${agentId}?includeAssignedRequest=true&api-version=7.0" \
     -H "Content-Type: application/json" |jq '.' > /root/script_docker_prune/getagent.txt

AGENT_STATUS=$(jq '.assignedRequest' /root/script_docker_prune/getagent.txt)
#echo "values: $my_var"
if [ "$AGENT_STATUS" = "null" ]
then
  echo "$(date): Currently agent ${agentName} is not running any Job"  > /root/script_docker_prune/docker_prune.log

  if [ $SPACE_CK -gt 75 ]
  then
    docker compose -f /root/adoagent/docker-compose.yaml down
    sleep 2
    echo "$(date): docker system prune succeed ,Disk Used: $SPACE_CK GB. " >> /root/script_docker_prune/docker_prune.log
    docker system prune -a -f --volumes
    sleep 2
    docker pull public.ecr.aws/b2d1y8a5/ado-agent:12112023
    docker compose -f /root/adoagent/docker-compose.yaml up -d
    # Pull Image Bases.
    while read -r IMAGE_BASE;
    do
      docker pull $IMAGE_BASE
    done < /root/script_docker_prune/image_base_list.txt
  else
    echo "$(date): disk space usage is under threshold, Disk Used: $SPACE_CK GB." >> /root/script_docker_prune/docker_prune.log
  fi

else
  echo "$(date): Currently agent 01 is processing Job" > /root/script_docker_prune/docker_prune.log
  echo "$(date): disk space usage is under threshold, Disk Used: $SPACE_CK GB." >> /root/script_docker_prune/docker_prune.log
fi