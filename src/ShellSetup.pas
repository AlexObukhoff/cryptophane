unit ShellSetup;

interface

type
  TShellSetup = class
    class function Setup: boolean;
    class procedure Remove;
  end;

implementation

uses Registry, Windows, ShlObj, Classes;

const
  KeyProgID = 'Cryptophane.Key.1';
  KeyExts: array [1..1] of string = ('.asc');
  EncProgID = 'Cryptophane.Encrypted.1';
  EncExts: array [1..2] of string = ('.gpg','.pgp');
  SigProgID = 'Cryptophane.Signature.1';
  SigExts: array [1..1] of string = ('.sig');

{ TShellSetup }

class function TShellSetup.Setup: boolean;
var
  r: TRegistry;
  i: integer;
  old: string;
  changed: boolean;
begin
  result := false;
  changed := false;
  r := TRegistry.Create;
  try
    try
      r.RootKey := HKEY_CLASSES_ROOT;

      // ImportProgID
      if not r.KeyExists('\' + KeyProgID) then changed := true;
      r.OpenKey('\' + KeyProgID, true);
      r.WriteString('', 'Key File');
      r.OpenKey('shell', true);
      r.WriteString('', 'import');
      r.OpenKey('import', true);
      r.WriteString('', 'Import');
      r.OpenKey('command', true);
      if r.ReadString('') <> '"' + ParamStr(0) + '" "%1"' then changed := true;
      r.WriteString('', '"' + ParamStr(0) + '" "%1"');

      for i := Low(KeyExts) to High(KeyExts) do
      begin
        r.OpenKey('\' + KeyExts[i], true);
        old := r.ReadString('');
        if (old <> '') and (old <> KeyProgID) then
        begin
          changed := true;
          r.WriteString('Cryptophane_back', old);
        end;
        r.WriteString('', KeyProgID);
      end;

      // EncProgID
      if not r.KeyExists('\' + EncProgID) then changed := true;
      r.OpenKey('\' + EncProgID, true);
      r.WriteString('', 'Encrypted File');
      r.OpenKey('shell', true);
      r.WriteString('', 'decrypt');
      r.OpenKey('decrypt', true);
      r.WriteString('', 'Decrypt');
      r.OpenKey('command', true);
      if r.ReadString('') <> '"' + ParamStr(0) + '" /decrypt "%1"' then changed := true;
      r.WriteString('', '"' + ParamStr(0) + '" /decrypt "%1"');

      for i := Low(EncExts) to High(EncExts) do
      begin
        r.OpenKey('\' + EncExts[i], true);
        old := r.ReadString('');
        if (old <> '') and (old <> EncProgID) then
        begin
          changed := true;
          r.WriteString('Cryptophane_back', old);
        end;
        r.WriteString('', EncProgID);
      end;

      // SigProgID
      if not r.KeyExists('\' + SigProgID) then changed := true;
      r.OpenKey('\' + SigProgID, true);
      r.WriteString('', 'File Signature');
      r.OpenKey('shell', true);
      r.WriteString('', 'verify');
      r.OpenKey('verify', true);
      r.WriteString('', 'Verify');
      r.OpenKey('command', true);
      if r.ReadString('') <> '"' + ParamStr(0) + '" /verify "%1"' then changed := true;
      r.WriteString('', '"' + ParamStr(0) + '" /verify "%1"');

      for i := Low(SigExts) to High(SigExts) do
      begin
        r.OpenKey('\' + SigExts[i], true);
        old := r.ReadString('');
        if (old <> '') and (old <> SigProgID) then
        begin
          changed := true;
          r.WriteString('Cryptophane_back', old);
        end;
        r.WriteString('', SigProgID);
      end;


      // Global encrypt/sign handler
      r.OpenKey('\*\shell', true);
      if not r.KeyExists('cryptophane') then changed := true;
      r.OpenKey('cryptophane', true);
      r.WriteString('', 'Encrypt and/or Sign');
      r.OpenKey('command', true);
      if r.ReadString('') <> '"' + ParamStr(0) + '" /encryptsign "%1"' then changed := true;
      r.WriteString('', '"' + ParamStr(0) + '" /encryptsign "%1"');


      // Path
      r.RootKey := HKEY_LOCAL_MACHINE;
      r.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Cryptophane.exe', true);
      r.WriteString('', ParamStr(0));
    except
      Exit;
    end;
  finally
    r.Free;
    if changed then SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
  end;

  result := true;
end;

class procedure TShellSetup.Remove;
var
  r: TRegistry;
  old: string;
  i: integer;
  ss: TStringList;
begin
  r := TRegistry.Create;
  ss := TStringList.Create;
  try
    try
      r.RootKey := HKEY_CLASSES_ROOT;

      for i := Low(EncExts) to High(EncExts) do ss.Add(EncExts[i]);
      for i := Low(SigExts) to High(SigExts) do ss.Add(SigExts[i]);

      for i := 0 to ss.Count - 1 do
      begin
        if r.OpenKey('\' + ss[i], false) then
        begin
          old := r.ReadString('');
          if (old = encProgID) or (old = sigProgId) then
          begin
            if r.ValueExists('Cryptophane_back') then
            begin
              r.WriteString('', r.ReadString('Cryptophane_back'));
              r.DeleteValue('Cryptophane_back');
            end
            else
            begin
              r.CloseKey;
              r.DeleteKey('\' + ss[i]);
            end;
          end;
        end;
      end;

      r.DeleteKey('\' + encProgID);
      r.DeleteKey('\' + sigProgID);
      r.DeleteKey('\*\shell\cryptophane');

      r.RootKey := HKEY_LOCAL_MACHINE;
      r.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Cryptophane.exe');
    except
      Exit;
    end;
  finally
    r.Free;
    ss.Free;
    SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
  end;
end;

end.
