terraform init -upgrade
terraform apply -auto-approve
terraform output -json > terraform-outputs.json
