$cert = Get-ChildItem Cert:\CurrentUser\Root\DD9FFF3030DCDCD38E28A7AD6CB3E69AF3FDE848
Set-AuthenticodeSignature -FilePath .\mztool.ps1 -Certificate $cert

git add .
git commit -m "Updating files"
git push
