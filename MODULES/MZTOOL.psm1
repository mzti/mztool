#MÓDULO MZTOOL

#region Variáveis Globais
$Global:TITLE = "MZTOOL BETA"
$Global:DESKTOP = "C:\Users\Public\DESKTOP"
$Global:MZTOOLMODULE = Get-Module -Name "MZTOOL" -ErrorAction SilentlyContinue 
$Global:EXECUTIONPOLICY = { Get-ExecutionPolicy -List -ErrorAction SilentlyContinue }
$Global:WINVER = (Get-CimInstance Win32_OperatingSystem).Caption, (Get-CimInstance -Class Win32_OperatingSystem).OSArchitecture
$Global:WINGETVER = "v1.10.390"
$Global:GETWINGETVER = { Winget --version 2>&1 }
$Global:MZTOOLAPPDATA = $MZTOOLAPPDATA


#endregion

#region Definições Globais
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
#endregion
function custom {
    Start-Sleep 2

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
public static class ConsoleEventHandler {
    // Delegate para o manipulador de eventos de controle do console.
    public delegate bool HandlerRoutine(int dwCtrlType);
    [DllImport("Kernel32")]
    public static extern bool SetConsoleCtrlHandler(HandlerRoutine Handler, bool Add);
}
"@
    #endregion
    #region CLOSE WINDOW
    $handler = [ConsoleEventHandler+HandlerRoutine] {
        param([int]$CtrlType)
        # Os códigos dos eventos são:
        # 0 = CTRL_C_EVENT
        # 1 = CTRL_BREAK_EVENT
        # 2 = CTRL_CLOSE_EVENT  <-- botão "X" ou fechamento da janela
        # 5 = CTRL_LOGOFF_EVENT
        # 6 = CTRL_SHUTDOWN_EVENT
        Write-Host "Evento de controle recebido: $CtrlType"
        if ($CtrlType -eq 2) {
            Write-Host "A janela do PowerShell foi fechada. Executando função personalizada..." -ForegroundColor Yellow
            # Chame aqui a função desejada antes do término do processo.
            CLEANTEMP
        }
        # Retorne $true para indicar que o evento foi tratado (impede, se possível, o fechamento imediato)
        return $true
    }
    
    # Registra o manipulador para os eventos de controle do console.
    [ConsoleEventHandler]::SetConsoleCtrlHandler($handler, $true) | Out-Null
    
    Write-Host "Manipulador de fechamento registrado. A janela do PowerShell agora irá acionar a função quando o botão 'X' for clicado."
    Write-Host "Pressione Enter para finalizar o script (ou feche a janela para disparar o manipulador)."
    Read-Host
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

}
custom
#region FUNÇÕES DO MÓDULO
function GETMZTOOLMODULE {     
        
    if (-not ($Global:MZTOOLMODULE -and $Global:MZTOOLMODULETRUE)) {
        
        Import-Module MZTOOL -Force -ErrorAction SilentlyContinue 
    }

    $Global:MZTOOLMODULE = Get-Module -Name "MZTOOL" -ErrorAction SilentlyContinue 
    
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
    elseif ($Hidden -and $ReturnProcess) {
        $proc = Start-Process powershell -ArgumentList $arguments -PassThru -WindowStyle Hidden
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

    if (Test-Path -Path $Global:MZTOOLAPPDATA -ErrorAction SilentlyContinue) {

        REMOVEFILE -Path $Global:MZTOOLAPPDATA -Description "pasta MZTOOL (APPDATA)."
    }

    if (Test-Path $PROFILE -ErrorAction SilentlyContinue) {
        
        REMOVEPROFILELOADED
    }

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

function CLOCKDATE {

    $Host.UI.RawUI.WindowTitle = "$Global:TITLE> CLOCK|DATE"   

    #Define um novo servidor e sincroniza o relógio e a data do sistema.  
  
    w32tm /config /manualpeerlist:pool.ntp.br /syncfromflags:manual /update
    net start w32time 
    w32tm /resync /force
   
}  
#endregion

#region FUNÇÕES REDUNDANTES
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

#endregion

#region TRUE
$Global:MZTOOLMODULETRUE = $TRUE
$Global:GIT = $TRUE
#endregion

#ENDMODULE