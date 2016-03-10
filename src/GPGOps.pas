unit GPGOps;

interface

uses GPGWrapper, Classes, Call, SysUtils;

type
  TProxySetting = (psDirectConnection, psUseWindows, psManual);

  TGPGEncryptSignOpt = (gpgEncrypt, gpgEncryptSym, gpgSign, gpgSignDetached, gpgSignPlain,
                         gpgAlwaysTrust, gpgASCIIOutput);
  TGPGEncryptSignOpts = set of TGPGEncryptSignOpt;

  InvalidArgumentsException = class(GPGException);
  GPGConnectException = class(GPGException);
  GPGDeleteKeyException = class(GPGException);
  GPGDecryptionFailedException = class(GPGException);
  GPGKeyException = class(GPGException)
  protected
    FLongID: string;
  public
    constructor Create(const msg, longID: string);
    property LongID: string read FLongID;
  end;
  GPGBadSignatureException = class(GPGKeyException);
  GPGAlreadySignedException = class(GPGKeyException);
  GPGNoPublicKeyException = class(GPGKeyException);

  GPGKeysException = class(GPGException)
  protected
    FLongIDs: TStringList;
  public
    constructor Create(const msg: string; longIDs: TStrings);
    destructor Destroy; override;
    property LongIDs: TStringList read FLongIDs;
  end;
  GPGNoSecretKeysException = class(GPGKeysException);

  GPGInvalidRecipientsException = class(GPGException)
  protected
    FLongIDs: TStringList;
    FErrors: TStringList;
  public
    constructor Create(errors, longIDs: TStrings);
    destructor Destroy; override;
    property LongIDs: TStringList read FLongIDs;
    property Errors: TStringList read FErrors;
  end;


  GPGOpsException = class(GPGException)
  protected
    FRawData: string;
  public
    constructor Create(const msg, rawData: string);
    property RawData: string read FRawData;
  end;
  GPGKeyExpiredException = class(GPGOpsException);
  GPGNoDataException = class(GPGOpsException);


  
  TEditTrustRequestData = class(TGPGRequestData)
  public
    TrustValue: integer;
    SentTrust: boolean;
  end;
  TSearchKeysRequestData = class(TGPGRequestData)
  public
    KeySearchNextIterations: integer;
    KeySearchLastLineNumber: integer;
  end;

  TGPGOps = class
  protected
    FGetPassphraseCallback: TGetPassphraseCallback;
    FPromptOverwriteFileCallback: TPromptOverwriteFileCallback;
    FGetOutputFilenameCallback: TGetOutputFilenameCallback;
    FDataReceivedCallback: TDataReceivedCallback;

    function CreateWrapperObject: TGPGWrapper; virtual;
    function CreateWrapper(requestData: TGPGRequestData = nil): TGPGWrapper;
    function GetKeys(keys: TList; secret: boolean): boolean;
    procedure DecryptVerifyResult(verify: boolean; w: TGPGWrapper; validSignatures, invalidSignatures: TStrings);

    function EncryptSignCallback(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean;
    function RevokeCallback(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean;
    function EditTrustCallback(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean;
    function SignKeyCallback(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean;
    function SearchKeysCallback(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean;
    function DeleteKeyCallback(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean;

    function GetKeyserverProxyParameter(setting: TProxySetting; host: string; port: integer): string;
    procedure CheckForConnectionError(line: string);

  public
    constructor Create;
    destructor Destroy; override;

    function GetVersion: string;
    procedure GetPublicKeys(keys: TList);
    procedure GetSecretKeys(keys: TList);

    procedure EncryptSign(eso: TGPGEncryptSignOpts; const inFilename, outFilename: string; const signKeyLongID: string; encryptTo: TStrings);
    procedure Decrypt(const inFilename, outFilename: string; validSignatures, invalidSignatures: TStrings);
    procedure Verify(const inFilename: string; validSignatures, invalidSignatures: TStrings);
    procedure SignKey(const longID, signKeyLongID: string);
    procedure SearchKeys(const searchString, keyserver: string; proxySetting: TProxySetting; proxyHost: string; proxyPort: integer; keys: TList);
    procedure RecvKeys(const keyserver: string; proxySetting: TProxySetting; proxyHost: string; proxyPort: integer; keys: TStrings; var keysImportedCount: cardinal; keysImportedUserIDs: TStrings);
    procedure SendKeys(const keyserver: string; proxySetting: TProxySetting; proxyHost: string; proxyPort: integer; keys: TStrings);
    procedure ImportKeys(const inFilename: string; var pubImported, pubUnchanged, secImported, secUnchanged, revoked: cardinal; importedIDs: TStrings);
    procedure ExportKeys(secret: boolean; keys: TList; var keyData: string);
    procedure GenerateKey(
      primaryKeyType: TGPGAlgorithm; primaryKeyLength: cardinal;
      secondaryKeyType: TGPGAlgorithm; secondaryKeyLength: cardinal;
      name, comment, email: string; expiry: TDateTime;
      passphrase: PChar);
    procedure EditTrust(key: TGPGKey; trust: TGPGTrust);
    procedure DeleteKey(key: TGPGKey; secretKey: boolean);
    procedure RevokeKey(key: TGPGKey; var certificate: string);
    procedure ChangeSecretKeyPassphrase(key: TGPGkey);

    property DataReceivedCallback: TDataReceivedCallback read FDataReceivedCallback write FDataReceivedCallback;
    property GetPassphraseCallback: TGetPassphraseCallback read FGetPassphraseCallback write FGetPassphraseCallback;
    property GetOutputFilenameCallback: TGetOutputFilenameCallback read FGetOutputFilenameCallback write FGetOutputFilenameCallback;
    property PromptOverwriteFileCallback: TPromptOverwriteFileCallback read FPromptOverwriteFileCallback write FPromptOverwriteFileCallback;
  end;

var
  UseUntrustedKey: boolean;

implementation

uses Utils, TypInfo;

{ TGPGOps }

constructor TGPGOps.Create;
begin
end;

destructor TGPGOps.Destroy;
begin
end;


function TGPGOps.GetKeys(keys: TList; secret: boolean): boolean;
var
  i: integer;
  k: TGPGKey;
  lastPub, lastKey: TGPGKey;
  w: TGPGWrapper;
begin
  w := CreateWrapper;
  try
    lastPub := nil;
    lastKey := nil;
    result := false;
    if secret then
    begin
      w.NewExec('--list-secret-keys --batch --fingerprint --with-colons');
    end
    else
    begin
      w.NewExec('--list-sigs --batch --fingerprint --with-colons');
    end;
    keys.Clear;

    for i := 0 to w.RawLines.Count - 1 do
    begin
      k := w.CreateKey;
      if k.Parse(w.RawLines[i]) then
      begin
        if k.KeyType = gpgFingerprint then
        begin
          if not Assigned(lastKey) then Exit;
          lastKey.Fingerprint := k.Fingerprint;
          k.Free;
        end
        else if k.KeyType = gpgSignature then
        begin
          if not Assigned(lastKey) then Exit;
          lastKey.Signatures.Add(k);
        end
        else if k.KeyType = gpgUserID then
        begin
          if not Assigned(lastKey) then Exit;
          lastKey.UserIDs.Add(k);
        end
        else if k.KeyType in [gpgPublicPrimary, gpgSecretPrimary] then
        begin
          keys.Add(k);
          lastPub := k;
          lastKey := k;
        end
        else
        begin
          if not Assigned(lastPub) then Exit;
          lastPub.SubKeys.Add(k);
          lastKey := k;
        end;
      end
      else
      begin
        k.Free;
      end;
    end;
    result := true;
  finally
    w.Free;
  end;
end;

function TGPGOps.GetVersion: string;
const
  id: string = 'gpg (GnuPG) ';
var
  w: TGPGWrapper;
begin
  w := CreateWrapper;
  try
    result := '';
    w.NewExec('--version');
    if w.RawLines.Count < 1 then Exit;
    if Copy(w.RawLines[0], 1, Length(id)) <> id then Exit;
    result := Copy(w.RawLines[0], Length(id) + 1, Length(w.RawLines[0]));
  finally
    w.Free;
  end;
end;

procedure TGPGOps.GetPublicKeys(keys: TList);
begin
  GetKeys(keys, false);
end;

procedure TGPGOps.GetSecretKeys(keys: TList);
begin
  GetKeys(keys, true);
end;

procedure TGPGOps.EncryptSign(
  eso: TGPGEncryptSignOpts;
  const inFilename, outFilename: string;
  const signKeyLongID: string;
  encryptTo: TStrings);
var
  cmd: string;
  i, n: integer;
  w: TGPGWrapper;
  sl, invalidRecipients, errors: TStringList;
  //nopubkey, noseckey: TStringList;
  s: string;
begin
  if not IsValidFilename(inFilename) or not IsValidFilename(outFilename) then raise InvalidArgumentsException.Create('inFilename/outFilename not a valid filename');

  cmd := '--command-fd 0 --status-fd 1 -o ' + CommandQuote(outFilename);
  if signKeyLongID <> '' then cmd := cmd + ' --default-key ' + signKeyLongID;
  if (gpgAlwaysTrust in eso) then cmd := cmd + ' --always-trust';
  if gpgASCIIOutput in eso then cmd := cmd + ' -a';
  if gpgSign in eso then cmd := cmd + ' -s';
  if gpgEncryptSym in eso then cmd := cmd + ' -c';
  if gpgSignDetached in eso then cmd := cmd + ' -b';
  if gpgSignPlain in eso then cmd := cmd + ' --clearsign';
  if gpgEncrypt in eso then
  begin
    cmd := cmd + ' -e';
    for i := 0 to encryptTo.Count - 1 do cmd := cmd + ' -r ' + encryptTo[i];
  end;
  cmd := cmd + ' ' + CommandQuote(inFilename);

  sl := TStringList.Create;
  errors := TStringList.Create;
  invalidRecipients := TStringList.Create;
  //nopubkey := TStringList.Create;
  //noseckey := TStringList.Create;
  w := CreateWrapper;
  try
    w.NewExec(cmd, EncryptSignCallback, gpgNewMessage, outFilename);

    for i := 0 to w.RawLines.Count - 1 do
    begin
      if Copy(w.RawLines[i], 1, 9) = '[GNUPG:] ' then
      begin
        s := Copy(w.RawLines[i], 10, Length(w.RawLines[i]));
        Split(' ', s, sl);

        if sl[0] = 'END_ENCRYPTION' then exit;
        if sl[0] = 'SIG_CREATED' then exit;
        if sl[0] = 'INV_RECP' then
        begin
          n := StrToIntDef(sl[1], 0);
          if n <= High(CInvRecpReasons) then
            errors.Add(CInvRecpReasons[n])
          else
            errors.Add('unknown error');
          invalidRecipients.Add(sl[2]);
        end;
        if (sl[0] = 'NODATA') or (sl[0] = 'UNEXPECTED') then raise GPGNoDataException.Create(sl[0], w.RawData);
        //if (sl[0] = 'NO_PUBKEY') then nopubkey.Add(sl[1]);
        //if (sl[0] = 'NO_SECKEY') then noseckey.Add(sl[1]);
      end;
    end;

    if errors.Count > 0 then raise GPGInvalidRecipientsException.Create(errors, invalidRecipients);
    //if noseckey.Count > 0 then raise GPGNoSecretKeysException.Create('No secret keys', noseckey);
    //if nopubkey.Count > 0 then raise GPGNoPublicKeysException.Create('No public keys', nopubkey);

    raise GPGOpsException.Create('Unknown error encrypting/signing', w.RawData);

  finally
    w.Free;
    //noseckey.Free;
    //nopubkey.Free;
    invalidRecipients.Free;
    errors.Free;
    sl.Free;
  end;
end;

function TGPGOps.EncryptSignCallback(const dataType, promptName: string;
  requestData: TGPGRequestData; var response: string): boolean;
var
  answer: string;
begin
  result := true;
  answer := 'n'#13#10;

  if GPGOps.UseUntrustedKey then answer := 'y'#13#10;

  if promptName = 'untrusted_key.override' then response := answer
  else result := false;
end;

procedure TGPGOps.Decrypt(const inFilename, outFilename: string; validSignatures, invalidSignatures: TStrings);
var
  cmd: string;
  w: TGPGWrapper;
  sl: TStringList;
begin
  if not IsValidFilename(inFilename) or not IsValidFilename(outFilename) then
  begin
    raise InvalidArgumentsException.Create('inFilename/outFilename not a valid filename');
  end;

  cmd := '--command-fd 0 --status-fd 1 -o ' + CommandQuote(outFilename);
  cmd := cmd + ' ' + CommandQuote(inFilename);

  sl := TStringList.Create;
  w := CreateWrapper;
  try
    w.NewExec(cmd, nil, gpgExistingMessage, outFilename);
    DecryptVerifyResult(false, w, validSignatures, invalidSignatures);
  finally
    w.Free;
    sl.Free;
  end;
end;

procedure TGPGOps.Verify(const inFilename: string; validSignatures, invalidSignatures: TStrings);
var
  cmd: string;
  w: TGPGWrapper;
  sl: TStringList;
begin
  if not IsValidFilename(inFilename) then
  begin
    raise InvalidArgumentsException.Create('inFilename not a valid filename');
  end;

  cmd := '--command-fd 0 --status-fd 1 --verify ' + CommandQuote(inFilename);

  sl := TStringList.Create;
  w := CreateWrapper;
  try
    w.NewExec(cmd);
    DecryptVerifyResult(true, w, validSignatures, invalidSignatures);
  finally
    w.Free;
    sl.Free;
  end;
end;

procedure TGPGOps.SignKey(const longID, signKeyLongID: string);
var
  cmd: string;
  w: TGPGWrapper;
  i: integer;
  sl: TStringList;
begin
  cmd := '--command-fd 0 --status-fd 1';
  if signKeyLongID <> '' then cmd := cmd + ' --default-key ' + signKeyLongID;
  cmd := cmd + ' --edit-key ' + longID + ' sign save';

  sl := TStringList.Create;
  w := CreateWrapper;
  try
    w.NewExec(cmd, SignKeyCallback);
    for i := 0 to w.RawLines.Count - 1 do
    begin
      if Copy(w.RawLines[i], 1, 9) = '[GNUPG:] ' then
      begin
        sl.Clear;
        if Split(' ', w.RawLines[i], sl) then
        begin
          if sl[1] = 'GOOD_PASSPHRASE' then exit;
          if sl[1] = 'KEYEXPIRED' then raise GPGKeyExpiredException.Create('Key expired', w.RawData);
          if sl[1] = 'ALREADY_SIGNED' then raise GPGAlreadySignedException.Create('Key already signed', sl[2]);
        end;
      end;
    end;

    raise GPGOpsException.Create('Sign key failed.', w.RawData);
  finally
    w.Free;
    sl.Free;
  end;
end;

function TGPGOps.SignKeyCallback(const dataType, promptName: string;
  requestData: TGPGRequestData; var response: string): boolean;
begin
  result := true;
  if promptName = 'sign_uid.okay' then response := 'y'#13#10
  else if promptName = 'sign_uid.expire' then response  := 'y'#13#10
  else result := false;
end;

procedure TGPGOps.SearchKeys(const searchString, keyserver: string; proxySetting: TProxySetting; proxyHost: string; proxyPort: integer; keys: TList);
var
  cmd: string;
  i, n: integer;
  key: TGPGKey;
  s: string;
  sl: TStringList;
  w: TGPGWrapper;
  rd: TSearchKeysRequestData;
begin
  cmd := '--command-fd 0 --status-fd 1 ';
  if keyServer <> '' then cmd := cmd + ' --keyserver ' + CommandQuote(keyServer) + GetKeyserverProxyParameter(proxySetting, proxyHost, proxyPort);
  cmd := cmd + ' --search-keys ' + CommandQuote(searchString);

  rd := TSearchKeysRequestData.Create;
  w := CreateWrapper(rd);
  try
    w.NewExec(cmd, SearchKeysCallback);

    i := 0;
    while i < w.RawLines.Count do
    begin
      s := w.RawLines[i];

      CheckForConnectionError(s);

      for n := 1 to Length(s) do if s[n] = #9 then s[n] := ' ';
      if (Length(s) > 0) and (s[1] = '(') then
      begin
        n := 3;
        while (n < Length(s)) and (s[n] <> ')') do Inc(n);
        Inc(n);
        while (n < Length(s)) and (s[n] = ' ') do Inc(n);
        if n < Length(s) then
        begin
          key := w.CreateKey;
          key.RawUserID := Copy(s, n, Length(s));
          sl := TStringList.Create;
          try
            while (i < w.RawLines.Count) and (Length(s) > 2) and (s[2] <> ' ') do
            begin
              Inc(i);
              if i < w.RawLines.Count then
              begin
                s := w.RawLines[i];
                for n := 1 to Length(s) do if s[n] = #9 then s[n] := ' ';
              end;
            end;

            if (i < w.RawLines.Count) and Split(' ', s, sl) then
            begin
              n := 0;
              while (n < sl.Count) and (sl[n] = '') do Inc(n);
              if (n + 6 < sl.Count) then
              begin
                key.KeyLength := StrToIntDef(sl[n], 0);
                s := sl[n+4];
                if (Length(s) > 0) and (s[Length(s)] = ',') then s := Copy(s, 1, Length(s) - 1);
                key.LongID := s;
                key.CreatedDate := YMDToDateTime(sl[n+6]);
              end;
            end;
          finally
            sl.Free;
          end;
          keys.Add(key);
        end;
      end;
      Inc(i);
    end;
  finally
    w.Free;
  end;
end;

function TGPGOps.SearchKeysCallback(const dataType, promptName: string;
  requestData: TGPGRequestData; var response: string): boolean;
var
  rd: TSearchKeysRequestData;
begin
  rd := TSearchKeysRequestData(requestData);
  
  result := true;
  if promptName = 'keysearch.prompt' then
  begin
    Inc(rd.KeySearchNextIterations);
    if (rd.LineNumber <= rd.KeySearchLastLineNumber + 3) or
       (rd.KeySearchNextIterations > 100) then
      response := 'q'#13#10
    else
      response := 'n'#13#10;

    rd.KeySearchLastLineNumber := rd.LineNumber;
  end
  else
    result := false;
end;


procedure TGPGOps.RecvKeys(const keyserver: string; proxySetting: TProxySetting; proxyHost: string; proxyPort: integer; keys: TStrings; var keysImportedCount: cardinal; keysImportedUserIDs: TStrings);
var
  cmd: string;
  i: integer;
  w: TGPGWrapper;
  sl: TStringList;
begin
  keysImportedCount := 0;
  if keys.Count = 0 then InvalidArgumentsException.Create('No keys specified');

  cmd := '--command-fd 0 --status-fd 1 ';
  if keyServer <> '' then cmd := cmd + ' --keyserver ' + CommandQuote(keyServer) + GetKeyserverProxyParameter(proxySetting, proxyHost, proxyPort);
  cmd := cmd + ' --recv-keys';

  for i := 0 to keys.Count - 1 do cmd := cmd + ' ' + keys[i];

  w := CreateWrapper;
  sl := TStringList.Create;
  try
    w.NewExec(cmd);

    for i := 0 to w.RawLines.Count - 1 do
    begin
      CheckForConnectionError(w.RawLines[i]);
      
      if Copy(w.RawLines[i], 1, 9) = '[GNUPG:] ' then
      begin
        if Split(' ', w.RawLines[i], sl) then
        begin
          if sl[1] = 'IMPORT_RES' then
          begin
            keysImportedCount := StrToIntDef(sl[2], 0);
          end;
          if (sl[1] = 'IMPORTED') and Assigned(keysImportedUserIDs) then
          begin
            keysImportedUserIDs.Add(Copy(w.RawLines[i], 19, Length(w.RawLines[i])));
          end;
        end;
      end;
    end;

    if keysImportedCount = 0 then raise GPGOpsException.Create('No keys imported', w.RawData);
  finally
    sl.Free;
    w.Free;
  end;
end;

procedure TGPGOps.SendKeys(const keyserver: string; proxySetting: TProxySetting; proxyHost: string; proxyPort: integer; keys: TStrings);
var
  cmd: string;
  i: integer;
  w: TGPGWrapper;
begin
  if keys.Count = 0 then InvalidArgumentsException.Create('No keys specified');

  cmd := '--command-fd 0 --status-fd 1 ';
  if keyServer <> '' then cmd := cmd + ' --keyserver ' + CommandQuote(keyServer) + GetKeyserverProxyParameter(proxySetting, proxyHost, proxyPort);
  cmd := cmd + ' --send-keys';

  for i := 0 to keys.Count - 1 do cmd := cmd + ' ' + keys[i];

  w := CreateWrapper;
  try
    w.NewExec(cmd);

    for i := 0 to w.RawLines.Count - 1 do
    begin
      CheckForConnectionError(w.RawLines[i]);
    end;

    // GnuPG is silly.  Older (1.2?) versions gave us a success message,
    // newer versions just don't print an error to indicate everything went alright.
    if Pos('gpg: success sending to', w.RawData) > 0 then exit;

    i := w.RawLines.Count - 2;
    if (Pos('gpg: sending key ', w.RawLines[i]) > 0) and
       (w.RawLines[i + 1] = '') then exit;

    raise GPGOpsException.Create('Key sending failed', w.RawData);
  finally
    w.Free;
  end;
end;

procedure TGPGOps.EditTrust(key: TGPGKey; trust: TGPGTrust);
var
  cmd: string;
  w: TGPGWrapper;
  rd: TEditTrustRequestData;
begin
  cmd :=
    '--command-fd 0 --status-fd 1 --edit-key ' + key.LongID + ' trust quit';

  rd := TEditTrustRequestData.Create;
  w := CreateWrapper(rd);
  try
    case trust of
      trustNone: rd.TrustValue := 2;
      trustMarginal: rd.TrustValue := 3;
      trustFull: rd.TrustValue := 4;
      trustUltimate: rd.TrustValue := 5;
      else rd.TrustValue := 1;
    end;

    w.NewExec(cmd, EditTrustCallback);
    if rd.SentTrust then exit;

    raise GPGOpsException.Create('Edit trust failed', w.RawData);
  finally
    w.Free;
  end;
end;

function TGPGOps.EditTrustCallback(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean;
begin
  result := true;
  if promptName = 'edit_ownertrust.value' then
  begin
    response := IntToStr(TEditTrustRequestData(requestData).TrustValue) + #13#10;
    TEditTrustRequestData(requestData).SentTrust := true;
  end
  else if promptName = 'edit_ownertrust.set_ultimate.okay' then response := 'y'#13#10
  else result := false;
end;

procedure TGPGOps.GenerateKey(primaryKeyType: TGPGAlgorithm;
  primaryKeyLength: cardinal; secondaryKeyType: TGPGAlgorithm;
  secondaryKeyLength: cardinal; name, comment, email: string;
  expiry: TDateTime; passphrase: PChar);
var
  s: string;
  buf: PChar;
  i, n: cardinal;
  w: TGPGWrapper;
begin
  s :=
    'Key-Type: ' + CGPGAlgorithmGenKey[primaryKeyType] + #13#10 +
    'Key-Length: ' + IntToStr(primaryKeyLength) + #13#10 +
    'Subkey-Type: ' + CGPGAlgorithmGenKey[secondaryKeyType] + #13#10 +
    'Subkey-Length: ' + IntToStr(secondaryKeyLength) + #13#10;

  if name <> '' then s := s + 'Name-Real: ' + name + #13#10;
  if comment <> '' then s := s + 'Name-Comment: ' + comment + #13#10;
  if email <> '' then s := s + 'Name-Email: ' + email + #13#10;

  if expiry > 0 then s := s + 'Expire-Date: ' + DateTimeToYMD(expiry) + #13#10;

  s := s + 'Passphrase: ';

  n := Length(s);
  if n > 1048576 then InvalidArgumentsException.Create('Generate key block is too long');
  if StrLen(passphrase) > 1048576 then Exit;
  buf := StrAlloc(n + StrLen(passphrase) + 3);
  w := CreateWrapper;
  try
    StrCopy(buf, PChar(s));
    StrCat(buf, passphrase);
    StrCat(buf, #13#10);

    w.OldExec('--batch --status-fd 1 --gen-key', buf, StrLen(buf));
    for i := 0 to w.RawLines.Count - 1 do
    begin
      if Copy(w.RawLines[i], 1, 21) = '[GNUPG:] KEY_CREATED ' then exit;
    end;

    raise GPGOpsException.Create('Generate key failed', w.RawData);
  finally
    w.Free;
    StrDispose(buf);
  end;
end;

procedure TGPGOps.ImportKeys(const inFilename: string; var pubImported, pubUnchanged, secImported, secUnchanged, revoked: cardinal; importedIDs: TStrings);
var
  cmd: string;
  w: TGPGWrapper;
  sl: TStringList;
  i: integer;
  ok: boolean;
begin
  pubImported := 0;
  pubUnchanged := 0;
  secImported := 0;
  secUnchanged := 0;
  revoked := 0;
  if Assigned(importedIDs) then importedIDs.Clear;

  if not IsValidFilename(inFilename) then
  begin
    raise InvalidArgumentsException.Create('inFilename not a valid filename');
  end;

  cmd := '--command-fd 0 --status-fd 1 --import ' + CommandQuote(inFilename);

  sl := TStringList.Create;
  w := CreateWrapper;
  ok := false;
  try
    w.NewExec(cmd);
    for i := 0 to w.RawLines.Count - 1 do
    begin
      if Copy(w.RawLines[i], 1, 9) = '[GNUPG:] ' then
      begin
        if Split(' ', w.RawLines[i], sl) then
        begin
          if (sl[1] = 'IMPORTED') and Assigned(importedIDs) then
          begin
            importedIDs.Add(Copy(w.RawLines[i], 19, Length(w.RawLines[i])));
          end;

          if sl[1] = 'IMPORT_RES' then
          begin
            pubImported := StrToIntDef(sl[4], 0);
            pubUnchanged := StrToIntDef(sl[6], 0);
            revoked := StrToIntDef(sl[10], 0);
            secImported := StrToIntDef(sl[12], 0);
            secUnchanged := StrToIntDef(sl[13], 0);
            ok := true;
          end;
        end;
      end;
    end;

    if ok then exit;
    raise GPGOpsException.Create('Could not import keys', w.RawData);
  finally
    w.Free;
    sl.Free;
  end;
end;

procedure TGPGOps.ExportKeys(secret: boolean; keys: TList; var keyData: string);
var
  cmd: string;
  i: integer;
  w: TGPGWrapper;
begin
  cmd := '-a';
  if secret then
    cmd := cmd + ' --export-secret-key'
  else
    cmd := cmd + ' --export';

  if Assigned(keys) then
  begin
    for i := 0 to keys.Count - 1 do cmd := cmd + ' ' + TGPGKey(keys[i]).LongID;
  end;

  w := CreateWrapper;
  try
    w.NewExec(cmd);
    keyData := w.RawData;
  finally
    w.Free;
  end;
end;

procedure TGPGOps.DeleteKey(key: TGPGKey; secretKey: boolean);
var
  cmd: string;
  w: TGPGWrapper;
  sl: TStringList;
  i: integer;
begin
  cmd := '--command-fd 0 --status-fd 1';
  if secretKey then
    cmd := cmd + ' --delete-secret-key'
  else
    cmd := cmd + ' --delete-key';
  cmd := cmd + ' ' + CommandQuote(key.Fingerprint);

  sl := TStringList.Create;
  w := CreateWrapper;
  try
    w.NewExec(cmd, DeleteKeyCallback);
    for i := 0 to w.RawLines.Count - 1 do
    begin
      if Copy(w.RawLines[i], 1, 9) = '[GNUPG:] ' then
      begin
        Split(' ', w.RawLines[i], sl);

        if sl[1] = 'DELETE_PROBLEM' then
        begin
          raise GPGDeleteKeyException.Create(CDeleteProblemReasons[StrToIntDef(sl[2], 0)]);
        end;
      end;
    end;
  finally
    w.Free;
    sl.Free;
  end;
end;

function TGPGOps.DeleteKeyCallback(const dataType, promptName: string;
  requestData: TGPGRequestData; var response: string): boolean;
begin
  result := true;
  if promptName = 'delete_key.secret.okay' then response := 'y'#13#10
  else if promptName = 'delete_key.okay' then response := 'y'#13#10
  else result := false;
end;

procedure TGPGOps.RevokeKey(key: TGPGKey; var certificate: string);
var
  cmd: string;
  i: integer;
  w: TGPGWrapper;
begin
  cmd := '--command-fd 0 --status-fd 1 --gen-revoke ' + CommandQuote(key.Fingerprint);
  w := CreateWrapper;
  try
    w.NewExec(cmd, RevokeCallback);

    certificate := '';
    i := 0;
    while i < w.RawLines.Count do
    begin
      if w.RawLines[i] = '-----BEGIN PGP PUBLIC KEY BLOCK-----' then break;
      Inc(i);
    end;

    while i < w.RawLines.Count do
    begin
      certificate := certificate + w.RawLines[i] + #13#10;
      if w.RawLines[i] = '-----END PGP PUBLIC KEY BLOCK-----' then break;
      Inc(i);
    end;

    if certificate = '' then raise GPGOpsException.Create('Cannot generate revocation certificate', w.RawData);
  finally
    w.Free;
  end;
end;

function TGPGOps.RevokeCallback(const dataType, promptName: string;
  requestData: TGPGRequestData; var response: string): boolean;
begin
  result := true;
  if promptName = 'gen_revoke.okay' then response := 'y'#13#10
  else if promptName = 'ask_revocation_reason.code' then response := '0'#13#10
  else if promptName = 'ask_revocation_reason.text' then response := #13#10
  else if promptName = 'ask_revocation_reason.okay' then response := 'y'#13#10
  else result := false;
end;

procedure TGPGOps.ChangeSecretKeyPassphrase(key: TGPGkey);
var
  cmd: string;
  w: TGPGWrapper;
  i: integer;
  sl: TStringList;
  a: boolean;
begin
  cmd :=
    '--command-fd 0 --status-fd 1 --edit-key ' + key.LongID + ' passwd save';

  sl := TStringList.Create;
  w := CreateWrapper;
  a := false;
  try
    w.NewExec(cmd, nil, gpgNewKey);
    for i := 0 to w.RawLines.Count - 1 do
    begin
      if Copy(w.RawLines[i], 1, 9) = '[GNUPG:] ' then
      begin
        sl.Clear;
        if Split(' ', w.RawLines[i], sl) then
        begin
          if sl[1] = 'GOOD_PASSPHRASE' then a := true;
          if a and (sl[1] = 'GOT_IT') then exit;
        end;
      end;
    end;

    raise GPGOpsException.Create('Change passphrase failed.', w.RawData);
  finally
    w.Free;
    sl.Free;
  end;
end;


function TGPGOps.CreateWrapperObject: TGPGWrapper;
begin
  result := TGPGWrapper.Create;
end;

function TGPGOps.CreateWrapper(requestData: TGPGRequestData): TGPGWrapper;
begin
  result := CreateWrapperObject;
  result.RequestData := requestData;
  result.GetPassphraseCallback := GetPassphraseCallback;
  result.PromptOverwriteFileCallback := PromptOverwriteFileCallback;
  result.GetOutputFilenameCallback := GetOutputFilenameCallback;
  result.DataReceivedCallback := DataReceivedCallback;
end;
{
procedure TGPGOps.ParseResult(w: TGPGWrapper);
var
  i: integer;
  s: string;
  ss: TStringList;
begin
  for i := 0 to FRawLines.Count - 1 do
  begin
    if Copy(FRawLines[i], 1, 9) = '[GNUPG:] ' then
    begin
      s := Copy(FRawLines[i], 10, Length(FRawLines[i]));
      ss := TStringList.Create;
      try
        if not Split(' ', s, ss) then Exit;
        if ss[0] = 'GOODSIG' then
        begin
          FGoodSignatures.Add(ss[1]);
        end;

        if ss[0] = 'ERRSIG' then
        begin
          FErrorSignatures.Add(ss[1]);
        end;

        if ss[0] = 'BAD_PASSPHRASE' then
        begin
          FErrorType := gpgBadPassphrase;
          FErrorLongIDs.Add(ss[1]);
          Exit;
        end;

        if ss[0] = 'MISSING_PASSPHRASE' then
        begin
          if FErrorType = gpgUnknownError then FErrorType := gpgMissingPassphrase;
        end;

        if ss[0] = 'BADSIG' then
        begin
          FErrorType := gpgBadSignature;
          FErrorLongIDs.Add(ss[1]);
          Exit;
        end;

        if (ss[0] = 'NODATA') or (ss[0] = 'UNEXPECTED') then
        begin
          FErrorType := gpgNoData;
          Exit;
        end;

        if ss[0] = 'INV_RECP' then
        begin
          FErrorType := gpgInvalidRecipient;
          FErrorMessage := CInvRecpReasons[StrToIntDef(ss[1], 0)];
          FErrorLongIDs.Add(ss[2]);
          Exit;
        end;

        if ss[0] = 'ALREADY_SIGNED' then
        begin
          FErrorType := gpgAlreadySigned;
          FErrorLongIDs.Add(ss[1]);
          Exit;
        end;

        if ss[0] = 'NO_SECKEY' then
        begin
          if FErrorType = gpgUnknownError then FErrorType := gpgNoSecretKey;
          FErrorLongIDs.Add(ss[1]);
        end;

        if ss[0] = 'NO_PUBKEY' then
        begin
          FErrorType := gpgNoPublicKey;
          FNoPubKeyIDs.Add(ss[1]);
          // Don't exit, though.
        end;

        if ss[0] = 'DECRYPTION_FAILED' then
        begin
          if FErrorType = gpgUnknownError then FErrorType := gpgDecryptionFailed;
          Exit;
        end;

        if ss[0] = 'DELETE_PROBLEM' then
        begin
          FErrorType := gpgDeleteFailed;
          FErrorMessage := CDeleteProblemReasons[StrToIntDef(ss[1], 0)];
          Exit;
        end;

        // Success states

        if ss[0] = 'SIG_CREATED' then
        begin
          FErrorType := gpgSuccessSigned;
          break;
        end;

        if ss[0] = 'END_ENCRYPTION' then
        begin
          FErrorType := gpgSuccessEncrypted;
          break;
        end;

        if ss[0] = 'END_DECRYPTION' then
        begin
          FErrorType := gpgSuccessDecrypted;
          break;
        end;
      finally
        ss.Free;
      end;
    end;
  end;

  if (FErrorType = gpgUnknownError) and (FGoodSignatures.Count > 0) then
  begin
    FErrorType := gpgSuccessVerified;
  end;

  result := true;
end;
}

procedure TGPGOps.DecryptVerifyResult(verify: boolean; w: TGPGWrapper; validSignatures, invalidSignatures: TStrings);
var
  i: integer;
  sl: TStringList;
  noseckey: TStringList;
  s: string;
begin
  sl := TStringList.Create;
  noseckey := TStringList.Create;
  try
    for i := 0 to w.RawLines.Count - 1 do
    begin
      if Copy(w.RawLines[i], 1, 9) = '[GNUPG:] ' then
      begin
        s := Copy(w.RawLines[i], 10, Length(w.RawLines[i]));
        Split(' ', s, sl);

        if sl[0] = 'END_DECRYPTION' then exit;
        if (sl[0] = 'GOODSIG') and Assigned(validSignatures) then validSignatures.Add(sl[1]);
        if (sl[0] = 'ERRSIG') and Assigned(invalidSignatures) then invalidSignatures.Add(sl[1]);

        if sl[0] = 'BADSIG' then raise GPGBadSignatureException.Create('Bad signature', sl[1]);
        if (sl[0] = 'NODATA') or (sl[0] = 'UNEXPECTED') then raise GPGNoDataException.Create(sl[0], w.RawData);
        if sl[0] = 'NO_PUBKEY' then raise GPGNoPublicKeyException.Create('No public key', sl[1]);
        if sl[0] = 'NO_SECKEY' then noseckey.Add(sl[1]);
        if sl[0] = 'DECRYPTION_FAILED' then
        begin
          if noseckey.Count > 0 then
          begin
            validSignatures.Clear;
            break;
          end;
          raise GPGDecryptionFailedException.Create('Decryption failed.');
        end;
      end;
    end;

    if validSignatures.Count > 0 then exit;
    if noseckey.Count > 0 then raise GPGNoSecretKeysException.Create('No secret keys', noseckey);
    raise GPGOpsException.Create('Unknown error decrypting/verifying', w.RawData);
  finally
    noseckey.Free;
    sl.Free;
  end;
end;


function TGPGOps.GetKeyserverProxyParameter(setting: TProxySetting;
  host: string; port: integer): string;
begin
  result := '';
  if (setting = psDirectConnection) or (host = '') or (port = 0) then exit;
  result := ' --keyserver-options http-proxy=http://' + CommandQuote(host + ':' + IntToStr(port), false);
end;


procedure TGPGOps.CheckForConnectionError(line: string);
var
  n: integer;
  host: string;
begin
  if (Copy(line, 1, 2) = '?:') and (Pos('ec=', line) > 0) then
  begin
    line := Copy(line, 4, Length(line));
    n := Pos(': ', line);
    if n > 0 then
    begin
      host := Copy(line, 1, n - 1);
      line := Copy(line, n + 2, Length(line));
      if Pos('Host not found', line) = 1 then
        raise GPGConnectException.Create('The hostname "' + host + '" could not be found.  Please check your keyserver and proxy settings.')
      else if Pos('Unable to connect', line) = 1 then
        raise GPGConnectException.Create('Could not connect to host "' + host + '".  Please check your keyserver and proxy settings.')
      else
        raise GPGConnectException.Create('An error occurred while connecting to "' + host + '": ' + line + '.  Please check your keyserver and proxy settings.');
    end;
  end;
end;

{ GPGOpsException }

constructor GPGOpsException.Create(const msg, rawData: string);
begin
  inherited Create(msg);
  FRawData := rawData;
end;

{ GPGKeyException }

constructor GPGKeyException.Create(const msg, longID: string);
begin
  inherited Create(msg);
  FLongID := longID;
end;

{ GPGInvalidRecipientsException }

constructor GPGInvalidRecipientsException.Create(errors,
  longIDs: TStrings);
begin
  FErrors := TStringList.Create;
  FLongIDs := TStringList.Create;
  FErrors.Assign(errors);
  FLongIDs.Assign(longIDs);
end;

destructor GPGInvalidRecipientsException.Destroy;
begin
  FreeAndNil(FLongIDs);
  FreeAndNil(FErrors);
  inherited;
end;

{ GPGKeysException }

constructor GPGKeysException.Create(const msg: string; longIDs: TStrings);
begin
  FLongIDs := TStringList.Create;
  FLongIDs.Assign(longIDs);
end;

destructor GPGKeysException.Destroy;
begin
  FreeAndNil(FLongIDs);
  inherited;
end;

end.
