Compress-Archive -Path ".\DATA\MZTOOL\*" -DestinationPath ".\DATA\MZTOOL.zip" -Force

terraform init -upgrade
terraform apply -auto-approve
terraform output -json > terraform-outputs.json

Invoke-RestMethod ".\COMMIT.ps1" | Invoke-Expression
