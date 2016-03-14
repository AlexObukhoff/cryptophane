; Cryptophane setup file

#include "common.iss"

[Setup]
AppName=Cryptophane+GnuPG

AppVerName=Cryptophane+GnuPG 0.7.4
AppVersion=0.7.4
OutputBaseFilename="cryptophane-0.7.4-gnupg-1.4.12"

AppCopyright=Cryptophane (c) 2005-2008 eCOSM; 2016 Alexey Obukhov

[Files]
Source: "c:\bin\GnuPG\gpg.exe"; DestDir: "{app}\GnuPG"
Source: "c:\bin\GnuPG\gpgkeys_finger.exe"; DestDir: "{app}\GnuPG"
Source: "c:\bin\GnuPG\gpgkeys_hkp.exe"; DestDir: "{app}\GnuPG"
Source: "c:\bin\GnuPG\gpgkeys_curl.exe"; DestDir: "{app}\GnuPG"
Source: "c:\bin\GnuPG\gpgkeys_ldap.exe"; DestDir: "{app}\GnuPG"
Source: "c:\bin\GnuPG\iconv.dll"; DestDir: "{app}\GnuPG"
Source: "c:\bin\GnuPG\gnupg.nls\*.*"; DestDir: "{app}\GnuPG\gnupg.nls"
Source: "c:\bin\GnuPG\Doc\COPYING.txt"; DestDir: "{app}\GnuPG\Doc"
Source: "c:\bin\GnuPG\Doc\README.txt"; DestDir: "{app}\GnuPG\Doc"
Source: "c:\bin\GnuPG\Doc\README-W32.txt"; DestDir: "{app}\GnuPG\Doc"

[Registry]
Root: HKLM; Subkey: "Software\GNU"
Root: HKLM; Subkey: "Software\GNU\GNUPG"
Root: HKLM; Subkey: "Software\GNU\GNUPG"; ValueType: string; ValueName: "gpgProgram"; ValueData: "{app}\GnuPG\gpg.exe"; flags: createvalueifdoesntexist

[INI]
Filename: "{app}\Cryptophane.ini"; Section: "gpg"; Key: "gpg-path"; String: "{app}\GnuPG"; Flags: createkeyifdoesntexist
