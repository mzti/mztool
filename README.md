![image](https://github.com/user-attachments/assets/c00c49c6-f4a9-4b0e-9ce3-7f8327387e45)

## FUNCIONALIDADES

- 1 - Implementação automatizada:

      Módulos e Gerenciador de pacotes (MSIX, NuGet): Implementação, atualização e auto-reparo do Winget e PSWindowsUpdate.
      
      Softwares (Winget): Adobe Acrobat Reader, Google Chrome, Microsoft 365, Powershell, AnyDesk.

      Atualizações (PSWindowsUpdate): Remoção de drivers de dispositivo não utilizados pelo sistema atualmente (Dispositivos Ocultos) e Implementação e Atualização de novos e atuais Drivers de Dispositivo e Atualizações do Windows Update.
      
      Personalização do Perfil de Usuário (Regedit, XML, Appx): Tema, Ícones da Área de Trabalho e Barra de Tarefas, Remoção de Widgets, Remoção de Bloatwares, Remoção do Microsoft Copilot, Remoção de Ícones Visão de Tarefas e Notícias, Remoção de notificações da Central de Ações, Define o Google Chrome como navegador padrão e o Acrobat Reader como leitor de PDF padrão.

![image](https://github.com/user-attachments/assets/f8fd0c6a-13ae-4216-8119-5958d63c12b1)

- 2 - Download, extração e execução automatizada em nuvem AWS (CloudFront) de softwares standalone para monitoramento e diagnóstico de hardwares. 
      
      HDSentinel, AIDA64, CPUZ, BlueScreenView, Core Temp, Crystal Disk Info, HWInfo, GPUZ.

 ![image](https://github.com/user-attachments/assets/07a41ae4-6b9b-40c1-a76d-c82c6558bac2)
  
- 3 - Atualização automatizada de softwares e drivers através do Winget e Módulo Windows Update.

 ![image](https://github.com/user-attachments/assets/25ab021f-24b4-4f17-b77b-3e345f887a12)

- 4 - Implementação automatizada de diferentes versões do Pacote Office e Microsoft 365 com instalação personalizada via XML.

![image](https://github.com/user-attachments/assets/52044d82-b57d-4df7-b62d-aea413c67416)


## COMO USAR A FERRAMENTA 
### EM UM AMBIENTE WINDOWS
### COLE O CÓDIGO NA CAIXA EXECUTAR EM UMA SESSÃO POWERSHELL OU WINDOWS TERMINAL COM POWERSHELL.
```PowerShell
irm https://bit.ly/MZT00L | iex
```
![image](https://github.com/user-attachments/assets/866ad246-5419-45ba-9e62-993e9ea14ba4)

### OU, APERTE A COMBINAÇÃO DE TECLAS "WINDOWS + R" E COLE O CÓDIGO ABAIXO NA CAIXA EXECUTAR. 
(Em novas atualizaçõeos do Windows Defender este método pode identificar um Falso Positivo.)
```PowerShell
PowerShell irm https://bit.ly/MZT00L | iex
```
![image](https://github.com/user-attachments/assets/f7bc4572-3880-4bc8-a0de-9c9dcdd28040)



## DEMONSTRAÇÃO



https://github.com/user-attachments/assets/959a14dc-1a25-4350-be1d-6e704cc257ed



VÍDEO SEM EDIÇOES - https://www.youtube.com/watch?v=w7V6YisqsB4

## VARIÁVEIS DE AMBIENTE

Após a primeira execução da ferramenta, é instalada uma variável de ambiente no escopo user que armazena o código acima e logo é possível executar a ferramenta com a variável a partir de então:

```PowerShell
%MZTOOL%
```

![image](https://github.com/user-attachments/assets/d8d3f908-6fcd-407a-8115-502a9e018f93)


### COMPATIBILIDADE 

Windows 10 X64 & X86, Windows 11.
*Versões anteriores ao Windows 10 não são compatíves.

PowerShell 5.1.0 ou superior.
