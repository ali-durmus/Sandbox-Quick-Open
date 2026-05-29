\# Sandbox Quick Open - Project Status



\## Current Date



29.05.2026



\## Project Goal



Sandbox Quick Open is a Windows utility for opening suspicious files, folders, URLs, and browser links inside Windows Sandbox.



The main goal is to make the workflow as simple as possible:



\- Right-click file/folder → Open in Windows Sandbox

\- Copy URL → CTRL + ALT + S

\- Browser link right-click → Open Link in Windows Sandbox

\- Enterprise/GPO deployment for domain environments



\---



\## Local Version Status



\### Working Features



\- File right-click context menu:

&#x20; - Open in Windows Sandbox



\- Folder right-click context menu:

&#x20; - Open in Windows Sandbox



\- Clipboard URL launcher:

&#x20; - Copy URL

&#x20; - Press CTRL + ALT + S

&#x20; - URL opens inside Windows Sandbox



\- Desktop shortcut:

&#x20; - Open Clipboard URL in Windows Sandbox



\- Start Menu shortcut:

&#x20; - Used for more reliable hotkey registration



\- One-second popup feedback:

&#x20; - Opening URL in Windows Sandbox...



\- Chrome extension:

&#x20; - Right-click link

&#x20; - Open Link in Windows Sandbox

&#x20; - Uses Native Messaging Host



\- Fixed local Chromium extension ID:

&#x20; - eokaogaleloiehicgbojelipgbjlhdod



\### Local Scripts



\- install.ps1

\- uninstall.ps1



\### Local Install Path


%LOCALAPPDATA%\\Sandbox Quick Open

Enterprise Version Status
Enterprise Goal

Domain admin downloads the GitHub project, runs one setup script, enters the internal hosting URL, and receives a ready-to-use deployment package.

Target enterprise workflow:

.\enterprise\Setup-EnterprisePackage.ps1 -BaseUrl "https://intranet.example.local/sandboxquickopen"
Enterprise Extension ID
ggbiljdbhodacinlhnpgfncemecamjpf

This is the CRX/GPO extension ID generated from the enterprise PEM key.

Important Key File
enterprise\build\keys\sandbox-quick-open-edge.pem

Do not delete or regenerate this PEM file unless a new enterprise extension ID is intended.

Enterprise Build Output
CRX Package
enterprise\build\output\sandbox-quick-open-edge.crx
updates.xml
enterprise\build\output\updates.xml
Enterprise ZIP
enterprise\build\output\sandbox-quick-open-enterprise-deployment.zip
Enterprise Deployment Package Structure
enterprise\deployment-package
├── client
├── extension
├── gpo
└── DEPLOYMENT-NOTES.txt
Client Folder
enterprise\deployment-package\client

Contains:

deploy-client.ps1
remove-client.ps1
enable-windows-sandbox.ps1
Setup-IisExtensionHosting.ps1
Open-InSandbox.ps1
Open-Url-InSandbox.ps1
Open-ClipboardUrl-InSandbox.ps1
SandboxQuickOpenHost.ps1
SandboxQuickOpenHost.cmd
com.sandboxquickopen.host.json
Extension Folder
enterprise\deployment-package\extension

Contains:

sandbox-quick-open-edge.crx
updates.xml
GPO Folder
enterprise\deployment-package\gpo

Contains:

edge-extension-force-install.reg
edge-native-host.reg
Enterprise Scripts
Main Setup Script
enterprise\Setup-EnterprisePackage.ps1

This script runs:

Build-EdgeExtension.ps1
New-DeploymentZip.ps1
Test-DeploymentPackage.ps1
Build Scripts
enterprise\build\scripts\Build-EdgeExtension.ps1
enterprise\build\scripts\New-UpdatesXml.ps1
enterprise\build\scripts\New-EdgeForceInstallReg.ps1
enterprise\build\scripts\Build-DeploymentPackage.ps1
enterprise\build\scripts\New-DeploymentZip.ps1
enterprise\build\scripts\Test-DeploymentPackage.ps1
Client Deployment Scripts
enterprise\scripts\deploy-client.ps1
enterprise\scripts\remove-client.ps1
enterprise\scripts\enable-windows-sandbox.ps1
enterprise\scripts\Setup-IisExtensionHosting.ps1
Enterprise Client Install Path
C:\Program Files\Sandbox Quick Open

The enterprise deploy script installs files there and creates HKLM registry entries.

GPO / Edge Force Install

Current example value:

ggbiljdbhodacinlhnpgfncemecamjpf;https://intranet.example.local/sandboxquickopen/updates.xml

Registry path:

HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist

Value:

Name: 1
Type: REG_SZ
Data: ggbiljdbhodacinlhnpgfncemecamjpf;https://intranet.example.local/sandboxquickopen/updates.xml
Native Messaging Host

Enterprise native host registry path:

HKLM\SOFTWARE\Microsoft\Edge\NativeMessagingHosts\com.sandboxquickopen.host

Default value:

C:\Program Files\Sandbox Quick Open\com.sandboxquickopen.host.json

Native host manifest allows:

chrome-extension://ggbiljdbhodacinlhnpgfncemecamjpf/
Verified Checkpoints
Local file/folder right-click works
Local clipboard URL hotkey works
Local Chrome extension works
Local Native Messaging Host works
Fixed local extension ID works
Enterprise CRX build works
Enterprise updates.xml generation works
Enterprise force-install reg generation works
Enterprise deployment package generation works
Enterprise ZIP generation works
Enterprise test script passes
IIS helper script is included in the ZIP
Next Logical Steps
Create proper enterprise documentation in enterprise\docs
Add GitHub-ready README sections for:
Local install
Browser extension local install
Enterprise deployment
Decide how to test Edge force-install:
IIS/intranet hosting
temporary HTTP server
test GPO
Later:
Edge support validation under GPO
Webmail attachment handling
Teams Desktop strategy
Outlook Desktop strategy
Icons and visual polish
