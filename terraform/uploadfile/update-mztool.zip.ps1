# Hashtable para armazenar as variáveis do tfvars
$tfvarsPath = ".\terraform\uploadfile\terraform.tfvars"
$lines = Get-Content $tfvarsPath
$vars = @{}

foreach ($line in $lines) {
    if ($line -match '^\s*([^=]+)\s*=\s*"?(.+?)"?\s*$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $vars[$key] = $value
    }
}


# Agora monta o objeto final de configuração
$config = @{
    ZipPath                  = ".\data\mztool.zip"
  
    # Variáveis extraídas do tfvars
    CloudfrontDistributionId = $vars["cloudfront_distribution_id"]
    MztoolZip                = $vars["mztool_zip"]
    GithubPat                = $vars["github_pat"]
    GithubRepo               = $vars["github_repo"]
  
}


#Função Update-MztoolZip: gera o novo arquivo zip local a partir de sua pasta orinal com arquivos e coleta e armazena as Hashes SHA256 e SHA512 na pasta .\checksums do novo arquivo criado.
function Update-MztoolZip {

    $path = $config.ZipPath
    $sourceFolder = ".\data\zip\*"
    $shaValue = "256", "512"
    
    if (Test-Path $sourceFolder) {

        # Gera o arquivo local mztool.zip
        Compress-Archive -Path $sourceFolder -DestinationPath $path -Force
    
        # Armazena as hashes SHA256 e SHA512 do arquivo mztool.zip local na pasta .\checksums
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

#Função Update-Terraform: envia o novo arquivo mztool.zip local para o bucket no S3 destinado e coleta e armazena a hash SHA256 no arquivo JSON terraform\uploadfile\terraform-outputs.json.
function Update-Terraform {

    $path = $config.ZipPath
   
    if (Test-Path $path) { 
       
        # Envia o arquivo mztool.zip para o bucket no S3 via Terraform.
        terraform -chdir=terraform\uploadfile init -upgrade
        terraform -chdir=terraform\uploadfile apply -auto-approve
     
        # Coleta a hash SHA256 do arquivo mztool.zip e insere no arquivo terraform-outputs.json para consulta futura.
        terraform -chdir=terraform\uploadfile output -json > terraform\uploadfile\terraform-outputs.json

    }

}

function Update-MultiCloudWorkflow {
    curl.exe -i -X POST `
        -H "Accept: application/vnd.github+json" `
        -H ("Authorization: Bearer {0}" -f $config.GithubPat) `
        -H "X-GitHub-Api-Version: 2022-11-28" `
        https://api.github.com/repos/mzti/mztool/dispatches `
        -d '{"event_type":"mztool-updated"}'
}



#Função Update-Cloudfront: Executa o cloudfront invalidation via AWS CLI para manter o arquivo mztool.zip atualizado no cloudfront.
function Update-Cloudfront {

    $distributionId = $config.CloudfrontDistributionId

    aws cloudfront create-invalidation `
        --distribution-id $distributionId `
        --paths "/mztool.zip" `
        --no-cli-pager

}

#Função Update-Github: Executa o commit e envio dos arquivos locais atualizados no repositório.
function Update-Github {

    # Commit e envio dos arquivos e pastas checksums/mztool.sha256, checksums/mztool.sha512 e terraform/uploadfile atualizados.
    
    # 1) Detectar branch atual
    $currentBranch = git rev-parse --abbrev-ref HEAD

    Write-Host "Branch atual: $currentBranch"

    # 2) Commitar terraform/uploadfile na branch atual
    git add terraform/uploadfile
    git commit -m "Update terraform/uploadfile after mztool.zip S3 upload"
    git push origin $currentBranch

    if ($currentBranch -ne "main") {

        Write-Host "Não está na main, Branch atual: $currentBranch"

        # 3) Salvar checksums temporariamente
        Write-Host "Salvando checksums temporariamente..."
        mkdir temp_checksums -ErrorAction SilentlyContinue
        Copy-Item -r checksums/* temp_checksums/

        # 4) Checkout da main
        Write-Host "Trocando para main..."
        git fetch origin main
        git checkout main

        # 5) Copiar checksums para main
        Write-Host "Copiando checksums para main..."
        Copy-Item -r temp_checksums/* checksums/
    
        # 6) Commitar checksums na main
        git add checksums
        git commit -m "Update checksums SHA256 SHA512 after mztool.zip S3 upload"
        git push origin main        

    }

    # 7) Voltar para a branch original
    Write-Host "Voltando para a branch original..."
    git checkout $currentBranch
    # Limpar temporários
    Remove-Item -Recurse -Force temp_checksums -ErrorAction SilentlyContinue

    #8) Commitar checksums também na branch atual
    git add checksums
    git commit -m "Mirror checksums from main"
    git push origin $currentBranch   

    Write-Host "Update-Github finalizado com sucesso."

}

#Executa a função Update-MztoolZip.
Update-MztoolZip

#Executa a função Update-Terraform.
Update-Terraform

#Executa a função Update-MultiCloudWorkflow.
Update-MultiCloudWorkflow

#Executa a função Update-Cloudfront.
Update-Cloudfront

#Executa a função Update-Github.
Update-Github
