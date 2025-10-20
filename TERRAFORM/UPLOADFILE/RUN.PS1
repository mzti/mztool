Compress-Archive -Path ".\DATA\ZIP\*" -DestinationPath ".\DATA\MZTOOL.zip" -Force

terraform init -upgrade
terraform apply -auto-approve
terraform output -json > terraform-outputs.json

.\COMMIT.ps1
