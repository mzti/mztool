<#
.SYNOPSIS
    Instalação e personalização automatizada de softwares e o perfil de usuário no ambiente Windows.

.DESCRIPTION
    Instala e atualiza softwares, personaliza o perfil de usuário no Windows automaticamente, realiza o download e executa softwares de diagnósticos a partir de pacotes e módulos da Microsoft, CDN's com redundância e da nuvem.
    
.NOTES
    Autor: Daniel Mozart - https://www.linkedin.com/in/danielmozart/
    Compatibilidade: Windows 11 e 10. PowerShell 5.1 ou superior.
    Versão: BETA.
     
.EXAMPLE

    1 - Implementação automatizada:

Módulos e Gerenciador de pacotes (MSIX, NuGet): Implementação, atualização e auto-reparo do Winget e PSWindowsUpdate.

Softwares (Winget, MSI, APPX): Adobe Acrobat Reader, Google Chrome, Microsoft 365, Microsoft Powershell, AnyDesk, Microsoft Visual C++ Redistributables 2015+ (x86 & x64), Microsoft VCLibs 14.0.

Atualizações (PSWindowsUpdate): Remoção de drivers de dispositivo não utilizados pelo sistema atualmente (Dispositivos Ocultos) e Implementação e Atualização de novos e atuais Drivers de Dispositivo e Atualizações do Windows Update.

Personalização do Perfil de Usuário (Regedit, XML, APPX): Tema, Ícones da Área de Trabalho e Barra de Tarefas, Remoção de Widgets, Remoção de Bloatwares, Remoção do Microsoft Copilot, Remoção de Ícones Visão de Tarefas e Notícias, Remoção de notificações da Central de Ações, Define o Google Chrome como navegador padrão e o Acrobat Reader como leitor de PDF padrão.

2 - Download e execução standalone automatizada em nuvem de softwares para monitoramento e diagnóstico de hardwares.

HDSentinel, AIDA64, CPUZ, BlueScreenView, Core Temp, Crystal Disk Info, HWInfo, GPUZ.

3 - Atualização automatizada de softwares e drivers através do Winget e Módulo Windows Update.

4 - Implementação automatizada de diferentes versões do Pacote Office e Microsoft 365.

.LINK
    https://github.com/DanielMozartt/MZTOOL    
#>

#MZTOOL - MOZART IT | MZ.IT | MOZART INFORMÁTICA | DANIEL MOZART

Clear-Host

#VARIÁVEIS GLOBAIS.
$Global:TITLE = 'MZTOOL BETA'
$Global:EXECUTIONPOLICY = { Get-ExecutionPolicy -List -ErrorAction SilentlyContinue }
$Global:MZTOOLMODULE = Get-Module -Name "MZTOOL" -ErrorAction SilentlyContinue 
$Global:WINVER = (Get-CimInstance Win32_OperatingSystem).Caption, (Get-CimInstance -Class Win32_OperatingSystem).OSArchitecture
$Global:PSVER = { $PSVersionTable.PSVersion }
$Global:MZPSVER = "5.1.0"
$Global:SCRIPTCODE = $MyInvocation.MyCommand.Definition

#$ErrorActionPreference = 'SilentlyContinue'

$Host.UI.RawUI.WindowTitle = "$Global:TITLE"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ((& $Global:EXECUTIONPOLICY).Scope -in @('Process', 'CurrentUser') -notin "Bypass") {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
}  

function OPSYS {

    #Verifica se o sistema operacional é suportado.

    if (-not ($Global:WINVER -match 'Windows 10|Windows 11')) {
      
        Write-Host "SISTEMA OPERACIONAL NÃO SUPORTADO."

        Read-Host "`n`nPRESSIONE ENTER PARA SAIR" | Out-Null

        Clear-Host

        Write-Host "ENCERRANDO MZTOOL - MOZART IT | MZ.IT | MOZART INFORMÁTICA | DANIEL MOZART"

        Start-Sleep 2

        EXIT

    }
}

OPSYS 

function PSVER {
   
    #Verifica se a versão do PowerShell é suportada.    

    if ((& $Global:PSVER) -lt [version]$Global:MZPSVER ) {
       
        Write-Host "VERSÃO NECESSÁRIA DO POWERSHELL:"$($Global:MZPSVER)" OU SUPERIOR."
       
        Write-Host "`n`VERSÃO ATUAL DO POWERSHELL  :"$(& $Global:PSVER)""

        Write-Host "`n`nATUALIZE A SUA VERSÃO DO POWERSHELL PARA CONTINUAR: `nhtps://github.com/PowerShell/PowerShell/releases/download/v7.5.1/PowerShell-7.5.1-win-x64.msi" -ForegroundColor Cyan
        
        Read-Host "`n`nPRESSIONE ENTER PARA SAIR" | Out-Null

        Clear-Host

        Write-Host "MZTOOL - MOZART IT | MZ.IT | MOZART INFORMÁTICA | DANIEL MOZART"

        Start-Sleep 2
       
        EXIT     
    
    }    
}

PSVER

function RESTARTADMIN {    
 
    # Obtém o ID e o Objeto de Segurança do usuário na sessão atual.
    $MYWINDOWSID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $MYWINDOWSPRINCIPAL = New-Object System.Security.Principal.WindowsPrincipal($MYWINDOWSID)
    $ADMINROLE = ([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    
    # Se a sessão não estiver sendo executada como administrador, reinicia solicitando UAC ao usuário.
    if (-not $MYWINDOWSPRINCIPAL.IsInRole($ADMINROLE)) {
        $RESTART = New-Object System.Diagnostics.ProcessStartInfo 'PowerShell'
        $RESTART.Arguments = "-Command `"${global:SCRIPTCODE}`""
        $RESTART.Verb = 'runas'
        [System.Diagnostics.Process]::Start($RESTART) | Out-Null
        EXIT
    }
    
}

RESTARTADMIN

function MZTOOLMODULE {

    # Define o nome do módulo
    $MODULENAME = "MZTOOL"

    # Define o caminho do diretório do módulo (pasta padrão para módulos do usuário)
    $MODULEDIR = Join-Path -Path (Split-Path -Path $PROFILE -Parent) -ChildPath "Modules\$MODULENAME"

    # Deleta o diretório, se existir.
    if (Test-Path $MODULEDIR) {
        Remove-Item  -Path $MODULEDIR -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    # Cria o diretório do módulo.
    New-Item -Path $MODULEDIR -ItemType Directory -Force | Out-Null

    # Define o caminho completo para o arquivo .psm1 do módulo
    $MODULEPATH = Join-Path -Path $MODULEDIR -ChildPath "$MODULENAME.psm1"

    # Verifica se o arquivo .psm1 já existe e o deleta, se necessário
    if (Test-Path -Path $MODULEPATH) {
        Remove-Item -Path $MODULEPATH -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }
    try { Invoke-RestMethod https://raw.githubusercontent.com/DanielMozartt/MZTOOL/refs/heads/BETA/MODULES/MZTOOL.psm1 | Out-File -FilePath $MODULEPATH -Encoding UTF8 }
    catch {
        $MODULECONTENT = @'
#MÓDULO MZTOOL

#region Variáveis Globais
$Global:TITLE = "MZTOOL BETA"
$Global:DESKTOP = "C:\Users\Public\DESKTOP"
$Global:MZTOOLMODULE = Get-Module -Name "MZTOOL" -ErrorAction SilentlyContinue 
$Global:EXECUTIONPOLICY = { Get-ExecutionPolicy -List -ErrorAction SilentlyContinue }
$Global:WINVER = (Get-CimInstance Win32_OperatingSystem).Caption, (Get-CimInstance -Class Win32_OperatingSystem).OSArchitecture
#endregion

#region Definições Globais
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
#endregion

#region Customização do Console
$Host.UI.RawUI.BackgroundColor = 'DarkBlue'
$H = Get-Host
$Win = $H.UI.RawUI.WindowSize
$Win.Height = 20
$Win.Width = 58
$H.UI.RawUI.Set_WindowSize($Win)
$H.UI.RawUI.Set_BufferSize($Win)
#endregion

#region Importações e API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    public const int GWL_STYLE = -16;
    public const int WS_SIZEBOX = 0x00040000;
    public const int WS_MAXIMIZEBOX = 0x00010000;

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
}
"@
#endregion

#region Fixar tamanho e remover redimensionamento
$global:hwnd = (Get-Process -Id $PID).MainWindowHandle
if ($global:hwnd -ne [IntPtr]::Zero) {
    $style = [Win32]::GetWindowLong($global:hwnd, [Win32]::GWL_STYLE)
    $newStyle = $style -band (-bnot ([Win32]::WS_SIZEBOX -bor [Win32]::WS_MAXIMIZEBOX))
    [Win32]::SetWindowLong($global:hwnd, [Win32]::GWL_STYLE, $newStyle)

    # Bloqueia a alteração do tamanho pelo mouse, sem reposicionar ou redimensionar a janela
    $SWP_NOMOVE = 0x0002
    $SWP_NOSIZE = 0x0001
    $SWP_NOZORDER = 0x0004
    $SWP_FRAMECHANGED = 0x0020
    $flags = $SWP_NOMOVE -bor $SWP_NOSIZE -bor $SWP_NOZORDER -bor $SWP_FRAMECHANGED
    [Win32]::SetWindowPos($global:hwnd, [IntPtr]::Zero, 0, 0, 0, 0, $flags)
}
#endregion

#region FUNÇÕES DO MÓDULO
function GETMZTOOLMODULE {     
        
    if (-not($Global:MZTOOLMODULE)) {
        
        Import-Module MZTOOL -Force -ErrorAction SilentlyContinue 
    }

    $Global:MZTOOLMODULE 
    
}
#endregion

#region FUNCÕES GLOBAIS

function TOOLDIR {

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> TOOL"   

    $ErrorActionPreference = 'silentlycontinue'
     
    #Se o diretório C:\MZTOOL já existir, é deletado.
    if (Test-Path -Path $env:TOOL -ErrorAction SilentlyContinue) {

        Remove-Item -Path $env:TOOL -Recurse -Force -ErrorAction SilentlyContinue
    }

    #Criação do diretório C:\MZTOOL.
    [System.IO.Directory]::CreateDirectory($env:TOOL) | Out-Null
    $TOOLFOLDER = Get-Item $env:TOOL -ErrorAction SilentlyContinue
    $TOOLFOLDER.Attributes = 'Hidden' 

}

function NEWPWSH {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Functions,
        [switch]$Wait,
        [switch]$ReturnProcess,
        [switch]$Hidden
    )    
    
    $baseDefinition = (Get-Command -Type Function GETMZTOOLMODULE).Definition

    # Junta as definições das funções especificadas
    $funcDefinitions = foreach ($fn in $Functions) {
    (Get-Command -Type Function $fn).Definition
    } -join "`n"

    $combinedDefinitions = $baseDefinition + "`n" + $funcDefinitions
    # Converte o conteúdo para Base64 para uso com -EncodedCommand
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($combinedDefinitions))
    $arguments = @('-EncodedCommand', $encodedCommand)
    
    if ($Wait -and $Hidden) {
        # Se ambos, Wait e Hidden, forem true:
        [void](Start-Process powershell -ArgumentList $arguments -Wait -WindowStyle Hidden)
        return
    }
    elseif ($Wait -and $ReturnProcess) {
        $proc = Start-Process powershell -ArgumentList $arguments -PassThru -Wait
        return $proc
    }
    elseif ($Wait) {
        [void](Start-Process powershell -ArgumentList $arguments -Wait)
        return
    }
    elseif ($Hidden) {
        [void](Start-Process powershell -ArgumentList $arguments -WindowStyle Hidden)
        return
    }
    elseif ($ReturnProcess) {
        $proc = Start-Process powershell -ArgumentList $arguments -PassThru       
        return $proc
    }
    else {
        [void](Start-Process powershell -ArgumentList $arguments)
        return
    }
    
}

<#
function NEWPWSH {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Functions,
        [switch]$Wait,
        [switch]$ReturnProcess,
        [switch]$Hidden
    )    
      
    $baseDefinition = (Get-Command -Type Function GETMZTOOLMODULE).Definition
    $funcDefinitions = foreach ($fn in $Functions) {
        (Get-Command -Type Function $fn).Definition
    } -join "`n"
    
    $combinedDefinitions = $baseDefinition + "`n" + $funcDefinitions
  
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($combinedDefinitions))
      
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"   
    $psi.Arguments = "-EncodedCommand `"$encodedCommand`""
    $psi.UseShellExecute = $false  
    $psi.RedirectStandardOutput = $true
    
    if ($Hidden) {
        $psi.WindowStyle = 'Hidden'
        $psi.CreateNoWindow = $true
    }

    else {
        $psi.CreateNoWindow = $false
    }

    $process = [System.Diagnostics.Process]::Start($psi)
    if ($Wait -and $ReturnProcess) {
        $process.WaitForExit()
        $output = $process.StandardOutput.ReadToEnd()
        return $output
    } 
    elseif ($Wait) {
        $process.WaitForExit()
    }
    elseif ($ReturnProcess) {
        $output = $process.StandardOutput.ReadToEnd()
        return $output
    }   
    else {}
}
#>

# Função para exibir a barra de progresso in-place em uma linha fixa.           
function DEPLOYFUNCTIONPROGRESS {
    param(
        [Parameter(Mandatory = $true)]
        [int]$PercentComplete,
        [int]$BarWidth = 30,
        [string]$Message = "IMPLEMENTANDO",
        [int]$LinePosition = 17
    )

    $rawUI = $Host.UI.RawUI
    $windowSize = $rawUI.WindowSize

    # Posiciona o cursor na linha fixa determinada por -LinePosition
    $cursorPos = $rawUI.CursorPosition
    $cursorPos.X = 0
    $cursorPos.Y = $LinePosition
    $rawUI.CursorPosition = $cursorPos

    # Calcula o número de caracteres preenchidos e vazios
    $filled = [math]::Round($PercentComplete * $BarWidth / 100)
    $empty = $BarWidth - $filled
    $bar = ("#" * $filled) + ("-" * $empty)
    $progressText = "${Message}: {0,3}% [$bar]" -f $PercentComplete

    # Limpa a linha completa e escreve a barra de progresso
    $clearLine = " " * $windowSize.Width
    Write-Host $clearLine -NoNewline
    $rawUI.CursorPosition = $cursorPos
    Write-Host $progressText -NoNewline
}

function DEPLOYFUNCTION {
    param(
        [hashtable[]]$DEPLOYFUNCTIONHASH,
        [int]$BarWidth = 30,
        [int]$LinePosition = 17,
        [switch]$HIDDENALL
    )
    
    $total = $DEPLOYFUNCTIONHASH.Count
    $completed = 0

    # Exibe a barra inicial (0% concluído)
    DEPLOYFUNCTIONPROGRESS -PercentComplete 0 -BarWidth $BarWidth -Message "IMPLEMENTANDO" -LinePosition $LinePosition
    
   
    foreach ($group in $DEPLOYFUNCTIONHASH) {       
        
        # Se para este grupo foi especificado Wait, adiciona o parâmetro Wait com valor $true
        # Inicializa os valores padrão para os switches
        $Wait = $false
        if ($group.ContainsKey("Wait") -and $group.Wait) {
            $Wait = $true
        }

        # Aqui, $HIDDENALL é um parâmetro (SwitchParameter) da função DEPLOYFUNCTION.
        # Se ele estiver presente, vamos garantir que na passagem para NEWPWSH
        # seja utilizado o valor $true.
        $Hidden = $false
        if ($HIDDENALL) {
            $Hidden = $true
        }

        # Monta a tabela de parâmetros para passar à função NEWPWSH
        $arguments = @{
            Functions = $group.Functions
            Wait      = $Wait
            Hidden    = $Hidden
        }

        # Chama a função passando os parâmetros via splatting
        NEWPWSH @arguments
           
      
        $completed++
        $percent = [math]::Round(($completed * 100) / $total)
        DEPLOYFUNCTIONPROGRESS -PercentComplete $percent -BarWidth $BarWidth -Message "IMPLEMENTANDO" -LinePosition $LinePosition
        
        # Aguarda 3 segundos antes de iniciar o próximo grupo
        Start-Sleep -Seconds 3
    }

    # Ao término, pula para a linha seguinte para que o prompt não fique sobre a barra
    Write-Host ""
}   

function TESTLINK {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )
    try {
        $req = [System.Net.HttpWebRequest]::Create($Url)
        $req.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"  # Simula um navegador
        $req.AllowAutoRedirect = $true  # Permite seguir redirecionamentos automaticamente
        $req.Method = "GET"  # Usa GET ao invés de HEAD para capturar corretamente a URI final
        $resp = $req.GetResponse()
        $resp.Close()
        return $true
    }
    catch {
        return $false
    }
}
# Exibe o status dos links
function CLOUDSTATUS {
    param (
        [STRING]$URL,
        [STRING]$CLOUD
    )
  
    Write-Host "               "$($CLOUD)"  " -NoNewline; $(if (TESTLINK -Url $URL) {
            Write-Host "ONLINE" -ForegroundColor Green
        }    
        else {
            Write-Host "OFFLINE" -ForegroundColor Red
        })

}     

function DOWNLOADPROGRESS {
    param(
        [Parameter(Mandatory = $true)]
        [int]$PercentComplete,
        [int]$BarWidth = 30
    )

    $rawUI = $Host.UI.RawUI
    $winSize = $rawUI.WindowSize

    # Posiciona o cursor na última linha
    $cursorPos = $rawUI.CursorPosition
    $cursorPos.X = 0
    $cursorPos.Y = $winSize.Height - 1
    $rawUI.CursorPosition = $cursorPos

    $filled = [math]::Round($PercentComplete * $BarWidth / 100)
    $empty = $BarWidth - $filled
    $bar = ("#" * $filled) + ("-" * $empty)
    $progress = "BAIXANDO: {0,3}% [{1}]" -f $PercentComplete, $bar

    $clearLine = " " * $winSize.Width
    Write-Host $clearLine -NoNewline
    $rawUI.CursorPosition = $cursorPos
    Write-Host $progress -NoNewline
}

# Função para efetuar o download via HttpWebRequest e atualizar a barra de progresso
function INVOKEDOWNLOAD {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [Parameter(Mandatory = $true)]
        [string]$Destination,
        [int]$BarWidth = 30
    )

    Add-Type -AssemblyName "System.Net.Http"

    # Força o uso do TLS 1.2 para conexões seguras (necessário para HTTPS)
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    try {
        $req = [System.Net.HttpWebRequest]::Create($Url)
        $req.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        $req.AllowAutoRedirect = $true
        $resp = $req.GetResponse()
    }
    catch {
        return
    }

    $totalBytes = $resp.ContentLength
    if ($totalBytes -eq -1) {
        return
    }

    $inputStream = $resp.GetResponseStream()

    try {
        $fileStream = [System.IO.File]::Create($Destination)
    }
    catch {
        return
    }

    $buffer = New-Object byte[] 8192
    $totalRead = 0
    $lastPercent = 0

    while (($read = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $fileStream.Write($buffer, 0, $read)
        $totalRead += $read
        if ($totalBytes -gt 0) {
            $percent = [math]::Round(($totalRead / $totalBytes) * 100)
            if ($percent -ne $lastPercent) {
                DOWNLOADPROGRESS -PercentComplete $percent -BarWidth $BarWidth
                $lastPercent = $percent
            }
        }
    }

    $fileStream.Dispose()
    $inputStream.Dispose()
    $resp.Dispose()
}

# Função que tenta baixar de uma lista de URLs (ordem de prioridade)
function DOWNLOAD {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Urls,
        [Parameter(Mandatory = $true)]
        [string]$Destination,
        [int]$BarWidth = 30
    )

    foreach ($url in $Urls) {
        if (TESTLINK -Url $url) {
            INVOKEDOWNLOAD -Url $url -Destination $Destination -BarWidth $BarWidth
            return
        }

        else {
            
            #Caso os links estejam fora do ar oferece um menu de opções.
            
            DISPLAYMENUDOWNLOADERROR
            
        }
    }
}

function EXPANDPROGRESS {
    param(
        [Parameter(Mandatory = $true)]
        [int]$PercentComplete
    )

    $rawUI = $Host.UI.RawUI
    $windowSize = $rawUI.WindowSize

    # Posiciona o cursor na última linha da janela
    $cursorPos = $rawUI.CursorPosition
    $cursorPos.X = 0
    $cursorPos.Y = $windowSize.Height - 1
    $rawUI.CursorPosition = $cursorPos

    # Define o tamanho da barra (por exemplo, 50 caracteres)
    $barWidth = 30
    $filled = [math]::Round($PercentComplete * $barWidth / 100)
    $empty = $barWidth - $filled

    $bar = ("#" * $filled) + ("-" * $empty)
    $progressText = "EXTRAINDO: {0,3}% [{1}]" -f $PercentComplete, $bar

    # Limpa a última linha e escreve a barra de progresso
    $clearLine = " " * $windowSize.Width
    Write-Host $clearLine -NoNewline
    $rawUI.CursorPosition = $cursorPos
    Write-Host $progressText -NoNewline
}

# Função auxiliar para extrair uma entrada via streams (caso ExtractToFile não esteja disponível)
function EXPANDSTREAM {
    param (
        [Parameter(Mandatory = $true)]
        $Entry,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,
        [switch]$Quiet
    )

    try {
        $fileStream = [System.IO.File]::Create($DestinationPath)
    }
    catch {
        if (-not $Quiet) {
            Write-Host "Falha ao criar '$DestinationPath': $_" -ForegroundColor Red
        }
        return
    }

    if (-not $fileStream) {
        if (-not $Quiet) {
            Write-Host "fileStream nulo para '$DestinationPath'." -ForegroundColor Red
        }
        return
    }

    $stream = $Entry.Open()
    $buffer = New-Object byte[] 8192
    while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $fileStream.Write($buffer, 0, $bytesRead)
    }
    $fileStream.Dispose()
    $stream.Dispose()
}

# Função principal para extrair o ZIP com a barra de progresso customizada na parte inferior
function EXPAND {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,
        [switch]$Force,
        [switch]$Quiet
    )

    # Cria o diretório de destino, se não existir
    if (-not (Test-Path $DestinationPath)) {
        New-Item -Path $DestinationPath -ItemType Directory | Out-Null
    }

    # Carrega a assembly para manipulação de arquivos ZIP
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # Abre o arquivo ZIP para leitura
    $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    $totalEntries = $zipArchive.Entries.Count
    $currentEntry = 0

    foreach ($entry in $zipArchive.Entries) {
        $currentEntry++
        $percentComplete = [math]::Round(($currentEntry / $totalEntries) * 100)
        # Atualiza a barra de progresso customizada na última linha
        EXPANDPROGRESS -PercentComplete $percentComplete

        # Define o caminho completo de destino para a entrada
        $destPath = Join-Path -Path $DestinationPath -ChildPath $entry.FullName

        if ([string]::IsNullOrEmpty($entry.Name) -or $entry.FullName.EndsWith("/")) {
            # Trata diretórios
            if (-not (Test-Path $destPath)) {
                New-Item -Path $destPath -ItemType Directory | Out-Null
            }
        }
        else {
            # Garante que o diretório pai exista
            $directory = Split-Path -Path $destPath -Parent
            if (-not (Test-Path $directory)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }
        
            # Se necessário, remove o arquivo existente (utilizando -Force)
            if ((Test-Path $destPath) -and $Force.IsPresent) {
                try {
                    Remove-Item $destPath -Force -ErrorAction Stop
                }
                catch {
                    if (-not $Quiet) {
                        Write-Host "Não foi possível remover '$destPath'. Pulando essa entrada." -ForegroundColor Red
                    }
                    continue
                }
            }
        
            # Tenta usar o método ExtractToFile, se disponível
            $methInfo = $entry.GetType().GetMethod("ExtractToFile")
            if ($methInfo) {
                try {
                    $entry.ExtractToFile($destPath, $Force.IsPresent)
                }
                catch {
                    if (-not $Quiet) {
                        Write-Host "Erro em ExtractToFile para '$($entry.FullName)', usando stream." -ForegroundColor Yellow
                    }
                    EXPANDSTREAM -Entry $entry -DestinationPath $destPath -Quiet:$Quiet
                }
            }
            else {
                if (-not $Quiet) {
                    Write-Host "Método ExtractToFile indisponível para '$($entry.FullName)', usando stream." -ForegroundColor Yellow
                }
                EXPANDSTREAM -Entry $entry -DestinationPath $destPath -Quiet:$Quiet
            }
        }
    }

    # Fecha o arquivo ZIP
    $zipArchive.Dispose()

    # Limpa a última linha da janela após a conclusão
    $rawUI = $Host.UI.RawUI
    $windowSize = $rawUI.WindowSize
    $cursorPos = $rawUI.CursorPosition
    $cursorPos.X = 0
    $cursorPos.Y = $windowSize.Height - 1
    $rawUI.CursorPosition = $cursorPos
    Write-Host (" " * $windowSize.Width)

    if (-not $Quiet) {
        Write-Host "Extração de '$Path' concluída com sucesso em '$DestinationPath'." -ForegroundColor Green
    }
}

function INTERNET {

    $INTERNET = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet
    if (-not($INTERNET)) {

        Write-Warning "AGUARDANDO CONEXÃO COM A INTERNET."

        do { 
            $INTERNET = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet 
            Start-Sleep Seconds -5 
        }while (-not($INTERNET))
    }
      
}

function DESKTOPUPDATE {         
    for ($i = 0; $i -le 1; $i++) {
        (New-Object -ComObject shell.application).toggleDesktop()
        Start-Sleep 2
        (New-Object -ComObject Wscript.Shell).sendkeys('{F5}')
        Start-Sleep 1
        (New-Object -ComObject shell.application).undominimizeall()
        Start-Sleep 2
    }
}

function REFRESHUSER {
    Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,UpdatePerUserSystemParameters"
    Stop-Process -Name explorer        
}

function UNINSTALLOFFICE {
    function GetAllInstalledOffice {
  
        $OfficeApps = @()    
     
        $UninstallPaths = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
            
        foreach ($path in $UninstallPaths) {
            $apps = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
            Where-Object { 
                $_.DisplayName -like "*Office*" -or 
                $_.DisplayName -like "*Microsoft Office*" -or 
                $_.DisplayName -like "*Microsoft 365*" 
            }
            if ($apps) {
                $OfficeApps += $apps
            }
        }    
        return $OfficeApps
    }    
    
    function UninstallOfficeApps {
        param(
            [Parameter(Mandatory = $true)]
            [Array]$OfficeApps
        )
    
        foreach ($app in $OfficeApps) {
                    
            If ($app.UninstallString -notmatch "MsiExec.exe") {           
               
                $uninstallCmd = $app.UninstallString
                
                RESETCURSOR
              
                Write-Warning "INICIANDO DESINSTALAÇÃO - $($app.DisplayName)"
         
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCmd" -Wait -NoNewWindow

            }            
        }
    }
    
    $InstalledOffice = GetAllInstalledOffice
    
    if ($InstalledOffice.Count -gt 0) {       
       
        Write-Warning "`nINSTALAÇÃO DO OFFICE OU 365 ENCONTRADA:"
        foreach ($app in $InstalledOffice) {
            RESETCURSOR
            Write-Host "$($app.DisplayName) - VERSÃO: $($app.DisplayVersion)" -ForegroundColor Green
        }         
        UninstallOfficeApps -OfficeApps $InstalledOffice
    }
    else {
        RESETCURSOR
        Write-Warning "NENHUMA INSTALAÇÃO DO OFFICE OU 365 ENCONTRADA. INICIANDO INSTALAÇÃO."
    }

    $StillInstalled = (GetAllInstalledOffice).Count -gt 0

    return $StillInstalled
}

function CLEANTEMP {
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> CLEANTEMP"

    Write-Host 'LIMPANDO ARQUIVOS TEMPORÁRIOS'

    # Função para remoção de arquivos temporários.
    function REMOVEFILE {
        param (
            [string]$Path,
            [string]$Description
        )

        RESETCURSOR

        Write-Host "`rLimpando $Description" -NoNewline   
        
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Remove arquivos temporários do sistema.
    REMOVEFILE -Path "$env:TEMP\*" -Description "arquivos temporários do sistema"

    # Remove arquivos temporários do Windows.
    REMOVEFILE -Path "C:\Windows\temp\*" -Description "arquivos temporários do Windows"

    # Remove arquivos de Prefetch.
    REMOVEFILE -Path "C:\Windows\Prefetch\*" -Description "arquivos de Prefetch"

    # Remove arquivos de CrashDumps.
    REMOVEFILE -Path "$env:LOCALAPPDATA\CrashDumps\*" -Description "arquivos de CrashDumps"
    
    # Remove arquivos de Internet Temporários.
    REMOVEFILE -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Description "arquivos de Internet Temporários"

    # Remove arquivos de atualização do Windows.
    REMOVEFILE -Path "C:\Windows\SoftwareDistribution\Download\*" -Description "arquivos de atualização do Windows"

    # Remove relatórios de erros do Windows.
    REMOVEFILE -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Description "relatórios de erros do Windows"
    REMOVEFILE -Path "C:\ProgramData\Microsoft\Windows\WER\Temp\*" -Description "relatórios de erros do Windows"
    
    # Remove histórico do Microsoft Defender.
    REMOVEFILE -Path "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*" -Description "histórico do Microsoft Defender"

    # Remove arquivos de programas baixados.
    REMOVEFILE -Path "C:\Windows\Downloaded Program Files\*" -Description "arquivos de programas baixados"

    # Remove cache de sombreador DirectX.
    REMOVEFILE -Path "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache\*" -Description "cache de sombreador DirectX"

    # Remove arquivos de otimização de entrega.
    REMOVEFILE -Path "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Description "arquivos de otimização de entrega"

    # Remove miniaturas.
    REMOVEFILE -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Description "miniaturas"

    if (Test-Path -Path $env:TOOL -ErrorAction SilentlyContinue) {

        REMOVEFILE -Path $env:TOOL -Description "pasta TOOL."
    }
   
    Start-Sleep -Seconds 2
}

function RESETCURSOR {
    $rawUI = $Host.UI.RawUI
    $windowSize = $rawUI.WindowSize
    # Posiciona o cursor na última linha da janela
    $cursorPos = $rawUI.CursorPosition
    $cursorPos.X = 0
    $cursorPos.Y = $windowSize.Height - 1
    $rawUI.CursorPosition = $cursorPos
    # Limpa a última linha e escreve a barra de progresso
    $clearLine = " " * $windowSize.Width
    Write-Host $clearLine -NoNewline          
    $rawUI.CursorPosition = $cursorPos
}

function ENTRYERROR {
    
    #ENTRADA INVÁLIDA.

    RESETCURSOR
    Write-Host 'OPÇÃO INVÁLIDA. INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
    Start-Sleep -Seconds 1        
    
    $callStack = Get-PSCallStack

    # Verifica se há um chamador. Geralmente, o índice 1 contém o contexto do menu.
    if ($callStack.Count -gt 1) {
        $callerFrame = $callStack[1]
        $callerFunction = $callerFrame.Command  # Normalmente exibe o nome da função chamadora
    
        Start-Sleep -Seconds 1
        # Invoca novamente a função chamadora
        & $callerFunction
    }
    else {
        Write-Host "Nenhum menu encontrado para retornar. Encerrando." -ForegroundColor Yellow
        pause
    }
}

function CLOCKDATE {

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> CLOCK|DATE"   

    #Define um novo servidor e sincroniza o relógio e a data do sistema.  
  
    w32tm /config /manualpeerlist:pool.ntp.br /syncfromflags:manual /update
    net start w32time 
    w32tm /resync /force
   
}  
#endregion

$Global:GIT = $FALSE
'@         
        # Grava o conteúdo no arquivo .psm1 (sobrescrevendo, se necessário)
        Set-Content -Path $MODULEPATH -Value $MODULECONTENT -Force
    }  
}

function GETMZTOOLMODULE {     
        
    if (-not($Global:MZTOOLMODULE)) {
        
        Import-Module MZTOOL -Force -ErrorAction SilentlyContinue 
    }

    $Global:MZTOOLMODULE = Get-Module -Name "MZTOOL" -ErrorAction SilentlyContinue 
    
}

do {   
    # Importa o módulo MZTOOL para a sessão atual.
    MZTOOLMODULE 
    GETMZTOOLMODULE 
        
 
    # Verifica se o módulo foi carregado com sucesso.
    if ($Global:MZTOOLMODULE) {

        $MODULESTATUS = "MÓDULO ON"

    }

    else {       
               
        $TRYGETMODULE++      
        
        #Se o número de tentativas for maior ou igual a 5, encerra o MZTOOL.
        if ($TRYGETMODULE -ge 5) {

            Write-Host "Tentativas de carregamento do módulo MZTOOL esgotadas. ENCERRANDO MZTOOL" -ForegroundColor Red
            Start-Sleep -Seconds 5
            EXIT
        }

        Write-Host ($MODULESTATUS = "MÓDULO OFF") -ForegroundColor Yellow
        
    }    

} while (-not ($Global:MZTOOLMODULE))

$Global:ENVIROMENTVARS = @{
    'TOOL'                 = "C:\MZTOOL"
    'Global:DESKTOP'       = "C:\Users\Public\DESKTOP"
    'Global:TITLE'         = $Global:TITLE 
    'Global:WINVER'        = $Global:WINVER  
    'Global:PROFILELOADED' = "`$True"         
    'MZTOOL'               = "irm https://bit.ly/MZT00L | iex"
    'MZBETA'               = "irm https://bit.ly/MZBETA | iex"
     
}.GetEnumerator() | ForEach-Object {      
    
    if ($_.Key -in @('MZTOOL', 'MZBETA', 'TOOL')) {
       
        $PWSHKEY = "PowerShell " ; if ($_.Key -eq 'TOOL') { $PWSHKEY = $null } 

        # Define o a variável para cada Scopo. Se a variável já existir, ela será atualizada.
        foreach ($SCOPE in @('Process', 'User')) {
            [Environment]::SetEnvironmentVariable($_.Key, "$($PWSHKEY)$($_.Value)", $SCOPE)
        }
    }
    $_
}

NEWPWSH -Functions 'CLOCKDATE' -Hidden

<#
# Define as variáveis no perfil do PowerShell e verifica se foi carregado, se não, tenta carregá-lo.
function GETPROFILE {  

   $Global:ENVIROMENTVARS | ForEach-Object {
if ($_.Key -notin @('MZTOOL', 'MZBETA')) { 
 
        # Cria o arquivo de perfil do PowerShell se não existir.
        if (-not (Test-Path $PROFILE)) { New-Item $PROFILE -ItemType File -Force | Out-Null > $null 2>&1 }
                              
        # Cria a linha de definição da variável (com o símbolo $ escapado).
        $SETENVPROFILE = "`$$($_.Key) = `"$($_.Value)`"`n`n"        
                
        # Verifica se a variável já existe no arquivo de perfil.
        if (Select-String -Path $PROFILE -Pattern "`$$($_.Key) =" -Quiet) {            
            $PROFILEBKP = Get-Content -Path $PROFILE | Where-Object { $_ -notmatch "`$$($_.Key) =" } 
            $PROFILEBKP + $SETENVPROFILE | Set-Content -Path $PROFILE           
        } 
         
        # Adiciona a variável ao arquivo de perfil na biblioteca Powershell do ambiente User.
        else {
            Add-Content -Path $PROFILE -Value $SETENVPROFILE
        }
    }
}
    if ($Global:PROFILELOADED -eq $True) {
        Write-Host "`nO perfil de usuário foi carregado." -ForegroundColor Green
    }
    else {
        . $PROFILE
        Start-Sleep -Seconds 2        
        if ($Global:PROFILELOADED -eq $True) {
            Write-Host "O perfil de usuário foi carregado." -NoNewline -ForegroundColor Green
        }
        else { Write-Host "FALHA NO PERFIL DE USUÁRIO POWERSHELL."-NoNewline -ForegroundColor Red }
        Start-Sleep -Seconds 2
    }
}
       
GETPROFILE
#>

<#
    Get-ExecutionPolicy -List | Where-Object { $_.Scope -in @('LocalMachine', 'CurrentUser') } | ForEach-Object {
        if ($_.ExecutionPolicy -eq "Undefined") {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope $_.Scope -Force -ErrorAction SilentlyContinue 2>$null
            Write-host "REDEFININDO POLITICA DE EXECUÇÃO TEMPORARIAMENTE." -ForegroundColor Gray           
            RESTARTADMIN
        } 

        else {
            Write-host "POLITICA DE EXECUÇÃO JÁ DEFINIDA TEMPORARIAMENTE." -ForegroundColor Green
        }
    }

# Define as variáveis de ambiente no escopo do sistema (Machine) para MZTOOL e MZBETA.
$Global:ENVIROMENTVARS | Where-Object { $_.Key -in @('MZTOOL', 'MZBETA') } | ForEach-Object { 
    
    [Environment]::SetEnvironmentVariable($_.Key, $_.Value, 'Machine') 
    
    $loadedValue = [Environment]::GetEnvironmentVariable($_.Key, 'Machine')
    
    if ($loadedValue -eq $_.Value) {
        Write-Host "VARIÁVEL "$_.Key" CARREGADA NO SCOPO MACHINE." -ForegroundColor Green
    }
   
    else {
        Write-Host "FALHA AO CARREGAR "$_.Key" NO ESCOPO MACHINE." -ForegroundColor Red
    }
}
#>

#MENU -----------------------------------------------------

$FUNCTIONCALLSTACK = function DISPLAYMENU {

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE"         
    
    Clear-Host
    Write-Host '
______________________________________________________
|                                                    |
|                       MZTOOL                       |
| _______________________BETA_______________________ | 
|                                                    | 
|                                                    |
| |1| INSTALAÇÃO COMPLETA                            |
| |2| DIAGNÓSTICO DE HARDWARE E SISTEMA              |
| |3| INSTALAR WINGET & WINDOWS UPDATE               |
| |4| INSTALAR OFFICE                                |
| |0| SAIR                                           |
|                                                    |
|                 MOZART INFORMÁTICA | DANIEL MOZART |
|____________________________________________________|
'
    # Informa se o Módulo está importado.
    Write-Host "$MODULESTATUS $(if ($Global:GIT) { "- GIT VERSION" } else { "- PS1 VERSION" })" -ForegroundColor $(if ($Global:MZTOOLMODULE) { 'Green' } else { 'Red' })

    # Solicita ao usuário que insira o número correspondente à opção desejada.
    $CHOICE = Read-Host "`nINSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA"
   
    Switch ($CHOICE) {

        #OPÇÃO 1 - INSTALAR SOFTWARES E ATUALIZAÇÕES DO SISTEMA.
        1 {
            #Verifica se há conexão com internet.
            INTERNET
           
            $Host.UI.RawUI.WindowTitle = "$Global:TITLE> INSTALL"
                       
            Clear-Host
            Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| __________________________________________________ |
|                                                    |
|                     AGUARDE                        |
|                                                    |
|                  EM INSTALAÇÃO                     |
|                                                    |
|                                                    |
|                                 MOZART INFORMÁTICA |
|                                      DANIEL MOZART |
|____________________________________________________|
'
            $DEPLOYFUNCTION = @(
                @{ Functions = 'PERFILTHEME' },
                @{ Functions = 'ANYDESK' },
                @{ Functions = 'WINGETMODULE'; Wait = $true },
                @{ Functions = 'WINUPDATEMODULE', 'REMOVEGHOSTDRIVERS', 'WINUPDATE' },
                @{ Functions = 'WINGETAPPS', 'WINGETUPGRADE' },
                @{ Functions = 'MICROSOFT365'; Wait = $true },
                @{ Functions = 'PINICONS', 'STARTSOFTWARES' }
            )
       
            # Executa o conjunto de funções com os devidos parâmetros especificados.
            DEPLOYFUNCTION -BarWidth 30 -LinePosition 17 -DEPLOYFUNCTIONHASH $DEPLOYFUNCTION -HIDDENALL   
            
            Clear-Host
            Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|                                                    |
|                                                    |
|      INSTALAÇÃO CONCLUÍDA - ENCERRANDO MZTOOL      |
|                                                    |
|   O WINDOWS SERÁ ATUALIZADO AGORA EM SEGUNDO PLANO |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'
            Start-Sleep -Seconds 5

            DISPLAYMENU
            
        }
       
        #OPÇÃO 2 - DIAGNÓSTICO DE HARDWARE E SISTEMA.
        2 {
            #Verifica se há conexão com internet.
            INTERNET
            
            $Host.UI.RawUI.WindowTitle = "$Global:TITLE> TOOL"    
               
            Clear-Host
            Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|            FERRAMENTAS DE DIAGNÓSTICOS             |
|                                                    |
|                                                    |
|               DOWNLOAD EM ANDAMENTO                |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'                               
            DOWNLOADMZTOOL            
          
            function DISPLAYMENU2 {
                
                $Host.UI.RawUI.WindowTitle = "$Global:TITLE> TOOL"

                Clear-Host
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|            FERRAMENTAS DE DIAGNÓSTICOS             |
|                                                    |
|                                                    |
| |1| INICIAR FERRAMENTAS DE DIAGNÓSTICO             |
| |2| FECHAR TODAS AS FERRAMENTAS                    |
| |3| FECHAR FERRAMENTAS E VOLTAR AO MENU            |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'         

                $CHOICE = Read-Host 'INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
             
                Switch ($CHOICE) {

                    1 {
                        DIAGNOSTICS -START
                                                    
                        DISPLAYMENU2
                    }
                    
                    2 {                     
                        DIAGNOSTICS -STOP                                            

                        DISPLAYMENU2
                    }

                    3 {
                        DIAGNOSTICS -STOP 

                        DISPLAYMENU
                    }

                    default {
                        ENTRYERROR
                    }

                }
            }
                
            DISPLAYMENU2

        }

        3 {
            function DISPLAYMENU3 {
    
                Clear-Host        
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|             WINGET & WINDOWS UPDATE                |
|                                                    |
| |1| ISTALAR MÓDULOS WINGET E WINDOWS UPDATE        |
| |2| INSTALAR ATUALIZAÇÕES (MÓDULOS JÁ INSTALADOS)  |
| |3| VOLTAR                                         |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA | DANIEL MOZART |
|____________________________________________________|
'
                $CHOICE = Read-Host 'INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
                Switch ($CHOICE) {
                    1 {
                        #Verifica se há conexão com internet.
                        INTERNET

                        Clear-Host
                        Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|             WINGET & WINDOWS UPDATE                |
|                                                    |
|                                                    |
|           INSTALAÇÃO DE MÓDULOS INICIADA           |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'
                        $Null = @(                             
                            NEWPWSH -Functions 'WINGETMODULE' -ReturnProcess
                            NEWPWSH -Functions 'WINUPDATEMODULE' -ReturnProcess
                        ) | Where-Object { $_.Id -gt 0 } | ForEach-Object { Wait-Process -Id $_.Id }         
         
                        CLEANTEMP

                        DISPLAYMENU3
            
                    }
        
                    2 {
                        #Verifica se há conexão com internet.
                        INTERNET

                        Clear-Host
                        Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|             WINGET & WINDOWS UPDATE                |
|                                                    |
|                                                    |
|        INSTALAÇÃO DE ATUALIZAÇÕES INICIADA         |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
' 
                        $Null = @(
                            NEWPWSH -Functions 'WINGETUPGRADE' -ReturnProcess
                            NEWPWSH -Functions 'REMOVEGHOSTDRIVERS', 'WINUPDATE' -ReturnProcess
                        ) | Where-Object { $_.Id -gt 0 } | ForEach-Object { Wait-Process -Id $_.Id } 

                        CLEANTEMP
                                    
                        DISPLAYMENU3
                    }
        
                    3 {
                        DISPLAYMENU
                    }
        
                    default {
                        ENTRYERROR
                    }
             
                }
                       
            }

            DISPLAYMENU3

        }
       

        4 {

            $FUNCTIONCALLSTACK = function DISPLAYMENU4 {
                param(
                    [int]$CHOICE4
                )
            
                Clear-Host            
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|                 MICROSOFT OFFICE                   |
|                                                    |
|                                                    |
| |1| INSTALAR OFFICE 365                            | 
| |2| INSTALAR OFFICE 2007                           |
| |3| VOLTAR                                         |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'
                if (-not $CHOICE4) {
                    $CHOICE4 = [int](Read-Host 'INSIRA O NÚMERO CORRESPONDENTE À OPÇÃO DESEJADA')
                }
                switch ($CHOICE4) {
                   
                    1 {
                        #Verifica se há conexão com internet.
                        INTERNET

                        Clear-Host
                        Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|                   MICROSOFT 365                    |
|                                                    |
|                                                    |
|                    INSTALANDO                      |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'    
                                        
                        $365STATUS = MICROSOFT365    
                       
                        DISPLAYMENU365STATUS -365STATUS $365STATUS    
                   
                        CLEANTEMP
             
                        DISPLAYMENU 
                    }

                    2 {
                        #Verifica se há conexão com internet.
                        INTERNET

                        Clear-Host
                        Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|               MICROSOFT OFFICE 2007                |
|                                                    |
|                                                    |
|                    INSTALANDO                      |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
 '
                        OFFICE2007

                        CLEANTEMP                   

                        DISPLAYMENU
                    }
               
                    3 {
                        DISPLAYMENU
                    }

                    default {
                        ENTRYERROR
                    }
                }

            }
            DISPLAYMENU4
        } 

        0 {
            #OPÇÃO 0 - ENCERRAR MZTOOL.
            
            EXITMZTOOL         
            
        }
       
        # COMANDOS DE TESTE OCULTOS DO MENU.
        
        #Testa a função ANYDESK.
        any {

            NEWPWSH -Functions 'ANYDESK' 
            DISPLAYMENU

        }    

        #Testa a função WINGETAPPS.
        w {
            
            NEWPWSH -Functions 'WINGETAPPS' -Wait
            DISPLAYMENU

        }

        #Testa a função WINUPDATE.
        u {

            NEWPWSH -Functions 'WINUPDATEMODULE', 'WINUPDATE' -Wait
            DISPLAYMENU

        }
        
        #Testa a função CLOCKDATE.
        h {

            NEWPWSH -Functions 'CLOCKDATE'
            DISPLAYMENU

        }

        #Testa a função PRO.
        p {

            NEWPWSH -Functions 'PRO' 
            DISPLAYMENU

        }

        #Testa a função IMGHEALTH.
        sfc {

            NEWPWSH -Functions 'IMGHEALTH', 'CLEANTEMP'             
            DISPLAYMENU

        }

        #Testa a função DRIVERBOOSTER.
        db {

            DOWNLOADMZTOOL
            NEWPWSH -Functions 'DRIVERBOOSTER'
            DISPLAYMENU

        }

        awin {
            awin exit
        }

        default {
            ENTRYERROR
        }
    }
}
#Funções auxiliares do MENU.
function EXITMZTOOL {
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> EXIT"  

    Clear-Host
    Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|                                                    |
|                                                    |
|                                                    |
|                 ENCERRANDO MZTOOL                  |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'
    CLEANTEMP

    EXIT 

}

function DISPLAYMENUDOWNLOADERROR {      
    
    do {
    
        Clear-Host
        Write-Host '
______________________________________________________
|                                                    |
|                       MZTOOL                       |
| __________________________________________________ | 
|            FERRAMENTAS DE DIAGNÓSTICOS             | 
|                                                    |'
        Write-Host '|  ONEDRIVE     = ' -NoNewline; Write-Host "OFFLINE"-ForegroundColor Red -NoNewline; Write-Host "                            |"
        Write-Host '|  GOOGLE DRIVE = ' -NoNewline; Write-Host "OFFLINE"-ForegroundColor Red -NoNewline; Write-Host "                            |" 
        Write-Host '|                                                    |
|                                                    |
| |1| TENTAR NOVAMENTE                               |
| |2| VOLTAR AO MENU PRINCIPAL                       |
| |0| ENCERRAR MZTOOL                                |
|                                                    |
|                 MOZART INFORMÁTICA | DANIEL MOZART |
|____________________________________________________|'

        $CHOICE = Read-Host "INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA"
    
        switch ($CHOICE) {
            '1' {                        
                return
                break
            }
            '2' {
                DISPLAYMENU
                break
            }
            '0' {    
                EXITMZTOOL       
            }
            default {
                ENTRYERROR
            }
        }
    } while ($true)
}

function DISPLAYMENU365STATUS {
    param(
        [switch]$365STATUS 
    ) 

    if ($365STATUS -eq "1") {

        Write-Warning "MICROSOFT 365 INSTALADO COM SUCESSO."    
        Start-Sleep -Seconds 5

    }

    if ($365STATUS -eq "2") {
        
        Clear-Host
        Write-Host '
______________________________________________________
|                                                    |        
|                      MZTOOL                        |
| _________________________________________________  |
|                   MICROSOFT 365                    |
|                                                    |
|       SERVIÇO DE INSTALAÇÃO INDISPONÍVEL           |
|                                                    |
|   |1| TENTAR NOVAMENTE                             |
|   |2| IGNORAR & CONTINUAR                          |
|   |3| VOLTAR AO MENU                               |
|   |0| ENCERRAR MZTOOL                              |      
|                                                    |
|                 MOZART INFORMÁTICA | DANIEL MOZART |
|____________________________________________________|  
' 
        Write-Host "INSIRA O NÚMERO CORRESPONDENTE À OPÇÃO DESEJADA:"
           
        $timeoutEmSegundos = 10
            
        $cronometro = [System.Diagnostics.Stopwatch]::StartNew()
        while (-not [System.Console]::KeyAvailable -and ($cronometro.Elapsed.TotalSeconds -lt $timeoutEmSegundos)) {
            Start-Sleep -Milliseconds 100
        }

        if ([System.Console]::KeyAvailable) {
            # Se uma tecla estiver disponível, lê a linha (o que o usuário digitou)
            $CHOICE = [System.Console]::ReadLine().Trim()
        }
        else {
            # Se o tempo expirar sem entrada, seta a opção para 2
            $CHOICE = 2
               
        }
        switch ($CHOICE) {
            1 {
                $WINGETAVAILABLE = Get-Command winget -ErrorAction SilentlyContinue
                if (-not ($WINGETAVAILABLE)) { WINGETMODULE }
                DISPLAYMENU4 -CHOICE4 1
            }
            2 {
                #SCRIPT CONTINUA.
            }
            3 {
                DISPLAYMENU                     
            }
            0 {
                EXITMZTOOL
            }
            default {
                ENTRYERROR
            } 
        }  
    }  
    
    if ($365STATUS -eq "3") {

        Write-Warning "ENCONTRADA(S) UMA OU MAIS VERSÃO(S) DO MICROSOFT 365 OU OFFICE JÁ INSTALADO(S).`n`nDESINSTALE A(S) VERSÃO(S) JÁ INSTALADA(S)`n`n"    
        Start-Sleep -Seconds 5
        
    }                                       
}

#FUNÇÕES---------------------------------------------------------------

function DOWNLOADMZTOOL {
     
    # Download do arquivo MZTOOL.zip

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> DOWNLOADMZTOOL"  

    $MZTOOLZIP = "$Env:TOOL\MZTOOL.zip"

    $MZTOOLZIPHASH1 = "465B09A547F5FAA30B7CDD1B49126185"
    $MZTOOLZIPHASH2 = "15795A668435FA4A6F81A6E9BFB4DEEB"
    $MZTOOLZIPHASH = @($MZTOOLZIPHASH1, $MZTOOLZIPHASH2)

    $MZTOOLAWS = 'https://d15d16xpb69uci.cloudfront.net/MZTOOL.zip'      
    $MZTOOLGOOGLEDRIVE = 'https://drive.usercontent.google.com/download?id=19eiKJbx55RgkV_KczFrkL7uMkxjVrMo9&confirm=yy'
    
    TOOLDIR
    
    # Exibe o status dos links das Nuvens. 
    CLOUDSTATUS -URL $MZTOOLAWS -CLOUD AWS
    CLOUDSTATUS -URL $MZTOOLGOOGLEDRIVE -CLOUD GOOGLEDRIVE   
    
    # Lista de URLs para teste (AWS + Google Drive como fallback).
    $DRIVEURLS = @($MZTOOLAWS, $MZTOOLGOOGLEDRIVE)

    do {
        
        DOWNLOAD -Urls $DRIVEURLS -Destination $MZTOOLZIP -BarWidth 30
              
        $NEWMZTOOLZIPHASH = Get-FileHash -Path $MZTOOLZIP -Algorithm MD5 -ErrorAction SilentlyContinue
    
        $TRYGETMZTOOLZIP++   
        
        if ($TRYGETMZTOOLZIP -ge 3) {
            $MZTOOLAWS = 'HTTPS://NULL.NULL'           
            $DRIVEURLS = @($MZTOOLAWS, $MZTOOLGOOGLEDRIVE)              
        }
            
        #Se o número de tentativas for maior ou igual a 5, encerra o MZTOOL.
        if ($TRYGETMZTOOLZIP -ge 5) {
    
            Write-Warning "FALHA NO CARREGAMENTO DO MZTOOL.ZIP. RETORNANDO AO MENU."
            Start-Sleep -Seconds 3
            DISPLAYMENU
        }
  
    } while (
        (-not (Test-Path -Path $MZTOOLZIP -ErrorAction SilentlyContinue)) -or 
        ($NEWMZTOOLZIPHASH.Hash -notin @("$MZTOOLZIPHASH1", "$MZTOOLZIPHASH2"))
    )
    
    $MZTOOLZIPHASH | Where-Object ( $_ -eq $NEWMZTOOLZIPHASH.Hash ) | ForEach-Object {
        Write-Host "`nHASH = " ; Write-Host "`n"$($_)"`n"$($NEWMZTOOLZIPHASH.Hash)"" -ForegroundColor Green
    }

    RESETCURSOR   

    #Verifica se o arquivo MZTOOL.zip existe antes de extrair.
    if (Test-Path -Path $MZTOOLZIP -ErrorAction SilentlyContinue ) {        
  
        #Extrai o arquivo MZTOOL.zip para a pasta $Env:TOOL.
        EXPAND -Path $MZTOOLZIP -DestinationPath $env:TOOL -Force -Quiet
                      
        #Deleta o arquivo MZTOOL.zip.
        Remove-Item $MZTOOLZIP

    }   
  
}

function DIAGNOSTICS {
    param(
        #[Parameter(Mandatory = $true)]
        [Switch]$START,
        [Switch]$STOP
    )  

    # Inicializa ou encerra os softwares de diagnósticos de hardware x64 ou x32.
    $TOOLFOLDER = "$env:TOOL\TOOL"
                                
    $APPS = @(
        @{ Name = "aida64"; Path = "AIDA_64\aida64.exe" },
        @{ Name = "BlueScreenView"; Path = "BLUE_SCREEN_VIEW\BlueScreenView.exe" },
        @{ Name = "HDSentinel"; Path = "HDSENTINEL\HDSentinel.exe" },
        @{ Name = "GPU_Z"; Path = "GPU_Z.exe" }
    )

    if ($Global:WINVER -match '64 bits') {
        $APPS += @(
            @{ Name = "Core_Temp_64"; Path = "CORE_TEMP\Core_Temp_64.exe" },
            @{ Name = "cpuz_x64"; Path = "CPU_Z\cpuz_x64.exe" },
            @{ Name = "HWiNFO64"; Path = "HWINFO\HWiNFO64.exe" }
        )
    }
    elseif ($Global:WINVER -match '32 bits') {
        $APPS += @(
            @{ Name = "Core_Temp_32"; Path = "CORE_TEMP\Core_Temp_32.exe" },
            @{ Name = "cpuz_x32"; Path = "CPU_Z\cpuz_x32.exe" },
            @{ Name = "HWiNFO32"; Path = "HWINFO\HWiNFO32.exe" }
        )
    }
    else {
        Write-Host "ARQUITETURA DO SISTEMA NÃO SUPORTADA."       
    }
 
    if ($START) {
  
        $APPS | ForEach-Object {
            if (-not (Get-Process -Name $_.Name -ErrorAction SilentlyContinue)) {
                Start-Process "$TOOLFOLDER\$($_.Path)"
            }
        }   
    }

    elseif ($STOP) { 
        
        $APPS | ForEach-Object {
            if (Get-Process -Name $_.Name -ErrorAction SilentlyContinue) {                 
                Stop-Process -Name $_.Name -Force -ErrorAction SilentlyContinue
            }            
        }        
    }
    
    else {
        Write-Host "SWITCH NÃO DETECTADO."
    }
}

function WINUPDATEMODULE {
    
    #INSTALAÇÃO DOS MÓDULO WINDOWS UPDATE.       
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> WINUPDATEMODULE"   
    
    #Pacote NuGet.
    Install-PackageProvider -Name NuGet -Force |  Clear-Host   
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted  |  Clear-Host
    
    #Módulo WINDOWS UPDATE.
    Install-Module PSWindowsUpdate -AllowClobber -Force |  Clear-Host
    Import-Module PSWindowsUpdate -Force |  Clear-Host        
                
}

function WINGETMODULE {
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE > WINGETMODULE"
   
    #Implementa e ou atualiza o WINGET.
     
    #Verifica se a versão do Windows é a 11.
    if ($Global:WINVER -Match 'Windows 11') {
                     
        #Reinstala, redefine as fontes e atualiza o Módulo WINGET.
        Start-BitsTransfer -Source 'https://cdn.winget.microsoft.com/cache/source.msix' -Destination "$env:TEMP\source.msix" -ErrorAction SilentlyContinue |  Clear-Host
        Add-AppPackage -Path "$env:TEMP\source.msix" -ErrorAction SilentlyContinue |  Clear-Host
        Winget Install Microsoft.UI.Xaml.2.8 --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Winget Install Microsoft.UI.Xaml.2.7 --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Start-BitsTransfer -Source 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'-Destination "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ErrorAction SilentlyContinue |  Clear-Host
        Add-AppPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ErrorAction SilentlyContinue |  Clear-Host
        Winget Upgrade Microsoft.AppInstaller --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Winget Install Microsoft.WindowsTerminal --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Winget Install Microsoft.NuGet --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        
    }

    #Verifica se a versão do Windows é a 10.
    elseif ($Global:WINVER -Match 'Windows 10') {
                     
        #Instala o pacote NuGet.
        Install-PackageProvider -Name NuGet -Force |  Clear-Host
        
        #Reinstala, redefine as fontes e atualiza o WINGET.
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -ErrorAction SilentlyContinue |  Clear-Host
        Repair-WinGetPackageManager |  Clear-Host
        Winget Source Remove --Name winget |  Clear-Host
        Winget Source Remove --Name msstore |  Clear-Host
        Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue |  Clear-Host
        Start-BitsTransfer -Source 'https://cdn.winget.microsoft.com/cache/source.msix' -Destination "$env:TEMP\source.msix" -ErrorAction SilentlyContinue |  Clear-Host
        Add-AppPackage -Path "$env:TEMP\source.msix" -ErrorAction SilentlyContinue |  Clear-Host
        Start-Sleep 1
        Winget Source Reset --Force |  Clear-Host     
        Winget Source Update |  Clear-Host
        Winget Install Microsoft.UI.Xaml.2.8 --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Winget Install Microsoft.UI.Xaml.2.7 --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Start-BitsTransfer -Source 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'-Destination "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ErrorAction SilentlyContinue |  Clear-Host
        Add-AppPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ErrorAction SilentlyContinue  |  Clear-Host
        Winget Upgrade Microsoft.AppInstaller --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Winget Install Microsoft.WindowsTerminal --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Winget Install Microsoft.NuGet --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
    }

    else {
        Write-Host 'VERSÃO DO WINDOWS NÃO COMPATÍVEL COM WINGET.'
        Start-Sleep -Seconds 5
    }  

}

function WINGETAPPS {
    
    # Altera o título da janela e garante que o módulo MZTOOL esteja carregado.
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE > WINGET APPS"
 
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        WINGETMODULE
    }

    # Função responsável por instalar via método redundante (fallback)
    function REDUNDANTINSTALL {
        param ([hashtable]$APPFAIL)

        Write-Host "INSTALAÇÃO REDUNDANTE $($APPFAIL.Id)"

        # Define o caminho do arquivo temporário para o instalador
        $APPFILE = Join-Path $env:TEMP $APPFAIL.TempFileName

        try {          

            # Tenta fazer o download do instalador
            DOWNLOAD -Urls $APPFAIL.DownloadUrl -Destination $APPFILE -BarWidth 30  

            # Se houver argumentos definidos, substitui o placeholder "{0}" pelo caminho do arquivo
            $APPARGS = $null

            if ($APPFAIL.Arguments) {
                $APPARGS = $APPFAIL.Arguments | ForEach-Object { $_ -f $APPFILE }
            }
            
            # Verifica o tipo de instalação e realiza o procedimento adequado
            switch ($APPFAIL.Install) {  

                "MSI" {
                    Start-Process -FilePath "msiexec.exe" -ArgumentList $APPARGS -Verb RunAs                    
                }
                "EXE" {                    
                    Start-Process -FilePath $APPFILE -ArgumentList $APPARGS -Verb RunAs
                }
                "APPX" {                   
                    Add-AppPackage -Path $APPFILE -ErrorAction SilentlyContinue                 
                }
                "MSIX" {
                    Add-AppxPackage -Path $APPFILE -ErrorAction SilentlyContinue
                }
                default {
                    Write-Output "Tipo de instalação não suportado para $($APPFAIL.Id)"
                }
            }
        }
        catch {
            Clear-Host
            Write-Output "FALHA NA INSTALAÇÃO DO $($APPFAIL.Id) : $_"
        }
    }
      
    $APP = @(
        @{ 
            Id           = "Google.Chrome"; 
            DownloadUrl  = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"; 
            TempFileName = "GoogleChrome.msi"; 
            Arguments    = @('/i', '{0}', '/passive'); 
            Install      = "MSI" 
        },
        @{ 
            Id           = "Adobe.Acrobat.Reader.64-bit"; 
            DownloadUrl  = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2500120474/AcroRdrDCx642500120474_MUI.exe"; 
            TempFileName = "AcrobatReader.exe"; 
            Arguments    = @("/msi", "/passive", "/norestart"); 
            Install      = "EXE" 
        },
        @{ 
            Id           = "Microsoft.VCRedist.2015+.x64"; 
            DownloadUrl  = "https://aka.ms/vs/17/release/vc_redist.x64.exe"; 
            TempFileName = "vc_redist_x64.exe"; 
            Arguments    = @("/msi", "/passive", "/norestart"); 
            Install      = "EXE" 
        },
        @{ 
            Id           = "Microsoft.VCRedist.2015+.x86"; 
            DownloadUrl  = "https://aka.ms/vs/17/release/vc_redist.x86.exe"; 
            TempFileName = "vc_redist_x86.exe"; 
            Arguments    = @("/msi", "/passive", "/norestart"); 
            Install      = "EXE" 
        },
        @{ 
            Id           = "Microsoft.VCLibs.Desktop.14"; 
            DownloadUrl  = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"; 
            TempFileName = "Microsoft.VCLibs.x64.14.00.Desktop.appx"; 
            Arguments    = $null; 
            Install      = "APPX" 
        },
        @{ 
            Id           = "Microsoft.Powershell"; 
            DownloadUrl  = "https://github.com/PowerShell/PowerShell/releases/download/v7.5.1/PowerShell-7.5.1-win-x64.msi"; 
            TempFileName = "PowerShell.msi"; 
            Arguments    = @('/i', '{0}', '/passive'); 
            Install      = "MSI" 
        }
        @{ 
            Id           = "Microsoft.WindowsTerminal"; 
            DownloadUrl  = "https://github.com/microsoft/terminal/releases/download/v1.22.11141.0/Microsoft.WindowsTerminal_1.22.11141.0_8wekyb3d8bbwe.msixbundle"; 
            TempFileName = "WindowsTerminal.msixbundle"; 
            Arguments    = $null; 
            Install      = "MSIX" 
        }
    )

    $APP | ForEach-Object {
       
        $ERRORCODE = Winget Install --Id $_.Id --Accept-Source-Agreements --Accept-Package-Agreements | Out-String

        if ($LASTEXITCODE -ne 0) {
            if ($ERRORCODE -match "já instalado" -or $ERRORCODE -match "installed") {
                Write-Host "$($_.Id) JÁ INSTALADO."
            }
            else {               
                REDUNDANTINSTALL -APPFAIL $_               
            }
        }     
    }    
}

function WINGETUPGRADE { 

    #Busca e atualiza todos softwares já previamente instalados compatíveis com o Winget.
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> WINGETUPGRADE"

    1..2 | ForEach-Object {
            
        Winget Upgrade --All --Accept-Source-Agreements --Accept-Package-Agreements 
       
        Clear-Host

    }
}

function WINUPDATE { 

    #Busca, realiza o download e implementa novas atualizações do Windows e de Drivers de Dispositivos através do Módulo PSWindowsUpdate e do canal de atualizações MicrosoftUpdate.

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> WINUPDATE"

    Import-Module PSWindowsUpdate -Force 

    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
       
}

function REMOVEGHOSTDRIVERS {
    
    #Remove os drivers de dispositivo não utilizados pelo sistema atualmente (Dispositivos Ocultos)
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> REMOVEGHOSTDRIVERS"
     
    #Obtem a lista de drivers de Dispositivos Ocultos e os remove.
    $null = Get-PnpDevice | Where-Object { $_.Status -eq 'Unknown' } | ForEach-Object {
        
        pnputil /remove-device $_.InstanceId | Clear-Host
    
    }
       
}

function ANYDESK {
    
    #Download do software Standalone ANYDESK-CM para a área de trabalho pública.  
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> ANYDESK"     
    
    $ANYDESKLINK = 'https://download.anydesk.com/AnyDesk-CM.exe'
    
    DOWNLOAD -Urls $ANYDESKLINK -Destination "$Global:DESKTOP\AnyDesk.exe" -BarWidth 30
    
}

function MICROSOFT365 {
    
    #Implementação do Microsoft Office 365.
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> MICROSOFT365"
    
    #Verifica se o Microsoft 365 já está instalado.
    $MS365 = { Get-Command "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" -ErrorAction SilentlyContinue }
    
    $INSTALLED = UNINSTALLOFFICE
    
    if (-not ($INSTALLED)) {             
        
        #Cria o arquivo XML de instalação personalizada no diretório %TEMP%.
        [xml]$XML = @'
<Configuration ID="c53a84ef-bc97-461f-a0fe-9211c1ef6ee3">
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusEEANoTeamsRetail">
      <Language ID="pt-br" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneNote" />
      <ExcludeApp ID="Publisher" />
      <ExcludeApp ID="Bing" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="verticalruler" Value="1" Type="REG_DWORD" App="word16" Id="L_VerticalrulerPrintviewonly" />
  </AppSettings>
  <Display Level="FALSE" AcceptEULA="TRUE" />
</Configuration> 
'@           

        $365XML = "$env:Temp\MICROSOFT365.xml"

        $XML.save("$365XML") 

        $WINGETAVAILABLE = Get-Command winget -ErrorAction SilentlyContinue
        $WINGETRUNNING = Get-Process -Name winget -ErrorAction SilentlyContinue

        if ($WINGETAVAILABLE -and !($WINGETRUNNING) -and !(& $MS365)) {      
        
            Winget Install --Id Microsoft.Office --Override "/configure $365XML" --Accept-Source-Agreements --Accept-Package-Agreements --Silent
        }

        elseif ($WINGETRUNNING -and !(& $MS365)) {

            #Caso o Winget não esteja disponível, baixa o Microsoft 365 de forma alternativa.
        
            $365URL1 = "https://officecdn.microsoft.com/pr/wsus/setup.exe"
            $365URL2 = "https://go.microsoft.com/fwlink/?linkid=2264705&clcid=0x409&culture=pt-br&country=br"
        
            $365URLS = @($365URL1, $365URL2)
            $365EXE = "$env:TEMP\MICROSOFT365.exe"

            DOWNLOAD -Urls $365URLS -Destination $365EXE -BarWidth 30
        
            if (Test-Path -Path $365EXE -ErrorAction SilentlyContinue) {        
                Start-Process -FilePath $365EXE -ArgumentList "/configure $365XML" -Wait
            }
     
        }

        else {
            $365STATUS = "2"            
        }    
    
        #Implementa os atalhos dos aplicativos Word, Excel e PowePoint na área de trabalho pública.
        $365LNK = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
        @("Word.lnk", "Excel.lnk", "PowerPoint.lnk") | ForEach-Object { Copy-Item "$365LNK\$_" "$Global:DESKTOP" -ErrorAction SilentlyContinue }
    
        Stop-Process -Name OfficeC2RClient -Force -ErrorAction SilentlyContinue
        
        if (& $MS365) { 
            
            Start-Process PowerShell -WindowStyle Hidden { Start-Process WINWORD }

            $365STATUS = "1"

        }
    }
    
    else {        
        
        $365STATUS = "3"
    }   

    return $365STATUS

}   

function OFFICE2007 {

    #Implementação do Microsoft Office 2007.

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> OFFICE2007"

    #Verifica se o Microsoft Office 2007 já está instalado.
    $OFFICE2007 = { Get-Command "C:\Program Files\Microsoft Office\Office12\WINWORD.EXE" -ErrorAction SilentlyContinue }
    $INSTALLED = UNINSTALLOFFICE
    if (-NOT ($INSTALLED)) {                  
       
        $OFFICE2007AWS = 'https://d15d16xpb69uci.cloudfront.net/OFFICE2007.zip'
        $OFFICE2007GOOGLEDRIVE = $OFFICE2007AWS

        $OFFICE2007ZIP = "$env:TOOL\OFFICE\OFFICE2007.zip"
        $OFFICE2007FOLDER = "$env:TOOL\OFFICE\2007"
        $OFFICE2007HASH = "43543423A3EF750BFCA1E1A35696741A"

        $DRIVEURLS = @($OFFICE2007AWS, $OFFICE2007GOOGLEDRIVE)

        function DOWNLOADOFFICE2007 {   
        
            #Download do arquivo OFFICE2007.zip
    
            #Verifica se a pasta OFFICE2007 já existe. Caso não exista, cria a pasta e baixa o arquivo ZIP do Microsoft Office 2007.

            if (-not (Test-Path -Path $OFFICE2007FOLDER -ErrorAction SilentlyContinue)) {

                TOOLDIR

                New-Item -Path $OFFICE2007FOLDER -ItemType Directory -Force | Out-Null

            }                           
           
            CLOUDSTATUS -URL $OFFICE2007AWS -CLOUD AWS
            CLOUDSTATUS -URL $OFFICE2007GOOGLEDRIVE -CLOUD GOOGLEDRIVE
      
            do {
                DOWNLOAD -Urls $DRIVEURLS -Destination $OFFICE2007ZIP -BarWidth 30

                $NEWOFFICE2007HASH = Get-FileHash -Path $OFFICE2007ZIP -Algorithm MD5

                $TRYGETOFFICE2007ZIP++      
            
                #Se o número de tentativas for maior ou igual a 5, encerra o MZTOOL.
                if ($TRYGETOFFICE2007ZIP -ge 5) {
        
                    Write-Warning "FALHA NO CARREGAMENTO DO MZTOOL.ZIP. RETORNANDO AO MENU."
                    Start-Sleep -Seconds 3
                    DISPLAYMENU
               
                }
            
            } while (
            (-not (Test-Path -Path $OFFICE2007ZIP -ErrorAction SilentlyContinue)) -or 
            ($NEWOFFICE2007HASH.Hash -ne $OFFICE2007HASH)
            )
        
            Write-Host "`nHASH`n$OFFICE2007HASH`n$($NEWOFFICE2007HASH.Hash)" -ForegroundColor Green
           
            RESETCURSOR      
           
            EXPAND -Path $OFFICE2007ZIP -DestinationPath $OFFICE2007FOLDER -Force -Quiet

            Remove-Item $OFFICE2007ZIP -Force -ErrorAction SilentlyContinue

        } 
        function NETFX3 {

            #Implementa o recurso .NetFramework 3.5 no sistema.
    
            Start-Job -Name NETFX3 -ScriptBlock { 
                $Host.UI.RawUI.WindowTitle = "$Global:TITLE> .NETFRAMEWORK3.5"
                Dism.exe /Online /NoRestart /Add-Package /PackagePath:$OFFICE2007FOLDER\NetFx35\update.mum | Out-Null
            } | Out-Null
        
        }
     
        DOWNLOADOFFICE2007

        NETFX3
    
        #Implementa o Microsoft Office 2007 com configurações de instalação AdminFile MSP.
        Start-Process "$OFFICE2007FOLDER\Setup.exe" -ArgumentList '/adminfile Silent.msp' -Wait     
        Wait-Job -Name NetFx3 | Out-Null
        if (& $OFFICE2007) { Start-Process PowerShell -WindowStyle Hidden { Start-Process 'winword.exe' } }

    }
    else {
        Clear-Host
        Write-Warning "ENCONTRADA(S) UMA OU MAIS VERSÃO(S) DO MICROSOFT 365 OU OFFICE JÁ INSTALADO(S).`n`nDESINSTALE A(S) VERSÃO(S) JÁ INSTALADA(S)`n`n"    
        Start-Sleep -Seconds 5
    }        
   
}

function DRIVERBOOSTER {
    
    #Extrai e inicializa o software Driver Booster.   

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> DRIVER_BOOSTER"

    $TOOLFOLDER = "$Env:TOOL\TOOL"

    $DRIVERBOOSTERPATH = "$TOOLFOLDER\DRIVER_BOOSTER"
        
    Expand-Archive -LiteralPath "$TOOLFOLDER\DRIVER_BOOSTER.zip" -DestinationPath "$DRIVERBOOSTERPATH"

    Start-Process "$DRIVERBOOSTERPATH\DriverBoosterPortable.exe" -Wait        
    
    #Finaliza os serviços do software Driver Booster e deleta a pasta temporária do mesmo.
    function STOPDRIVERBOOSTER {

        Start-Sleep -Seconds 2
            
        if (Get-Process -Name 'DriverBooster'-ErrorAction SilentlyContinue ) {
                
            Stop-Process -Name 'DriverBooster' -Force

            if (Get-Process -Name 'ScanWinUpd'-ErrorAction SilentlyContinue) {
                
                Stop-Process -Name 'ScanWinUpd' -Force
            }
                
            Start-Sleep -Seconds 5

            Remove-Item -Path "$DRIVERBOOSTERPATH" -Recurse -Force -ErrorAction SilentlyContinue
        }

        elseif (Get-Process -Name 'ScanWinUpd'-ErrorAction SilentlyContinue) {
                
            Stop-Process -Name 'ScanWinUpd' -Force

            if (Get-Process -Name 'DriverBooster'-ErrorAction SilentlyContinue ) {
                
                Stop-Process -Name 'DriverBooster' -Force
            }
                
            Start-Sleep -Seconds 5

            Remove-Item -Path "$DRIVERBOOSTERPATH" -Recurse -Force -ErrorAction SilentlyContinue
        }

        else {
                
            #Script continua.
        }
    
    }

    STOPDRIVERBOOSTER
    
}

function PERFILTHEME {

    #Modifica o perfil de usuário e adiciona configurações personalizadas.

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> PERFILTHEME"  
  
    #Adiciona o Tema Escuro ao Windows.

    $THEMESPATH = "C:\Windows\Resources\Themes"
    
    if ($Global:WINVER -Match 'Windows 11') {
        
        Start-Process -FilePath "$THEMESPATH\dark.theme"        
    }

    elseif ($Global:WINVER -Match 'Windows 10') {
        
        Start-Process -FilePath "$THEMESPATH\aero.theme"
    }

    else {
        Write-Host 'Windows não identificado, tema não aplicado.'
    }    
  
    #Adiciona ícones de sistema a Área de Trabalho.
    
    # Lista de ícones de sistema.
    $ICONS = @(
        '{018D5C66-4533-4307-9B53-224DE2ED1FE6}', #OneDrive
        '{20D04FE0-3AEA-1069-A2D8-08002B30309D}', #Este Computador
        '{59031a47-3f72-44a7-89c5-5595fe6b30ee}', #Rede
        '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}', #Grupo Doméstico
        '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'  #Painel de Controle
    )  
    
    # Chave do registro onde se encontram os ícones da Área de Trabalho.
    $DESKINCONSREG = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
    
    ForEach ($ICON in $ICONS) {
        New-ItemProperty -Path "$DESKINCONSREG" -Name $ICON -PropertyType dword -Value 0 -ErrorAction SilentlyContinue
    }    

    #Mostra e atualiza a Área de Trabalho.
    DESKTOPUPDATE  

    #Personaliza e define efeitos visuais para obter melhor desempenho e manter a boa leitura.
    $regSettings = @(
        @{
            Path       = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
            Properties = @(
                @{ Name = "VisualFXSetting"; Value = 3; Type = "DWord" }
            )
        },
        @{
            Path       = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Properties = @(
                @{ Name = "IconsOnly"; Value = 0; Type = "DWord" },
                @{ Name = "ListviewAlphaSelect"; Value = 0; Type = "DWord" },
                @{ Name = "ListviewShadow"; Value = 1; Type = "DWord" },
                @{ Name = "TaskbarAnimations"; Value = 0; Type = "DWord" }
            )
        },
        @{
            Path       = "HKCU:\Control Panel\Desktop"
            Properties = @(
                @{ Name = "UserPreferencesMask"; Value = [byte[]](0x98, 0x32, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00); Type = "Binary" },
                @{ Name = "DragFullWindows"; Value = "0"; Type = "String" }
            )
        },
        @{
            Path       = "HKCU:\Control Panel\Desktop\WindowMetrics"
            Properties = @(
                @{ Name = "MinAnimate"; Value = "0"; Type = "String" }
            )
        },
        @{
            Path       = "HKCU:\Software\Microsoft\Windows\DWM"
            Properties = @(
                @{ Name = "EnableAeroPeek"; Value = 0; Type = "DWord" }
            )
        }
    )

    foreach ($section in $regSettings) {
        # Cria a chave se ela não existir
        if (-not (Test-Path $section.Path)) {
            New-Item -Path $section.Path -Force | Out-Null
            Write-Host "Chave criada: $($section.Path)" -ForegroundColor Green
        }
        else {
            Write-Host "Chave existente: $($section.Path)" -ForegroundColor Yellow
        }
    
        # Cria ou atualiza cada propriedade para a chave
        foreach ($prop in $section.Properties) {
            New-ItemProperty -Path $section.Path -Name $prop.Name -Value $prop.Value -PropertyType $prop.Type -Force | Out-Null
            Write-Host "Propriedade '$($prop.Name)' definida como '$($prop.Value)'" -ForegroundColor Cyan
        }
    }  

    #Finaliza janela de personalização do Windows.
    if (Get-Process -Name 'systemsettings' -ErrorAction SilentlyContinue) {
                        
        Stop-Process -Name 'systemsettings' -Force
    }

    #Remove Widgets.    
    Get-AppxPackage *WebExperience* | Remove-AppxPackage -ErrorAction SilentlyContinue
    
    #Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    REFRESHUSER   
 
}

function PINICONS {

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> PERFILTHEME > PINICONS"  

    #Fixa os ícones dos softwares Google Chrome, Acrobat Reader, Microsoft Word e do Windows Explorer na barra de tarefas e remove os demais ícones.
    $TASKBAR =
    @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
        <taskbar:DesktopApp DesktopApplicationID="Chrome" />
        <taskbar:DesktopApp DesktopApplicationID="{6D809377-6AF0-444B-8957-A3773F02200E}\Adobe\Acrobat DC\Acrobat\Acrobat.exe" />
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Office.WINWORD.EXE.15" />
        <taskbar:DesktopApp DesktopApplicationID="C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WINWORD.lnk" />
        <taskbar:DesktopApp DesktopApplicationID="{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}\Microsoft Office\Office12\WINWORD.exe" /> 
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@

    # Define o caminho do arquivo de layout
    [System.IO.FileInfo]$PATH = "$($env:ProgramData)\provisioning\taskbar_layout.xml"
    if (-not $PATH.Directory.Exists) {
        $PATH.Directory.Create()
    }

    # Cria o arquivo XML com o layout da taskbar
    $TASKBAR | Out-File $PATH.FullName -Encoding utf8

    # Define as configurações do registro utilizando o caminho correto ($PATH.FullName)
    $settings = @(
        [PSCustomObject]@{
            Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
            Value = $PATH.FullName
            Name  = "StartLayoutFile"
            Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
        },
        [PSCustomObject]@{
            Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
            Value = 1
            Name  = "LockedStartLayout"
        }
    ) | Group-Object Path

    foreach ($setting in $settings) {
        # Abre ou cria a chave no registro
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
        }
        # Define as propriedades para essa chave
        $setting.Group | ForEach-Object {
            if (-not $_.Type) {
                $registry.SetValue($_.Name, $_.Value)
            }
            else {
                $registry.SetValue($_.Name, $_.Value, $_.Type)
            }
        }
        $registry.Dispose()
    }

    Write-Host "Layout da taskbar e configurações foram aplicadas com sucesso!"


    #Remove o ícone do Microsoft CoPilot da barra de tarefas.
    $settings = [PSCustomObject]@{
        Path  = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Value = 0
        Name  = 'ShowCopilotButton'
    } | Group-Object Path

    foreach ($setting in $settings) {
        $registry = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($setting.Name, $true)
        }
        $setting.Group | ForEach-Object {
            if (!$_.Type) {
                $registry.SetValue($_.name, $_.value)
            }
            else {
                $registry.SetValue($_.name, $_.value, $_.type)
            }
        }
        $registry.Dispose()
    }

    function TRAYICONS {

        #Define e personaliza as configurações dos ícones da barra de tarefas.
        $property = @{
            "Start_SearchFiles"           = 2
            "ServerAdminUI"               = 0
            "Hidden"                      = 1
            "ShowCompColor"               = 1
            "HideFileExt"                 = 1
            "DontPrettyPath"              = 0
            "ShowInfoTip"                 = 1
            "HideIcons"                   = 0
            "MapNetDrvBtn"                = 0
            "WebView"                     = 1
            "Filter"                      = 0
            "ShowSuperHidden"             = 0
            "SeparateProcess"             = 0
            "AutoCheckSelect"             = 0
            "IconsOnly"                   = 0
            "ShowTypeOverlay"             = 1
            "ShowStatusBar"               = 1
            "ListviewAlphaSelect"         = 1
            "ListviewShadow"              = 1
            "TaskbarAnimations"           = 1
            "TaskbarSizeMove"             = 0
            "DisablePreviewDesktop"       = 1
            "TaskbarSmallIcons"           = 0
            "TaskbarAutoHideInTabletMode" = 0
            "ShellMigrationLevel"         = 3
            "StartShownOnUpgrade"         = 1
            "ReindexedProfile"            = 1
            "StartMenuInit"               = 13
            "OTPTBAttempted"              = 1
            "WinXMigrationLevel"          = 1
            "OTPTBImprSuccess"            = 1
            "ShowCopilotButton"           = 0
            "ShowTaskViewButton"          = 0
        }

        foreach ($name in $property.Keys) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name $name -Value $property[$name] -Type DWord
        }

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarStateLastRun" -Value 0x5eae966600000000 -Type QWord

    }
    
    TRAYICONS

    #Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    REFRESHUSER

    #Mostra e atualiza a Área de Trabalho.
    DESKTOPUPDATE    

    #Desabilita as notificações da central de ações.    
    If (!(Test-Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -ErrorAction SilentlyContinue)) {
        New-Item -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -ErrorAction SilentlyContinue
    }
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'DisableNotificationCenter' -Type DWord -Value 1
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'ToastEnabled' -Type DWord -Value 0

    #Ativa plano de energia para Alto Desempenho.    
    #POWERCFG /SETACTIVE SCHEME_MIN

    #Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    REFRESHUSER
          
}

function STARTSOFTWARES {

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> STARTSOFTWARES"

    Start-Process CHROME
    Start-Process ACROBAT
    
    Start-Sleep 5
    
    Stop-Process -Name CHROME -Force
    Stop-Process -Name ACROBAT -Force
    Stop-Process -Name Eula -Force

    #Desabilita a primeira inicialização do Microsoft Edge.
    $settings = 
    [PSCustomObject]@{
        Path  = 'SOFTWARE\Policies\Microsoft\Edge'
        Value = 1
        Name  = 'HideFirstRunExperience'
    } | Group-Object Path

    foreach ($setting in $settings) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
        }
        $setting.Group | ForEach-Object {
            $registry.SetValue($_.name, $_.value)
        }
        $registry.Dispose()
    }

    #Aceita EULA Acrobat Reader.
    $ACROBATREG = 'HKCU:\SOFTWARE\Adobe\Adobe Acrobat\DC\AdobeViewer'
    New-Item -Path "$ACROBATREG"
    New-ItemProperty -Path "$ACROBATREG" -Name 'EULA' -PropertyType dword -Value 00000001
   
    #Desabilita notificações do Google Chrome e desabilita a tela inicial.
    $settings = 
    [PSCustomObject]@{
        Path  = 'SOFTWARE\Policies\Google\Chrome'
        Value = 0
        Name  = 'PrivacySandboxPromptEnabled' #Notificação.
    },
    [PSCustomObject]@{ 
        Path  = 'SOFTWARE\Policies\Google\Chrome'
        Value = 0
        Name  = 'PrivacySandboxAdMeasurementEnabled'
    },
    [PSCustomObject]@{ 
        Path  = 'SOFTWARE\Policies\Google\Chrome'
        Value = 0
        Name  = 'PrivacySandboxAdTopicsEnabled'
    },
    [PSCustomObject]@{ 
        Path  = 'SOFTWARE\Policies\Google\Chrome'
        Value = 0
        Name  = 'PrivacySandboxSiteEnabledAdsEnabled'
    },
    [PSCustomObject]@{
        Path  = 'SOFTWARE\Policies\Google\Chrome'
        Value = 2
        Name  = 'DefaultNotificationsSetting'
    } | Group-Object Path

    foreach ($setting in $settings) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
        }
        $setting.Group | ForEach-Object {
            $registry.SetValue($_.name, $_.value)
        }
        $registry.Dispose()
    }    

    Start-Sleep 5

    #Mostra e atualiza a Área de Trabalho.
    DESKTOPUPDATE 

    Start-Process ACROBAT
    Start-Process CHROME https://github.com/DanielMozartt/MZTOOL, https://www.youtube.com/mozartinformatica, https://www.instagram.com/mozartinformatica/    
    Start-Process -FilePath "C:\Windows\System32\SystemPropertiesPerformance.exe"    

}

function IMGHEALTH {

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> IMGHEALTH"

    # Verifica a integridade da imagem do sistema.
    DISM /Online /Cleanup-Image /CheckHealth

    Clear-Host    
    
    # Repara a imagem do sistema, se necessário.
    DISM /Online /Cleanup-Image /RestoreHealth

    Clear-Host

    # Executa o comando SFC para verificar e reparar arquivos corrompidos do sistema.
    SFC /SCANNOW
    
}

function PRO {
    
    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> WINDOWSPRO"

    #Converte a versão do Windows para PRO. (Não ativa o sistema, para a ativação é necessário já haver uma Licença Digital HWID).
    1..2 | ForEach-Object {
        changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T
        SLMGR.VBS /CPKY
        SLMGR.VBS /CKMS
        Net stop Sppsvc
        Set-Location C:\Windows\System32\SPP\Store\2.0
        Rename-Item Tokens.dat Tokens.old
        SLMGR.VBS /RILC
        changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T    
    }

}

function awin {
    Start-Process powershell -WindowStyle Hidden { Invoke-RestMethod https://4br.me/awin | Invoke-Expression }
}
    
DISPLAYMENU 

EXIT   