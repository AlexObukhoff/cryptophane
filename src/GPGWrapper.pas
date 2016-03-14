unit GPGWrapper;

interface

uses Classes, Contnrs, SysUtils, Call;

type
  TGPGRequestData = class
    LineNumber: integer;  
  end;

  GPGException = class(Exception);

  TGPGPassphraseGetType = (gpgExistingKey, gpgExistingMessage, gpgNewKey, gpgNewMessage);
  TGetPassphraseCallback = function(getType: TGPGPassphraseGetType; longID: string; passphrase: PChar): boolean of object;
  TGetOutputFilenameCallback = function(var filename: string): boolean of object;
  TPromptOverwriteFileCallback = function(const filename: string): boolean of object;  
  TPromptResponseCallback = function(const dataType, promptName: string; requestData: TGPGRequestData; var response: string): boolean of object;

  CannotFindGPGException = class(Exception);

const
  CInvRecpReasons: array [0..10] of string = (
    'No specific reason given',
    'Not found',
    'Ambiguous specification',
    'Wrong key usage',
    'Key revoked',
    'Key expired',
    'No CRL known',
    'CRL too old',
    'Policy mismatch',
    'Not a secret key',
    'Key not trusted'
  );

  CDeleteProblemReasons: array [1..3] of string = (
    'No such key on your keyring.',
    'Before deleting this public key, you must delete the corresponding secret key first.',
    'Ambiguous specification.'
  );

type
  TGPGKeyType = (
    gpgPublicPrimary, gpgPublicSecondary,
    gpgSecretPrimary, gpgSecretSecondary,
    gpgSignature, gpgFingerprint, gpgUserID
  );
  TGPGAlgorithm = (gpgDSA, gpgElGamal, gpgRSA, gpgUnknownAlgorithm);
  TGPGTrust = (trustUnknown, trustNoPublicKey, trustNotSelected, trustInvalid, trustDisabled,
    trustRevoked, trustExpired, trustNone, trustMarginal, trustFull, trustUltimate);

const
  CGPGKeyType: array [gpgPublicPrimary..gpgFingerprint] of string = (
    'Public Primary Key',
    'Public Secondary Key',
    'Secret Primary Key',
    'Secret Secondary Key',
    'Signature',
    'Fingerprint'
  );

  CGPGAlgorithm: array [gpgDSA..gpgUnknownAlgorithm] of string = (
    'DSA', 'ElGamal', 'RSA', 'Unknown'
  );

  CGPGAlgorithmGenKey: array [gpgDSA..gpgUnknownAlgorithm] of string = (
    'DSA', 'ELG-E', 'RSA', 'Unknown'
  );

  CGPGTrust: array [trustUnknown..trustUltimate] of string = (
    'Unknown', 'No PubKey', '', 'Invalid', 'Disabled', 'Revoked', 'Expired',
    'None', 'Marginal', 'Full', 'Ultimate'
  );

type
  TGPGKey = class
  private
    function GetShortKeyID: string;
    function GetLongKeyID: string;
    function GetUserID: string;
    procedure SetUserID(const Value: string);
  protected
    FKeyType: TGPGKeyType;
    FCalcTrust: TGPGTrust;
    FAlgorithm: TGPGAlgorithm;
    FKeyLength: cardinal;
    FLongID: string;
    FCreatedDate: TDateTime;
    FExpiryDate: TDateTime;
    FUserTrust: TGPGTrust;
    FUserID: string;
    FFingerprint: string;
    FSubKeys: TObjectList;
    FSignatures: TObjectList;
    FUserIDs: TObjectList;

    FEncrypt: boolean;
    FSigning: boolean;
    FDisabled: boolean;

    function GetUserIDName: string;
    function GetUserIDComment: string;
    function GetUserIDEmail: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Parse(line: string): boolean;

    function GetKeyID(long: boolean): string;

    function Encode(text: string): string;
    function Decode(text: string): string;

    function IsExpired: boolean;
    function IsValid: boolean;

    property KeyType: TGPGKeyType read FKeyType;
    property CalcTrust: TGPGTrust read FCalcTrust;
    property Algorithm: TGPGAlgorithm read FAlgorithm;
    property KeyLength: cardinal read FKeyLength write FKeyLength;
    property ShortID: string read GetShortKeyID;
    property LongID: string read GetLongKeyID write FLongID;
    property Fingerprint: string read FFingerprint write FFingerprint;
    function GetFingerprint: string;
    property CreatedDate: TDateTime read FCreatedDate write FCreatedDate;
    property ExpiryDate: TDateTime read FExpiryDate;
    property UserTrust: TGPGTrust read FUserTrust;
    property SubKeys: TObjectList read FSubKeys;
    property Signatures: TObjectList read FSignatures;
    property UserIDs: TObjectList read FUserIDs;

    property RawUserID: string read FUserID write FUserID;
    property UserID: string read GetUserID write SetUserID;
    property UserIDName: string read GetUserIDName;
    property UserIDComment: string read GetUserIDComment;
    property UserIDEmail: string read GetUserIDEmail;

    property IsEncrypt: boolean read FEncrypt;
    property IsSigning: boolean read FSigning;
    property IsDisabled: boolean read FDisabled;
  end;

  PGPGKey = ^TGPGKey;

  TGPGError = (gpgSuccessEncrypted, gpgSuccessSigned, gpgSuccessDecrypted, gpgSuccessVerified,
                gpgSystemError, gpgBadPassphrase, gpgMissingPassphrase,
                gpgBadSignature, gpgNoData,
                gpgAlreadySigned,
                gpgNoPublicKey, gpgNoSecretKey,
                gpgDecryptionFailed,
                gpgDeleteFailed,
                gpgInvalidRecipient, gpgUnknownError);

  TGPGLocation = class
  private
    FEXEPath: string;
    FHomeDir: string;
    FUseGPGRegistry: boolean;
    FDebugFile: string;
  public
    constructor Create(useGPGRegistry: boolean; useEXEPath: string = ''; useHomeDir: string = '');
    property EXEPath: string read FEXEPath;
    property HomeDir: string read FHomeDir;
    property UseGPGRegistry: boolean read FUseGPGRegistry;
    property DebugFile: string read FDebugFile write FDebugFile;
  end;

  TGPGWrapper = class
  private
    FEXEPath: string;
    FHomeDir: string;

    FCommandLine: string;
    FRawData: string;
    FRawLines: TStringList;

    FPassphrase: PChar;
    FDataReceivedCallback: TDataReceivedCallback;
    FPromptResponseCallback: TPromptResponseCallback;
    FGetPassphraseCallback: TGetPassphraseCallback;
    FPromptOverwriteFileCallback: TPromptOverwriteFileCallback;
    FGetOutputFilenameCallback: TGetOutputFilenameCallback;

    FSymPassphraseRequestType: TGPGPassphraseGetType;
    FOutputFilename: string;

    FRequestData: TGPGRequestData;

  protected
    procedure ClearPassphrase;
    procedure DataCallback(cmd: string; lineNumber: integer; isFragment: boolean; var write_stdin: THandle; var terminateProgram: boolean);
    procedure WriteDebug(str: string);

  private
    procedure WriteStdIn(var write_stdin: THandle; var s: string; var count: cardinal);

  public
    constructor Create;
    destructor Destroy; override;

    function CreateKey: TGPGKey; virtual;

    procedure NewExec(const args: string; promptResponseCallback: TPromptResponseCallback = nil; symPassphraseRequestType: TGPGPassphraseGetType = gpgExistingMessage; outputFilename: string = '');
    procedure OldExec(const args: string; const writeData: PChar = nil; writeDataLen: cardinal = 0);

    property EXEPath: string read FEXEPath;
    property HomeDir: string read FHomeDir;

    property CommandLine: string read FCommandLine;
    property RawData: string read FRawData;
    property RawLines: TStringList read FRawLines;

    property RequestData: TGPGRequestData read FRequestData write FRequestData;

    property DataReceivedCallback: TDataReceivedCallback read FDataReceivedCallback write FDataReceivedCallback;
    property GetPassphraseCallback: TGetPassphraseCallback read FGetPassphraseCallback write FGetPassphraseCallback;
    property GetOutputFilenameCallback: TGetOutputFilenameCallback read FGetOutputFilenameCallback write FGetOutputFilenameCallback;
    property PromptOverwriteFileCallback: TPromptOverwriteFileCallback read FPromptOverwriteFileCallback write FPromptOverwriteFileCallback;
  end;

var
  GGPGLocation: TGPGLocation;


implementation

uses Windows, Utils, Dialogs, Registry, ShlObj;

{ TGPGWrapper }

constructor TGPGWrapper.Create;
begin
  if not Assigned(GGPGLocation) then raise Exception.Create('GGPGLocation must be assigned before creating TGPGWrapper.');

  FRequestData := nil;
  FPassphrase := StrAlloc(256);
  FEXEPath := GGPGLocation.EXEPath;
  FHomedir := GGPGLocation.Homedir;
  FRawLines := TStringList.Create;
end;

destructor TGPGWrapper.Destroy;
begin
  FRawLines.Free;
  FreeAndNil(FRequestData);

  if Assigned(FPassphrase) then
  begin
    ClearPassphrase;
    StrDispose(FPassphrase);
  end;
end;

function TGPGWrapper.CreateKey: TGPGKey;
begin
  result := TGPGKey.Create;
end;

procedure TGPGWrapper.ClearPassphrase;
begin
  if Assigned(FPassphrase) then FillChar(FPassphrase^, 256, 0);
end;

procedure TGPGWrapper.OldExec(const args: string;
                             const writeData: PChar; writeDataLen: cardinal);
var
  i: integer;
  s: string;
  prefix: string;
begin
  prefix := '[GNUPG:] ';

  FRawLines.Clear;
  FCommandLine := FEXEPath + ' --homedir ' + CommandQuote(GGPGLocation.HomeDir) + ' --display-charset utf-8 --utf8-strings ' + args;

  WriteDebug('Executing:'#13#10 + FCommandLine + #13#10#13#10);

  if CallProgram(FCommandLine, FRawData, DataCallback, prefix, writeData, writeDataLen) then
  begin
    WriteDebug('Result:'#13#10 + FRawData + #13#10#13#10#13#10);

    Split(#10, FRawData, FRawLines);
    for i := 0 to FRawLines.Count - 1 do
    begin
      s := FRawLines[i];
      if (s <> '') and (s[Length(s)] = #13) then FRawLines[i] := Copy(s, 1, Length(s) - 1);
    end;
  end
  else
  begin
    WriteDebug('ERROR RESULT'#13#10#13#10#13#10);
    raise GPGException.Create('Error executing GnuPG.');
  end;
end;

procedure TGPGWrapper.NewExec(const args: string; promptResponseCallback: TPromptResponseCallback; symPassphraseRequestType: TGPGPassphraseGetType; outputFilename: string);
begin
  FPromptResponseCallback := promptResponseCallback;
  if symPassphraseRequestType = gpgExistingKey then raise Exception.Create('Invalid symPassphraseRequestType');
  FSymPassphraseRequestType := symPassphraseRequestType;
  FOutputFilename := outputFilename;
  OldExec(args);
end;

procedure TGPGWrapper.WriteStdIn(var write_stdin: THandle; var s: string; var count: cardinal);
var
  bufs: TBytes;
begin
  bufs := TEncoding.UTF8.GetBytes(s);
  WriteFile(write_stdin, bufs[0], Length(bufs), count, nil);
end;

procedure TGPGWrapper.DataCallback(cmd: string; lineNumber: integer;
  isFragment: boolean; var write_stdin: THandle; var terminateProgram: boolean);
var
  c: TStringList;
  count: cardinal;
  s: string;
begin
  if not isFragment then
  begin
    c := TStringList.Create;
    try
      Split(' ', cmd, c);
      if c[0] = '[GNUPG:]' then
      begin
        if c[1] = 'NEED_PASSPHRASE' then
        begin
          ClearPassphrase;
          if not Assigned(FGetPassphraseCallback) or
             not FGetPassphraseCallback(gpgExistingKey, c[2], FPassphrase) then
          begin
            terminateProgram := true;
            exit;
          end;
        end;

        if c[1] = 'NEED_PASSPHRASE_SYM' then
        begin
          ClearPassphrase;
          if not Assigned(FGetPassphraseCallback) or
             not FGetPassphraseCallback(FSymPassphraseRequestType, c[2], FPassphrase) then
          begin
            terminateProgram := true;
            exit;
          end;
        end;

        if Copy(c[1], 1, 4) = 'GET_' then
        begin
          if c[2] = 'passphrase.enter' then
          begin
            if Assigned(FPassphrase) then
            begin
              s := FPassphrase;
              WriteStdIn(write_stdin, s, count);
            end;
            s := #13#10;
            WriteStdIn(write_stdin, s, count);
          end
          else if c[2] = 'openfile.overwrite.okay' then
          begin
            if not Assigned(FPromptOverwriteFileCallback) or
               FPromptOverwriteFileCallback(FOutputFilename) then
              s := 'y'#13#10
            else
              s := 'n'#13#10;
            WriteStdIn(write_stdin, s, count);
          end
          else if c[2] = 'openfile.askoutname' then
          begin
            s := FOutputFilename;
            if not Assigned(FGetOutputFilenameCallback) or
               not FGetOutputFilenameCallback(s) then
              terminateProgram := true
            else
            begin
              s := s + #13#10;
              WriteStdIn(write_stdin, s, count);
              FOutputFilename := s;
            end;
          end
          else
          begin
            if Assigned(FRequestData) then
            begin
              FRequestData.LineNumber := lineNumber;
            end;

            if not Assigned(FPromptResponseCallback) or
               not FPromptResponseCallback(Copy(c[1], 5, Length(c[1])), c[2], FRequestData, s) then
            begin
              // Bad stuff -- we've come across a prompt that we
              // don't know how to answer.

              MessageDlg(
                'GPGWrapper error: don''t know how to respond to GnuPG prompt "' + c[2] + '".'#13#10#10 +
                'Please contact the author about this bug.',
                mtError, [mbOK], 0
              );

              Halt;
            end;

            WriteStdIn(write_stdin, s, count);
          end;
        end;
      end;
    finally
      c.Free;
    end;
  end;

  if Assigned(FDataReceivedCallback) then FDataReceivedCallback(cmd, lineNumber, isFragment, write_stdin, terminateProgram);
end;

procedure TGPGWrapper.WriteDebug(str: string);
var
  f: TFileStream;
  bytes: TBytes;
begin
  if GGPGLocation.DebugFile = '' then exit;

  if not FileExists(GGPGLocation.DebugFile) then
  begin
    try
      f := TFileStream.Create(GGPGLocation.DebugFile, fmOpenWrite or fmCreate);
    except
      exit;
    end;
  end
  else
  begin
    try
      f := TFileStream.Create(GGPGLocation.DebugFile, fmOpenReadWrite);
      f.Position := f.Size;
    except
      exit;
    end;
  end;

  try
    bytes := TEncoding.UTF8.GetBytes(str);
    f.Write(bytes[0], Length(bytes));
  finally
    f.Free;
  end;
end;










{ TGPGKey }

constructor TGPGKey.Create;
begin
  FSubKeys := TObjectList.Create;
  FSignatures := TObjectList.Create;
  FUserIDs := TObjectList.Create;
end;

destructor TGPGKey.Destroy;
begin
  FUserIDs.Free;
  FSignatures.Free;
  FSubKeys.Free;
end;

function TGPGKey.GetFingerprint: string;
var
  i: integer;
begin
  result := FFingerprint;
  i := 5;
  while i <= Length(result) do
  begin
    Insert(' ', result, i);
    Inc(i, 5);
  end;
end;

function TGPGKey.GetKeyID(long: boolean): string;
begin
  if long then
    result := LongID
  else
    result := ShortID;
end;

function TGPGKey.GetShortKeyID: string;
begin
  result := Copy(LongID, 9, 8);
end;

function TGPGKey.GetLongKeyID: string;
begin
  if (FLongID = '') and (FFingerprint <> '') then
    Result := Copy(FFingerprint, Length(FFingerprint) - 15, 16)
  else
    Result := FLongID;
end;

function TGPGKey.GetUserIDComment: string;
var
  n: integer;
begin
  result := '';
  n := Pos('(', UserID);
  if n = 0 then Exit;
  result := Copy(UserID, n + 1, Length(UserID));
  n := Pos(')', result);
  if n > 0 then result := Copy(result, 1, n - 1);
  result := Decode(result);
end;

function TGPGKey.GetUserIDEmail: string;
var
  n: integer;
begin
  result := '';
  n := Pos('<', UserID);
  if n = 0 then Exit;
  result := Copy(UserID, n + 1, Length(UserID));
  n := Pos('>', result);
  if n > 0 then result := Copy(result, 1, n - 1);
  result := Decode(result);
end;

function TGPGKey.GetUserIDName: string;
var
  n: integer;
begin
  result := UserID;
  n := Pos(' <', UserID);
  if n > 0 then result := Copy(result, 1, n - 1);
  n := Pos(' (', result);
  if n > 0 then result := Copy(result, 1, n - 1);
  result := Decode(result);
end;

function TGPGKey.IsExpired: boolean;
begin
  result :=
    (FUserTrust = trustExpired) or
    (FCalcTrust = trustExpired) or
    ((FExpiryDate > 0) and (Now > FExpiryDate));
end;

function TGPGKey.IsValid: boolean;
begin
  result :=
    not IsExpired and
    not (FUserTrust in [trustInvalid, trustDisabled, trustRevoked]) and
    not (FCalcTrust in [trustInvalid, trustDisabled, trustRevoked]);
end;

function TGPGKey.Parse(line: string): boolean;
var
  l: TStringList;
  algo: integer;
  opts: string;
begin
  result := false;
  l := TStringList.Create;
  try
    if not Split(':', line, l) then exit;
    if l.Count < 1 then exit;

    if l[0] = 'pub' then FKeyType := gpgPublicPrimary
    else if l[0] = 'sub' then FKeyType := gpgPublicSecondary
    else if l[0] = 'sec' then FKeyType := gpgSecretPrimary
    else if l[0] = 'ssb' then FKeyType := gpgSecretSecondary
    else if l[0] = 'sig' then FKeyType := gpgSignature
    else if l[0] = 'fpr' then FKeyType := gpgFingerprint
    else if l[0] = 'uid' then FKeyType := gpgUserID
    else exit;

    case FKeyType of
      gpgFingerprint: if l.Count <> 11 then exit;
      gpgUserID:      if l.Count <> 11 then exit;
      gpgSignature:   if l.Count <> 12 then exit;
      else            if l.Count <> 13 then exit;
    end;

    if FKeyType = gpgFingerprint then
    begin
      FFingerprint := l[9];
      result := true;
      exit;
    end;

    if l[1] <> '' then
    begin
      case l[1][1] of
        '-': FCalcTrust := trustNotSelected;
        'q', 'o': FCalcTrust := trustUnknown;
        'i': FCalcTrust := trustInvalid;
        'd': FCalcTrust := trustDisabled;
        'r': FCalcTrust := trustRevoked;
        'e': FCalcTrust := trustExpired;
        'n': FCalcTrust := trustNone;
        'm': FCalcTrust := trustMarginal;
        'f': FCalcTrust := trustFull;
        'u': FCalcTrust := trustUltimate;
        else exit;
      end;
    end;

    FKeyLength := StrToIntDef(l[2], 0);
    
    algo := StrToIntDef(l[3], -1);
    case algo of
      1:  FAlgorithm := gpgRSA;
      16: FAlgorithm := gpgElGamal;
      17: FAlgorithm := gpgDSA;
      else FAlgorithm := gpgUnknownAlgorithm;
    end;

    FLongID := l[4];
    FCreatedDate := YMDToDateTime(l[5]);
    if l[6] <> '' then FExpiryDate := YMDToDateTime(l[6]);
    FFingerprint := l[7];

    if l[8] <> '' then
    begin
      case l[8][1] of
        '-': FUserTrust := trustNotSelected;
        'q', 'o': FUserTrust := trustUnknown;
        'i': FUserTrust := trustInvalid;
        'd': FUserTrust := trustDisabled;
        'r': FUserTrust := trustRevoked;
        'e': FUserTrust := trustExpired;
        'n': FUserTrust := trustNone;
        'm': FUserTrust := trustMarginal;
        'f': FUserTrust := trustFull;
        'u': FUserTrust := trustUltimate;
        else exit;
      end;
    end;

    // Store the user ID _raw_.
    RawUserID := l[9];

    if l.Count >= 12 then
    begin
      opts := l[11];
      if Pos('s', opts) > 0 then FSigning := true;
      if Pos('e', opts) > 0 then FEncrypt := true;
      if Pos('D', opts) > 0 then FDisabled := true;
    end;
    
    result := true;
  finally
    l.Free;
  end;
end;

function TGPGKey.Decode(text: string): string;
var
  i, n: integer;
begin
  // optimisation
  if Pos('\', text) = 0 then
  begin
    result := text;
    exit;
  end;

  result := '';
  i := 1;
  while i < Length(text) - 4 do
  begin
    if (text[i] = '\') and (text[i+1] = 'x') and (
         ( (text[i+2] >= 'a') and (text[i+2] <= 'f') ) or
         ( (text[i+2] >= '0') and (text[i+2] <= '9') )
       ) and (
         ( (text[i+3] >= 'a') and (text[i+3] <= 'f') ) or
         ( (text[i+3] >= '0') and (text[i+3] <= '9') )
       ) then
    begin
      n := StrToInt('$' + Copy(text, i + 2, 2));
      if (n < 32) or (n = 127) then
        result := result + '?'
      else
        result := result + Chr(n);
      Inc(i, 3);
    end
    else
      result := result + text[i];

    Inc(i);
  end;

  while i <= Length(text) do
  begin
    result := result + text[i];
    Inc(i);
  end;
end;

function TGPGKey.Encode(text: string): string;
var
  i: integer;
begin
  result := '';
  for i := 1 to Length(text) do
  begin
    if (Ord(text[i]) < 32) or (Ord(text[i]) > 126) or (text[i] = '\') then
      result := result + '\x' + LowerCase(IntToHex(Ord(text[i]), 2))
    else
      result := result + text[i];
  end;
end;


function TGPGKey.GetUserID: string;
begin
  result := Decode(FUserID);
end;

procedure TGPGKey.SetUserID(const Value: string);
begin
  FUserID := Encode(Value);
end;

{ TGPGLocation }

constructor TGPGLocation.Create(useGPGRegistry: boolean; useEXEPath, useHomeDir: string);

  // Make relative paths absolute relative to cryptophane.exe directory.
  function MakeAbsolutePath(path: string): string;
  begin
    if (Length(path) > 3) and (Copy(path, 2, 2) = ':\') then
      result := path
    else if (Length(path) > 2) and (path[2] = ':') then // C:blah --> C:\blah
      result := path[1] + ':/' + Copy(path, 3, Length(path))
    else if (Length(path) > 2) and (Copy(path, 1, 2) = '\\') then
      result := path
    else if (path <> '') and (path[1] = '\') then
    begin
      result := ExtractFileDir(ParamStr(0));
      result := result[1] + ':' + path;
    end
    else
      result := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + path;
  end;

var
  r: TRegistry;
  paths: TStringList;
  progFilesDir, appDataDir: string;
  i: integer;
  path: array[0..MAX_PATH] of char;
begin
  if SHGetSpecialFolderPath(0, path, CSIDL_APPDATA, false) then appDataDir := path;
  if appDataDir = '' then appDataDir := 'C:\WINDOWS\Application Data';

  if useHomeDir <> '' then
  begin
    useHomeDir := MakeAbsolutePath(useHomeDir);

    if not DirectoryExists(useHomeDir) then
    begin
      raise Exception.Create('Cannot locate specified HomeDir at ' + useHomeDir);
    end;

    FHomeDir := useHomeDir;
  end;

  if useEXEPath <> '' then
  begin
    useEXEPath := MakeAbsolutePath(useEXEPath);

    if LowerCase(Copy(useEXEPath, Length(useEXEPath) - 3, 4)) <> '.exe' then
    begin
      useEXEPath := IncludeTrailingPathDelimiter(useEXEPath) + 'gpg.exe';
    end;

    if not FileExists(useEXEPath) then
    begin
      raise CannotFindGPGException.Create('Cannot find GnuPG executable at path ' + useEXEPath);
    end;

    FEXEPath := useEXEPath;
    if FHomeDir = '' then FHomeDir := IncludeTrailingPathDelimiter(appDataDir) + 'GnuPG';
    FUseGPGRegistry := false;
    exit;
  end;

  FUseGPGRegistry := useGPGRegistry;

  progFilesDir := 'C:\Program Files';

  r := TRegistry.Create;
  try
    r.RootKey := HKEY_LOCAL_MACHINE;
    if r.OpenKey('Software\Microsoft\Windows\CurrentVersion', false) then
    begin
      if r.ValueExists('ProgramFilesDir') then
        progFilesDir := r.ReadString('ProgramFilesDir')
      else if r.ValueExists('ProgramFilesPath') then
        progFilesDir := r.ReadString('ProgramFilesPath');

      r.CloseKey;
    end;

    if useGPGRegistry then
    begin
      if r.OpenKey('SOFTWARE\GNU\GNUPG', false) then
      begin
        if r.ValueExists('gpgProgram') then FEXEPath := r.ReadString('gpgProgram');

        if FHomeDir = '' then
        begin
          if r.ValueExists('HomeDir') then FHomeDir := r.ReadString('HomeDir');
          if r.ValueExists('Install Directory') then FHomeDir := r.ReadString('Install Directory');
        end;

        if (FHomeDir <> '') and (FEXEPath = '') then
        begin
          FEXEPath := IncludeTrailingPathDelimiter(FHomeDir) + 'gpg.exe';
        end;

        if (FHomeDir = '') and (FEXEPath <> '') then
        begin
          FHomeDir := IncludeTrailingPathDelimiter(appDataDir) + 'GnuPG';
        end;

        r.CloseKey;
      end;
    end;
  finally
    r.Free;
  end;

  if (FEXEPath = '') or not FileExists(FEXEPath) or not DirectoryExists(FHomeDir) then
  begin
    paths := TStringList.Create;
    try
      paths.Add(ExtractFilePath(ParamStr(0)) + '\GnuPG\gpg.exe');
      paths.Add(ExtractFilePath(ParamStr(0)) + '\gpg\gpg.exe');
      paths.Add(ExtractFilePath(ParamStr(0)) + '\gpg.exe');
      paths.Add(progFilesDir + '\GNU\GnuPG\gpg.exe');
      paths.Add(progFilesDir + '\GnuPG\gpg.exe');
      paths.Add('C:\GNUPG\gpg.exe');
      paths.Add(progFilesDir + '\GPG\gpg.exe');

      for i := 0 to paths.Count - 1 do
      begin
        if FileExists(paths[i]) then
        begin
          FEXEPath := paths[i];
          if FHomeDir = '' then FHomeDir := IncludeTrailingPathDelimiter(appDataDir) + 'GnuPG';
          break;
        end;
      end;

      if FEXEPath = '' then raise CannotFindGPGException.Create('Cannot find GnuPG executable installed on this machine.');
    finally
      paths.Free;
    end;
  end;
end;

end.
