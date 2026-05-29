# Sandbox Quick Open

Sandbox Quick Open is a small Windows utility that helps you open suspicious files, folders, and copied URLs inside Windows Sandbox.

The goal is simple:

- Right-click a file or folder and open it in Windows Sandbox
- Copy a suspicious URL and open it in Windows Sandbox with a hotkey
- Keep the host system safer by testing unknown content in an isolated environment

## Features

### File and Folder Support

Adds a right-click menu entry:


Open in Windows Sandbox
Supported items include, for example:

EXE
MSI
ZIP
PDF
DOCX
XLSX
TXT
CSV
Folders
Other file types

The selected file or folder is copied into a temporary working directory and then opened inside Windows Sandbox.

URL Support

> Note: If the CTRL + ALT + S hotkey does not work immediately after installation, restart Windows Explorer or sign out and sign in again. Windows sometimes caches shortcut hotkeys.

Copy any HTTP or HTTPS link and press:

CTRL + ALT + S

Sandbox Quick Open shows a short confirmation popup and opens the copied URL inside Windows Sandbox using Microsoft Edge.

This is useful for links from:

Outlook
Teams
Webmail
Browsers
PDF documents
Word documents
Other applications
Desktop Shortcut

The installer creates a desktop shortcut:

Open Clipboard URL in Windows Sandbox

You can double-click this shortcut after copying a URL.

Installation

Open PowerShell in the project folder and run:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\install.ps1

The installer will:

Copy the required scripts to the local AppData folder
Add the file right-click menu
Add the folder right-click menu
Create a desktop shortcut
Add the CTRL + ALT + S hotkey
Uninstallation

Open PowerShell in the project folder and run:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\uninstall.ps1

The uninstaller will remove:

Context menu entries
Desktop shortcut
Installed script files

It will not disable the Windows Sandbox feature.

Requirements
Windows Sandbox must be available and enabled
Windows 10/11 Pro, Enterprise, or Education is recommended
Virtualization must be enabled
Windows PowerShell must be available


## Current Status

Local MVP is working:

- File right-click support
- Folder right-click support
- Clipboard URL support
- CTRL + ALT + S hotkey
- Desktop shortcut
- Start Menu shortcut
- Chrome extension support
- Chrome right-click link support
- Native Messaging Host support
- Install script
- Uninstall script



Roadmap

Phase 1 — Local Core
File and folder right-click support
Clipboard URL hotkey
Desktop shortcut
Installer and uninstaller

### Phase 2 — Browser Integration

Current status:

- Google Chrome extension works
- Fixed Chromium extension ID is configured
- Native Messaging Host works
- Right-click link menu works in Chrome:

```text
Open Link in Windows Sandbox
Phase 3 — Webmail Attachment Handling
Detect attachments in webmail
Download attachments to a temporary location without opening them on the host
Send attachments to Windows Sandbox
Phase 4 — Teams Desktop Integration
Investigate available Teams Desktop integration options
Provide the best possible one-click or low-click workflow
Phase 5 — Outlook Desktop Integration
Investigate Outlook Add-in, VSTO, or COM Add-in options
Provide safer handling for Outlook links and attachments
Security Notes

Sandbox Quick Open does not analyze whether a file or URL is malicious.

It only helps open selected content inside Windows Sandbox.

For file and folder handling:

The selected item is copied to a temporary folder
The temporary folder is mapped read-only into Windows Sandbox
Inside the Sandbox, the item is copied into a working folder
Clipboard redirection is disabled
Printer redirection is disabled

For URL handling:

The URL is opened inside Windows Sandbox
No host folder is mapped for URL-only sessions
Clipboard redirection is disabled
Printer redirection is disabled
Limitations
Windows Sandbox startup can take a few seconds
Office documents may not open automatically if Microsoft Office is not installed inside the Sandbox
RAR and 7Z files may require additional tools inside the Sandbox
Outlook Desktop and Teams Desktop context menu integration is not part of the current local MVP
