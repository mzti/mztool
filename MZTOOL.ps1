Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

#Obtém o ID e o Objeto de Segurança do usuário atual.
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

#Obtém o Objeto de Segurança do usuário Administrador.
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
  
#Verifica se o script está sendo executado como administrador.
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    
    #Executando como administrador. Formatação e estilo aplicadas.


    $Host.UI.RawUI.WindowTitle = 'MZTOOL ⭡'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'
    $H = Get-Host
    $Win = $H.UI.RawUI.WindowSize
    $Win.Height = 20
    $Win.Width = 58
    $H.UI.RawUI.Set_WindowSize($Win)
  
    Clear-Host

}

else {
    
    #Não está executando como administrador.
    
    #Fecha o processo atual e inicia um novo com o script como administrador solicitando UAC.
  
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo 'PowerShell'
    $newProcess.Arguments = $myInvocation.MyCommand.Definition
    $newProcess.Verb = 'runas'
    [System.Diagnostics.Process]::Start($newProcess) | Out-Null     
    exit 
}
 
function OpSys {
    #Verifica se o sistema operacional é suportado.
    $WinVer = (Get-WmiObject Win32_OperatingSystem).Caption

    if ( $WinVer -Match 'Microsoft Windows 11') {
        
        Write-Host "$WinVer"

    }

    elseif ($WinVer -Match 'Microsoft Windows 10') {
        
        Write-Host "$WinVer"

    }

    elseif ($WinVer -Match 'Microsoft Windows 8.1') {
        
        Write-Host "$WinVer"

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
    
    Clear-Host
    Write-Host '
______________________________________________________
|                                                    |
|                       MZTOOL                       |
| _________________________________________________  | 
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
            Hora
            AnyDesk
            EnvTool
            ToolDir           

            Start-Process powershell -args '-noprofile', '-EncodedCommand',
            ([Convert]::ToBase64String(
                [Text.Encoding]::Unicode.GetBytes(
                    (Get-Command -Type Function RemoveMStoreApps, PerfilTheme).Definition
                ))
            )

            Start-Process powershell -args '-noprofile', '-EncodedCommand',
            ([Convert]::ToBase64String(
                [Text.Encoding]::Unicode.GetBytes(
                    (Get-Command -Type Function DownloadMztool, <#DriverBooster,#> NetFx3, Office2007).Definition
                ))
            )


            Start-Process powershell -Wait -args '-noprofile', '-EncodedCommand',
            ([Convert]::ToBase64String(
                [Text.Encoding]::Unicode.GetBytes(
                    (Get-Command -Type Function WingetModule, WingetInstall).Definition
                ))
            )
         
            PinIcons

            DefaultSoftwares

            STARTSOFTWARES

            WingetUpdate

            Start-Process powershell -args '-noprofile', '-EncodedCommand',
            ([Convert]::ToBase64String(
                [Text.Encoding]::Unicode.GetBytes(
                    (Get-Command -Type Function WinUpdateModule, WinUpdate).Definition
                ))
            )
            
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
            DelTemp
            Start-Sleep -Seconds 5
            Exit
        }

        2 {
    
            #OPÇÃO 2 - DIAGNÓSTICO DE HARDWARE E SISTEMA.

            $OSARCHITECTURE = get-wmiobject -class win32_operatingsystem | format-list osarchitecture
           
            Write-Host "ARQUITETURA DO SISTEMA - $OSARCHITECTURE"
           
            if ($OSARCHITECTURE = '64 bits') {
               
                Clear-Host
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|           FERRAMENTAS DE DIAGNÓSTICOS X64          |
|                                                    |
|                                                    |
|               DOWNLOAD EM ANDAMENTO                |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'
                Hora
                        
                AnyDesk
                                
                ToolDir 

                Start-Sleep -Seconds 1

                DownloadMztool 

                Start-Sleep -Seconds 1
                
                Clear-Host
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|           FERRAMENTAS DE DIAGNÓSTICOS X64          |
|                                                    |
|                                                    |
|        FERRAMENTAS DE DIAGNÓSTICO INICIADAS        |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'     
                        
                Diagnostics64
                                                
                Start-Sleep -Seconds 1

                DelTemp

                EnvTool

                Clear-Host
        
                DisplayMenu
            
            }
        
            elseif ($OSARCHITECTURE = '32 bits') {

                Clear-Host
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|           FERRAMENTAS DE DIAGNÓSTICOS X32          |
|                                                    |
|                                                    |
|               DOWNLOAD EM ANDAMENTO                |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
'
                
                Hora
                        
                AnyDesk
                                
                ToolDir 

                Start-Sleep -Seconds 1

                DownloadMztool 

                Start-Sleep -Seconds 1 
                
                Clear-Host
                Write-Host '
______________________________________________________
|                                                    |
|                      MZTOOL                        |
| _________________________________________________  | 
|           FERRAMENTAS DE DIAGNÓSTICOS X32          |
|                                                    |
|                                                    |
|        FERRAMENTAS DE DIAGNÓSTICO INICIADAS        |
|                                                    |
|                                                    |
|                 MOZART INFORMÁTICA                 |
|                   DANIEL MOZART                    |
|____________________________________________________|
' 
                
                Diagnostics32
                                                
                Start-Sleep -Seconds 1

                DelTemp

                EnvTool

                Clear-Host
        
                DisplayMenu
            }
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

                        EnvTool

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

                        Hora
                        
                        Start-Process powershell -Wait -args '-noprofile', '-EncodedCommand',
                        ([Convert]::ToBase64String(
                            [Text.Encoding]::Unicode.GetBytes(
                              (Get-Command -Type Function WingetUpdate, WinUpdate).Definition
                            ))
                        )
                        
                        DelTemp

                        EnvTool

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
            
                            if (Test-Path -Path $2007Folder) {

                                continue

                            }

                            else {
                
                                ToolDir
                   
                                DownloadMztool
                            }
    
                        }

                        2007Folder

                        Office2007

                        Start-Sleep -1

                        DelTemp

                        EnvTool

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

                        Office365 

                        Start-Sleep -1

                        DelTemp

                        EnvTool

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
            Start-Sleep -Seconds 3
            Exit
            Exit-PSHostProcess
            Exit-PSSession
        }

        . {
            awin exit
        }

        e {
            EnvTool #TESTAR ENVTOOL
        }

        w {
            WingetModule
            WingetInstall #TESTAR WINGET
        }

        u {
            WinUpdateModule
            WinUpdate #TESTAR WINUPDATE
        }
        
        h {
            Hora #Testar Hora/Data
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

function Hora {
    
    Start-Process PowerShell -WindowStyle Hidden {
    
        net start w32time 
        w32tm /resync /force
   
    }
}

function ToolDir {

    #Criação do diretório C:\TOOL.

    $TOOL = 'C:\TOOL'
    
    #Se o diretório C:\TOOL já existir, é deletado.

    if (Test-Path -Path $TOOL) {

        Remove-Item -Path $TOOL -Recurse -Force -ErrorAction SilentlyContinue
    }

    [System.IO.Directory]::CreateDirectory($TOOL) | Out-Null
    $TOOLFOLDER = Get-Item $TOOL -ErrorAction SilentlyContinue
    $TOOLFOLDER.Attributes = 'Hidden' 

}

function DownloadMztool {
     
    #Download do arquivo MZTOOL.zip

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> DOWNLOADMZTOOL'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

    $TOOL = 'C:\TOOL'
   
    $MZTOOLZIP = 'C:\TOOL\MZTOOL.zip'

    $ONEDRIVELINK = 'https://bit.ly/MZTZIP'
       
    $GOOGLEDRIVELINK = 'https://drive.usercontent.google.com/download?id=19eiKJbx55RgkV_KczFrkL7uMkxjVrMo9&confirm=yy'
    
    try {
        $wc = new-object System.Net.WebClient
        $wc.DownloadFile("$ONEDRIVELINK", "$MZTOOLZIP")
    }
    
    catch [System.Net.WebException] , [System.IO.IOException] {
         
        try {
            $wc = new-object System.Net.WebClient
            $wc.DownloadFile("$GOOGLEDRIVELINK", "$MZTOOLZIP")
        }
       
        catch {
            CLEAR-HOST
            "A CONEXÃO COM O ONEDRIVE E GOOGLE DRIVE NÃO PUDERAM SER CONCLUÍDAS. VERIFIQUE A SUA CONEXÃO E TENTE NOVAMENTE"
        }
    }
    
    Clear-Host
            
    #Extração do arquivo MZTOOL.zip para a pasta $TOOL.
    
    Expand-Archive -LiteralPath $MZTOOLZIP -DestinationPath $TOOL

    #Deletar o arquivo MZTOOL.zip.

    Remove-Item $MZTOOLZIP

}

function EnvTool {
    
    #Adicionar variáveis de ambiente.
    Start-Process PowerShell {
        [Environment]::SetEnvironmentVariable('TOOL', 'C:\TOOL', 'Machine') 
        [Environment]::SetEnvironmentVariable('MZTOOL', 'PowerShell irm https://bit.ly/MZT00L | iex', 'MACHINE')
        [Environment]::SetEnvironmentVariable('MZBETA', 'PowerShell irm https://seulink.net/MZTBETA | iex', 'MACHINE')
    }
}

function Diagnostics64 {
   
    $MZTOOLFOLDER = 'C:\TOOL\MZTOOL'

    Start-Process $MZTOOLFOLDER\AIDA_64\aida64.exe
    Start-Process $MZTOOLFOLDER\BLUE_SCREEN_VIEW\BlueScreenView.exe
    Start-Process $MZTOOLFOLDER\CORE_TEMP\Core_Temp_64.exe
    Start-Process $MZTOOLFOLDER\CPU_Z\cpuz_x64.exe
    Start-Process $MZTOOLFOLDER\CRYSTAL_DISK\DiskInfo64.exe
    Start-Process $MZTOOLFOLDER\HDSENTINEL\HDSentinel.exe
    Start-Process $MZTOOLFOLDER\HWINFO\HWiNFO64.exe
    Start-Process $MZTOOLFOLDER\GPU_Z.exe

    Clear-Host
        
}

function Diagnostics32 {

    $MZTOOLFOLDER = 'C:\TOOL\MZTOOL'
              
    Start-Process $MZTOOLFOLDER\AIDA_64\aida64.exe
    Start-Process $MZTOOLFOLDER\BLUE_SCREEN_VIEW\BlueScreenView.exe
    Start-Process $MZTOOLFOLDER\CORE_TEMP\Core_Temp_32.exe
    Start-Process $MZTOOLFOLDER\CPU_Z\cpuz_x32.exe
    Start-Process $MZTOOLFOLDER\CRYSTAL_DISK\DiskInfo32.exe
    Start-Process $MZTOOLFOLDER\HDSENTINEL\HDSentinel.exe
    Start-Process $MZTOOLFOLDER\HWINFO\HWiNFO32.exe
    Start-Process $MZTOOLFOLDER\GPU_Z.exe

    Clear-Host
        
}

function WinUpdateModule {
    
    #INSTALAÇÃO DOS MÓDULO WINDOWS UPDATE.       
    
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINUPDATEMODULE'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'   
    
    #Pacote NuGet.
    Install-PackageProvider -Name NuGet -Force
        
    #Módulo WINDOWS UPDATE.
    Install-Module PSWindowsUpdate -AllowClobber -Force
    Import-Module PSWindowsUpdate -Force       
    
    Clear-Host
             
}

function WingetModule {
    
    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINGETMODULE'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'  
   
    #Módulo WINGET.
    $WinVer = (Get-WmiObject Win32_OperatingSystem).Caption
            
    if ( $WinVer -Match 'Windows 11') {
        Write-Host "$WinVer"
                
        #Reinstala, redefine as fontes e atualiza o Módulo WINGET.
        Start-BitsTransfer -Source 'https://cdn.winget.microsoft.com/cache/source.msix' -Destination "$env:TEMP\source.msix"
        Add-AppPackage -Path "$env:TEMP\source.msix"
        Winget Install Microsoft.UI.Xaml.2.8 --Accept-Source-Agreements --Accept-Package-Agreements
        Winget Install Microsoft.UI.Xaml.2.7 --Accept-Source-Agreements --Accept-Package-Agreements
        Start-BitsTransfer -Source 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'-Destination "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Add-AppPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Winget Upgrade Microsoft.AppInstaller --Accept-Source-Agreements --Accept-Package-Agreements
        
    }

    elseif ($WinVer -Match 'Windows 10') {
        Write-Host "$WinVer"
                
        #Pacote NuGet.
        Install-PackageProvider -Name NuGet -Force
        
        #Reinstala, redefine as fontes e atualiza o Módulo WINGET.
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery 
        Repair-WinGetPackageManager
        Winget Source Remove --Name winget
        Winget Source Remove --Name msstore
        Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue 
        Start-BitsTransfer -Source 'https://cdn.winget.microsoft.com/cache/source.msix' -Destination "$env:TEMP\source.msix"
        Add-AppPackage -Path "$env:TEMP\source.msix"
        Start-Sleep 1
        Winget Source Reset --Force     
        Winget Source Update
        Winget Install Microsoft.UI.Xaml.2.8 --Accept-Source-Agreements --Accept-Package-Agreements
        Winget Install Microsoft.UI.Xaml.2.7 --Accept-Source-Agreements --Accept-Package-Agreements
        Start-BitsTransfer -Source 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'-Destination "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Add-AppPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"  
        Winget Upgrade Microsoft.AppInstaller --Accept-Source-Agreements --Accept-Package-Agreements
    
    }

    else {
        Write-Host 'Versão do Windows não compatível com Winget.'
    }  

}

function WingetInstall {
    
    #WINGET - Instalação dos softwares Acrobat Reader, Google Chrome, Microsoft Powershell 7+.

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINGET'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

    function WaitOffice2007Winget {
            
        if (Get-Process -Name setup -ErrorAction SilentlyContinue) {
            Wait-Process -Name setup
        }

    }
        
    WaitOffice2007Winget
            
    for ($i = 0; $i -le 2; $i++) {

        WaitOffice2007Winget
        
        Winget Install --Id Adobe.Acrobat.Reader.64-bit --Accept-Source-Agreements --Accept-Package-Agreements

        WaitOffice2007Winget
         
        Winget Install --Id Google.Chrome --Accept-Source-Agreements --Accept-Package-Agreements 

        WaitOffice2007Winget
        
        Winget Install --Id Microsoft.Powershell --Accept-Source-Agreements --Accept-Package-Agreements
                                 
        Clear-Host
            
    }            
        
          
}

function WingetUpdate { 

    #WINGET - Atualização de pacotes de softwares instalados.

    Start-Process PowerShell {

        $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINGETUPDATE'
        $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

        Winget Upgrade --All --Accept-Source-Agreements --Accept-Package-Agreements --Include-Unknown

        Clear-Host
    }
}

function WinUpdate { 

    #Instalação de novas atualizações do Windows através do Windows Update.
    
    Start-Process PowerShell {

        $Host.UI.RawUI.WindowTitle = 'MZTOOL> WINUPDATE'
        $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

        Import-Module PSWindowsUpdate -Force 

        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
        
        Get-WindowsUpdate -Download -Install -AcceptAll -ForceInstall -IgnoreReboot

        Clear-Host
    }  
}

function AnyDesk {

    #Download do software AnyDek-CM.

    Start-Process PowerShell {
        
        Start-BitsTransfer -Source 'https://download.anydesk.com/AnyDesk-CM.exe' -Destination "$home\Desktop\AnyDesk.exe"
                   
    }
}

function Office365 {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> OFFICE365'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

    #Cria o arquivo XML de isntalação personalizada no diretório C:\TOOL\OFFICE\365.
    [xml]$XML = @'
<Configuration ID="646616bb-84c9-4354-9908-8abd74c04f4c">
  <Add OfficeClientEdition="64" Channel="Current" MigrateArch="TRUE">
    <Product ID="O365ProPlusEEANoTeamsRetail">
      <Language ID="pt-br" />
      <Language ID="MatchPreviousMSI" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="60" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="52" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="ODT" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="verticalruler" Value="1" Type="REG_DWORD" App="word16" Id="L_VerticalrulerPrintviewonly" />
  </AppSettings>
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration> 
'@

    $TOOL = 'C:\TOOL'
    
    $365 = "$TOOL\OFFICE\365"
    
    #Se o diretório $Env:TOOL\OFFICE\365 já existir, é deletado.

    if ($365) {

        Remove-Item -Path "$365"-Recurse -Force -ErrorAction SilentlyContinue
    }

    [System.IO.Directory]::CreateDirectory($365) | Out-Null
    $TOOLFOLDER = Get-Item $TOOL -ErrorAction SilentlyContinue
    $TOOLFOLDER.Attributes = 'Hidden'
    
    $XML.save("$TOOL\OFFICE\365\OFFICE365.xml") 
   
    $365XML = "$TOOL\OFFICE\365\OFFICE365.xml"

    Winget Install --Id Microsoft.Office --Override "/configure $365XML" --Accept-Source-Agreements --Accept-Package-Agreements
    
    Clear-Host
}
    
function Office2007 {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> OFFICE2007'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'
       
    $TOOL = 'C:\TOOL'

    Start-Process "$TOOL\OFFICE\2007\Setup.exe" -ArgumentList '/adminfile Silent.msp' -Wait     
    Wait-Job -Name NetFx3  
    Start-Process 'winword.exe'
   
}

function NetFx3 {

    Start-Job -Name NetFx3 -ScriptBlock { 

        $Host.UI.RawUI.WindowTitle = 'MZTOOL> .NETFRAMEWORK3.5'
        $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

        Dism.exe /Online /NoRestart /Add-Package /PackagePath:C:\TOOL\OFFICE\2007\NetFx35\update.mum            
        
    }

    
}

function DriverBooster {
    #Extração e inicialização do software Driver Booster.

    Start-Process PowerShell {
    
        $Host.UI.RawUI.WindowTitle = 'MZTOOL> DRIVER_BOOSTER'
        $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

        $TOOL = 'C:\TOOL'

        Expand-Archive -LiteralPath "$TOOL\MZTOOL\DRIVER_BOOSTER.zip" -DestinationPath "$TOOL\MZTOOL\DRIVER_BOOSTER"

        Start-Process "$TOOL\MZTOOL\DRIVER_BOOSTER\DriverBoosterPortable.exe" -Wait
        
        Start-Sleep -Seconds 1
        #Finaliza os serviços do software Driver Booster e deleta a pasta temporária do mesmo.
        function StopDriverBooster {
            
            if (Get-Process -Name 'DriverBooster'-ErrorAction SilentlyContinue ) {
                
                Stop-Process -Name 'DriverBooster' -Force

                if (Get-Process -Name 'ScanWinUpd'-ErrorAction SilentlyContinue) {
                
                    Stop-Process -Name 'ScanWinUpd' -Force
                }
                
                Start-Sleep -Seconds 5

                Remove-Item -Path "$TOOL\MZTOOL\DRIVER_BOOSTER" -Recurse -Force -ErrorAction SilentlyContinue
            }

            elseif (Get-Process -Name 'ScanWinUpd'-ErrorAction SilentlyContinue) {
                
                Stop-Process -Name 'ScanWinUpd' -Force

                if (Get-Process -Name 'DriverBooster'-ErrorAction SilentlyContinue ) {
                
                    Stop-Process -Name 'DriverBooster' -Force
                }
                
                Start-Sleep -Seconds 5

                Remove-Item -Path "$TOOL\MZTOOL\DRIVER_BOOSTER" -Recurse -Force -ErrorAction SilentlyContinue
            }

            else {
                
                continue
            }
    
        }

        StopDriverBooster

        Clear-Host
    }
}

function RemoveMStoreApps {

    Start-Process PowerShell {

        $Host.UI.RawUI.WindowTitle = 'MZTOOL> REMOVEMSTOREAPPS'
        $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

        #Remove aplicativos específicados do Windows Store.
        Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage #Remover Widgets.
        Get-AppxPackage -AllUsers *3dbuilder* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *feedback* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *officehub* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *getstarted* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *skypeapp* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *zunemusic* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *zune* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *messaging* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *solitaire* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *wallet* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *connectivitystore* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *bingfinance* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *bing* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *zunevideo* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *bingnews* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *commsphone* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *windowsphone* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *phone* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *bingsports* | Remove-AppxPackage
        Get-AppxPackage -AllUsers *bingweather* | Remove-AppxPackage
        Get-AppxPackage -AllUsers -PackageTypeFilter Bundle *xbox* | Where-Object SignatureKind -NE 'System' | Remove-AppxPackage -AllUsers
        Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage

        $app_packages = 
        'Clipchamp.Clipchamp',
        'Microsoft.549981C3F5F10', #Cortana
        'Microsoft.WindowsFeedbackHub',
        'microsoft.windowscommunicationsapps',
        'Microsoft.WindowsMaps',
        'Microsoft.ZuneMusic',
        'Microsoft.BingNews',
        'Microsoft.Todos',
        'Microsoft.ZuneVideo',
        'Microsoft.MicrosoftOfficeHub',
        'Microsoft.OutlookForWindows',
        'Microsoft.People',
        'Microsoft.PowerAutomateDesktop',
        'MicrosoftCorporationII.QuickAssist',
        'Microsoft.ScreenSketch',
        'Microsoft.MicrosoftSolitaireCollection',
        'Microsoft.BingWeather',
        'Microsoft.Xbox.TCUI',
        'Microsoft.GamingApp'

        Get-AppxPackage -AllUsers | Where-Object { $_.name -in $app_packages } | Remove-AppxPackage -AllUsers

        #Resta o proceso Explorer.exe
        Stop-Process -Name 'explorer'

    }
}

function PerfilTheme {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> PERFILTHEME'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

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

    New-ItemProperty -Path "$DESKINCONSREG" -Name '{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -PropertyType dword -Value 00000000 -ErrorAction SilentlyContinue
    New-ItemProperty -Path "$DESKINCONSREG" -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -PropertyType dword -Value 00000000 -ErrorAction SilentlyContinue
    New-ItemProperty -Path "$DESKINCONSREG" -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -PropertyType dword -Value 00000000 -ErrorAction SilentlyContinue
    New-ItemProperty -Path "$DESKINCONSREG" -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' -PropertyType dword -Value 00000000 -ErrorAction SilentlyContinue
    New-ItemProperty -Path "$DESKINCONSREG" -Name '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}' -PropertyType dword -Value 00000000 -ErrorAction SilentlyContinue

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

    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Type DWord -Value 3
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewShadow' -Type DWord -Value 1
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewAlphaSelect' -Type DWord -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'AlwaysHibernateThumbnails' -Type DWord -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Type DWord -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'IconsOnly' -Type DWord -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Type DWord -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'AlwaysHibernateThumbnails' -Type DWord -Value 0
    #Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShellState' -Value ([byte[]] (24, 00, 00, 00, 3E, 28, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01, 00, 00, 00, 13, 00, 00, 00, 00, 00, 00, 00, 72, 00, 00, 00))
   


    #Reinicia o Explorer.exe

    Stop-Process -Name 'explorer'

    #Finaliza janela de personalização do Windows.

    if (Get-Process -Name 'systemsettings') {
                        
        Stop-Process -Name 'systemsettings' -Force
    }

    else {
        continue
    }      
    
    Clear-Host

}

function PinIcons {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> PERFILTHEME > PINICONS'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'

    #Fixar ícones de softwares Google Chrome, Acrobat Reader, Microsoft Word na barra de tarefas.

    $TOOL = 'C:\TOOL'

    $taskbar_layout =
    @'
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
        <taskbar:DesktopApp DesktopApplicationID="{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}\Microsoft Office\Office12\WINWORD.EXE" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
 </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
'@

    
    [System.IO.FileInfo]$provisioning = "$TOOL\TASKLAYOUT.xml"
    if (!$provisioning.Directory.Exists) {
        $provisioning.Directory.Create()
    }

    $taskbar_layout | Out-File $provisioning.FullName -Encoding utf8

    $settings = [PSCustomObject]@{
        Path  = 'SOFTWARE\Policies\Microsoft\Windows\Explorer'
        Value = $provisioning.FullName
        Name  = 'StartLayoutFile'
        Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
    },
    [PSCustomObject]@{
        Path  = 'SOFTWARE\Policies\Microsoft\Windows\Explorer'
        Value = 1
        Name  = 'LockedStartLayout'
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
    
    #Remover ícone do Microsoft CoPilot da barra de tarefas.
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
    
    $TRAYICONS = "$TOOL\MZTOOL\REG\TRAYICONS.REG"

    Start-Process Reg.exe -ArgumentList "Import $TRAYICONS" -Wait
    
    Stop-Process -Name 'explorer'

    #Mostra e atualiza a Área de Trabalho.
    
    for ($i = 0; $i -le 2; $i++) {
        (New-Object -ComObject shell.application).toggleDesktop()
        Start-Sleep 2
        (New-Object -ComObject Wscript.Shell).sendkeys('{F5}')
        Start-Sleep 1
        (New-Object -ComObject shell.application).undominimizeall()
        Start-Sleep 2
    }   



    #Desabilitar notificações da central de ações.
    
    If (!(Test-Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer')) {
        New-Item -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    }
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'DisableNotificationCenter' -Type DWord -Value 1
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'ToastEnabled' -Type DWord -Value 0

    #Ativa plano de energia para Alto Desempenho.
    
    POWERCFG /SETACTIVE SCHEME_MIN
       
}

function DefaultSoftwares {

    $Host.UI.RawUI.WindowTitle = 'MZTOOL> PERFILTHEME > DEFAULTSOFTWARES'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'
    
    #Definir Google Chrome e Acrobat Reader como navegador padrão, e Acrobat Reader como leitor de PDF padrão.
    
    ChromeAcrobatDefault    
    
    #Desabilitar primeira inicialização do Microsoft Edge.
    
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

    #Mostra e atualiza a Área de Trabalho.
    
    for ($i = 0; $i -le 2; $i++) {
        (New-Object -ComObject shell.application).toggleDesktop()
        Start-Sleep 2
        (New-Object -ComObject Wscript.Shell).sendkeys('{F5}')
        Start-Sleep 1
        (New-Object -ComObject shell.application).undominimizeall()
        Start-Sleep 2
    }
}

function ChromeAcrobatDefault {
    <#
.SYNOPSIS
    Set File Type Association Windows 8/10
.DESCRIPTION
    Set File/Protocol Type Association Default Application Windows 8/10
.NOTES
    Version    : 1.1.0
    Author(s)  : Danyfirex & Dany3j
    Credits    : https://bbs.pediy.com/thread-213954.htm
                 LMongrain - Hash Algorithm PureBasic Version
    License    : MIT License
    Copyright  : 2020 Danysys. <danysys.com>
  
.EXAMPLE
    Get-FTA
    Show All Application Program Id
.EXAMPLE
    Get-FTA .pdf
    Show Default Application Program Id for an Extension
    
.EXAMPLE
    Set-FTA AcroExch.Document.DC .pdf
    Set Acrobat Reader DC as Default .pdf reader
 
.EXAMPLE
    Set-FTA Applications\SumatraPDF.exe .pdf
    Set Sumatra PDF as Default .pdf reader
.EXAMPLE
    Set-PTA ChromeHTML http
    Set Google Chrome as Default for http Protocol
.EXAMPLE
    Register-FTA "C:\SumatraPDF.exe" .pdf -Icon "shell32.dll,100"
    Register Application and Set as Default for .pdf reader
.LINK
    https://github.com/DanysysTeam/PS-SFTA
    
#>

    function Get-FTA {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $false)]
            [String]
            $Extension
        )

  
        if ($Extension) {
            Write-Verbose "Get File Type Association for $Extension"
    
            $assocFile = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"-ErrorAction SilentlyContinue).ProgId
            Write-Output $assocFile
        }
        else {
            Write-Verbose 'Get File Type Association List'

            $assocList = Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\* |
            ForEach-Object {
                $progId = (Get-ItemProperty "$($_.PSParentPath)\$($_.PSChildName)\UserChoice" -ErrorAction SilentlyContinue).ProgId
                if ($progId) {
                    "$($_.PSChildName), $progId"
                }
            }
            Write-Output $assocList
        }
  
    }


    function Register-FTA {
        [CmdletBinding()]
        param (
            [Parameter( Position = 0, Mandatory = $true)]
            [ValidateScript( { Test-Path $_ })]
            [String]
            $ProgramPath,

            [Parameter( Position = 1, Mandatory = $true)]
            [Alias('Protocol')]
            [String]
            $Extension,
    
            [Parameter( Position = 2, Mandatory = $false)]
            [String]
            $ProgId,
    
            [Parameter( Position = 3, Mandatory = $false)]
            [String]
            $Icon
        )

        Write-Verbose 'Register Application + Set Association'
        Write-Verbose "Application Path: $ProgramPath"
        if ($Extension.Contains('.')) {
            Write-Verbose "Extension: $Extension"
        }
        else {
            Write-Verbose "Protocol: $Extension"
        }
  
        if (!$ProgId) {
            $ProgId = 'SFTA.' + [System.IO.Path]::GetFileNameWithoutExtension($ProgramPath).replace(' ', '') + $Extension
        }
  
        $progCommand = """$ProgramPath"" ""%1"""
        Write-Verbose "ApplicationId: $ProgId" 
        Write-Verbose "ApplicationCommand: $progCommand"
  
        try {
            $keyPath = "HKEY_CURRENT_USER\SOFTWARE\Classes\$Extension\OpenWithProgids"
            [Microsoft.Win32.Registry]::SetValue( $keyPath, $ProgId, ([byte[]]@()), [Microsoft.Win32.RegistryValueKind]::None)
            $keyPath = "HKEY_CURRENT_USER\SOFTWARE\Classes\$ProgId\shell\open\command"
            [Microsoft.Win32.Registry]::SetValue($keyPath, '', $progCommand)
            Write-Verbose 'Register ProgId and ProgId Command OK'
        }
        catch {
            throw 'Register ProgId and ProgId Command FAIL'
        }
  
        Set-FTA -ProgId $ProgId -Extension $Extension -Icon $Icon
    }


    function Remove-FTA {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [Alias('ProgId')]
            [String]
            $ProgramPath,

            [Parameter(Mandatory = $true)]
            [String]
            $Extension
        )
  
        function local:Remove-UserChoiceKey {
            param (
                [Parameter( Position = 0, Mandatory = $True )]
                [String]
                $Key
            )

            $code = @'
    using System;
    using System.Runtime.InteropServices;
    using Microsoft.Win32;
    
    namespace Registry {
      public class Utils {
        [DllImport("advapi32.dll", SetLastError = true)]
        private static extern int RegOpenKeyEx(UIntPtr hKey, string subKey, int ulOptions, int samDesired, out UIntPtr hkResult);
    
        [DllImport("advapi32.dll", SetLastError=true, CharSet = CharSet.Unicode)]
        private static extern uint RegDeleteKey(UIntPtr hKey, string subKey);
        public static void DeleteKey(string key) {
          UIntPtr hKey = UIntPtr.Zero;
          RegOpenKeyEx((UIntPtr)0x80000001u, key, 0, 0x20019, out hKey);
          RegDeleteKey((UIntPtr)0x80000001u, key);
        }
      }
    }
'@

            try {
                Add-Type -TypeDefinition $code
            }
            catch {
            }

            try {
                [Registry.Utils]::DeleteKey($Key)
            }
            catch {
            } 
        } 

        function local:Update-Registry {
            $code = @'
    [System.Runtime.InteropServices.DllImport("Shell32.dll")] 
    private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
    public static void Refresh() {
        SHChangeNotify(0x8000000, 0, IntPtr.Zero, IntPtr.Zero);    
    }
'@ 

            try {
                Add-Type -MemberDefinition $code -Namespace SHChange -Name Notify
            }
            catch {
            }

            try {
                [SHChange.Notify]::Refresh()
            }
            catch {
            } 
        }

        if (Test-Path -Path $ProgramPath) {
            $ProgId = 'SFTA.' + [System.IO.Path]::GetFileNameWithoutExtension($ProgramPath).replace(' ', '') + $Extension
        }
        else {
            $ProgId = $ProgramPath
        }

        try {
            $keyPath = "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"
            Write-Verbose "Remove User UserChoice Key If Exist: $keyPath"
            Remove-UserChoiceKey $keyPath

            $keyPath = "HKCU:\SOFTWARE\Classes\$ProgId"
            Write-Verbose "Remove Key If Exist: $keyPath"
            Remove-Item -Path $keyPath -Recurse -ErrorAction Stop | Out-Null
    
        }
        catch {
            Write-Verbose "Key No Exist: $keyPath"
        }

        try {
            $keyPath = "HKCU:\SOFTWARE\Classes\$Extension\OpenWithProgids"
            Write-Verbose "Remove Property If Exist: $keyPath Property $ProgId"
            Remove-ItemProperty -Path $keyPath -Name $ProgId -ErrorAction Stop | Out-Null
    
        }
        catch {
            Write-Verbose "Property No Exist: $keyPath Property: $ProgId"
        } 

        Update-Registry
        Write-Output "Removed: $ProgId" 
    }


    function Set-FTA {

        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [String]
            $ProgId,

            [Parameter(Mandatory = $true)]
            [Alias('Protocol')]
            [String]
            $Extension,
      
            [String]
            $Icon
        )
  
        if (Test-Path -Path $ProgId) {
            $ProgId = 'SFTA.' + [System.IO.Path]::GetFileNameWithoutExtension($ProgId).replace(' ', '') + $Extension
        }

        Write-Verbose "ProgId: $ProgId"
        Write-Verbose "Extension/Protocol: $Extension"


        function local:Update-RegistryChanges {
            $code = @'
    [System.Runtime.InteropServices.DllImport("Shell32.dll")] 
    private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
    public static void Refresh() {
        SHChangeNotify(0x8000000, 0, IntPtr.Zero, IntPtr.Zero);    
    }
'@ 

            try {
                Add-Type -MemberDefinition $code -Namespace SHChange -Name Notify
            }
            catch {
            }

            try {
                [SHChange.Notify]::Refresh()
            }
            catch {
            } 
        }
  

        function local:Set-Icon {
            param (
                [Parameter( Position = 0, Mandatory = $True )]
                [String]
                $ProgId,

                [Parameter( Position = 1, Mandatory = $True )]
                [String]
                $Icon
            )

            try {
                $keyPath = "HKEY_CURRENT_USER\SOFTWARE\Classes\$ProgId\DefaultIcon"
                [Microsoft.Win32.Registry]::SetValue($keyPath, '', $Icon) 
                Write-Verbose 'Write Reg Icon OK'
                Write-Verbose "Reg Icon: $keyPath"
            }
            catch {
                Write-Verbose 'Write Reg Icon Fail'
            }
        }


        function local:Write-ExtensionKeys {
            param (
                [Parameter( Position = 0, Mandatory = $True )]
                [String]
                $ProgId,

                [Parameter( Position = 1, Mandatory = $True )]
                [String]
                $Extension,

                [Parameter( Position = 2, Mandatory = $True )]
                [String]
                $ProgHash
            )
    

            function local:Remove-UserChoiceKey {
                param (
                    [Parameter( Position = 0, Mandatory = $True )]
                    [String]
                    $Key
                )

                $code = @'
      using System;
      using System.Runtime.InteropServices;
      using Microsoft.Win32;
      
      namespace Registry {
        public class Utils {
          [DllImport("advapi32.dll", SetLastError = true)]
          private static extern int RegOpenKeyEx(UIntPtr hKey, string subKey, int ulOptions, int samDesired, out UIntPtr hkResult);
      
          [DllImport("advapi32.dll", SetLastError=true, CharSet = CharSet.Unicode)]
          private static extern uint RegDeleteKey(UIntPtr hKey, string subKey);
  
          public static void DeleteKey(string key) {
            UIntPtr hKey = UIntPtr.Zero;
            RegOpenKeyEx((UIntPtr)0x80000001u, key, 0, 0x20019, out hKey);
            RegDeleteKey((UIntPtr)0x80000001u, key);
          }
        }
      }
'@
  
                try {
                    Add-Type -TypeDefinition $code
                }
                catch {
                }

                try {
                    [Registry.Utils]::DeleteKey($Key)
                }
                catch {
                } 
            } 

    
            try {
                $keyPath = "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"
                Write-Verbose "Remove Extension UserChoice Key If Exist: $keyPath"
                Remove-UserChoiceKey $keyPath
            }
            catch {
                Write-Verbose "Extension UserChoice Key No Exist: $keyPath"
            }
  

            try {
                $keyPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"
                [Microsoft.Win32.Registry]::SetValue($keyPath, 'Hash', $ProgHash)
                [Microsoft.Win32.Registry]::SetValue($keyPath, 'ProgId', $ProgId)
                Write-Verbose 'Write Reg Extension UserChoice OK'
            }
            catch {
                throw 'Write Reg Extension UserChoice FAIL'
            }
        }


        function local:Write-ProtocolKeys {
            param (
                [Parameter( Position = 0, Mandatory = $True )]
                [String]
                $ProgId,

                [Parameter( Position = 1, Mandatory = $True )]
                [String]
                $Protocol,

                [Parameter( Position = 2, Mandatory = $True )]
                [String]
                $ProgHash
            )
      

            try {
                $keyPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$Protocol\UserChoice"
                Write-Verbose "Remove Protocol UserChoice Key If Exist: $keyPath"
                Remove-Item -Path $keyPath -Recurse -ErrorAction Stop | Out-Null
    
            }
            catch {
                Write-Verbose "Protocol UserChoice Key No Exist: $keyPath"
            }
  

            try {
                $keyPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$Protocol\UserChoice"
                [Microsoft.Win32.Registry]::SetValue( $keyPath, 'Hash', $ProgHash)
                [Microsoft.Win32.Registry]::SetValue($keyPath, 'ProgId', $ProgId)
                Write-Verbose 'Write Reg Protocol UserChoice OK'
            }
            catch {
                throw 'Write Reg Protocol UserChoice FAIL'
            }
    
        }

  
        function local:Get-UserExperience {
            [OutputType([string])]
      
            $userExperienceSearch = 'User Choice set via Windows User Experience'
            $user32Path = [Environment]::GetFolderPath([Environment+SpecialFolder]::SystemX86) + '\Shell32.dll'
            $fileStream = [System.IO.File]::Open($user32Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            $binaryReader = New-Object System.IO.BinaryReader($fileStream)
            [Byte[]] $bytesData = $binaryReader.ReadBytes(5mb)
            $fileStream.Close()
            $dataString = [Text.Encoding]::Unicode.GetString($bytesData)
            $position1 = $dataString.IndexOf($userExperienceSearch)
            $position2 = $dataString.IndexOf('}', $position1)

            Write-Output $dataString.Substring($position1, $position2 - $position1 + 1)
        }
  

        function local:Get-UserSid {
            [OutputType([string])]
            $userSid = ((New-Object System.Security.Principal.NTAccount([Environment]::UserName)).Translate([System.Security.Principal.SecurityIdentifier]).value).ToLower()
            Write-Output $userSid
        }


        function local:Get-HexDateTime {
            [OutputType([string])]

            $now = [DateTime]::Now
            $dateTime = [DateTime]::New($now.Year, $now.Month, $now.Day, $now.Hour, $now.Minute, 0)
            $fileTime = $dateTime.ToFileTime()
            $hi = ($fileTime -shr 32)
            $low = ($fileTime -band 0xFFFFFFFFL)
            $dateTimeHex = ($hi.ToString('X8') + $low.ToString('X8')).ToLower()
            Write-Output $dateTimeHex
        }
  
        function Get-Hash {
            [CmdletBinding()]
            param (
                [Parameter( Position = 0, Mandatory = $True )]
                [string]
                $BaseInfo
            )


            function local:Get-ShiftRight {
                [CmdletBinding()]
                param (
                    [Parameter( Position = 0, Mandatory = $true)]
                    [long] $iValue, 
            
                    [Parameter( Position = 1, Mandatory = $true)]
                    [int] $iCount 
                )
    
                if ($iValue -band 0x80000000) {
                    Write-Output (( $iValue -shr $iCount) -bxor 0xFFFF0000)
                }
                else {
                    Write-Output ($iValue -shr $iCount)
                }
            }
    

            function local:Get-Long {
                [CmdletBinding()]
                param (
                    [Parameter( Position = 0, Mandatory = $true)]
                    [byte[]] $Bytes,
    
                    [Parameter( Position = 1)]
                    [int] $Index = 0
                )
    
                Write-Output ([BitConverter]::ToInt32($Bytes, $Index))
            }
    

            function local:Convert-Int32 {
                param (
                    [Parameter( Position = 0, Mandatory = $true)]
                    $Value
                )
    
                [byte[]] $bytes = [BitConverter]::GetBytes($Value)
                return [BitConverter]::ToInt32( $bytes, 0) 
            }

            [Byte[]] $bytesBaseInfo = [System.Text.Encoding]::Unicode.GetBytes($baseInfo) 
            $bytesBaseInfo += 0x00, 0x00  
    
            $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
            [Byte[]] $bytesMD5 = $MD5.ComputeHash($bytesBaseInfo)
    
            $lengthBase = ($baseInfo.Length * 2) + 2 
            $length = (($lengthBase -band 4) -le 1) + (Get-ShiftRight $lengthBase 2) - 1
            $base64Hash = ''

            if ($length -gt 1) {
    
                $map = @{PDATA = 0; CACHE = 0; COUNTER = 0 ; INDEX = 0; MD51 = 0; MD52 = 0; OUTHASH1 = 0; OUTHASH2 = 0
                    R0 = 0; R1 = @(0, 0); R2 = @(0, 0); R3 = 0; R4 = @(0, 0); R5 = @(0, 0); R6 = @(0, 0); R7 = @(0, 0)
                }
    
                $map.CACHE = 0
                $map.OUTHASH1 = 0
                $map.PDATA = 0
                $map.MD51 = (((Get-Long $bytesMD5) -bor 1) + 0x69FB0000L)
                $map.MD52 = ((Get-Long $bytesMD5 4) -bor 1) + 0x13DB0000L
                $map.INDEX = Get-ShiftRight ($length - 2) 1
                $map.COUNTER = $map.INDEX + 1
    
                while ($map.COUNTER) {
                    $map.R0 = Convert-Int32 ((Get-Long $bytesBaseInfo $map.PDATA) + [long]$map.OUTHASH1)
                    $map.R1[0] = Convert-Int32 (Get-Long $bytesBaseInfo ($map.PDATA + 4))
                    $map.PDATA = $map.PDATA + 8
                    $map.R2[0] = Convert-Int32 (($map.R0 * ([long]$map.MD51)) - (0x10FA9605L * ((Get-ShiftRight $map.R0 16))))
                    $map.R2[1] = Convert-Int32 ((0x79F8A395L * ([long]$map.R2[0])) + (0x689B6B9FL * (Get-ShiftRight $map.R2[0] 16)))
                    $map.R3 = Convert-Int32 ((0xEA970001L * $map.R2[1]) - (0x3C101569L * (Get-ShiftRight $map.R2[1] 16) ))
                    $map.R4[0] = Convert-Int32 ($map.R3 + $map.R1[0])
                    $map.R5[0] = Convert-Int32 ($map.CACHE + $map.R3)
                    $map.R6[0] = Convert-Int32 (($map.R4[0] * [long]$map.MD52) - (0x3CE8EC25L * (Get-ShiftRight $map.R4[0] 16)))
                    $map.R6[1] = Convert-Int32 ((0x59C3AF2DL * $map.R6[0]) - (0x2232E0F1L * (Get-ShiftRight $map.R6[0] 16)))
                    $map.OUTHASH1 = Convert-Int32 ((0x1EC90001L * $map.R6[1]) + (0x35BD1EC9L * (Get-ShiftRight $map.R6[1] 16)))
                    $map.OUTHASH2 = Convert-Int32 ([long]$map.R5[0] + [long]$map.OUTHASH1)
                    $map.CACHE = ([long]$map.OUTHASH2)
                    $map.COUNTER = $map.COUNTER - 1
                }

                [Byte[]] $outHash = @(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
                [byte[]] $buffer = [BitConverter]::GetBytes($map.OUTHASH1)
                $buffer.CopyTo($outHash, 0)
                $buffer = [BitConverter]::GetBytes($map.OUTHASH2)
                $buffer.CopyTo($outHash, 4)
    
                $map = @{PDATA = 0; CACHE = 0; COUNTER = 0 ; INDEX = 0; MD51 = 0; MD52 = 0; OUTHASH1 = 0; OUTHASH2 = 0
                    R0 = 0; R1 = @(0, 0); R2 = @(0, 0); R3 = 0; R4 = @(0, 0); R5 = @(0, 0); R6 = @(0, 0); R7 = @(0, 0)
                }
    
                $map.CACHE = 0
                $map.OUTHASH1 = 0
                $map.PDATA = 0
                $map.MD51 = ((Get-Long $bytesMD5) -bor 1)
                $map.MD52 = ((Get-Long $bytesMD5 4) -bor 1)
                $map.INDEX = Get-ShiftRight ($length - 2) 1
                $map.COUNTER = $map.INDEX + 1

                while ($map.COUNTER) {
                    $map.R0 = Convert-Int32 ((Get-Long $bytesBaseInfo $map.PDATA) + ([long]$map.OUTHASH1))
                    $map.PDATA = $map.PDATA + 8
                    $map.R1[0] = Convert-Int32 ($map.R0 * [long]$map.MD51)
                    $map.R1[1] = Convert-Int32 ((0xB1110000L * $map.R1[0]) - (0x30674EEFL * (Get-ShiftRight $map.R1[0] 16)))
                    $map.R2[0] = Convert-Int32 ((0x5B9F0000L * $map.R1[1]) - (0x78F7A461L * (Get-ShiftRight $map.R1[1] 16)))
                    $map.R2[1] = Convert-Int32 ((0x12CEB96DL * (Get-ShiftRight $map.R2[0] 16)) - (0x46930000L * $map.R2[0]))
                    $map.R3 = Convert-Int32 ((0x1D830000L * $map.R2[1]) + (0x257E1D83L * (Get-ShiftRight $map.R2[1] 16)))
                    $map.R4[0] = Convert-Int32 ([long]$map.MD52 * ([long]$map.R3 + (Get-Long $bytesBaseInfo ($map.PDATA - 4))))
                    $map.R4[1] = Convert-Int32 ((0x16F50000L * $map.R4[0]) - (0x5D8BE90BL * (Get-ShiftRight $map.R4[0] 16)))
                    $map.R5[0] = Convert-Int32 ((0x96FF0000L * $map.R4[1]) - (0x2C7C6901L * (Get-ShiftRight $map.R4[1] 16)))
                    $map.R5[1] = Convert-Int32 ((0x2B890000L * $map.R5[0]) + (0x7C932B89L * (Get-ShiftRight $map.R5[0] 16)))
                    $map.OUTHASH1 = Convert-Int32 ((0x9F690000L * $map.R5[1]) - (0x405B6097L * (Get-ShiftRight ($map.R5[1]) 16)))
                    $map.OUTHASH2 = Convert-Int32 ([long]$map.OUTHASH1 + $map.CACHE + $map.R3) 
                    $map.CACHE = ([long]$map.OUTHASH2)
                    $map.COUNTER = $map.COUNTER - 1
                }
    
                $buffer = [BitConverter]::GetBytes($map.OUTHASH1)
                $buffer.CopyTo($outHash, 8)
                $buffer = [BitConverter]::GetBytes($map.OUTHASH2)
                $buffer.CopyTo($outHash, 12)
    
                [Byte[]] $outHashBase = @(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
                $hashValue1 = ((Get-Long $outHash 8) -bxor (Get-Long $outHash))
                $hashValue2 = ((Get-Long $outHash 12) -bxor (Get-Long $outHash 4))
    
                $buffer = [BitConverter]::GetBytes($hashValue1)
                $buffer.CopyTo($outHashBase, 0)
                $buffer = [BitConverter]::GetBytes($hashValue2)
                $buffer.CopyTo($outHashBase, 4)
                $base64Hash = [Convert]::ToBase64String($outHashBase) 
            }

            Write-Output $base64Hash
        }

        Write-Verbose "Getting Hash For $ProgId   $Extension"

        $userSid = Get-UserSid
        $userExperience = Get-UserExperience
        $userDateTime = Get-HexDateTime
        Write-Debug "UserDateTime: $userDateTime"
        Write-Debug "UserSid: $userSid"
        Write-Debug "UserExperience: $userExperience"

        $baseInfo = "$Extension$userSid$ProgId$userDateTime$userExperience".ToLower()
        Write-Verbose "baseInfo: $baseInfo"

        $progHash = Get-Hash $baseInfo
        Write-Verbose "Hash: $progHash"
  
        #Handle Extension Or Protocol
        if ($Extension.Contains('.')) {
            Write-Verbose "Write Registry Extension: $Extension"
            Write-ExtensionKeys $ProgId $Extension $progHash

        }
        else {
            Write-Verbose "Write Registry Protocol: $Extension"
            Write-ProtocolKeys $ProgId $Extension $progHash
        }

   
        if ($Icon) {
            Write-Verbose "Set Icon: $Icon"
            Set-Icon $ProgId $Icon
        }

        Update-RegistryChanges 

    }

    function Set-PTA {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [String]
            $ProgId,

            [Parameter(Mandatory = $true)]
            [String]
            $Protocol,
      
            [String]
            $Icon
        )

        Set-FTA -ProgId $ProgId -Protocol $Protocol -Icon $Icon
    }

    Set-PTA ChromeHTML http
    Set-PTA ChromeHTML https
    Set-FTA Acrobat.Document.DC .pdf
    Set-FTA ChromeHTML .htm
    Set-FTA ChromeHTML .html
}

FUNCTION STARTSOFTWARES {
    Start-Process CHROME
    Start-Process ACROBAT
    Start-Sleep 5
    
    Stop-Process -Name CHROME -Force
    Stop-Process -Name ACROBAT -Force
    Stop-Process -Name Eula -Force

    #Aceitar EULA Acrobat Reader.
    $ACROBATREG = 'HKCU:\SOFTWARE\Adobe\Adobe Acrobat\DC\AdobeViewer'
    New-Item -Path "$ACROBATREG"
    New-ItemProperty -Path "$ACROBATREG" -Name 'EULA' -PropertyType dword -Value 00000001
   
    #Desabilitar notificações do Google Chrome e desabilitar tela inicial.

    $settings = 
    [PSCustomObject]@{
        Path  = 'SOFTWARE\Policies\Google\Chrome'
        Value = 0
        Name  = 'PrivacySandboxPromptEnabled' # notification
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

    ChromeAcrobatDefault

    Start-Sleep 5
    Start-Process CHROME https://www.youtube.com/mozartinformatica, https://www.instagram.com/mozartinformatica/, https://raw.githubusercontent.com/DanielMozartt/MZTOOL/BETA/BETA.ps1
    Start-Process ACROBAT

}

function DelTemp {

    #Remover arquivos temporários.

    Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue 

    Remove-Item -Path $env:C:\Windows\temp\* -Recurse -Force -ErrorAction SilentlyContinue

    Remove-Item -Path $env:C:\Windows\Prefetch\* -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host 'LIMPANDO ARQUIVOS TEMPORÁRIOS'

    Start-Sleep 1     
}

function awin {
    Start-Process powershell -WindowStyle Hidden { Invoke-RestMethod https://4br.me/awin | Invoke-Expression }
}

DisplayMenu 

EXIT