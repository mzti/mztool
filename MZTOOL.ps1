<#
.SYNOPSIS
    Instalação e personalização automatizada de softwares e o perfil de usuário no ambiente Windows.

.DESCRIPTION
    Instale softwares e personaliza o perfil de usuário no Windows automaticamente a partir da nuvem e de pacotes e módulos da Microsoft. 
    
.NOTES
    Autor: Daniel Mozart - https://www.linkedin.com/in/danielmozart/
    Compatibilidade: Windows 11 e 10.
    Versão: BETA.
     
.EXAMPLE

    1 - Implementação automatizada:

Módulos e Gerenciador de pacotes (MSIX, NuGet): Implementação, atualização e auto-reparo do Winget e PSWindowsUpdate.

Softwares (Winget): Adobe Acrobat Reader, Google Chrome, Microsoft 365, Powershell, AnyDesk.

Atualizações (PSWindowsUpdate): Remoção de drivers de dispositivo não utilizados pelo sistema atualmente (Dispositivos Ocultos) e Implementação e Atualização de novos e atuais Drivers de Dispositivo e Atualizações do Windows Update.

Personalização do Perfil de Usuário (Regedit, XML, Appx): Tema, Ícones da Área de Trabalho e Barra de Tarefas, Remoção de Widgets, Remoção de Bloatwares, Remoção do Microsoft Copilot, Remoção de Ícones Visão de Tarefas e Notícias, Remoção de notificações da Central de Ações, Define o Google Chrome como navegador padrão e o Acrobat Reader como leitor de PDF padrão.
2 - Download e execução standalone automatizada em nuvem de softwares para monitoramento e diagnóstico de hardwares.

HDSentinel, AIDA64, CPUZ, BlueScreenView, Core Temp, Crystal Disk Info, HWInfo, GPUZ.
3 - Atualização automátizada de softwares e drivers através do Winget e Módulo Windows Update.

4 - Implementação automatizada de diferentes versões do Pacote Office e Microsoft 365.

.LINK
    https://github.com/DanielMozartt/MZTOOL
    
#>


#MZTOOL - MOZART IT | MZ.IT | MOZART INFORMÁTICA | DANIEL MOZART


#Define a política de execução para permitir scripts assinados.
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

$Host.UI.RawUI.WindowTitle = 'MZTOOL BETA'

function MZTOOLMODULE {
    # Define o nome do módulo
    $moduleName = "MZTOOL"

    # Define o caminho do diretório do módulo (pasta padrão para módulos do usuário)
    $moduleDir = Join-Path -Path (Split-Path -Path $PROFILE -Parent) -ChildPath "Modules\$moduleName"

    # Cria o diretório, se não existir
    if (-Not (Test-Path $moduleDir)) {
        New-Item -Path $moduleDir -ItemType Directory -Force | Out-Null
    }

    # Define o caminho completo para o arquivo .psm1 do módulo
    $modulePath = Join-Path -Path $moduleDir -ChildPath "$moduleName.psm1"
    
    # Verifica se o arquivo .psm1 já existe e o deleta, se necessário
    if (Test-Path -Path $modulePath) {
       
        Remove-Item -Path $modulePath -Force -ErrorAction Stop
        
    }

    # Conteúdo do módulo MZTOOL.psm1
    $moduleContent = @'
# MZTOOL.psm1
#region Importações e API

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$workArea     = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$screenWidth  = $workArea.Width
$screenHeight = $workArea.Height

$global:winWidth  = 464
$global:winHeight = 320

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    public const int GWL_STYLE = -16;
    public const int WS_SIZEBOX = 0x00040000;
    public const int WS_MAXIMIZEBOX = 0x00010000;
    
    [DllImport("user32.dll", SetLastError=true)]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
    
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter,
        int X, int Y, int cx, int cy, uint uFlags);
}
"@
#endregion

#region Fixar tamanho e remover redimensionamento
$global:hwnd = (Get-Process -Id $PID).MainWindowHandle
if ($global:hwnd -ne [IntPtr]::Zero) {
    $style = [Win32]::GetWindowLong($global:hwnd, [Win32]::GWL_STYLE)
    $newStyle = $style -band (-bnot ([Win32]::WS_SIZEBOX -bor [Win32]::WS_MAXIMIZEBOX))
    [Win32]::SetWindowLong($global:hwnd, [Win32]::GWL_STYLE, $newStyle)
    
    $SWP_NOMOVE       = 0x0002
    $SWP_NOSIZE       = 0x0001
    $SWP_NOZORDER     = 0x0004
    $SWP_FRAMECHANGED = 0x0020
    $flags = $SWP_NOMOVE -bor $SWP_NOSIZE -bor $SWP_NOZORDER -bor $SWP_FRAMECHANGED
    [Win32]::SetWindowPos($global:hwnd, [IntPtr]::Zero, 0, 0, 0, 0, $flags)
}
#endregion

#region Layout de Janela - Contador e Posicionamento

$global:counterFile = Join-Path $env:TEMP "MZTOOL_Index.txt"

function Get-MZTOOLIndex {
    if (-Not (Test-Path $global:counterFile)) {
         1 | Out-File -FilePath $global:counterFile -Encoding ASCII
         return 1
    }
    else {
         try {
             $index = [int](Get-Content $global:counterFile -Raw)
         }
         catch { $index = 1 }
         $newIndex = $index + 1
         $newIndex | Out-File -FilePath $global:counterFile -Encoding ASCII
         return $index
    }
}

function Reset-MZTOOLLayout {
    1 | Out-File -FilePath $global:counterFile -Encoding ASCII
    $centerX = [Math]::Floor(($screenWidth - $global:winWidth) / 2)
    $centerY = [Math]::Floor(($screenHeight - $global:winHeight) / 2)
    $SWP_NOSIZE       = 0x0001
    $SWP_NOZORDER     = 0x0004
    $SWP_SHOWWINDOW   = 0x0040
    $flags = $SWP_NOSIZE -bor $SWP_NOZORDER -bor $SWP_SHOWWINDOW
    [Win32]::SetWindowPos($global:hwnd, [IntPtr]::Zero, $centerX, $centerY, 0, 0, $flags)
}
Export-ModuleMember -Function Reset-MZTOOLLayout

$global:currentIndex = Get-MZTOOLIndex

if ($global:currentIndex -eq 1) {
    # Mantenha a janela principal sempre centralizada
    $posX = [Math]::Floor(($screenWidth - $global:winWidth) / 2)
    $posY = [Math]::Floor(($screenHeight - $global:winHeight) / 2)
}
else {
    # Para janelas adicionais: posiciona em layout em grade, sem reajustar as já abertas.
    $maxCols = [Math]::Floor($screenWidth / $global:winWidth)
    $gridIndex = $global:currentIndex - 1
    $col = ($gridIndex - 1) % $maxCols
    $row = [Math]::Floor(($gridIndex - 1) / $maxCols)
    $posX = $col * $global:winWidth
    $posY = $row * $global:winHeight
}

$SWP_NOSIZE     = 0x0001
$SWP_NOZORDER   = 0x0004
$SWP_SHOWWINDOW = 0x0040
$flags = $SWP_NOSIZE -bor $SWP_NOZORDER -bor $SWP_SHOWWINDOW
[Win32]::SetWindowPos($global:hwnd, [IntPtr]::Zero, $posX, $posY, 0, 0, $flags)
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
'@

    # Grava o conteúdo no arquivo .psm1 (sobrescrevendo, se necessário)
    Set-Content -Path $modulePath -Value $moduleContent -Force
}

#Chama a função MZTOOLMODULE para criar e configurar o módulo MZTOOL.
MZTOOLMODULE
   
#Importa o módulo MZTOOL para a sessão atual.
Import-Module MZTOOL -Force

# Obtém o ID e o Objeto de Segurança do usuário atual.
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Obtém o Objeto de Segurança do usuário Administrador.
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Verifica se o script está sendo executado como administrador.
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    # Define a política de execução para Bypass apenas para a sessão atual suprimindo restrições ou avisos.
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

    # Executando como administrador. Formatação e estilo aplicadas.
    $Host.UI.RawUI.WindowTitle = 'MZTOOL BETA'
    
    #Importa o módulo MZTOOL para a sessão atual.
    Import-Module MZTOOL -Force

} 
    
else {
    # Não está executando como administrador.
    function PwshEnvTool {
        if (-not (Test-Path -Path $PROFILE -ErrorAction SilentlyContinue)) {
            Start-Process Powershell -WindowStyle Hidden -Wait {
                
                # Verifica e cria o perfil do PowerShell se não existir.
                if (-not (Test-Path -Path $PROFILE -ErrorAction SilentlyContinue)) {
                    New-Item -Path $PROFILE -Type File -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                }
            
            }
                          
        }
          
        # Adiciona as variáveis de ambiente ao perfil do PowerShell.
        Add-Content -Path $PROFILE -Value "`n[Environment]::SetEnvironmentVariable('TOOL', 'C:\TOOL', 'User')" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Add-Content -Path $PROFILE -Value "`n[Environment]::SetEnvironmentVariable('DESKTOP', 'C:\Users\Public\DESKTOP', 'User')" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        # Define as variáveis de ambiente para o ambiente de usuário.
        [Environment]::SetEnvironmentVariable('TOOL', 'C:\TOOL', 'User')
        [Environment]::SetEnvironmentVariable('DESKTOP', 'C:\Users\Public\DESKTOP', 'User')

             
    }

    #Chama a função PwshEnvTool para definir as variáveis de ambiente.
    PwshEnvTool

    # Fecha o processo atual e inicia um novo com o script como administrador solicitando UAC.
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo 'PowerShell'
    $newProcess.Arguments = $myInvocation.MyCommand.Definition
    $newProcess.Verb = 'runas'
    [System.Diagnostics.Process]::Start($newProcess) | Out-Null
    exit
}



function OpSys {

    #Verifica se o sistema operacional é suportado.
    $WinVer = (Get-WmiObject Win32_OperatingSystem).Caption

    if ($WinVer -Match 'Microsoft Windows 10' -or $WinVer -Match 'Microsoft Windows 11') {
        
        #Script Continua.
    }

    else {

        Write-Host 'SISTEMA OPERACIONAL NÃO SUPORTADO.'

        Start-Sleep 5

        EXIT
                
    }
}

OpSys
    
#MENU MZTOOL -----------------------------------------------------

function DisplayMenu {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL BETA'
    Import-Module MZTOOL -Force 
    Reset-MZTOOLLayout 
    
    
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
    
    $MENU = Read-Host 'INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
    Switch ($MENU) {

        1 {
            #OPÇÃO 1 - INSTALAR SOFTWARES E ATUALIZAÇÕES DO SISTEMA.
            $Host.UI.RawUI.WindowTitle = 'MZTOOL> INSTALL'
            Import-Module MZTOOL -Force
            
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
            # Garante uma linha em branco abaixo do menu
            Write-Host ""

            # ----------------------------------------------------------------------
            # Função para exibir a barra de progresso in-place em uma linha fixa.
            # ----------------------------------------------------------------------
            function Show-CustomProgress {
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

            function Invoke-AllGroups {
                param(
                    [int]$BarWidth = 30,
                    [int]$LinePosition = 17
                )
    
                $groups = @(
                    @{ Functions = 'PerfilTheme' },
                    @{ Functions = 'AnyDesk' },
                    @{ Functions = 'WingetModule'; Wait = $true },
                    @{ Functions = 'WinUpdateModule', 'RemoveGhostDrivers', 'WinUpdate' },
                    @{ Functions = 'WingetInstall', 'WingetUpdate' },
                    @{ Functions = 'Microsoft365'; Wait = $true },
                    @{ Functions = 'PinIcons', 'StartSoftwares' }
                )
    
                $total = $groups.Count
                $completed = 0

                # Exibe a barra inicial (0% concluído)
                Show-CustomProgress -PercentComplete 0 -BarWidth $BarWidth -Message "IMPLEMENTANDO" -LinePosition $LinePosition

                foreach ($group in $groups) {
                    if ($group.ContainsKey("Wait") -and $group.Wait) {
                        NEWPWSH -FunctionNames $group.Functions -Wait
                    }
                    else {
                        NEWPWSH -FunctionNames $group.Functions
                    }
                    $completed++
                    $percent = [math]::Round(($completed * 100) / $total)
                    Show-CustomProgress -PercentComplete $percent -BarWidth $BarWidth -Message "IMPLEMENTANDO" -LinePosition $LinePosition
                    
                    # Aguarda 3 segundos antes de iniciar o próximo grupo
                    Start-Sleep -Seconds 3
                }

                # Ao término, pula para a linha seguinte para que o prompt não fique sobre a barra
                Write-Host ""
            }

            # ----------------------------------------------------------------------
            # Chamada final para executar os grupos com a barra de progresso unificada.
            # ----------------------------------------------------------------------
            Invoke-AllGroups -BarWidth 30 -LinePosition 17                      

                     
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

            DisplayMenu
            
        }

        2 {
    
            #OPÇÃO 2 - DIAGNÓSTICO DE HARDWARE E SISTEMA.
 
            $Host.UI.RawUI.WindowTitle = 'MZTOOL> TOOL'
            Import-Module MZTOOL -Force
            Reset-MZTOOLLayout
            
               
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
            ToolDir 

            Start-Sleep -Seconds 1

            DownloadMztool            
          
            Start-Sleep -Seconds 1

            function StartFerramentas {
                $OSARCHITECTURE = (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture
                                                
                if ($OSARCHITECTURE -eq '64 bits') {
                    Diagnostics64
                }

                elseif ($OSARCHITECTURE -eq '32 bits') {
                    Diagnostics32
                }
            }
            
            StartFerramentas
            function MENUFERRAMENTAS {
                
                $Host.UI.RawUI.WindowTitle = 'MZTOOL> TOOL'
                Import-Module MZTOOL -Force
                 

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
| |3| VOLTAR AO MENU PRINCIPAL                       |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'                                    
                $CHOICE = Read-Host 'INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
                Switch ($CHOICE) {
                    1 {
                        StartFerramentas

                        Start-Sleep -Seconds 1
                            
                        MENUFERRAMENTAS
                    }
                    2 {
                        # Fecha todas as ferramentas de diagnóstico se estiverem abertas
                        $tools = @("aida64", "BlueScreenView", "Core_Temp_64", "Core_Temp_32", "cpuz_x64", "cpuz_x32", "HDSentinel", "HWiNFO64", "HWiNFO32", "GPU_Z")
                        foreach ($tool in $tools) {
                            Stop-Process -Name $tool -Force -ErrorAction SilentlyContinue
                        }
                        Write-Host "Todas as ferramentas foram fechadas." -ForegroundColor Green
                        Start-Sleep -Seconds 2

                        MENUFERRAMENTAS
                    }
                    3 {
                        DisplayMenu
                    }
                    Default {
                        Write-Host "OPÇÃO INVÁLIDA. INSIRA UMA OPÇÃO VÁLIDA." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                        MENUFERRAMENTAS
                    }
                }
            }
                
            MENUFERRAMENTAS
                         
        }

        3 {
            function DisplayMenu3 {
    
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
                $SUBMENU3 = Read-Host 'INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
                Switch ($SUBMENU3) {
                    1 {
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
                        WingetModule

                        WinUpdateModule

                        Start-Sleep -Seconds 1

                        DelTemp

                        Clear-Host

                        DisplayMenu
            
                    }
        
                    2 { 
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

                   
                        $proc1 = NEWPWSH -FunctionNames 'WingetUpdate' -ReturnProcess
                        $proc2 = NEWPWSH -FunctionNames 'RemoveGhostDrivers', 'WinUpdate' -ReturnProcess

                        $validProcesses = @($proc1, $proc2) | Where-Object { $_.Id -gt 0 }
                        Wait-Process -Id $validProcesses.Id

                        DelTemp

                        Clear-Host
                                    
                        DisplayMenu
                    }
        
                    3 {

                        DisplayMenu
                
                    }
        
                    default {
                        #ENTRADA INVÁLIDA.
            
                        Write-Host 'OPÇÃO INVÁLIDA. INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
                        Start-Sleep -Seconds 2
                        DisplayMenu3
                    }
             
                }
                       
            }

            DisplayMenu3

        }
       

        4 {

            function DisplayMenu4 {
            
                Clear-Host            
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|                 MICROSOFT OFFICE                   |
|                                                    |
|                                                    |
| |1| INSTALAR OFFICE 2007                           | 
| |2| INSTALAR OFFICE 365                            |
| |3| VOLTAR                                         |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'
            
       
         
                $SUBMENU4 = Read-Host 'INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
                switch ($SUBMENU4) {
                    1 { 
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
                               
                        function 2007Folder {

                            $2007Folder = 'C:\TOOL\OFFICE\2007' 
            
                            if (Test-Path -Path $2007Folder -ErrorAction SilentlyContinue) {

                                #Script continua.

                            }

                            else {
                
                                ToolDir
                   
                                DownloadOffice2007
                            }
    
                        }
                                         
                        2007Folder

                        NetFx3

                        Office2007

                        Start-Sleep 1

                        DelTemp                       

                        Clear-Host
             
                        DisplayMenu
                    }

                    2 {
                        Clear-Host
                        Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|               MICROSOFT OFFICE 365                 |
|                                                    |
|                                                    |
|                    INSTALANDO                      |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'    
                        
                        WingetModule

                        Microsoft365 

                        Start-Sleep -1

                        DelTemp

                        Clear-Host
             
                        DisplayMenu 
                    }

                    3 {

                        DisplayMenu
                
                    }

                    Default {
                        #ENTRADA INVÁLIDA.

                        Write-Host 'OPÇÃO INVÁLIDA. INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
                        Start-Sleep -Seconds 1
                        Clear-Host
                        DisplayMenu4 
                    }
                }

            }
            DisplayMenu4
        } 

        0 {
            #OPÇÃO 0 - ENCERRAR MZTOOL.

            $Host.UI.RawUI.WindowTitle = 'MZTOOL> EXIT'
            Import-Module MZTOOL -Force

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
            
            DelTemp

            if (Test-Path -Path $env:TOOL -ErrorAction SilentlyContinue) {

                Remove-Item -Path $env:TOOL -Recurse -Force -ErrorAction SilentlyContinue
            }

            Start-Sleep -Seconds 2
            Exit
            Exit-PSHostProcess
            Exit-PSSession
        }

        # COMANDOS DE TESTE OCULTOS DO MENU.
        
        #Testa a função AnyDesk.
        any {

            AnyDesk 
            DisplayMenu

        }

        #Testa a função  EnvTool.
        e {

            EnvTool 
            DisplayMenu

        }

        #Testa a função WingetInstall.

        w {
            
            WingetInstall 
            DisplayMenu

        }

        #Testa a função WinUpdate.
        u {

            WinUpdateModule
            WinUpdate 
            DisplayMenu

        }
        
        #Testa a função ClockDate.
        h {

            ClockDate 
            DisplayMenu

        }

        #Testa a função Pro.
        p {

            Pro 
            DisplayMenu

        }

        #Testa a função ImgHealth.
        sfc {

            ImgHealth 
            DisplayMenu

        }

        #Testa a função DriverBooster.
        db {

            ToolDir
            DownloadMztool
            DriverBooster 
            DisplayMenu

        }

        dvr {

            Install-DeviceDrivers
            
        }

        . {
            awin exit
        }

        default {

            #ENTRADA INVÁLIDA.

            Write-Host 'OPÇÃO INVÁLIDA. INSIRA O NÚMERO CORRESPONDENTE A OPÇÃO DESEJADA'
            Start-Sleep -Seconds 1
            DisplayMenu

        }
    }
    
}

#FUNÇÕES---------------------------------------------------------------

function ClockDate {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> CLOCK|DATE'
    Import-Module MZTOOL -Force

    #Define um novo servidor e sincroniza o relógio e a data do sistema.    
    Start-Process PowerShell -WindowStyle Hidden {

        w32tm /config /manualpeerlist:pool.ntp.br /syncfromflags:manual /update
        net start w32time 
        w32tm /resync /force
   
    }
}

function MachineEnvTool {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> MACHINE ENVTOOL'
    Import-Module MZTOOL -Force
    
    #Adiciona variáveis de ambiente.
    Start-Process PowerShell -WindowStyle Hidden {        

        #Define as variáveis de ambiente para o ambiente de máquina.
        [Environment]::SetEnvironmentVariable('TOOL', 'C:\TOOL', 'Machine')        
        [Environment]::SetEnvironmentVariable('MZTOOL', 'PowerShell irm https://bit.ly/MZT00L | iex', 'Machine')
        [Environment]::SetEnvironmentVariable('MZBETA', 'PowerShell irm https://bit.ly/MZBETA | iex', 'Machine')
        #Define a variável na biblioteca Powershell do ambiente Machine.
        Add-Content -Path $PROFILE -Value "`n[Environment]::SetEnvironmentVariable('TOOL', 'C:\TOOL', 'Machine')"

    }
}

function ToolDir {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> TOOL'
    Import-Module MZTOOL -Force

    #Criação do diretório C:\TOOL.

    $ErrorActionPreference = 'silentlycontinue'
     
    #Se o diretório C:\TOOL já existir, é deletado.
    if (Test-Path -Path $env:TOOL -ErrorAction SilentlyContinue) {

        Remove-Item -Path $env:TOOL -Recurse -Force -ErrorAction SilentlyContinue
    }

    [System.IO.Directory]::CreateDirectory($env:TOOL) | Out-Null
    $TOOLFOLDER = Get-Item $env:TOOL -ErrorAction SilentlyContinue
    $TOOLFOLDER.Attributes = 'Hidden' 

}

function DownloadMztool {
     
    #Download do arquivo MZTOOL.zip

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> DOWNLOADMZTOOL'
    Import-Module MZTOOL -Force

    Add-Type -AssemblyName "System.Net.Http"
     
    #Verifica se o link do OneDrive está disponível, se não estiver, verifica se o link do Google Drive está disponível.
    $MZTOOLZIP = "$Env:TOOL\MZTOOL.zip"

    $ONEDRIVELINK = 'https://bit.ly/MZTZIP'
       
    $GOOGLEDRIVELINK = 'https://drive.usercontent.google.com/download?id=19eiKJbx55RgkV_KczFrkL7uMkxjVrMo9&confirm=yy'
    
    # Força o uso do TLS 1.2 para conexões seguras (necessário para HTTPS)
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    # Função para testar se um link está online (usando o método GET para evitar problemas de redirecionamento)
    function Test-LinkOnline {
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
    if (Test-LinkOnline -Url $ONEDRIVELINK) {
        Write-Host "                 ONEDRIVE     = " -NoNewline; Write-Host "ONLINE     " -ForegroundColor Green
    }
    else {
        Write-Host "                 ONEDRIVE     = " -NoNewline; Write-Host "OFFLINE    " -ForegroundColor Red
    }

    if (Test-LinkOnline -Url $GOOGLEDRIVELINK) {
        Write-Host "                 GOOGLE DRIVE = " -NoNewline; Write-Host "ONLINE     " -NoNewline -ForegroundColor Green
    }
    else {
        Write-Host "                 GOOGLE DRIVE = " -NoNewline; Write-Host "OFFLINE    " -NoNewline -ForegroundColor Red
    }

    # Função para exibir uma barra de progresso customizada na última linha do console
    function Show-CustomProgress {
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
    function Invoke-DownloadFileWithProgress {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Url,
            [Parameter(Mandatory = $true)]
            [string]$Destination,
            [int]$BarWidth = 30
        )
    
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
                    Show-CustomProgress -PercentComplete $percent -BarWidth $BarWidth
                    $lastPercent = $percent
                }
            }
        }
    
        $fileStream.Dispose()
        $inputStream.Dispose()
        $resp.Dispose()
    }

    # Função que tenta baixar de uma lista de URLs (ordem de prioridade)
    function Invoke-DownloadFileWithRedundancy {
        param(
            [Parameter(Mandatory = $true)]
            [string[]]$Urls,
            [Parameter(Mandatory = $true)]
            [string]$Destination,
            [int]$BarWidth = 30
        )
    
        foreach ($url in $Urls) {
            if (Test-LinkOnline -Url $url) {
                Invoke-DownloadFileWithProgress -Url $url -Destination $Destination -BarWidth $BarWidth
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
                                DownloadMztool
                                break
                            }
                            '2' {
                                DisplayMenu
                                break
                            }
                            '0' {
                        
                                #OPÇÃO 0 - ENCERRAR MZTOOL.

                                $Host.UI.RawUI.WindowTitle = 'MZTOOL> EXIT'
                                Import-Module MZTOOL -Force

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
            
                                DelTemp

                                if (Test-Path -Path $env:TOOL -ErrorAction SilentlyContinue) {

                                    Remove-Item -Path $env:TOOL -Recurse -Force -ErrorAction SilentlyContinue
                                }

                                Start-Sleep -Seconds 2
                                Exit
                                Exit-PSHostProcess
                                Exit-PSSession
                            }
                            default {
                                Write-Host "OPÇÃO INVÁLIDA. INSIRA UMA OPÇÃO VÁLIDA."
                                Start-Sleep -Seconds 2
                                DisplayMenuDownloadError
                            }
                        }
                    }
            
                    DisplayMenuDownloadError
        
                } while ($true)<# Action when all if and elseif conditions are false #>
            }
        }
    }

    # Lista de URLs para teste (OneDrive + Google Drive como fallback)
    $DRIVEURLS = @($ONEDRIVELINK, $GOOGLEDRIVELINK)
    Invoke-DownloadFileWithRedundancy -Urls $DRIVEURLS -Destination $MZTOOLZIP -BarWidth 30
    
            
    #Verifica se o arquivo MZTOOL.zip existe antes de extrair.
    if (Test-Path -Path $MZTOOLZIP -ErrorAction SilentlyContinue ) {        
  
        # Função para exibir a barra de progresso customizada na última linha
        function Show-CustomProgress {
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
        function Expand-ArchiveEntryStream {
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
        function Expand-Archive-WithCustomProgress {
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
                Show-CustomProgress -PercentComplete $percentComplete

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
                            Expand-ArchiveEntryStream -Entry $entry -DestinationPath $destPath -Quiet:$Quiet
                        }
                    }
                    else {
                        if (-not $Quiet) {
                            Write-Host "Método ExtractToFile indisponível para '$($entry.FullName)', usando stream." -ForegroundColor Yellow
                        }
                        Expand-ArchiveEntryStream -Entry $entry -DestinationPath $destPath -Quiet:$Quiet
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

        #Extrai o arquivo MZTOOL.zip para a pasta $Env:TOOL.
        Expand-Archive-WithCustomProgress -Path $MZTOOLZIP -DestinationPath $env:TOOL -Force -Quiet
                      
        #Deleta o arquivo MZTOOL.zip.
        Remove-Item $MZTOOLZIP

    }
    else {
            
        #Script continua.
    }
   
    Clear-Host
}

function Diagnostics64 {
    
    #Inicializa Softwares de diagnósticos de hardware x64.

    $MZTOOLFOLDER = "$env:TOOL\MZTOOL"

    $APPS = @(
        "AIDA_64\aida64.exe",
        "BLUE_SCREEN_VIEW\BlueScreenView.exe",
        "CORE_TEMP\Core_Temp_64.exe",
        "CPU_Z\cpuz_x64.exe",        
        "HDSENTINEL\HDSentinel.exe",
        "HWINFO\HWiNFO64.exe",
        "GPU_Z.exe"
    )

    foreach ($APP in $APPS) {

        Start-Process "$MZTOOLFOLDER\$APP"        
    }

    Clear-Host
}

function Diagnostics32 {
    
    #Inicializa Softwares de diagnósticos de hardware x32.

    $MZTOOLFOLDER = "$env:TOOL\MZTOOL"

    $APPS = @(
        "AIDA_64\aida64.exe",
        "BLUE_SCREEN_VIEW\BlueScreenView.exe",
        "CORE_TEMP\Core_Temp_32.exe",
        "CPU_Z\cpuz_x32.exe",
        "HDSENTINEL\HDSentinel.exe",
        "HWINFO\HWiNFO32.exe",
        "GPU_Z.exe"
    )

    foreach ($APP in $APPS) {

        Start-Process "$MZTOOLFOLDER\$APP"
    }    

    Clear-Host
        
}

function WinUpdateModule {
    
    #INSTALAÇÃO DOS MÓDULO WINDOWS UPDATE.       
    
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINUPDATEMODULE'
    Import-Module MZTOOL -Force  
    
    #Pacote NuGet.
    Install-PackageProvider -Name NuGet -Force |  Clear-Host   
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted  |  Clear-Host
    
    #Módulo WINDOWS UPDATE.
    Install-Module PSWindowsUpdate -AllowClobber -Force |  Clear-Host
    Import-Module PSWindowsUpdate -Force |  Clear-Host        
    
    Clear-Host
             
}

function WingetModule {
    
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINGETMODULE'
    Import-Module MZTOOL -Force  
   
    #Módulo WINGET.

    #Obtém a versão do Windows.
    $WinVer = (Get-WmiObject Win32_OperatingSystem).Caption
    $ErrorActionPreference = 'SilentlyContinue'
     
    #Verifica se a versão do Windows é a 11.
    if ( $WinVer -Match 'Windows 11') {
        Write-Host "$WinVer" |  Clear-Host
                
        #Reinstala, redefine as fontes e atualiza o Módulo WINGET.
        Start-BitsTransfer -Source 'https://cdn.winget.microsoft.com/cache/source.msix' -Destination "$env:TEMP\source.msix" -ErrorAction SilentlyContinue |  Clear-Host
        Add-AppPackage -Path "$env:TEMP\source.msix" |  Clear-Host
        Winget Install Microsoft.UI.Xaml.2.8 --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Winget Install Microsoft.UI.Xaml.2.7 --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        Start-BitsTransfer -Source 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'-Destination "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ErrorAction SilentlyContinue |  Clear-Host
        Add-AppPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" |  Clear-Host
        Winget Upgrade Microsoft.AppInstaller --Accept-Source-Agreements --Accept-Package-Agreements |  Clear-Host
        
    }

    #Verifica se a versão do Windows é a 10.
    elseif ($WinVer -Match 'Windows 10') {
        Write-Host "$WinVer"
                
        #Instala o pacote NuGet.
        Install-PackageProvider -Name NuGet -Force |  Clear-Host
        
        #Reinstala, redefine as fontes e atualiza o WINGET.
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery |  Clear-Host
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
    
    }

    else {
        Write-Host 'Versão do Windows não compatível com Winget.'
    }  

}

function WingetInstall {
    # Altera o título da janela e garante que o módulo MZTOOL esteja carregado.
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINGET'
    Import-Module MZTOOL -Force

    # Se o comando winget não estiver disponível, invoca outra rotina (WingetModule) para disponibilizá-lo.
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        WingetModule
    }

    # Lista dos IDs dos softwares a serem instalados.
    $softwareIds = @(
        "Google.Chrome",
        "Microsoft.Powershell",
        "Adobe.Acrobat.Reader.64-bit"
    )

    # Função local para instalar via método alternativo de acordo com o software.
    function InstallFallback ($id) {
        switch ($id) {
            "Google.Chrome" {
                Write-Output "Instalando Google Chrome via alternativa..."
                pause
                $downloadUrl = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
                $tempFile = Join-Path $env:TEMP "GoogleChrome.msi"
                try {
                    Start-BitsTransfer -Source $downloadUrl -Destination $tempFile -ErrorAction Stop
                    Start-Process "msiexec.exe" -ArgumentList "/i `"$tempFile`" /qn" -Wait
                    Write-Output "Google Chrome instalado via alternativa."
                }
                catch { Write-Output "Falha na instalação alternativa do Google Chrome: $_" }
            }
            "Microsoft.Powershell" {
                Write-Output "Instalando Microsoft PowerShell via alternativa..."
                $downloadUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.7/PowerShell-7.3.7-win-x64.msi"
                $tempFile = Join-Path $env:TEMP "PowerShell.msi"
                try {
                    Start-BitsTransfer -Source $downloadUrl -Destination $tempFile -ErrorAction Stop
                    Start-Process "msiexec.exe" -ArgumentList "/i `"$tempFile`" /qn" -Wait
                    Write-Output "Microsoft PowerShell instalado via alternativa."
                }
                catch { Write-Output "Falha na instalação alternativa do MS PowerShell: $_" }
            }
            "Adobe.Acrobat.Reader.64-bit" {
                Write-Output "Instalando Adobe Acrobat Reader via alternativa..."
                $downloadUrl = "https://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2300120155/AcroRdrDC2300120155_en_US.exe"
                $tempFile = Join-Path $env:TEMP "AcrobatReader.exe"
                try {
                    Start-BitsTransfer -Source $downloadUrl -Destination $tempFile -ErrorAction Stop
                    Start-Process -FilePath $tempFile -ArgumentList "/sAll", "/rs", "/rps", "/msi", "/norestart" -Wait
                    Write-Output "Adobe Acrobat Reader instalado via alternativa."
                }
                catch { Write-Output "Falha na instalação alternativa do Acrobat Reader: $_" }
            }
            default { Write-Output "Nenhuma alternativa definida para $id" }
        }
    }

    # Loop para instalar cada software.
    foreach ($id in $softwareIds) {
        Write-Output "Tentando instalar $id via winget..."
        try {
            $result = winget install --Id $id --Accept-Source-Agreements --Accept-Package-Agreements --Silent 2>&1
            if ($result -match "O hash do instalador não corresponde") {
                Write-Output "Erro de hash detectado para $id. Iniciando método alternativo..."
                InstallFallback $id
                pause
            }
            else {
                Write-Output "$id instalado com sucesso via winget."
            }
        }
        catch {
            Write-Output "Erro ao instalar $id via winget: $_. Iniciando método alternativo..."
            InstallFallback $id
            pause
        }
        Clear-Host
    }
}


function WingetUpdate { 

    #Busca e atualiza todos softwares já previamente instalados compatíveis com o Winget.
    #Start-Process PowerShell <#-WindowStyle Hidden#> {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINGETUPDATE'
    Import-Module MZTOOL -Force

    1..3 | ForEach-Object {
            
        Winget Upgrade --All --Accept-Source-Agreements --Accept-Package-Agreements --Include-Unknown

        Clear-Host
        #    }
    }
}

function WinUpdate { 

    #Busca, realiza o download e implementa novas atualizações do Windows e de Drivers de Dispositivos através do Módulo PSWindowsUpdate e do canal de atualizações MicrosoftUpdate.

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINUPDATE'
    Import-Module MZTOOL -Force

    Import-Module PSWindowsUpdate -Force 

    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
      
    Clear-Host
    
}

function RemoveGhostDrivers {
    
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> REMOVEGHOSTDEVICES'
    Import-Module MZTOOL -Force

    #Remove os drivers de dispositivo não utilizados pelo sistema atualmente (Dispositivos Ocultos)
   
    #Obtem a lista de drivers de Dispositivos Ocultos.
    $DISPOSITIVOSOCULTOS = Get-PnpDevice | Where-Object { $_.Status -eq 'Unknown' } 

    #Remove os drivers de Dispositivos Ocultos da lista obtida.
    ForEach ($DRIVER in $DISPOSITIVOSOCULTOS) {
        
        pnputil /remove-device $DRIVER.InstanceId | Clear-Host
    
    }
       
}

function AnyDesk {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> ANYDESK'
    Import-Module MZTOOL -Force

    #Download do software Standalone AnyDesk-CM para a área de trabalho pública.           

    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile('https://download.anydesk.com/AnyDesk-CM.exe', "$env:DESKTOP\AnyDesk.exe")

    Clear-Host
    
}

function Microsoft365 {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> MICROSOFT365'
    Import-Module MZTOOL -Force

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
  <Display Level="TRUE" AcceptEULA="TRUE" />
</Configuration> 
'@           
    $XML.save("$env:Temp\MICROSOFT365.xml") 
   
    $365XML = "$env:Temp\MICROSOFT365.xml"

    $WINGETAVAILABLE = Get-Command winget -ErrorAction SilentlyContinue
    $WINGETRUNNING = Get-Process -Name winget -ErrorAction SilentlyContinue

    if ($WINGETAVAILABLE -and !$WINGETRUNNING) {      
        
        Winget Install --Id Microsoft.Office --Override "/configure $365XML" --Accept-Source-Agreements --Accept-Package-Agreements --Silent
    }
    else {

        #Caso o Winget não esteja disponível, baixa o Microsoft 365 de forma alternativa.
        
        $365URL = "https://go.microsoft.com/fwlink/?linkid=2264705&clcid=0x409&culture=pt-br&country=br"
        $365EXE = "$env:TEMP\MICROSOFT365.exe"

        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($365URL, $365EXE)
        Start-Process -FilePath $365EXE -ArgumentList "/configure $365XML" -Wait
    }
    
    #Implementa os atalhos dos aplicativos Word, Excel e PowePoint na área de trabalho pública.
    $365LNK = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    $APPS = @("Word.lnk", "Excel.lnk", "PowerPoint.lnk")
    $APPS | ForEach-Object { Copy-Item "$365LNK\$_" "$env:DESKTOP" }
    
    Stop-Process -Name OfficeC2RClient -Force
    
    Clear-Host
}    
function DownloadOffice2007 {
    
    #Download do arquivo de instalação do Microsoft Office 2007.
        
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> DOWNLOADOFFICE2007'
    Import-Module MZTOOL -Force
    
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile('https://bit.ly/Office2007', "$env:TOOL\OFFICE\2007\Setup.exe")
    
    Clear-Host
}
function Office2007 {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> OFFICE2007'
    Import-Module MZTOOL -Force 
    
    #Implementa o Microsoft Office 2007 com configurações de instalação AdminFile MSP.
    Start-Process "$env:TOOL\OFFICE\2007\Setup.exe" -ArgumentList '/adminfile Silent.msp' -Wait     
    Wait-Job -Name NetFx3  
    Start-Process 'winword.exe'
   
}

function NetFx3 {

    #Implementa o recurso .NetFramework 3.5 no sistema.

    Start-Job -Name NetFx3 -ScriptBlock { 

        $Host.UI.RawUI.WindowTitle = 'MZTOOL> .NETFRAMEWORK3.5'
        Import-Module MZTOOL -Force

        Dism.exe /Online /NoRestart /Add-Package /PackagePath:C:\TOOL\OFFICE\2007\NetFx35\update.mum            
        
    }
    
}

function DriverBooster {
    
    #Extrai e inicializa o software Driver Booster.   

    Start-Process PowerShell <#-WindowStyle Hidden#> {
    
        $Host.UI.RawUI.WindowTitle = 'MZTOOL> DRIVER_BOOSTER'
        Import-Module MZTOOL -Force
        
        Expand-Archive -LiteralPath "$Env:TOOL\MZTOOL\DRIVER_BOOSTER.zip" -DestinationPath "$Env:TOOL\MZTOOL\DRIVER_BOOSTER"

        Start-Process "$Env:TOOL\MZTOOL\DRIVER_BOOSTER\DriverBoosterPortable.exe" -Wait
        
        Start-Sleep -Seconds 1
        #Finaliza os serviços do software Driver Booster e deleta a pasta temporária do mesmo.
        function StopDriverBooster {
            
            if (Get-Process -Name 'DriverBooster'-ErrorAction SilentlyContinue ) {
                
                Stop-Process -Name 'DriverBooster' -Force

                if (Get-Process -Name 'ScanWinUpd'-ErrorAction SilentlyContinue) {
                
                    Stop-Process -Name 'ScanWinUpd' -Force
                }
                
                Start-Sleep -Seconds 5

                Remove-Item -Path "$Env:TOOL\MZTOOL\DRIVER_BOOSTER" -Recurse -Force -ErrorAction SilentlyContinue
            }

            elseif (Get-Process -Name 'ScanWinUpd'-ErrorAction SilentlyContinue) {
                
                Stop-Process -Name 'ScanWinUpd' -Force

                if (Get-Process -Name 'DriverBooster'-ErrorAction SilentlyContinue ) {
                
                    Stop-Process -Name 'DriverBooster' -Force
                }
                
                Start-Sleep -Seconds 5

                Remove-Item -Path "$Env:TOOL:\MZTOOL\DRIVER_BOOSTER" -Recurse -Force -ErrorAction SilentlyContinue
            }

            else {
                
                #Script continua.
            }
    
        }

        StopDriverBooster

        Clear-Host
    }
}

function PerfilTheme {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> PERFILTHEME'
    Import-Module MZTOOL -Force
   
    # Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    function RefreshUser {

        Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,UpdatePerUserSystemParameters"
        Stop-Process -Name explorer        
    }

    $WinVer = (Get-WmiObject Win32_OperatingSystem).Caption

    #Adiciona o Tema Escuro ao Windows.
    if ( $WinVer -Match 'Windows 11') {
        Write-Host "$WinVer"
        Start-Process -FilePath 'C:\Windows\Resources\Themes\dark.theme'
    }

    elseif ($WinVer -Match 'Windows 10') {
        Write-Host "$WinVer"
        Start-Process -FilePath 'C:\Windows\Resources\Themes\aero.theme'
    }

    else {
        Write-Host 'Windows não identificado, tema não aplicado.'
    }    
    
    #Adiciona ícones de sistema a Área de Trabalho.
    $DESKINCONSREG = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'

    # Lista de ícones de sistema.
    $ICONS = @(
        '{018D5C66-4533-4307-9B53-224DE2ED1FE6}', #OneDrive
        '{20D04FE0-3AEA-1069-A2D8-08002B30309D}', #Este Computador
        '{59031a47-3f72-44a7-89c5-5595fe6b30ee}', #Rede
        '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}', #Grupo Doméstico
        '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'  #Painel de Controle
    )

    # Adiciona ou modifica propriedades no registro para exibir ícones.
    foreach ($ICON in $ICONS) {
        New-ItemProperty -Path "$DESKINCONSREG" -Name $ICON -PropertyType dword -Value 0 -ErrorAction SilentlyContinue
    }    

    #Mostra e atualiza a Área de Trabalho.    
    for ($i = 0; $i -le 1; $i++) {
        (New-Object -ComObject shell.application).toggleDesktop()
        Start-Sleep 2
        (New-Object -ComObject Wscript.Shell).sendkeys('{F5}')
        Start-Sleep 1
        (New-Object -ComObject shell.application).undominimizeall()
        Start-Sleep 2
    }

    #Define as opções de Efeitos Visuais do Windows para personalizado.
    $settings = @{
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' = @{
            'VisualFXSetting'           = 3
            'AlwaysHibernateThumbnails' = 0
            'IconsOnly'                 = 0
        }
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'      = @{
            'ListviewShadow'      = 1
            'ListviewAlphaSelect' = 0
            'TaskbarAnimations'   = 0
        }
        'HKCU:\Software\Microsoft\Windows\DWM'                                   = @{
            'EnableAeroPeek'            = 0
            'AlwaysHibernateThumbnails' = 0
        }
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'               = @{
            'ShellState' = [byte[]](24, 0, 0, 0, 62, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 114, 0, 0, 0)
        }
    }
   
    foreach ($path in $settings.Keys) {
        foreach ($name in $settings[$path].Keys) {
            Set-ItemProperty -Path $path -Name $name -Value $settings[$path][$name] -Type DWord -ErrorAction SilentlyContinue
        }
    }

    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Type DWord -Value 2
        
    #Remove Widgets.    
    Get-AppxPackage *WebExperience* | Remove-AppxPackage
    
    #Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    RefreshUser

    #Finaliza janela de personalização do Windows.
    if (Get-Process -Name 'systemsettings') {
                        
        Stop-Process -Name 'systemsettings' -Force
    }

    else {
        #Script continua.
    }    
       
    #Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    RefreshUser
    
    Clear-Host

}

function PinIcons {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> PERFILTHEME > PINICONS'
    Import-Module MZTOOL -Force
   
    # Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    function RefreshUser {

        Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,UpdatePerUserSystemParameters"
        Stop-Process -Name explorer        
    }

    #Fixa os ícones dos softwares Google Chrome, Acrobat Reader, Microsoft Word e do Windows Explorer na barra de tarefas e remove os demais ícones.
    $taskbar_layout =
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

    [System.IO.FileInfo]$provisioning = "$($env:ProgramData)\provisioning\taskbar_layout.xml"
    if (!$provisioning.Directory.Exists) {
        $provisioning.Directory.Create()
    }

    $taskbar_layout | Out-File $provisioning.FullName -Encoding utf8

    $settings = [PSCustomObject]@{
        Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
        Value = $provisioning.FullName
        Name  = "StartLayoutFile"
        Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
    },
    [PSCustomObject]@{
        Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
        Value = 1
        Name  = "LockedStartLayout"
    } | Group-Object Path

    foreach ($setting in $settings) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
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

    function TrayIcons {

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
    
    TrayIcons

    #Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    RefreshUser

    #Mostra e atualiza a Área de Trabalho.    
    for ($i = 0; $i -le 2; $i++) {
        (New-Object -ComObject shell.application).toggleDesktop()
        Start-Sleep 2
        (New-Object -ComObject Wscript.Shell).sendkeys('{F5}')
        Start-Sleep 1
        (New-Object -ComObject shell.application).undominimizeall()
        Start-Sleep 2
    }   

    #Desabilita as notificações da central de ações.    
    If (!(Test-Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -ErrorAction SilentlyContinue)) {
        New-Item -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -ErrorAction SilentlyContinue
    }
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'DisableNotificationCenter' -Type DWord -Value 1
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'ToastEnabled' -Type DWord -Value 0

    #Ativa plano de energia para Alto Desempenho.    
    POWERCFG /SETACTIVE SCHEME_MIN

    #Atualiza o perfil do usuário sem fazer logoff e reiniciar o Explorer.
    RefreshUser
          
}

function DefaultSoftwares {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> PERFILTHEME > DEFAULTSOFTWARES'
    Import-Module MZTOOL -Force
   
}

function StartSoftwares {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> STARTSOFTWARES'
    Import-Module MZTOOL -Force

    Start-Process CHROME
    Start-Process ACROBAT
    Start-Process WINWORD
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
    for ($i = 0; $i -le 2; $i++) {
        (New-Object -ComObject shell.application).toggleDesktop()
        Start-Sleep 2
        (New-Object -ComObject Wscript.Shell).sendkeys('{F5}')
        Start-Sleep 1
        (New-Object -ComObject shell.application).undominimizeall()
        Start-Sleep 2
    }

    Start-Process ACROBAT
    Start-Process CHROME https://github.com/DanielMozartt/MZTOOL, https://www.youtube.com/mozartinformatica, https://www.instagram.com/mozartinformatica/    
    Start-Process -FilePath "C:\Windows\System32\SystemPropertiesPerformance.exe"    

}

function DelTemp {
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> CLEANTEMP'
    Import-Module MZTOOL -Force

    Write-Host 'LIMPANDO ARQUIVOS TEMPORÁRIOS'

    # Função para remoção de arquivos temporários.
    function Remove-Files {
        param (
            [string]$Path,
            [string]$Description
        )
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
        Write-Host "`rLimpando $Description" -NoNewline   
        
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Remove arquivos temporários do sistema.
    Remove-Files -Path "$env:TEMP\*" -Description "arquivos temporários do sistema"

    # Remove arquivos temporários do Windows.
    Remove-Files -Path "C:\Windows\temp\*" -Description "arquivos temporários do Windows"

    # Remove arquivos de Prefetch.
    Remove-Files -Path "C:\Windows\Prefetch\*" -Description "arquivos de Prefetch"

    # Remove arquivos de CrashDumps.
    Remove-Files -Path "$env:LOCALAPPDATA\CrashDumps\*" -Description "arquivos de CrashDumps"
    
    # Remove arquivos de Internet Temporários.
    Remove-Files -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Description "arquivos de Internet Temporários"

    # Remove arquivos de atualização do Windows.
    Remove-Files -Path "C:\Windows\SoftwareDistribution\Download\*" -Description "arquivos de atualização do Windows"

    # Remove relatórios de erros do Windows.
    Remove-Files -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Description "relatórios de erros do Windows"
    Remove-Files -Path "C:\ProgramData\Microsoft\Windows\WER\Temp\*" -Description "relatórios de erros do Windows"
    
    # Remove histórico do Microsoft Defender.
    Remove-Files -Path "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*" -Description "histórico do Microsoft Defender"

    # Remove arquivos de programas baixados.
    Remove-Files -Path "C:\Windows\Downloaded Program Files\*" -Description "arquivos de programas baixados"

    # Remove cache de sombreador DirectX.
    Remove-Files -Path "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache\*" -Description "cache de sombreador DirectX"

    # Remove arquivos de otimização de entrega.
    Remove-Files -Path "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Description "arquivos de otimização de entrega"

    # Remove miniaturas.
    Remove-Files -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Description "miniaturas"
   
    Start-Sleep -Seconds 2
}

function ImgHealth {
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> IMGHEALTH'
    Import-Module MZTOOL -Force
    
    # Verifica a integridade da imagem do sistema.
    DISM /Online /Cleanup-Image /CheckHealth

    Clear-Host    
    
    # Repara a imagem do sistema, se necessário.
    DISM /Online /Cleanup-Image /RestoreHealth

    Clear-Host

    # Executa o comando SFC para verificar e reparar arquivos corrompidos do sistema.
    SFC /SCANNOW

    Clear-Host
}

function Pro {

    
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINDOWSPRO'
    Import-Module MZTOOL -Force

    #Converte a versão do Windows para PRO. (Não ativa o sistema, para a ativação é necessário haver uma Licença Digital HWID).

    changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T
    SLMGR.VBS /CPKY
    SLMGR.VBS /CKMS
    Net stop Sppsvc
    Set-Location C:\Windows\System32\SPP\Store\2.0
    Rename-Item Tokens.dat Tokens.old
    SLMGR.VBS /RILC
    changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T

    Clear-Host

}

function Install-DeviceDrivers {
    # Adicionar Serviço de Atualização do Windows
    $UpdateSvc = New-Object -ComObject Microsoft.Update.ServiceManager
    $UpdateSvc.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")

    # Buscar Atualizações de Drivers
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    $Searcher.ServiceID = '7971f918-a847-4430-9279-4a52d1efe18d'
    $Searcher.SearchScope = 1 # Somente na máquina
    $Searcher.ServerSelection = 3 # Terceiros
    $Criteria = "IsInstalled=0 and Type='Driver'"
    $SearchResult = $Searcher.Search($Criteria)
    $Updates = $SearchResult.Updates

    # Exibir Atualizações de Drivers Disponíveis
    $Updates | Select-Object Title, DriverModel, DriverVerDate, DriverClass, DriverManufacturer | Format-List

    # Baixar e Instalar as Atualizações
    $UpdatesToDownload = New-Object -Com Microsoft.Update.UpdateColl
    $Updates | ForEach-Object { $UpdatesToDownload.Add($_) | Out-Null }
    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $UpdatesToDownload
    $Downloader.Download()
    $UpdatesToInstall = New-Object -Com Microsoft.Update.UpdateColl
    $Updates | ForEach-Object { if ($_.IsDownloaded) { $UpdatesToInstall.Add($_) | Out-Null } }
    $Installer = $Session.CreateUpdateInstaller()
    $Installer.Updates = $UpdatesToInstall
    $InstallationResult = $Installer.Install()

    # Reiniciar se Necessário
    if ($InstallationResult.RebootRequired) {
        Write-Host "Reinicialização necessária. Por favor, reinicie o computador."
    }
}

function NEWPWSH {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$FunctionNames,
        [switch]$Wait,
        [switch]$ReturnProcess
    )
    
    # Combina as definições das funções (preservando a ordem)
    $combinedDefinitions = foreach ($fn in $FunctionNames) {
        (Get-Command -Type Function $fn).Definition
    } -join "`n"
    
    # Converte o conteúdo para Base64 para uso com -EncodedCommand
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($combinedDefinitions))
    $arguments = @('-noprofile', '-EncodedCommand', $encodedCommand)
    
    if ($Wait) {
        # Caso Wait seja especificado, aguardamos o término do processo internamente.
        [void](Start-Process powershell -ArgumentList $arguments -Wait)
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



function awin {
    Start-Process powershell -WindowStyle Hidden { Invoke-RestMethod https://4br.me/awin | Invoke-Expression }
}

ClockDate

MachineEnvTool

DisplayMenu 

EXIT   


