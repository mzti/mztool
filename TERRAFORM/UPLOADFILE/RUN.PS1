Compress-Archive -Path ".\DATA\ZIP\*" -DestinationPath ".\DATA\MZTOOL.zip" -Force

terraform -chdir=TERRAFORM\UPLOADFILE init -upgrade
terraform -chdir=TERRAFORM\UPLOADFILE apply -auto-approve
terraform -chdir=TERRAFORM\UPLOADFILE output -json > TERRAFORM\UPLOADFILE\terraform-outputs.json

aws cloudfront create-invalidation --distribution-id E2WXAENP66ZGFB --paths /MZTOOL.zip

.\COMMIT.ps1
