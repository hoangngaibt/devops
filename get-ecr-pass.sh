export AWS_ACCESS_KEY_ID=****************
export AWS_SECRET_ACCESS_KEY=*****************************
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=*******************

AWS_ECR_PASS=$(aws ecr get-login-password --region $AWS_REGION)

kubectl create secret docker-registry registry-secret-ecr-stag \
  --docker-server=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=${AWS_ECR_PASS} \
  --dry-run=client --output="yaml" > /root/aws-ecr-cred-stag/docker-registry-secret.yaml

kubectl apply -f /root/aws-ecr-cred-stag/docker-registry-secret.yaml
