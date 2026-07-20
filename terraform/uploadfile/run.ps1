# Gerar ZIP do arquivo MZTOOL.zip
Compress-Archive -Path ".\data\zip\*" -DestinationPath ".\data\MZTOOL.zip" -Force

# Gerar SHA256 local do arquivo MZTOOL.zip
$hashMztool = (Get-FileHash -Path ".\data\MZTOOL.zip" -Algorithm SHA256).Hash

# Salvar hash local do arquivo MZTOOL.zip no repositório
Set-Content -Path ".\checksums\mztool.sha256" -Value $hashMztool

terraform -chdir=terraform\uploadfile init -upgrade
terraform -chdir=terraform\uploadfile apply -auto-approve
terraform -chdir=terraform\uploadfile output -json > terraform\uploadfile\terraform-outputs.json

$tfvarsPath = ".\terraform\uploadfile\terraform.tfvars"
$lines = Get-Content $tfvarsPath
$vars = @{}
foreach ($line in $lines) {
    if ($line -match '^\s*(\w+)\s*=\s*"?(.*?)"?\s*$') {
        $key = $matches[1]
        $value = $matches[2]
        $vars[$key] = $value
    }
}

$distributionId = $vars["cloudfront_distribution_id"]

aws cloudfront create-invalidation `
    --distribution-id $distributionId `
    --paths "/MZTOOL.zip" `
    --no-cli-pager

git add .\terraform\uploadfile\
git commit -m "Update SHA256 hash for MZTOOL.zip after S3 upload"
git push
