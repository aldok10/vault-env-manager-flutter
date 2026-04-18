; Inno Setup script for Vault Env Manager desktop installer.
;
; Compiled in CI via `iscc` with the following preprocessor parameters:
;   /DAppVersion=<semver>          e.g. 1.0.1
;   /DBuildNumber=<ci build no.>   e.g. 42
;   /DArch=<x64|arm64>             target architecture tag (used for file naming + 64-bit mode)
;   /DBuildDir=<path>              absolute path to the Flutter Release directory (contents become {app})
;   /DOutputBase=<base name>       final .exe name without extension
;
; Produces an installer under `dist/` that registers Vault Env Manager in
; Programs & Features, installs to a per-architecture Program Files dir,
; and optionally creates a desktop shortcut.

#ifndef AppVersion
#define AppVersion "0.0.0"
#endif
#ifndef BuildNumber
#define BuildNumber "0"
#endif
#ifndef Arch
#define Arch "x64"
#endif
#ifndef BuildDir
#define BuildDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputBase
#define OutputBase "vault-env-manager-" + AppVersion + "-ci." + BuildNumber + "-windows-" + Arch + "-setup"
#endif

; Inno Setup 6.1+ uses `x64compatible` as the canonical token for "64-bit
; Windows that can run x64 binaries", which includes both native x64 hosts
; and Windows-on-ARM hosts running x64 code under the built-in emulator.
; The raw `x64` token only matches genuine x64 editions and would reject
; ARM64 Windows — breaking the documented Windows-on-ARM install path.
#if Arch == "x64"
  #define ArchCompat "x64compatible"
#else
  #define ArchCompat Arch
#endif

[Setup]
AppId={{8F1C9B1A-3F5E-4B9A-9B6E-VAULTENVMGR01}}
AppName=Vault Env Manager
AppVersion={#AppVersion}
AppVerName=Vault Env Manager {#AppVersion} (ci.{#BuildNumber})
AppPublisher=aldok10
AppPublisherURL=https://github.com/aldok10/vault-env-manager-flutter
AppSupportURL=https://github.com/aldok10/vault-env-manager-flutter/issues
AppUpdatesURL=https://github.com/aldok10/vault-env-manager-flutter/releases
DefaultDirName={autopf}\VaultEnvManager
DefaultGroupName=Vault Env Manager
DisableProgramGroupPage=yes
; Produce per-arch binaries. x64 / arm64 installers target 64-bit mode.
; See ArchCompat definition above for the Windows-on-ARM rationale.
ArchitecturesInstallIn64BitMode={#ArchCompat}
ArchitecturesAllowed={#ArchCompat}
OutputDir=dist
OutputBaseFilename={#OutputBase}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
PrivilegesRequiredOverridesAllowed=dialog
UninstallDisplayIcon={app}\vault_env_manager.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\Vault Env Manager"; Filename: "{app}\vault_env_manager.exe"
Name: "{group}\{cm:UninstallProgram,Vault Env Manager}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Vault Env Manager"; Filename: "{app}\vault_env_manager.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\vault_env_manager.exe"; Description: "{cm:LaunchProgram,Vault Env Manager}"; Flags: nowait postinstall skipifsilent
