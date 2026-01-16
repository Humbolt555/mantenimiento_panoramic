#define MyAppName "Pano_Mantenimiento"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "OctarineDevs"
#define MyAppExeName "mantenimiento_panoramic.exe"

[Setup]
; Cambiá el AppId por un GUID propio (podés dejarlo así por ahora, pero no lo repitas entre apps)
AppId={{D4A3E4E2-7D9D-4E7B-9B3C-2C8B5D8D6E02}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

OutputDir=.\dist
OutputBaseFilename=PanoMantenimiento_Setup_{#MyAppVersion}

Compression=lzma
SolidCompression=yes

ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; (Opcional) ícono del instalador / desinstalador
; SetupIconFile=.\windows\runner\resources\app_icon.ico
; UninstallDisplayIcon={app}\{#MyAppExeName}

[Files]
; Copia TODO lo que hay en Release (exe + dlls + assets)
Source: ".\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Tasks]
Name: "desktopicon"; Description: "Crear ícono en el Escritorio"; GroupDescription: "Tareas adicionales:"
Name: "startmenuicon"; Description: "Crear accesos en el Menú Inicio"; GroupDescription: "Tareas adicionales:"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: startmenuicon
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Ejecutar {#MyAppName}"; Flags: nowait postinstall skipifsilent
