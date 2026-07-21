$config = @{
    ZipPath = ".\data\MZTOOL.zip"
}

#Função Update-MztoolZip: gera o novo arquivo zip local a partir de sua pasta orinal com arquivos e coleta e armazena as Hashes SHA256 e SHA512 na pasta .\checksums do novo arquivo criado.
function Update-MztoolZip {

    $path = $config.ZipPath
    $sourceFolder = ".\data\zip\*"
    $shaValue = "256", "512"
    
    if (Test-Path $sourceFolder) {

        # Gera o arquivo local MZTOOL.zip
        Compress-Archive -Path $sourceFolder -DestinationPath $path -Force
    
        # Armazena as hashes SHA256 e SHA512 do arquivo MZTOOL.zip local na pasta .\checksums
        if (Test-Path $path) {   

            $shaValue | ForEach-Object {
            
                $hashPath = ".\checksums\mztool.sha$($_.ToLower())"
            
                if (Test-Path $hashPath) {
            
                    $oldHash = (Get-FileHash -Path $hashPath -Algorithm SHA$($_.ToLower())).Hash 
            
                }
            
                $newHash = (Get-FileHash -Path $path -Algorithm SHA$($_.ToLower())).Hash
       
                if ($newHash -ne $oldHash) {

                    Set-Content -Path $hashPath -Value $newHash

                }
            }
        }
    }

}

#Função Update-Terraform: envia o novo arquivo MZTOOL.zip local para o bucket no S3 destinado e coleta e armazena a hash SHA256 no arquivo JSON terraform\uploadfile\terraform-outputs.json.
function Update-Terraform {

    $path = $config.ZipPath
   
    if (Test-Path $path) { 
       
        # Envia o arquivo MZTOOL.zip para o bucket no S3 via Terraform.
        terraform -chdir=terraform\uploadfile init -upgrade
        terraform -chdir=terraform\uploadfile apply -auto-approve
     
        # Coleta a hash SHA256 do arquivo MZTOOL.zip e insere no arquivo terraform-outputs.json para consulta futura.
        terraform -chdir=terraform\uploadfile output -json > terraform\uploadfile\terraform-outputs.json

    }

}


#Função Update-Cloudfront: Executa o cloudfront invalidation via AWS CLI para manter o arquivo MZTOOL.ZIP atualizado no cloudfront.
function Update-Cloudfront {

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

}

#Função Update-Github: Executa o commit e envio dos arquivos locais atualizados no repositório.
function Update-Github {

    # Commit e envio dos arquivos e pastas checksums/mztool.sha256, checksums/mztool.sha512 e terraform/uploadfile atualizados.
    git add `
        terraform/uploadfile `
        checksums
    git commit -m "Update SHA256 and SHA512 hash for MZTOOL.zip after terraform S3 upload"
    git push

}

#Executa a função Update-MztoolZip.
Update-MztoolZip

#Executa a função Update-Terraform.
Update-Terraform

#Executa a função Update-Cloudfront.
Update-Cloudfront

#Executa a função Update-Github.
Update-Github