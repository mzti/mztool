#MÓDULO MZTOOL

#region Variáveis Globais
$Global:TITLE = "MZTOOL BETA"
$Global:DESKTOP = "C:\Users\Public\DESKTOP"
$Global:MZTOOLMODULE = Get-Module -Name "MZTOOL" 
$Global:EXECUTIONPOLICY = Get-ExecutionPolicy -List
$Global:WINVER = (Get-CimInstance Win32_OperatingSystem).Caption, (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture
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

#region FUNCÕES

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
        [string[]]$FunctionNames,
        [switch]$Wait,
        [switch]$ReturnProcess,
        [switch]$Hidden
    )    
    
   
    # Combina as definições das funções (preservando a ordem)
    $combinedDefinitions = foreach ($fn in $FunctionNames) {
         (Get-Command -Type Function GETMZTOOLMODULE).Definition      
        # Junta o código pré-carregado com a definição da função específica.
         (Get-Command -Type Function $fn).Definition
    } -join "`n"
    
    # Converte o conteúdo para Base64 para uso com -EncodedCommand
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($combinedDefinitions))
    $arguments = @('-EncodedCommand', $encodedCommand)
    
    if ($Wait) {
        # Caso Wait seja especificado, aguardamos o término do processo internamente.
        [void](Start-Process powershell -ArgumentList $arguments -Wait)
    }
      
    if ($Hidden) {
        # Caso Wait seja especificado, aguardamos o término do processo internamente.
        [void](Start-Process powershell -ArgumentList $arguments -WindowStyle Hidden)
    }

    elseif ($Wait -and $Hidden) {
        # Caso Wait e Hidden sejam especificados, aguardamos o término do processo internamente.
        [void](Start-Process powershell -ArgumentList $arguments -WindowStyle Hidden -Wait)
    }

    elseif ($ReturnProcess) {
        # Se o usuário quer o objeto do processo para controlar externamente, retornamos-o.
        $proc = Start-Process powershell -ArgumentList $arguments -PassThru
        return $proc
    }

    else {
        # Se nada for especificado, usamos a forma que não retorna nada – compatível com [void](...)
        [void](Start-Process powershell -ArgumentList $arguments)
    }
}

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
        [int]$LinePosition = 17
    )
          
    $total = $DEPLOYFUNCTIONHASH.Count
    $completed = 0

    # Exibe a barra inicial (0% concluído)
    DEPLOYFUNCTIONPROGRESS -PercentComplete 0 -BarWidth $BarWidth -Message "IMPLEMENTANDO" -LinePosition $LinePosition

    foreach ($group in $DEPLOYFUNCTIONHASH) {
        if ($group.ContainsKey("Wait") -and $group.Wait) {
            NEWPWSH -FunctionNames $group.Functions -Wait
        }
        else {
            NEWPWSH -FunctionNames $group.Functions
        }
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
            do {
            
                #Caso as duas nuvens estejam fora do ar oferece um menu de opções.
                                              
                Start-Sleep -Seconds 1
                function DisplayMenuDownloadError {           
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
           
                    $choice = Read-Host "INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA"
                    
                    switch ($choice) {
                        '1' {                        
                            return
                            break
                        }
                        '2' {
                            DISPLAYMENU
                            break
                        }
                        '0' {
                    
                            #OPÇÃO 0 - ENCERRAR MZTOOL.

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

                            Start-Sleep -Seconds 2
                            Exit                            
                        }
                        default {
                            ENTRYERROR
                        }
                    }
                }
        
                DisplayMenuDownloadError
    
            } while ($true)# Action when all if and elseif conditions are false
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

#endregion
