unit Crypto;

interface

uses Config, GPGOps, GPGWrapper,
     Contnrs, Classes, SysUtils;

type
  TCryptoOperation = (coEncrypt, coSign, coEncryptSign, coDecrypt, coVerify, coSignKey);
  TCryptoOperationSet = set of TCryptoOperation;

  TWrapper = class(TGPGWrapper)
  public
    function CreateKey: TGPGKey; override;
  end;

  TOps = class(TGPGOps)
  protected
    function CreateWrapperObject: TGPGWrapper; override;
  end;

  TCryptophaneKey = class(TGPGKey)
  protected
    FFolder: string;
  public
    constructor Create;
    property Folder: string read FFolder write FFolder;
    property UserTrust: TGPGTrust read FUserTrust write FUserTrust;
  end;

  TCrypto = class
  protected
    FPublicKeys, FSecretKeys: TObjectList;
    FOps: TOps;
    FAlwaysOverwrite: boolean;

    procedure HandleException(co: TCryptoOperation; e: Exception);
    procedure DecryptVerifySuccess(verify: boolean; validSignatures, invalidSignatures: TStrings);

    function GetPassphrase(getType: TGPGPassphraseGetType; longID: string; passphrase: PChar): boolean;
    function PromptOverwriteFile(const filename: string): boolean;
    function GetOutputFilename(var filename: string): boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure EncryptSign(co: TCryptoOperation; const inFilename: string = ''; const filter: string = ''; const outFilename: string = '');
    procedure Decrypt(inFilename: string = ''; outFilename: string = '');
    procedure Verify(inFilename: string = '');

    function SignKey(key: TGPGKey): boolean;
    function ImportKey(const filename: SysUtils.TFileName): boolean;
    function ImportKeys: boolean;
    function DeleteKey(key: TGPGKey; secretKey: boolean): boolean;
    function RevokeKey(key: TGPGKey): boolean;

    function GetPublicKeys: boolean;
    function GetSecretKeys: boolean;

    function ReceiveKey(key: string; showSuccess: boolean = true): boolean;
    function ReceiveKeys(keys: TStringList; showSuccess: boolean = true): boolean;

    function ChangeSecretKeyPassphrase(key: TGPGKey): boolean;

    function GetUserID(longID: string): string;
    function GetUserKey(longID: string): TGPGKey;

    property PublicKeys: TObjectList read FPublicKeys;
    property SecretKeys: TObjectList read FSecretKeys;
    property AlwaysOverwrite: boolean read FAlwaysOverwrite write FAlwaysOverwrite;
  end;


implementation

uses EncryptSign, DisplayData, Passphrase, NewPassphrase, ChangePassphrase, SymPassphrase,
     SignKey,
     Resources, Utils,
     Controls, Dialogs, Forms;

constructor TCrypto.Create;
begin
  FPublicKeys := TObjectList.Create;
  FSecretKeys := TObjectList.Create;
  FOps := TOps.Create;
  FOps.GetPassphraseCallback := GetPassphrase;
  FOps.PromptOverwriteFileCallback := PromptOverwriteFile;
  FOps.GetOutputFilenameCallback := GetOutputFilename;
end;

destructor TCrypto.Destroy;
begin
  FreeAndNil(FOps);
  FSecretKeys.Free;
  FPublicKeys.Free;
end;

procedure TCrypto.EncryptSign(co: TCryptoOperation; const inFilename, filter, outFilename: string);
var
  eso: TGPGEncryptSignOpts;
  esf: TEncryptSignForm;
  infn, outfn: string;
  signKeyLongID: string;
  recipients: TStringList;
  msg: string;
begin
  infn := inFilename;
  outfn := outFilename;

  esf := TEncryptSignForm.Create(nil);
  recipients := TStringList.Create;
  try
    if esf.Display(self, infn, outfn, co in [coEncrypt, coEncryptSign],
                   co in [coSign, coEncryptSign], filter, eso, recipients,
                   signKeyLongID) = mrOK then
    begin
      try
        if ((gpgEncrypt in eso) or (gpgEncryptSym in eso)) and
           ((gpgSign in eso) or (gpgSignDetached in eso) or (gpgSignPlain in eso)) then
          co := coEncryptSign
        else if (gpgEncrypt in eso) or (gpgEncryptSym in eso) then
          co := coEncrypt
        else
          co := coSign;

        FOps.EncryptSign(eso, infn, outfn, signKeyLongID, recipients);
        case co of
          coEncryptSign: msg := REncryptSignSuccess;
          coEncrypt: msg := REncryptSuccess;
          coSign: msg := RSignSuccess;
        end;
        if (msg <> '') and GConfig.ShowSuccessDialogs then
        begin
          MessageDlg(msg, mtInformation, [mbOK], 0);
        end;
      except
        on e: Exception do HandleException(co, e);
      end;
    end;
  finally
    FreeAndNil(esf);
    FreeAndNil(recipients);
  end;
end;

procedure TCrypto.Decrypt(inFilename, outFilename: string);
var
  ext: string;
  dstExt: string;
  od: TOpenDialog;
  sd: TSaveDialog;
  validSignatures, invalidSignatures: TStringList;
begin
  od := TOpenDialog.Create(nil);
  sd := TSaveDialog.Create(nil);
  validSignatures := TStringList.Create;
  invalidSignatures := TStringList.Create;
  try
    if inFilename = '' then
    begin
      od.FileName := '';
      od.Filter := 'GPG/PGP files|*.gpg;*.pgp;*.asc|All Files|*.*';
      if not od.Execute then Exit;
      inFilename := od.FileName;
    end;

    if outFilename = '' then
    begin
      ext := ExtractFileExt(inFilename);
      if (ext = '.gpg') or (ext = '.pgp') or (ext = '.asc') then begin
        sd.FileName := Copy(inFilename, 1, Length(inFilename) - Length(ext));
        ext := ExtractFileExt(sd.FileName);
        dstExt := Copy(ext, 2, Length(ext));
      end
      else sd.FileName := inFilename + '.decrypted';

      sd.DefaultExt := dstExt;
      sd.Filter := dstExt + ' files|*.' + dstExt + '|All Files|*.*';
      if not sd.Execute then Exit;
      outFilename := sd.FileName;
      if ExtractFileExt(outFilename) = '' then outFilename := outFilename + ext;
    end;

    try
      FOps.Decrypt(inFilename, outFilename, validSignatures, invalidSignatures);
      DecryptVerifySuccess(false, validSignatures, invalidSignatures);
    except
      on e: Exception do HandleException(coDecrypt, e);
    end;
  finally
    invalidSignatures.Free;
    validSignatures.Free;
    sd.Free;
    od.Free;
  end;
end;

procedure TCrypto.Verify(inFilename: string);
var
  od: TOpenDialog;
  validSignatures, invalidSignatures: TStringList;  
begin
  od := TOpenDialog.Create(nil);
  validSignatures := TStringList.Create;
  invalidSignatures := TStringList.Create;
  try
    if inFilename = '' then
    begin
      od.Filter := 'GPG/PGP/Signature files|*.gpg;*.pgp;*.asc;*.sig|All Files|*.*';
      od.FileName := '';
      if not od.Execute then Exit;
      inFilename := od.FileName;
    end;

    try
      FOps.Verify(inFilename, validSignatures, invalidSignatures);
      DecryptVerifySuccess(true, validSignatures, invalidSignatures);
    except
      on e: Exception do HandleException(coVerify, e);
    end;
  finally
    invalidSignatures.Free;
    validSignatures.Free;
    od.Free;
  end;
end;

procedure TCrypto.HandleException(co: TCryptoOperation; e: Exception);
var
  msg: string;
  i, n: integer;
  p: TGPGKey;
begin
  if e is GPGInvalidRecipientsException then
  begin
    msg := '';
    for i := 0 to FPublicKeys.Count - 1 do
    begin
      p := FPublicKeys[i] as TGPGKey;
      n := GPGInvalidRecipientsException(e).LongIDs.IndexOf(p.LongID);
      if (n >= 0) and (p.UserID <> '') then
      begin
        msg := msg + '   ' + p.UserID + ' (' + GPGInvalidRecipientsException(e).Errors[n] + ')'#13#10;
      end;
    end;
    if msg = '' then
      msg := RMainInvalidRecipient
    else
      msg := RTheRecipient + #13#10 + msg + RIsNotValid;

    MessageDlg(msg + #13#10#10 + RInvalidRecipientHelp, mtError, [mbOK], 0);
    exit;
  end;

  if e is GPGNoDataException then
  begin
    MessageDlg(RMainNoData, mtError, [mbOK], 0);
    exit;
  end;

  if e is GPGAlreadySignedException then
  begin
    MessageDlg(RMainPublicAlreadySigned + #13#10'   ' + GetUserID(GPGKeyException(e).LongID), mtError, [mbOK], 0);
    exit;
  end;

  if e is GPGBadSignatureException then
  begin
    MessageDlg(RSignatureBy + #13#10'   ' + GetUserID(GPGKeyException(e).LongID) + RIsNotValid + #13#10#10 + RBadSignatureHelp, mtError, [mbOK], 0);
    exit;
  end;

  if e is GPGDecryptionFailedException then
  begin
    MessageDlg(RMainDecryptionFailed, mtError, [mbOK], 0);
    exit;
  end;

  if e is GPGNoSecretKeysException then
  begin
    if GPGKeysException(e).LongIDs.Count = 1 then
      msg := RTheSecretKey + #13#10#10
    else
      msg := ROneSecretKey + #13#10#10;
    for i := 0 to GPGKeysException(e).LongIDs.Count - 1 do
    begin
      msg := msg + '   ' + GetUserID(GPGKeysException(e).LongIDs[i]) + #13#10;
    end;
    msg := msg + #13#10 + RRequiredToDecryptNotFound;

    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  if e is GPGNoPublicKeyException then
  begin
    msg := RThePublicKey + #13#10#10;
    msg := msg + '   key ID ' + GPGKeyException(e).LongID + #13#10;
    msg := msg + #13#10 + RMainReqToValidate;
    if co = coDecrypt then msg := msg + #13#10#10 + RMainDecryptionSuccessful;
    msg := msg + #13#10#10 + RMainWantToDownloadPrompt;

    if MessageDlg(msg, mtError, [mbYes, mbNo], 0) = mrYes then
    begin
      ReceiveKey(GPGKeyException(e).LongID, false);
    end;
    exit;
  end;

  if e is GPGOpsException then
  begin
    MessageDlg(RUnknownError + #13#10#10 + e.Message + #13#10#10 + GPGOpsException(e).RawData, mtError, [mbOK], 0);
    exit;
  end;

  MessageDlg(RUnknownError + #13#10#10 + e.Message, mtError, [mbOK], 0);
end;

function TCrypto.GetUserID(longID: string): string;
var
  key: TGPGKey;
begin
  key := GetUserKey(longID);
  if Assigned(key) then
    result := key.UserID
  else
    result := '<' + RUnknownKey + ' ' + longID + '>';
end;

function TCrypto.GetUserKey(longID: string): TGPGKey;
var
  key, subkey: TGPGKey;
  i, j: integer;
begin
  result := nil;
  for i := 0 to FPublicKeys.Count - 1 do
  begin
    key := FPublicKeys[i] as TGPGKey;
    if key.LongID = longID then
    begin
      result := key;
      exit;
    end;
    for j := 0 to key.SubKeys.Count - 1 do
    begin
      subkey := key.SubKeys[j] as TGPGKey;
      if subkey.LongID = longID then
      begin
        result := key;
        exit;
      end;
    end;
  end;
end;


function TCrypto.ReceiveKey(key: string; showSuccess: boolean): boolean;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Add(key);
    result := ReceiveKeys(sl, showSuccess);
  finally
    sl.Free;
  end;
end;

function TCrypto.ReceiveKeys(keys: TStringList; showSuccess: boolean): boolean;
var
  sl: TStringList;
  imported: cardinal;
begin
  result := false;
  if GConfig.KeyServers.Count = 0 then
  begin
    MessageDlg(RMainNoKeyservers, mtError, [mbOK], 0);
    Exit;
  end;

  sl := TStringList.Create;
  Screen.Cursor := crHourGlass;
  try
    try
      FOps.RecvKeys(GConfig.KeyServers[0], GConfig.ProxySetting, GConfig.ProxyHost, GConfig.ProxyPort, keys, imported, nil);
      Screen.Cursor := crDefault;
      if showSuccess then MessageDlg(RMainSuccessKeysReceived, mtInformation, [mbOK], 0);
      result := true;
    except
      on ce: GPGConnectException do
      begin
        Screen.Cursor := crDefault;
        MessageDlg(ce.Message, mtError, [mbOK], 0);
      end
      else
      begin
        Screen.Cursor := crDefault;
        MessageDlg(RMainFailKeysReceived, mtError, [mbOK], 0);
      end;
    end;
  finally
    sl.Free;
    Screen.Cursor := crDefault;
  end;
end;

function TCrypto.GetPassphrase(getType: TGPGPassphraseGetType; longID: string; passphrase: PChar): boolean;
var
  pf: TPassphraseForm;
  spf: TSymPassphraseForm;
  npf: TNewPassphraseForm;
  cpf: TChangePassphraseForm;
begin
  result := false;

  case getType of
    gpgExistingMessage:
    begin
      spf := nil;
      try
        spf := TSymPassphraseForm.Create(nil);
        result := spf.Display(passphrase);
      finally
        FreeAndNil(spf);
      end;
    end;

    gpgExistingKey:
    begin
      pf := nil;
      try
        pf := TPassphraseForm.Create(nil);
        result := pf.Display(passphrase, longID, GetUserKey(longID));
      finally
        FreeAndNil(pf);
      end;
    end;

    gpgNewMessage:
    begin
      npf := nil;
      try
        npf := TNewPassphraseForm.Create(nil);
        result := npf.Display(passphrase);
      finally
        FreeAndNil(npf);
      end;
    end;

    gpgNewKey:
    begin
      cpf := nil;
      try
        cpf := TChangePassphraseForm.Create(nil);
        result := cpf.Display(passphrase);
      finally
        FreeAndNil(cpf);
      end;
    end;
  end;
end;

function TCrypto.PromptOverwriteFile(const filename: string): boolean;
begin
  if FAlwaysOverwrite then
    result := true
  else
    result := MessageDlg('Overwrite existing file ' + filename + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

function TCrypto.GetOutputFilename(var filename: string): boolean;
var
  sd: TSaveDialog;
begin
  result := false;
  sd := TSaveDialog.Create(nil);
  try
    sd.FileName := filename;
    sd.Options := sd.Options + [ofOverwritePrompt, ofPathMustExist];
    sd.DefaultExt := Copy(ExtractFileExt(sd.FileName), 2, Length(ExtractFileExt(sd.FileName)));
    sd.Filter := sd.DefaultExt + ' files|*.' + sd.DefaultExt;
    if not sd.Execute then exit;
    filename := sd.FileName;
    result := true;
  finally
    sd.Free;
  end;
end;

function TCrypto.GetPublicKeys: boolean;
begin
  try
    FOps.GetPublicKeys(FPublicKeys);
    result := true;
  except
    result := false;
  end;
end;

function TCrypto.GetSecretKeys: boolean;
begin
  try
    FOps.GetSecretKeys(FSecretKeys);
    result := true;
  except
    result := false;
  end;
end;

function TCrypto.SignKey(key: TGPGKey): boolean;
var
  skf: TSignKeyForm;
  signWithLongID: string;
begin
  result := false;
  skf := TSignKeyForm.Create(nil);
  try
    if skf.Display(SecretKeys, key, signWithLongId) <> mrOK then exit;

    try
      FOps.SignKey(key.LongID, signWithLongID);
      result := true;
      MessageDlg(RMainSuccessKeySign, mtError, [mbOK], 0);
    except
      on GPGKeyExpiredException do MessageDlg(RMainFailKeySignExpired, mtError, [mbOK], 0);
      on oe: GPGOpsException do MessageDlg(RUnknownError + #13#10 + oe.RawData, mtError, [mbOK], 0);
      on e: Exception do MessageDlg(RUnknownError + #13#10 + e.Message, mtError, [mbOK], 0);
    end;
  finally
    FreeAndNil(skf);
  end;
end;

function TCrypto.ImportKeys: boolean;
var
  od: TOpenDialog;
begin
  result := false;
  od := TOpenDialog.Create(nil);
  try
    od.Filter := 'GPG/PGP files|*.gpg;*.pgp;*.asc|All Files|*.*';
    if not od.Execute then Exit;

    result := ImportKey(od.FileName);

  finally
    od.Free;
  end;

end;

function TCrypto.ImportKey(const filename: SysUtils.TFileName): boolean;
var
  sl: TStringList;
  i: integer;
  msg, imported: string;
  pubImported, pubUnchanged, secImported, secUnchanged, revoked: cardinal;
begin
  result := false;
  sl := TStringList.Create;
  try

    try
      FOps.ImportKeys(filename, pubImported, pubUnchanged, secImported, secUnchanged, revoked, sl);
    except
      MessageDlg(RMainImportFail, mtError, [mbOK], 0);
      exit;
    end;

    result := true;
    imported := '';
    for i := 0 to sl.Count - 1 do imported := imported + '   ' + sl[i] + #13#10;

    msg := '';
    if pubImported > 0 then msg := msg + RMainSuccessImportPublic + #13#10 + imported + #13#10#10;
    if secImported > 0 then msg := msg + Format(RMainSuccessImportSecret, [secImported]) + #13#10#10;
    if revoked > 0 then msg := msg + Format(RMainSuccessImportRevoked, [revoked]) + #13#10#10;

    if pubUnchanged > 0 then msg := msg + Format(RMainImportOtherPublicFail, [pubUnchanged]) + #13#10#10;
    if secUnchanged > 0 then msg := msg + Format(RMainImportOtherSecretFail, [secUnchanged]) + #13#10#10;

    if msg = '' then
      MessageDlg(RMainImportFail, mtError, [mbOK], 0)
    else
    begin
      // Remove the last #13#10#10 from the message.
      MessageDlg(Copy(msg, 1, Length(msg) - 3), mtInformation, [mbOK], 0);
    end;

  finally
    sl.Free;
  end;

end;

function TCrypto.DeleteKey(key: TGPGKey; secretKey: boolean): boolean;
begin
  result := false;
  try
    FOps.DeleteKey(key, secretKey);
    result := true;
  except
    on e: GPGException do MessageDlg(RMainDeleteError + #13#10#10 + e.Message, mtError, [mbOK], 0);
  end;
end;

function TCrypto.RevokeKey(key: TGPGKey): boolean;
var
  cert: string;
  sd: TSaveDialog;
  f: TFileStream;
  bytes: TBytes;
begin
  result := false;
  try
    FOps.RevokeKey(key, cert);
  except
    MessageDlg(RMainRevokeFail, mtError, [mbOK], 0);
    exit;
  end;

  sd := TSaveDialog.Create(nil);
  try
    sd.FileName := Trim(key.UserIDName + ' ' + key.UserIDEmail) + ' (' + Copy(key.LongID, Length(key.LongId)-7, 8) + ') revocation certificate.asc';
    sd.DefaultExt := 'asc';
    sd.Filter := 'ASC file|*.asc';
    sd.Options := sd.Options + [ofOverwritePrompt, ofPathMustExist];
    if sd.Execute then
    begin
      try
        f := TFileStream.Create(sd.FileName, fmCreate or fmOpenWrite);
        try
          bytes := TEncoding.UTF8.GetBytes(cert);
          f.Write(bytes[0], Length(bytes));
          result := true;
          MessageDlg(RMainSuccessCreateRevoke, mtInformation, [mbOK], 0);
        finally
          f.Free;
        end;
      except
        MessageDlg(Format(RCannotWriteFile, [sd.FileName]), mtError, [mbOK], 0);
        exit;
      end;
    end;
  finally
    sd.Free;
  end;
end;

function TCrypto.ChangeSecretKeyPassphrase(key: TGPGKey): boolean;
begin
  result := false;
  try
    FOps.ChangeSecretKeyPassphrase(key);
  except
    MessageDlg(RChangePassphraseFailed, mtError, [mbOK], 0);
    exit;
  end;

  MessageDlg(RChangePassphraseSuccess, mtInformation, [mbOK], 0);
  result := true;
end;





{ TOps }

function TOps.CreateWrapperObject: TGPGWrapper;
begin
  result := TWrapper.Create;
end;

{ TWrapper }

function TWrapper.CreateKey: TGPGKey;
begin
  result := TCryptophaneKey.Create;
end;

{ TCryptophaneKey }

constructor TCryptophaneKey.Create;
begin
  inherited;
  Folder := 'Keys';
end;

procedure TCrypto.DecryptVerifySuccess(verify: boolean; validSignatures, invalidSignatures: TStrings);
var
  msg: string;
  i: integer;
begin
  if invalidSignatures.Count > 0 then
  begin
    msg := '';
    for i := 0 to invalidSignatures.Count - 1 do
    begin
      msg := msg + '   ' + GetUserID(invalidSignatures[i]) + #13#10;
    end;
    msg := Format(RMainWarningSignatures, [msg]);
    if not verify then msg := RMainWarningSignaturesButOK + #13#10#10 + msg;
    MessageDlg(msg, mtWarning, [mbOK], 0);
  end;

  if validSignatures.Count > 0 then
  begin
    if not verify then
      msg := RMainSuccessDecryptAndVerify
    else
      msg := RMainSuccessVerify;

    msg := msg + #13#10#13#10 + RMainSuccessSigsVerified + #13#10;
    for i := 0 to validSignatures.Count - 1 do
    begin
      msg := msg + '   ' + GetUserID(validSignatures[i]) + #13#10;
    end;

    if verify or GConfig.ShowSuccessDialogs then
    begin
      MessageDlg(msg, mtInformation, [mbOK], 0);
    end;
  end;
end;


end.
