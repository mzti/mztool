![image](https://github.com/DanielMozartt/MZTOOL/blob/MZTOOL/PNG/MENU.png?raw=true)
![image](https://github.com/DanielMozartt/MZTOOL/blob/MZTOOL/PNG/WINGET%20%25%20WINUPDATE.png?raw=true)

## FUNCIONALIDADES

- 1 - Implementação automatizada:

      Módulos e Gerenciador de pacotes (MSIX, NuGet): Implementação, atualização e auto-reparo do Winget e PSWindowsUpdate.
      
      Softwares (Winget): Adobe Acrobat Reader, Google Chrome, Microsoft 365, Powershell, AnyDesk.

      Atualizações (PSWindowsUpdate): Remoção de drivers de dispositivo não utilizados pelo sistema atualmente (Dispositivos Ocultos) e Implementação e Atualização de novos e atuais Drivers de Dispositivo e Atualizações do Windows Update.
      
      Personalização do Perfil de Usuário (Regedit, XML, Appx): Tema, Ícones da Área de Trabalho e Barra de Tarefas, Remoção de Widgets, Remoção de Bloatwares, Remoção do Microsoft Copilot, Remoção de Ícones Visão de Tarefas e Notícias, Remoção de notificações da Central de Ações, Define o Google Chrome como navegador padrão e o Acrobat Reader como leitor de PDF padrão.

- 2 - Download e execução standalone automatizada em nuvem de softwares para monitoramento e diagnóstico de hardwares. 
      
      HDSentinel, AIDA64, CPUZ, BlueScreenView, Core Temp, Crystal Disk Info, HWInfo, GPUZ.
- 3 - Atualização automátizada de softwares e drivers através do Winget e Módulo Windows Update.
- 4 - Implementação automatizada de diferentes versões do Pacote Office e Microsoft 365.


## COMO USAR A FERRAMENTA 
### EM UM AMBIENTE WINDOWS, APERTE A COMBINAÇÃO DE TECLAS "WINDOWS + R" E COLE O CÓDIGO NA CAIXA EXECUTAR.
```PowerShell
PowerShell irm https://bit.ly/MZT00L | iex
```

![image](https://github.com/DanielMozartt/MZTOOL/blob/MZTOOL/PNG/EXECUTAR.png?raw=true)

### OU COLE O CÓDIGO NA CAIXA EXECUTAR EM UMA SESSÃO POWERSHELL OU WINDOWS TERMINAL COM POWERSHELL.
```PowerShell
irm https://bit.ly/MZT00L | iex
```


## DEMONSTRAÇÃO



https://github.com/user-attachments/assets/959a14dc-1a25-4350-be1d-6e704cc257ed



VÍDEO SEM EDIÇOES - https://www.youtube.com/watch?v=w7V6YisqsB4

## VARIÁVEIS DE AMBIENTE

Após a primeira execução da ferramenta, é instalada uma variável de ambiente global que armazena o código acima e logo é possível executar a ferramenta com a variável a partir de então:

```PowerShell
%MZTOOL%
```

![image](https://github.com/DanielMozartt/MZTOOL/blob/MZTOOL/PNG/ENVTOOL.png?raw=true)

### COMPATIBILIDADE 

Windows 10 X64 & X86, Windows 11.
*Versões anteriores ao Windows 10 não são compatíves.

PowerShell 5.1.0 ou superior.