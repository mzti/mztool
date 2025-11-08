Compress-Archive -Path ".\DATA\ZIP\*" -DestinationPath ".\DATA\MZTOOL.zip" -Force

terraform -chdir=TERRAFORM\UPLOADFILE init -upgrade
terraform -chdir=TERRAFORM\UPLOADFILE apply -auto-approve
terraform -chdir=TERRAFORM\UPLOADFILE output -json > TERRAFORM\UPLOADFILE\terraform-outputs.json


$tfvarsPath = ".\TERRAFORM\UPLOADFILE\terraform.tfvars"
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
    --paths "/MZTOOL.zip"

.\COMMIT.ps1