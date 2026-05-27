#ifndef MyAppName
#define MyAppName "Markdown Viewer TTS"
#endif
#ifndef MyAppVersion
#define MyAppVersion "1.0.0"
#endif
#ifndef MyAppPublisher
#define MyAppPublisher "Michael Guber"
#endif
#ifndef MyAppURL
#define MyAppURL "https://github.com/guberm/markdown-viewer-tts-windows"
#endif
#ifndef MyAppExeName
#define MyAppExeName "markdown_viewer_tts_windows.exe"
#endif

[Setup]
AppId={{6E282851-7DE7-41CC-B462-B10C95AE4A7A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=
OutputDir=..\build\windows\installer
OutputBaseFilename=MarkdownViewerTTS-Setup-{#MyAppVersion}
SetupIconFile=runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
