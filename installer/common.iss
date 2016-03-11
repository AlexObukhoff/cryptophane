; Cryptophane common setup file

[Setup]
DefaultDirName={pf}\Cryptophane
DefaultGroupName=Cryptophane
UninstallDisplayIcon={app}\Cryptophane.exe
AppMutex=CryptophaneMutex
AppPublisher=Alexey Obukhov
AppPublisherURL=https://github.com/AlexObukhoff/cryptophane
AppSupportURL=http://cryptophane.org/
AppUpdatesURL=http://cryptophane.org/
AlwaysUsePersonalGroup=yes

[Files]
Source: "..\src\Cryptophane.exe"; DestDir: "{app}"
Source: "..\src\Cryptophane.ini"; DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "..\help\Cryptophane.chm"; DestDir: "{app}"
Source: "..\installer\license.txt"; DestDir: "{app}"

[Icons]
Name: "{group}\Cryptophane"; Filename: "{app}\Cryptophane.exe"
Name: "{group}\Cryptophane Help"; Filename: "{app}\Cryptophane.chm"
Name: "{group}\Cryptophane License"; Filename: "{app}\license.txt"

[Run]
Filename: "{app}\Cryptophane.exe"; Description: "Start Cryptophane"; Flags: postinstall nowait

[UninstallRun]
Filename: "{app}\Cryptophane.exe"; Parameters: "/uninstall"; RunOnceId: "UninstallCmd"

