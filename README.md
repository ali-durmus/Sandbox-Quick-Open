# Sandbox Quick Open

Sandbox Quick Open is a small Windows utility for opening suspicious files, folders, and URLs inside **Windows Sandbox**.

The main goal is simple:

Instead of opening unknown files or links directly on the host system, open them quickly inside an isolated Windows Sandbox environment.

This project currently supports both:

- Local installation on a single Windows machine
- Enterprise/domain deployment with Microsoft Edge, Group Policy, IIS, and Native Messaging Host

---

## Project Goal

In daily IT work, we often need to inspect files or links that we do not fully trust.

Examples:

- Unknown installers
- ZIP archives
- PDF or Office documents
- Scripts
- Links from email or webmail
- Download links
- Files received from external sources

Windows Sandbox is already a useful isolated environment, but opening it manually and copying files or URLs into it is not very convenient.

Sandbox Quick Open makes this workflow faster by adding right-click menu options, URL shortcuts, and browser integration.

---

## Features

### File and Folder Support

Sandbox Quick Open adds a Windows right-click menu entry:

```text
Open in Windows Sandbox
```

Supported items include, for example:

- EXE
- MSI
- ZIP
- PDF
- DOCX
- XLSX
- TXT
- CSV
- Folders
- Other file types

When a file or folder is selected, the tool creates a temporary working folder and opens the selected item inside Windows Sandbox.

Inside the Sandbox, the content is available under:

```text
Desktop\SandboxWork
```

---

### Clipboard URL Support

You can copy an HTTP or HTTPS URL and open it inside Windows Sandbox.

The installer creates a desktop shortcut:

```text
Open Clipboard URL in Windows Sandbox
```

It also creates a hotkey:

```text
CTRL + ALT + S
```

Typical use cases:

- Copy a suspicious URL from an email
- Copy a link from webmail
- Copy a download URL
- Copy a link from a PDF or Office document
- Press the shortcut or use the desktop shortcut
- Open the URL inside Windows Sandbox

Note:

If the `CTRL + ALT + S` hotkey does not work immediately after installation, restart Windows Explorer or sign out and sign in again. Windows sometimes caches shortcut hotkeys.

---

### Browser Link Support

Sandbox Quick Open includes a Chromium-based browser extension.

The extension adds a browser right-click menu item:

```text
Open Link in Windows Sandbox
```

When the user right-clicks a link in the browser and selects this option, the extension sends the URL to the local Native Messaging Host.

The Native Messaging Host then starts the PowerShell URL script, and the URL is opened inside Windows Sandbox.

---

## Repository Structure

Important folders and files:

```text
README.md
PROJECT-STATUS.md
install.ps1
uninstall.ps1

src/
  Open-InSandbox.ps1
  Open-Url-InSandbox.ps1
  Open-ClipboardUrl-InSandbox.ps1

native-host/
  SandboxQuickOpenHost.ps1
  SandboxQuickOpenHost.cmd
  com.sandboxquickopen.host.json

browser-extension/chromium/
  manifest.json
  background.js

enterprise/
  Setup-EnterprisePackage.ps1
  enterprise-config.ps1

enterprise/scripts/
  deploy-client.ps1
  remove-client.ps1
  enable-windows-sandbox.ps1
  Setup-IisExtensionHosting.ps1

enterprise/gpo/
  com.sandboxquickopen.host.json
  edge-native-host.reg
  edge-extension-force-install.reg

enterprise/build/scripts/
  Build-EdgeExtension.ps1
  New-UpdatesXml.ps1
  New-EdgeForceInstallReg.ps1
  Build-DeploymentPackage.ps1
  New-DeploymentZip.ps1
  Test-DeploymentPackage.ps1
  Get-CrxExtensionId.ps1
```

Generated folders are excluded from GitHub:

```text
enterprise/build/keys/
enterprise/build/output/
enterprise/deployment-package/
```

These folders may contain generated packages, private keys, or deployment outputs and should not be committed to the repository.

---

## Requirements

### General Requirements

- Windows 10/11 Pro, Enterprise, or Education
- Windows Sandbox support
- Virtualization enabled in BIOS/UEFI
- Windows PowerShell
- Microsoft Edge or Google Chrome for browser integration

### Windows Sandbox Feature

Windows Sandbox must be enabled.

You can enable it from:

```text
Turn Windows features on or off > Windows Sandbox
```

Or with PowerShell:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All
```

A restart may be required.

To check the feature state:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM
```

Expected state:

```text
Enabled
```

---

# Local Installation

Use this method if you want to install Sandbox Quick Open on a single local Windows machine.

---

## Local Installation Steps

Download or clone the repository.

If Git is installed:

```powershell
git clone https://github.com/ali-durmus/Sandbox-Quick-Open.git
cd Sandbox-Quick-Open
```

Alternatively, download the repository as ZIP from GitHub:

```text
Code > Download ZIP
```

Then open PowerShell in the project folder and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\install.ps1
```

The installer copies the required files to:

```text
%LOCALAPPDATA%\Sandbox Quick Open
```

It also creates:

- File right-click menu entry
- Folder right-click menu entry
- Desktop shortcut
- Start Menu shortcut
- Clipboard URL hotkey
- Native Messaging Host registration for local browser integration

---

## Local Usage

### Open a File or Folder in Windows Sandbox

Right-click a file or folder and select:

```text
Open in Windows Sandbox
```

The selected item is copied into a temporary working folder and then made available inside Windows Sandbox.

Inside the Sandbox, the file or folder appears under:

```text
Desktop\SandboxWork
```

---

### Open Clipboard URL in Windows Sandbox

Copy an HTTP or HTTPS URL.

Then use one of these methods:

```text
CTRL + ALT + S
```

or double-click:

```text
Open Clipboard URL in Windows Sandbox
```

The tool checks the clipboard content. If the clipboard contains a valid URL, Windows Sandbox opens and the URL is launched inside the Sandbox using Microsoft Edge.

---

### Install the Local Browser Extension

The local Chromium extension is located here:

```text
browser-extension/chromium
```

To install it manually in Chrome or Edge:

1. Open the browser extensions page.

For Chrome:

```text
chrome://extensions
```

For Edge:

```text
edge://extensions
```

2. Enable Developer Mode.
3. Click **Load unpacked**.
4. Select the folder:

```text
browser-extension/chromium
```

After installation, right-click a link in the browser.

You should see:

```text
Open Link in Windows Sandbox
```

---

## Local Uninstallation

Open PowerShell in the project folder and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\uninstall.ps1
```

The uninstaller removes:

- File context menu entry
- Folder context menu entry
- Desktop shortcut
- Start Menu shortcut
- Installed local script files
- Native Messaging Host registration

It does not disable the Windows Sandbox feature.

---

# Enterprise / Domain Deployment

Sandbox Quick Open can also be deployed in a Windows domain environment.

The enterprise deployment is designed for a setup where:

- The Edge extension is packaged as a CRX file
- The CRX file and `updates.xml` are hosted internally
- Microsoft Edge installs the extension via Group Policy
- Client-side files are installed under `C:\Program Files`
- Edge communicates with the local Native Messaging Host
- URLs are opened inside Windows Sandbox

---

## Enterprise Deployment Overview

The domain deployment workflow is:

```text
1. Domain admin prepares the enterprise package
2. Edge extension CRX package is generated
3. updates.xml is generated
4. CRX and updates.xml are hosted on IIS or another internal web server
5. Client files are deployed to workstations
6. Edge extension is force-installed with Group Policy
7. Extension communicates with the Native Messaging Host
8. URLs are opened inside Windows Sandbox
```

---

## Enterprise Configuration

The main enterprise configuration file is:

```text
enterprise\enterprise-config.ps1
```

Important values:

```powershell
$EnterpriseExtensionId = "ggbiljdbhodacinlhnpgfncemecamjpf"
$EnterpriseExtensionVersion = "0.1.0"
$EnterpriseExtensionCrxFileName = "sandbox-quick-open-edge.crx"
$NativeHostName = "com.sandboxquickopen.host"
$EnterpriseInstallDir = "C:\Program Files\Sandbox Quick Open"
```

These values must be consistent across:

- Edge extension manifest
- CRX package
- updates.xml
- Edge Group Policy
- Native Messaging Host manifest
- Native Messaging Host registry key

---

## Build the Enterprise Package

Open PowerShell in the project root and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

.\enterprise\Setup-EnterprisePackage.ps1 -BaseUrl "http://DC/sandboxquickopen"
```

Replace the Base URL with your real internal hosting URL.

Examples:

```text
http://server01/sandboxquickopen
https://intranet.domain.local/sandboxquickopen
```

The setup script creates:

- Edge extension CRX package
- updates.xml
- Edge force-install registry helper file
- Client deployment package
- Enterprise deployment ZIP
- Basic validation test output

Expected result:

```text
Deployment package test passed.
Enterprise setup completed successfully.
```

Generated output examples:

```text
enterprise/build/output/sandbox-quick-open-edge.crx
enterprise/build/output/updates.xml
enterprise/build/output/sandbox-quick-open-enterprise-deployment.zip
enterprise/deployment-package/
```

---

## Host the Edge Extension Internally

The following files must be hosted on an internal HTTP or HTTPS location:

```text
sandbox-quick-open-edge.crx
updates.xml
```

Example IIS location:

```text
C:\inetpub\wwwroot\sandboxquickopen
```

Example URLs:

```text
http://DC/sandboxquickopen/updates.xml
http://DC/sandboxquickopen/sandbox-quick-open-edge.crx
```

The `updates.xml` file should look similar to this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gupdate xmlns="http://www.google.com/update2/response" protocol="2.0">
  <app appid="ggbiljdbhodacinlhnpgfncemecamjpf">
    <updatecheck codebase="http://DC/sandboxquickopen/sandbox-quick-open-edge.crx" version="0.1.0" />
  </app>
</gupdate>
```

If IIS is used, add the CRX MIME type:

```text
.crx = application/x-chrome-extension
```

The XML file can use:

```text
.xml = application/xml
```

Test from the client:

```powershell
Invoke-WebRequest `
  -Uri "http://DC/sandboxquickopen/updates.xml" `
  -OutFile "$env:TEMP\updates-test.xml"

Invoke-WebRequest `
  -Uri "http://DC/sandboxquickopen/sandbox-quick-open-edge.crx" `
  -OutFile "$env:TEMP\sandbox-test.crx"
```

If both files download successfully, the hosting part is working.

---

## Deploy Client Files

The enterprise client deployment installs the required files under:

```text
C:\Program Files\Sandbox Quick Open
```

The installed files include:

```text
Open-InSandbox.ps1
Open-Url-InSandbox.ps1
Open-ClipboardUrl-InSandbox.ps1
SandboxQuickOpenHost.ps1
SandboxQuickOpenHost.cmd
com.sandboxquickopen.host.json
```

Run the deployment script as Administrator on the client:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

.\enterprise\scripts\deploy-client.ps1
```

In a real domain environment, this script can be deployed using:

- GPO startup script
- SCCM
- Intune
- Remote management
- Software deployment tools

Expected result:

```text
Deployment completed successfully.

Installed to:
  C:\Program Files\Sandbox Quick Open
```

---

## Enterprise Native Messaging Host

The client deployment creates the Edge Native Messaging Host registry key:

```text
HKLM\SOFTWARE\Microsoft\Edge\NativeMessagingHosts\com.sandboxquickopen.host
```

The default value points to:

```text
C:\Program Files\Sandbox Quick Open\com.sandboxquickopen.host.json
```

The enterprise native host manifest should look like this:

```json
{
  "name": "com.sandboxquickopen.host",
  "description": "Sandbox Quick Open Native Messaging Host",
  "path": "C:\\Program Files\\Sandbox Quick Open\\SandboxQuickOpenHost.cmd",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://ggbiljdbhodacinlhnpgfncemecamjpf/"
  ]
}
```

The `allowed_origins` value must match the enterprise Edge extension ID.

---

## Configure Microsoft Edge GPO

The Edge extension is force-installed with this policy:

```text
ExtensionInstallForcelist
```

Registry path:

```text
HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist
```

Value:

```text
1 = ggbiljdbhodacinlhnpgfncemecamjpf;http://DC/sandboxquickopen/updates.xml
```

The value format is:

```text
extension_id;update_xml_url
```

Example:

```text
ggbiljdbhodacinlhnpgfncemecamjpf;http://DC/sandboxquickopen/updates.xml
```

After applying the policy on the client:

```cmd
gpupdate /force
```

Check applied policies:

```cmd
gpresult /r
```

Then open Edge:

```text
edge://policy
```

Expected policy:

```text
ExtensionInstallForcelist
```

Status should be:

```text
OK
```

---

## Verify the Enterprise Extension

Open Microsoft Edge and go to:

```text
edge://extensions
```

The extension should appear as:

```text
Sandbox Quick Open
```

It should be installed by organization policy.

Then right-click a link in Edge.

Expected context menu item:

```text
Open Link in Windows Sandbox
```

Clicking it should open the selected URL inside Windows Sandbox.

---

## Enterprise Removal

To remove the client installation, run as Administrator:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

.\enterprise\scripts\remove-client.ps1
```

This removes:

- File context menu registry entries
- Folder context menu registry entries
- Edge Native Messaging Host registry key
- Installed files under `C:\Program Files\Sandbox Quick Open`

The Edge extension force-install policy must be removed separately from Group Policy.

---

# Security Notes

Sandbox Quick Open does not analyze whether a file, folder, or URL is malicious.

It is not an antivirus replacement.

It only helps open selected content inside Windows Sandbox, so the user can inspect unknown content in an isolated environment before opening it on the main system.

---

## File and Folder Handling

For file and folder sessions:

- The selected item is copied to a temporary folder
- A Windows Sandbox configuration file is generated
- The temporary folder is mapped into Windows Sandbox
- Inside the Sandbox, the item is copied into `SandboxWork`
- Clipboard redirection is disabled
- Printer redirection is disabled

---

## URL Handling

For URL-only sessions:

- The URL is opened inside Windows Sandbox
- No host folder is mapped for URL-only sessions
- Clipboard redirection is disabled
- Printer redirection is disabled

---

## Browser Integration Security

The browser extension does not directly execute PowerShell.

It sends the selected URL to the local Native Messaging Host.

The Native Messaging Host is restricted to the configured extension ID through the `allowed_origins` setting.

---

# Limitations

- Windows Sandbox startup can take a few seconds
- Office documents may not open automatically if Microsoft Office is not installed inside the Sandbox
- RAR and 7Z files may require additional tools inside the Sandbox
- Browser integration depends on Native Messaging Host registration
- Domain deployment requires correct Edge policy configuration
- Windows Sandbox may not work inside virtual machines unless nested virtualization is enabled
- Outlook Desktop and Teams Desktop context menu integration is not part of the current MVP

---

# Current Status

## Local MVP

Working:

- File right-click support
- Folder right-click support
- Clipboard URL support
- CTRL + ALT + S hotkey
- Desktop shortcut
- Start Menu shortcut
- Chrome / Chromium extension support
- Browser right-click link support
- Native Messaging Host support
- Install script
- Uninstall script

## Enterprise / Domain MVP

Working:

- Enterprise configuration file
- Edge extension CRX generation
- updates.xml generation
- Internal IIS hosting workflow
- Client deployment under `C:\Program Files\Sandbox Quick Open`
- Edge Native Messaging Host registration
- Edge ExtensionInstallForcelist GPO value
- Edge extension force-install through policy
- Edge right-click link menu
- File and folder context menu on domain client
- URL opening through Native Messaging Host
- Basic deployment package validation

---

# Roadmap

## Phase 1 — Local Core

Status: Working

- File right-click support
- Folder right-click support
- Clipboard URL hotkey
- Desktop shortcut
- Installer
- Uninstaller

## Phase 2 — Browser Integration

Status: Working

- Chromium extension
- Native Messaging Host
- Browser right-click link menu
- Open browser links inside Windows Sandbox

## Phase 3 — Enterprise Deployment

Status: Working MVP

- Edge extension CRX packaging
- updates.xml generation
- IIS/internal hosting workflow
- Group Policy force installation
- Client deployment script
- Native Messaging Host registration under HKLM
- Program Files based installation

## Phase 4 — Webmail Attachment Handling

Planned:

- Detect attachments in webmail
- Download attachments to a temporary location without opening them on the host
- Send attachments to Windows Sandbox

## Phase 5 — Teams Desktop Integration

Planned:

- Investigate available Teams Desktop integration options
- Provide the best possible one-click or low-click workflow

## Phase 6 — Outlook Desktop Integration

Planned:

- Investigate Outlook Add-in, VSTO, or COM Add-in options
- Provide safer handling for Outlook links and attachments

---

# Troubleshooting

## Windows Sandbox does not start

Check:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM
```

Also verify:

- Windows edition supports Sandbox
- Virtualization is enabled
- A restart was completed after enabling the feature
- Nested virtualization is enabled if running inside a VM

---

## Hotkey does not work

If `CTRL + ALT + S` does not work immediately:

- Restart Windows Explorer
- Sign out and sign in again
- Check that the desktop shortcut exists
- Check that the shortcut has the hotkey assigned

---

## Browser right-click menu does not appear

Check:

- Extension is installed
- Extension is enabled
- You are right-clicking an actual link
- Browser extension permissions are correct
- For enterprise deployment, check `edge://policy`

---

## Edge extension is not installed by GPO

Check:

```text
edge://policy
```

Verify:

- `ExtensionInstallForcelist` exists
- Policy status is `OK`
- updates.xml is reachable from the client
- CRX file is reachable from the client
- Extension ID matches the updates.xml appid
- GPO is linked to the correct OU
- `gpupdate /force` has been executed

---

## Native Messaging does not work

Check the registry key:

```text
HKLM\SOFTWARE\Microsoft\Edge\NativeMessagingHosts\com.sandboxquickopen.host
```

Check that it points to:

```text
C:\Program Files\Sandbox Quick Open\com.sandboxquickopen.host.json
```

Check the manifest:

```json
"allowed_origins": [
  "chrome-extension://ggbiljdbhodacinlhnpgfncemecamjpf/"
]
```

The extension ID must match the installed Edge extension.

---

## Edge menu appears but URL does not open

Test the URL script manually:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Sandbox Quick Open\Open-Url-InSandbox.ps1" -Url "https://example.com"
```

If this works, check the Native Messaging Host script path.

For enterprise installation, the host should resolve the URL script from its own directory:

```powershell
$OpenUrlScript = Join-Path $PSScriptRoot "Open-Url-InSandbox.ps1"
```

---

# License

This project is currently published as an open learning project.

Use it carefully and review the scripts before running them in a production environment.

---

# Author

Ali Durmus

Project repository:

```text
https://github.com/ali-durmus/Sandbox-Quick-Open
```
