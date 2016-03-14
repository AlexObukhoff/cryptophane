unit Main;

interface

uses
  GPGWrapper, Config, Crypto,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, Contnrs, ImgList, Buttons, ExtCtrls,
  ScaledForm;//, pngimage;

const
  WM_STARTUP_COMPLETE = WM_USER + 22;
  CColumnNames: array [TCColumns] of string =
    ('Name','E-mail','Comment','Trust','Sig/UID','Created','Expires','Key ID');
  CDefaultColumnWidths: array [TCColumns] of integer =
    (120,180,100,66,55,70,70,125);
  CColumnAlignments: array [TCColumns] of TAlignment =
    (taLeftJustify, taLeftJustify, taLeftJustify, taCenter, taCenter, taLeftJustify, taLeftJustify, taLeftJustify);

type
  TMainForm = class(TScaledForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Keys1: TMenuItem;
    Refresh1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    StatusBar: TStatusBar;
    View1: TMenuItem;
    DisplayExpiredKeys1: TMenuItem;
    Label1: TLabel;
    FilterEdit: TEdit;
    N1: TMenuItem;
    PublicKeys1: TMenuItem;
    Secretkeys1: TMenuItem;
    Encrypt1: TMenuItem;
    Sign1: TMenuItem;
    EncryptandSign1: TMenuItem;
    N2: TMenuItem;
    Decrypt1: TMenuItem;
    Verifysignature1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    PopupMenu: TPopupMenu;
    KeyProperties1: TMenuItem;
    N3: TMenuItem;
    Sign2: TMenuItem;
    Properties1: TMenuItem;
    N4: TMenuItem;
    Sign3: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Searchkeyserverforkeys1: TMenuItem;
    N7: TMenuItem;
    SendtoKeyserver1: TMenuItem;
    RefreshfromKeyserver1: TMenuItem;
    RefreshfromKeyserver2: TMenuItem;
    SendtoKeyserver2: TMenuItem;
    N8: TMenuItem;
    ImportKeys: TMenuItem;
    N10: TMenuItem;
    GenerateSecretKey1: TMenuItem;
    N9: TMenuItem;
    EditTrust1: TMenuItem;
    EditTrust2: TMenuItem;
    GetKeyfromKeyserver1: TMenuItem;
    ExportPublicKeys1: TMenuItem;
    ExportSecretKeys1: TMenuItem;
    SmallImageList: TImageList;
    ViewButton: TSpeedButton;
    ViewPopupMenu: TPopupMenu;
    Icon1: TMenuItem;
    Report1: TMenuItem;
    N11: TMenuItem;
    Icon2: TMenuItem;
    Report2: TMenuItem;
    Encryptto1: TMenuItem;
    ools1: TMenuItem;
    Options1: TMenuItem;
    CryptophaneWebSite1: TMenuItem;
    DisplayExpiredKeysButton: TSpeedButton;
    DeleteKey1: TMenuItem;
    DeleteKey2: TMenuItem;
    LargeImageList: TImageList;
    HintHeadingLabel: TLabel;
    HintLine2Label: TLabel;
    CryptophaneImage: TImage;
    HintLink2Label: TLabel;
    HintLine1Label: TLabel;
    HintLink1Label: TLabel;
    HintBevel: TBevel;
    Hints1: TMenuItem;
    Contents1: TMenuItem;
    Index1: TMenuItem;
    N12: TMenuItem;
    De1: TMenuItem;
    N13: TMenuItem;
    Panel: TPanel;
    TreeView: TTreeView;
    Splitter: TSplitter;
    ListView: TListView;
    Folders1: TMenuItem;
    TreeMenu: TPopupMenu;
    Add1: TMenuItem;
    Delete1: TMenuItem;
    Rename1: TMenuItem;
    N14: TMenuItem;
    DonatetowardsCryptophanedevelopment1: TMenuItem;
    Comments1: TMenuItem;
    GenerateRevocationCertificateforSelectedKey1: TMenuItem;
    ChangePassphraseofSelectedKey1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DisplayExpiredKeys1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure PublicKeys1Click(Sender: TObject);
    procedure Secretkeys1Click(Sender: TObject);
    procedure Encrypt1Click(Sender: TObject);
    procedure Sign1Click(Sender: TObject);
    procedure EncryptandSign1Click(Sender: TObject);
    procedure Decrypt1Click(Sender: TObject);
    procedure Verifysignature1Click(Sender: TObject);
    procedure Sign3Click(Sender: TObject);
    procedure Sign2Click(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure KeyProperties1Click(Sender: TObject);
    procedure Searchkeyserverforkeys1Click(Sender: TObject);
    procedure SendtoKeyserver1Click(Sender: TObject);
    procedure RefreshfromKeyserver1Click(Sender: TObject);
    procedure RefreshfromKeyserver2Click(Sender: TObject);
    procedure SendtoKeyserver2Click(Sender: TObject);
    procedure ImportKeysClickClick(Sender: TObject);
    procedure GenerateSecretKey1Click(Sender: TObject);
    procedure EditTrust1Click(Sender: TObject);
    procedure EditTrust2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GetKeyfromKeyserver1Click(Sender: TObject);
    procedure ExportPublicKeys1Click(Sender: TObject);
    procedure ExportSecretKeys1Click(Sender: TObject);
    procedure ListViewAdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Icon1Click(Sender: TObject);
    procedure Report1Click(Sender: TObject);
    procedure ViewButtonClick(Sender: TObject);
    procedure ListViewDblClick(Sender: TObject);
    procedure ListViewKeyPress(Sender: TObject; var Key: Char);
    procedure FilterEditKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure Encryptto1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure CryptophaneWebSite1Click(Sender: TObject);
    procedure DisplayExpiredKeysButtonClick(Sender: TObject);
    procedure DeleteKey1Click(Sender: TObject);
    procedure DeleteKey2Click(Sender: TObject);
    procedure Hints1Click(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure Index1Click(Sender: TObject);
    procedure De1Click(Sender: TObject);
    procedure HintLink1LabelClick(Sender: TObject);
    procedure HintLink2LabelClick(Sender: TObject);
    procedure Folders1Click(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Delete1Click(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure TreeViewEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure Rename1Click(Sender: TObject);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DonatetowardsCryptophanedevelopment1Click(Sender: TObject);
    procedure Comments1Click(Sender: TObject);
    procedure GenerateRevocationCertificateforSelectedKey1Click(
      Sender: TObject);
    procedure ChangePassphraseofSelectedKey1Click(Sender: TObject);
  private
    FFirstFormShow: boolean;
    FHintLink1Index, FHintLink2Index: string;
    FTerminated: boolean;

    FStartupCommand: string;
    FStartupFilename: string;
    FEXEPath: string;
    FHomeDir: string;
    FNoConfig: boolean;
    FIgnoreGPGRegistry: boolean;

    FTreeNodeMenu: TTreeNode;
    FCrypto: TCrypto;

    procedure ParseCommandLine;
    procedure RunStartupCommand;

    procedure SetColumns;
    procedure UpdateView;
    procedure UpdateFolders;
    procedure UpdateStuff;
    procedure UpdateHints;
    procedure ClearKeyLists;
    procedure GetKeyList;
    procedure CheckVersion;
    procedure KeySign;
    procedure RefreshKeyList;
    procedure ExportKeys(secret: boolean);
    procedure DeleteKey;

    procedure AcceptFiles(var msg: TMessage); message WM_DROPFILES;
    procedure StartupComplete(var msg: TMessage); message WM_STARTUP_COMPLETE;

    function MakeFolder(folder: string): TTreeNode;
    function GetCurrentFolder: string;
    function GetTreeFolderName(tn: TTreeNode): string;
    procedure UpdateSecretTrustLevelsFromPublicKeys;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses Resources, ShellSetup, About, Passphrase, EncryptSign, KeyGet, GPGOps,
  SignKey, Setup, KeyProperties, KeySearch, KeySend, GenerateKey, EditTrust,
  AddFolder,
  Utils,
  DefaultRegistry,
  Math, ShellAPI, ConHTMLHelp, GetMessage, DisplayData, KeyExport,
  DateUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FFirstFormShow := true;

  ParseCommandLine;

  GConfig := TConfig.Create(FNoConfig);
  GConfig.Load;

  try
    GGPGLocation := TGPGLocation.Create(not FIgnoreGPGRegistry, FEXEPath, FHomeDir);
    //GGPGLocation.DebugFile := 'C:\test2\Cryptophane debug log.txt';
    CheckVersion;
  except
    on CannotFindGPGException do
    begin
      MessageDlg(RGPGNotInstalled, mtError, [mbOK], 0);
      FTerminated := true;
      Application.Terminate;
      exit;
    end;

    on e: Exception do
    begin
      MessageDlg(e.Message, mtError, [mbOK], 0);
      FTerminated := true;
      Application.Terminate;
      exit;
    end;
  end;

  FCrypto := TCrypto.Create;

  UpdateStuff;
  SetColumns;

  Caption := Caption + ' ' + GetFileVer(Application.ExeName, false);

  GetKeyList;

  DragAcceptFiles(Handle, true);

  if (ParamCount > 0) and (ParamStr(1) = '/uninstall') then
  begin
    TShellSetup.Remove;
    FTerminated := true;
    Application.Terminate;
    exit;
  end;

  if not FNoConfig then TShellSetup.Setup;

  Application.ShowMainForm := false;
  PostMessage(Handle, WM_STARTUP_COMPLETE, 0, 0);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if FTerminated or not FFirstFormShow then exit;
  FFirstFormShow := false;

  if GConfig.WindowRect.Right - GConfig.WindowRect.Left > 0 then
  begin
    Left := GConfig.WindowRect.Left;
    Top := GConfig.WindowRect.Top;
    Width := GConfig.WindowRect.Right - Left;
    Height := GConfig.WindowRect.Bottom - Top;
  end;

  TreeView.Width := GConfig.FolderWidth;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(Handle, false);

  FreeAndNil(FCrypto);

  if Assigned(GConfig) then
  begin
    GConfig.WindowRect := Rect(Left, Top, Left + Width, Top + Height);
    GConfig.Save;
    FreeAndNil(GConfig);
  end;

  FreeAndNil(GGPGLocation);
end;

function LoadFileToStr(const FileName: TFileName): String;
var
  FileStream : TFileStream;
  Bytes: TBytes;

begin
  Result:= '';
  FileStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    if FileStream.Size>0 then begin
      SetLength(Bytes, FileStream.Size);
      FileStream.Read(Bytes[0], FileStream.Size);
    end;
    Result:= TEncoding.ASCII.GetString(Bytes);
  finally
    FileStream.Free;
  end;
end;

function IsPublicKey(filename: string): boolean;
begin
  result := ansipos('-----BEGIN PGP PUBLIC KEY BLOCK-----', LoadFileToStr(filename)) > 0;
end;

procedure TMainForm.StartupComplete(var msg: TMessage);
begin
  RunStartupCommand;
end;

procedure TMainForm.ParseCommandLine;
var
  p, ext, inifn, key, value: string;
  n, i: integer;
  f: TFileStream;
  ss: TStringStream;
  sl: TStringList;
begin
  inifn := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'cryptophane.ini';
  if FileExists(inifn) then
  begin
    try
      f := TFileStream.Create(inifn, fmOpenRead);
      ss := TStringStream.Create('');
      sl := TStringList.Create;
      try
        ss.CopyFrom(f, f.Size);
        sl.Text := ss.DataString;

        for i := 0 to sl.Count - 1 do
        begin
          p := Trim(sl[i]);
          if p = '' then continue;
          if p[1] = '#' then continue;

          n := Pos('=', p);
          if n > 0 then
          begin
            key := LowerCase(Trim(Copy(p, 1, n - 1)));
            value := Trim(Copy(p, n + 1, Length(p)));
          end
          else
          begin
            key := LowerCase(p);
            value := '';
          end;

          if ((key = 'gpg') or (key = 'gpg-path')) and (value <> '') then
          begin
            FEXEPath := value;
            FIgnoreGPGRegistry := true;
          end

          else if (key = 'homedir') and (value <> '') then
          begin
            FHomeDir := value;
          end

          else if key = 'no-config' then FNoConfig := true

          else if key = 'ignore-gpg-registry' then FIgnoreGPGRegistry := true

          else if key = 'memstick' then
          begin
            FNoConfig := true;
            FIgnoreGPGRegistry := true;
          end

          else  ; // error?
        end;

      finally
        sl.Free;
        ss.Free;
        f.Free;
      end;
    except
    end;
  end;

  i := 1;
  while i <= ParamCount do
  begin
    p := ParamStr(i);
    if p = '' then continue;

    if (p[1] <> '/') and (p[1] <> '-') and FileExists(p) and (FStartupCommand = '') then
    begin
      FStartupFilename := p;
      ext := ExtractFileExt(p);
      if (ext = '.asc') then begin
        if IsPublicKey(FStartupFilename) then FStartupCommand := 'import' else FStartupCommand := 'decrypt';
      end
      else if(ext = '.gpg') or (ext = '.pgp') then
        FStartupCommand := 'decrypt'
      else if ext = '.sig' then
        FStartupCommand := 'verify'
      else
        FStartupCommand := 'encrypt';

      Inc(i);
      continue;
    end;

    Delete(p, 1, 1);
    if (p <> '') and (p[1] = '-') then Delete(p, 1, 1);
    p := LowerCase(p);

    if ((p = 'encrypt') or (p = 'e')) and (i < ParamCount) then
    begin
      FStartupCommand := 'encrypt';
      FStartupFilename := ParamStr(i + 1);
      Inc(i, 2);
    end
    else if ((p = 'sign') or (p = 's')) and (i < ParamCount) then
    begin
      FStartupCommand := 'sign';
      FStartupFilename := ParamStr(i + 1);
      Inc(i, 2);
    end
    else if ((p = 'encryptsign') or (p = 'es') or (p = 'se')) and (i < ParamCount) then
    begin
      FStartupCommand := 'encryptsign';
      FStartupFilename := ParamStr(i + 1);
      Inc(i, 2);
    end
    else if ((p = 'decrypt') or (p = 'd')) and (i < ParamCount) then
    begin
      FStartupCommand := 'decrypt';
      FStartupFilename := ParamStr(i + 1);
      Inc(i, 2);
    end
    else if ((p = 'verify') or (p = 'v')) and (i < ParamCount) then
    begin
      FStartupCommand := 'verify';
      FStartupFilename := ParamStr(i + 1);
      Inc(i, 2);
    end

    // Options
    
    else if ((p = 'gpg') or (p = 'gpg-path')) and (i < ParamCount) then
    begin
      FEXEPath := ParamStr(i + 1);
      FIgnoreGPGRegistry := true;
      Inc(i, 2);
    end
    else if (p = 'homedir') and (i < ParamCount) then
    begin
      FHomeDir := ParamStr(i + 1);
      Inc(i, 2);
    end
    else if p = 'no-config' then
    begin
      FNoConfig := true;
      Inc(i);
    end
    else if p = 'ignore-gpg-registry' then
    begin
      FIgnoreGPGRegistry := true;
      Inc(i);
    end
    else if p = 'memstick' then
    begin
      FNoConfig := true;
      FIgnoreGPGRegistry := true;
      Inc(i);
    end
    else
    begin
      Inc(i);
    end;
  end;
end;

procedure TMainForm.RunStartupCommand;
var
  run: boolean;
  curdir: string;
begin
  run := false;

  SetForegroundWindow(Application.Handle);

  if FStartupCommand <> '' then
  begin
    run := true;
    if not FileExists(FStartupFilename) then
    begin
      MessageDlg(Format(RFileNotFound, [FStartupFilename]), mtError, [mbOK], 0);
      run := false;
    end
    else
    begin
      if (Length(FStartupFilename) < 2) or
         ((FStartupFilename[1] <> '\') and (FStartupFilename[2] <> ':')) then
      begin
        GetDir(0, curdir);
        FStartupFilename := IncludeTrailingPathDelimiter(curdir) + FStartupFilename;
      end;

      if FStartupCommand = 'import' then
        FCrypto.ImportKey(FStartupFilename)
      else if FStartupCommand = 'encrypt' then
        FCrypto.EncryptSign(coEncrypt, FStartupFilename)
      else if FStartupCommand = 'sign' then
        FCrypto.EncryptSign(coSign, FStartupFilename)
      else if FStartupCommand = 'encryptsign' then
        FCrypto.EncryptSign(coEncryptSign, FStartupFilename)
      else if FStartupCommand = 'decrypt' then
        FCrypto.Decrypt(FStartupFilename)
      else if FStartupCommand = 'verify' then
        FCrypto.Verify(FStartupFilename)
      else
        run := false;
    end;
  end;

  if run then
    Application.Terminate
  else
  begin
    WindowState := wsNormal;
    Show;
  end;
end;


procedure TMainForm.UpdateView;
var
  key: TCryptophaneKey;

  function GetDataColumn(column: TCColumns): string;
  begin
    result := '';
    case column of
      cName: result := key.UserIDName;
      cEmail: result := key.UserIDEmail;
      cComment: result := key.UserIDComment;
      cTrust:
      begin
        if key.CalcTrust > key.UserTrust then
        begin
          if CGPGTrust[key.CalcTrust] <> '' then result := '(' + CGPGTrust[key.CalcTrust] + ')';
        end
        else
          result := CGPGTrust[key.UserTrust];
      end;
      cSigs:
      begin
        if PublicKeys1.Checked then
        begin
          result := IntToStr(key.Signatures.Count);
          if key.UserIDs.Count > 0 then result := result + ' / ' + IntToStr(key.UserIDs.Count);
        end;
      end;
      cCreated: result := DateTimeToYMD(key.CreatedDate);
      cExpires: if key.ExpiryDate > 0 then result := DateTimeToYMD(key.ExpiryDate);
      cKeyID: result := key.GetKeyID(GConfig.Show16DigitIDs);
      else result := '[unknown field name]';
    end;
  end;

var
  i, j: integer;
  item: TListItem;
  keys: ^TObjectList;
  currentFolder: string;
  ci: TListColumn;
  lcfilter: string;
  found: boolean;
begin
  if not Assigned(FCrypto) then exit;

  ListView.Items.Clear;

  if GConfig.ViewComments and (ListView.Columns.Count = 7) then
  begin
    ci := TListColumn(ListView.Columns.Insert(2));
    ci.Index := 2;
    ci.Caption := 'Comment';
    ci.Width := 100;
  end;

  if not GConfig.ViewComments and (ListView.Columns.Count = 8) then
  begin
    ListView.Columns.Delete(2);
  end;

  if PublicKeys1.Checked then
    keys := @FCrypto.PublicKeys
  else
    keys := @FCrypto.SecretKeys;

  lcfilter := LowerCase(FilterEdit.Text);
  currentFolder := GetCurrentFolder;
  for i := 0 to keys.Count - 1 do
  begin
    key := TCryptophaneKey(keys^[i]);

    if not GConfig.ShowExpiredKeys and
       (key.ExpiryDate > 0) and
       (key.ExpiryDate < Now) then continue;

    if GConfig.ShowFolders and
       PublicKeys1.Checked and
       (currentFolder <> key.Folder) then continue;

    if (lcfilter <> '') and
       (Pos(lcfilter, LowerCase(key.UserID)) = 0) then
    begin
      found := false;
      for j := 0 to key.UserIDs.Count - 1 do
      begin
        if Pos(lcfilter, LowerCase(TCryptophaneKey(key.UserIDs[j]).UserID)) > 0 then
        begin
          found := true;
          break;
        end;
      end;
      if not found then continue;
    end;

    item := ListView.Items.Add;
    item.Caption := GetDataColumn(TCColumns(ListView.Columns[0].Tag));
    for j := 1 to ListView.Columns.Count - 1 do
    begin
      item.SubItems.Add(GetDataColumn(TCColumns(ListView.Columns[j].Tag)));
    end;

    if key.IsValid then
      item.ImageIndex := 0
    else
      item.ImageIndex := 1;
      
    item.Data := key; // Do this last so we don't get race conditions below.
  end;

  ListView.AlphaSort;
  UpdateHints;
end;

procedure TMainForm.DisplayExpiredKeys1Click(Sender: TObject);
begin
  GConfig.ShowExpiredKeys := not GConfig.ShowExpiredKeys;
  UpdateStuff;
  UpdateView;
end;

procedure TMainForm.GetKeyList;
var
  key: TCryptophaneKey;
  i, n: integer;
begin
  if not FCrypto.GetPublicKeys or
     not FCrypto.GetSecretKeys then
  begin
    MessageDlg(RMainCannotGetKeyLists, mtError, [mbOK], 0);
    Exit;
  end;

  UpdateSecretTrustLevelsFromPublicKeys;

  for i := 0 to FCrypto.PublicKeys.Count - 1 do
  begin
    key := FCrypto.PublicKeys[i] as TCryptophaneKey;
    n := GConfig.KeyFolders.IndexOf(key.LongID);
    if n >= 0 then
      key.Folder := GConfig.KeyFolders.Values[n]
    else
      GConfig.KeyFolders.Add(key.LongID, key.Folder);
  end;
  
  UpdateFolders; // calls UpdateView
end;

procedure TMainForm.Refresh1Click(Sender: TObject);
begin
  RefreshKeyList;
end;

procedure TMainForm.FilterEditChange(Sender: TObject);
begin
  UpdateView;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  AboutForm := TAboutForm.Create(Application);
  AboutForm.ShowModal;
  FreeAndNil(AboutForm);
end;

procedure TMainForm.PublicKeys1Click(Sender: TObject);
begin
  PublicKeys1.Checked := true;
  UpdateStuff;
  UpdateView;
end;

procedure TMainForm.Secretkeys1Click(Sender: TObject);
begin
  SecretKeys1.Checked := true;
  UpdateStuff;
  UpdateView;
end;

procedure TMainForm.Encrypt1Click(Sender: TObject);
var
  filter: string;
begin
  filter := '';
  if Assigned(ListView.Selected) then
    filter := TGPGKey(ListView.Selected.Data).LongID
  else if ListView.Items.Count = 1 then
    filter := TGPGKey(ListView.Items[0].Data).LongID;

  FCrypto.EncryptSign(coEncrypt, '', filter);
end;

procedure TMainForm.Sign1Click(Sender: TObject);
begin
  FCrypto.EncryptSign(coSign);
end;

procedure TMainForm.EncryptandSign1Click(Sender: TObject);
var
  filter: string;
begin
  filter := '';
  if Assigned(ListView.Selected) then
    filter := TGPGKey(ListView.Selected.Data).LongID
  else if ListView.Items.Count = 1 then
    filter := TGPGKey(ListView.Items[0].Data).LongID;

  FCrypto.EncryptSign(coEncryptSign, '', filter);
end;

procedure TMainForm.Decrypt1Click(Sender: TObject);
begin
  FCrypto.Decrypt;
end;

procedure TMainForm.Verifysignature1Click(Sender: TObject);
begin
  FCrypto.Verify;
end;

procedure TMainForm.AcceptFiles(var msg: TMessage);
var
  count, i: integer;
  acFilename: array [0..1023] of char;
  s: string;
  pt: TPoint;
  filter: string;
  item: TListItem;
begin
  count := DragQueryFile(
    msg.WParam,
    $FFFFFFFF,
    acFilename,
    1023
  );

  filter := '';
  if DragQueryPoint(msg.WParam, pt) then
  begin
    pt := ListView.ScreenToClient(ClientToScreen(pt));
    item := ListView.GetItemAt(pt.X, pt.y);
    if Assigned(item) and Assigned(item.Data) then filter := TGPGKey(item.data).LongID;
  end;

  for i := 0 to count - 1 do
  begin
    DragQueryFile(msg.WParam, i, acFilename, 1023);
    s := ExtractFileExt(acFilename);
    if (s = '.gpg') or (s = '.pgp') or (s = '.asc') then
      FCrypto.Decrypt(acFilename)
    else if s = '.sig' then
      FCrypto.Verify(acFilename)
    else
      FCrypto.EncryptSign(coEncryptSign, acFilename, filter);
  end;

  DragFinish(msg.WParam);
end;

procedure TMainForm.Sign3Click(Sender: TObject);
begin
  KeySign;
end;

procedure TMainForm.KeySign;
var
  p: TGPGKey;
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;

  p := ListView.Selected.Data;
  if p.KeyType = gpgSignature then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;

  FCrypto.SignKey(p);
  RefreshKeyList;
end;

procedure TMainForm.ClearKeyLists;
begin
  ListView.Items.Clear;
  FCrypto.SecretKeys.Clear;
  FCrypto.PublicKeys.Clear;
end;

procedure TMainForm.RefreshKeyList;
var
  i: integer;
  lastLongID: string;
begin
  if Assigned(ListView.Selected) then
  begin
    lastLongID := TGPGKey(ListView.Selected.Data).LongID;
  end;

  ClearKeyLists;
  GetKeyList;

  for i := 0 to ListView.Items.Count - 1 do
  begin
    if TGPGKey(ListView.Items[i].Data).LongID = lastLongID then
    begin
      ListView.ItemFocused := ListView.Items[i];
      ListView.ItemIndex := i;
      break;
    end;
  end;
end;

procedure TMainForm.Sign2Click(Sender: TObject);
begin
  KeySign;
end;

procedure TMainForm.Properties1Click(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;
  KeyPropertiesForm := TKeyPropertiesForm.Create(Application);
  KeyPropertiesForm.Display(TGPGKey(ListView.Selected.Data), FCrypto.PublicKeys);
  FreeAndNil(KeyPropertiesForm);
end;

procedure TMainForm.KeyProperties1Click(Sender: TObject);
begin
  Properties1.Click;
end;

procedure TMainForm.Searchkeyserverforkeys1Click(Sender: TObject);
begin
  KeySearchForm := TKeySearchForm.Create(Application);
  KeySearchForm.ShowModal;
  FreeAndNil(KeySearchForm);
  RefreshKeyList;
end;

procedure TMainForm.SendtoKeyserver1Click(Sender: TObject);
var
  ksf: TKeySendForm;
begin
  ksf := TKeySendForm.Create(nil);
  if Assigned(ListView.Selected) then
    ksf.Display(FCrypto.PublicKeys, TGPGKey(ListView.Selected.Data).LongID)
  else
    ksf.Display(FCrypto.PublicKeys, '');
  FreeAndNil(ksf);
end;

procedure TMainForm.RefreshfromKeyserver1Click(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;
  
  if FCrypto.ReceiveKey(TGPGKey(ListView.Selected.Data).LongID) then RefreshKeyList;
end;

procedure TMainForm.RefreshfromKeyserver2Click(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;

  if FCrypto.ReceiveKey(TGPGKey(ListView.Selected.Data).LongID) then RefreshKeyList;
end;

procedure TMainForm.SendtoKeyserver2Click(Sender: TObject);
begin
  SendToKeyserver1.Click;
end;

procedure TMainForm.ImportKeysClickClick(Sender: TObject);
begin
  if FCrypto.ImportKeys then RefreshKeyList;
end;

procedure TMainForm.CheckVersion;
var
  gops: TGPGOps;
  v: string;
  n, major, minor, release: integer;
begin
  gops := TGPGOps.Create;
  try
    v := gops.GetVersion;

    major := 0;
    minor := 0;
    release := 0;

    n := Pos('.', v);
    if n > 0 then
    begin
      major := StrToIntDef(Copy(v, 1, n - 1), 0);
      v := Copy(v, n + 1, Length(v));
      n := Pos('.', v);
      if n > 0 then
      begin
        minor := StrToIntDef(Copy(v, 1, n - 1), 0);
        v := Copy(v, n + 1, Length(v));
        release := StrToIntDef(v, 0);
      end;
    end;

    if (major < 1) or
       ( (major = 1) and (minor < 2) ) or
       ( (major = 1) and (minor = 2) and (release < 3) ) then
    begin
      raise Exception.Create(RGPGInvalidVersion);
    end;

  finally
    gops.Free;
  end;
end;

procedure TMainForm.GenerateSecretKey1Click(Sender: TObject);
begin
  GenerateKeyForm := TGenerateKeyForm.Create(Application);
  try
    if GenerateKeyForm.ShowModal = mrOK then RefreshKeyList;
  finally
    FreeAndNil(GenerateKeyForm);
  end;
end;

procedure TMainForm.EditTrust1Click(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;

  if TGPGKey(ListView.Selected.Data).UserTrust = trustNoPublicKey then
  begin
    MessageDlg(RMainCannotEditSecretKeyTrust, mtError, [mbOK], 0);
    Exit;
  end;

  EditTrustForm := TEditTrustForm.Create(Application);
  if EditTrustForm.Display(TGPGKey(ListView.Selected.Data)) = mrOK then RefreshKeyList;
  FreeAndNil(EditTrustForm);
end;

procedure TMainForm.EditTrust2Click(Sender: TObject);
begin
  EditTrust1.Click;
end;

procedure TMainForm.GetKeyfromKeyserver1Click(Sender: TObject);
begin
  KeyGetForm := TKeyGetForm.Create(Application);
  KeyGetForm.ShowModal;
  FreeAndNil(KeyGetForm);
end;

procedure TMainForm.ExportKeys(secret: boolean);
var
  key: TGPGKey;
begin
  key := nil;
  if Assigned(ListView.Selected) then key := TGPGKey(ListView.Selected.Data);

  KeyExportForm := TKeyExportForm.Create(self);

  if secret then
    KeyExportForm.Display(secret, FCrypto.SecretKeys, key)
  else
    KeyExportForm.Display(secret, FCrypto.PublicKeys, key);

  KeyExportForm.Free;
end;

procedure TMainForm.ExportPublicKeys1Click(Sender: TObject);
begin
  ExportKeys(false);
end;

procedure TMainForm.ExportSecretKeys1Click(Sender: TObject);
begin
  if MessageDlg(RMainExportSecretConfirm, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  ExportKeys(true);
end;

procedure TMainForm.ListViewAdvancedCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
begin
  if (ListView.ViewStyle = vsReport) and (Item.Index mod 2 = 1) then
  begin
    Sender.Canvas.Brush.Color := RGB($fa, $f6, $f3);
  end;
end;

procedure TMainForm.ListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  key: TGPGKey;
  i: integer;
begin
  if not Assigned(FCrypto) then exit;
  
  if not Assigned(ListView.Selected) or not Assigned(Item.Data) then
  begin
    StatusBar.Panels[0].Text := '';
    StatusBar.Panels[0].Width := 0;
    if FCrypto.PublicKeys.Count = 1 then
      StatusBar.Panels[1].Text := RMainOneKeyInRing
    else
      StatusBar.Panels[1].Text := Format(RMainKeysInRing, [IntToStr(FCrypto.PublicKeys.Count)]);
    Exit;
  end;

  key := Item.Data;
  if GConfig.Show16DigitIDs then
  begin
    StatusBar.Panels[0].Text := key.LongID;
    // Was 115, increased to 140 for large fonts.  Put some auto-resizing based on PPI
    // code in but it didn't work for some reason.
    StatusBar.Panels[0].Width := 140;
  end
  else
  begin
    StatusBar.Panels[0].Text := key.ShortID;
    StatusBar.Panels[0].Width := 70;
  end;
  StatusBar.Panels[1].Text := ' ' + key.UserID;

  ChangePassphraseofSelectedKey1.Enabled := false;
  for i := 0 to FCrypto.SecretKeys.Count - 1 do
  begin
    if TGPGKey(FCrypto.SecretKeys[i]).LongID = key.LongID then
    begin
      ChangePassphraseofSelectedKey1.Enabled := true;
      break;
    end;
  end;

end;

procedure TMainForm.Icon1Click(Sender: TObject);
begin
  GConfig.ViewDetails := false;
  UpdateStuff;
end;

procedure TMainForm.Report1Click(Sender: TObject);
begin
  GConfig.ViewDetails := true;
  UpdateStuff;
end;

procedure TMainForm.ViewButtonClick(Sender: TObject);
var
  p: TPoint;
begin
  UpdateStuff;
  p := ViewButton.ClientOrigin;
  ViewPopupMenu.Popup(p.X + ViewButton.Width, p.Y + ViewButton.Height);
end;

procedure TMainForm.ListViewDblClick(Sender: TObject);
begin
  KeyProperties1.Click;
end;

procedure TMainForm.UpdateStuff;
begin
  DisplayExpiredKeys1.Checked := GConfig.ShowExpiredKeys;
  DisplayExpiredKeysButton.Down := GConfig.ShowExpiredKeys;

  Folders1.Checked := GConfig.ShowFolders;
  Folders1.Enabled := PublicKeys1.Checked;
  Splitter.Visible := GConfig.ShowFolders and PublicKeys1.Checked;
  TreeView.Visible := GConfig.ShowFolders and PublicKeys1.Checked;

  Hints1.Checked := GConfig.ViewHints;
  Comments1.Checked := GConfig.ViewComments;

  if GConfig.ViewHints then
    Panel.Height := HintBevel.Top - FilterEdit.Height - 16
  else
    Panel.Height := StatusBar.Top - FilterEdit.Height - 16;
  CryptophaneImage.Visible := GConfig.ViewHints;

  if GConfig.ViewDetails then
  begin
    Report1.Checked := true;
    Report2.Checked := true;
    ListView.ViewStyle := vsReport;
  end
  else
  begin
    Icon1.Checked := true;
    Icon2.Checked := true;
    ListView.ViewStyle := vsIcon;
  end;
end;

procedure TMainForm.ListViewKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then KeyProperties1.Click;
end;

procedure TMainForm.FilterEditKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #27 then FilterEdit.Text := '';
end;

procedure TMainForm.ListViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  k1, k2: TGPGKey;
begin
  if not Assigned(Item1.Data) or not Assigned(Item2.Data) then exit;

  k1 := TGPGKey(Item1.Data);
  k2 := TGPGKey(Item2.Data);

  case GConfig.SortColumn of
    cName: compare := CompareText(k1.UserIDName, k2.UserIDName);
    cEmail: compare := CompareText(k1.UserIDEmail, k2.UserIDEmail);
    cComment: compare := CompareText(k1.UserIDComment, k2.UserIDComment);
    cTrust:
    begin
      compare := CompareValue(Max(integer(k1.UserTrust), integer(k1.CalcTrust)), Max(integer(k2.UserTrust),integer(k2.CalcTrust)));
      if compare = 0 then compare := CompareValue(integer(k1.UserTrust), integer(k2.UserTrust));
    end;
    cSigs: compare := CompareValue(k1.Signatures.Count, k2.Signatures.Count);
    cCreated: compare := CompareDateTime(k1.CreatedDate, k2.CreatedDate);
    cExpires: compare := CompareDateTime(k1.CreatedDate, k2.CreatedDate);
    cKeyID: compare := CompareText(k1.GetKeyID(GConfig.Show16DigitIDs), k2.GetKeyID(GConfig.Show16DigitIDs));
  end;

  if GConfig.SortDesc then compare := -compare;
end;

procedure TMainForm.ListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if GConfig.SortColumn = TCColumns(column.Tag) then
    GConfig.SortDesc := not GConfig.SortDesc
  else
    GConfig.SortDesc := false;
    
  GConfig.SortColumn := TCColumns(column.Tag);
  
  ListView.AlphaSort;
end;

procedure TMainForm.Encryptto1Click(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;
  
  Encrypt1.Click;
end;

procedure TMainForm.Options1Click(Sender: TObject);
begin
  SetupForm := TSetupForm.Create(Application);
  SetupForm.Display(FCrypto);
  FreeAndNil(SetupForm);
  UpdateStuff;
  UpdateView;
end;

procedure TMainForm.CryptophaneWebSite1Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('http://cryptophane.org/'), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainForm.DisplayExpiredKeysButtonClick(Sender: TObject);
begin
  GConfig.ShowExpiredKeys := not GConfig.ShowExpiredKeys;
  UpdateStuff;
  UpdateView;
end;

procedure TMainForm.DeleteKey;
var
  key: TGPGKey;
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;

  key := TGPGKey(ListView.Selected.Data);

  if MessageDlg(Format(RMainDeleteConfirm, [key.UserID]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  if not Publickeys1.Checked and (MessageDlg(RMainDeleteSecretConfirm, mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;

  if FCrypto.DeleteKey(key, not Publickeys1.Checked) then RefreshKeyList;
end;

procedure TMainForm.DeleteKey1Click(Sender: TObject);
begin
  DeleteKey;
end;

procedure TMainForm.DeleteKey2Click(Sender: TObject);
begin
  DeleteKey;
end;

procedure TMainForm.Hints1Click(Sender: TObject);
begin
  GConfig.ViewHints := not GConfig.ViewHints;
  UpdateStuff;
  UpdateHints;
end;

procedure TMainForm.UpdateHints;

  function IsMyKey(key: TGPGKey): boolean;
  var
    i: integer;
  begin
    result := true;
    for i := 0 to FCrypto.SecretKeys.Count - 1 do
    begin
      if TGPGKey(FCrypto.SecretKeys[i]).LongID = key.LongID then Exit;
    end;
    result := false;
  end;

  function HasAssignedTrust: boolean;
  var
    i: integer;
  begin
    result := true;
    for i := 0 to FCrypto.PublicKeys.Count - 1 do
    begin
      if IsMyKey(TGPGKey(FCrypto.PublicKeys[i])) then continue;
      if TGPGKey(FCrypto.PublicKeys[i]).UserTrust >= trustNone then Exit;
    end;
    result := false;
  end;

  function HasKeyOfOthers: boolean;
  var
    i: integer;
  begin
    result := true;
    for i := 0 to FCrypto.PublicKeys.Count - 1 do
    begin
      if IsMyKey(TGPGKey(FCrypto.PublicKeys[i])) then continue;
      Exit;
    end;
    result := false;
  end;

  function HasSignedKey: boolean;
  var
    i, j, k: integer;
    sig: string;
  begin
    result := true;
    for i := 0 to FCrypto.PublicKeys.Count - 1 do
    begin
      if IsMyKey(TGPGKey(FCrypto.PublicKeys[i])) then continue;

      for j := 0 to TGPGKey(FCrypto.PublicKeys[i]).Signatures.Count - 1 do
      begin
        sig := TGPGKey(TGPGKey(FCrypto.PublicKeys[i]).Signatures[j]).LongID;
        for k := 0 to FCrypto.SecretKeys.Count - 1 do
        begin
          if sig = TGPGKey(FCrypto.SecretKeys[k]).LongID then Exit;
        end;
      end;
    end;
    result := false;
  end;

begin
  if not GConfig.ViewHints then Exit;

  if FCrypto.SecretKeys.Count = 0 then
  begin
    // Welcome to Cryptophane hint.
    HintHeadingLabel.Caption := RHint1Title;
    HintLine1Label.Caption := RHint1Label1;
    HintLink1Label.Caption := RHint1Link1;
    FHintLink1Index := RHint1Index1;
    HintLine2Label.Caption := RHint1Label2;
    HintLink2Label.Caption := RHint1Link2;
    FHintLink2Index := RHint1Index2;
  end
  else if not HasKeyOfOthers then
  begin
    // Adding other people to your keyring hint.
    HintHeadingLabel.Caption := RHint2Title;
    HintLine1Label.Caption := RHint2Label1;
    HintLink1Label.Caption := RHint2Link1;
    FHintLink1Index := RHint2Index1;
    HintLine2Label.Caption := RHint2Label2;
    HintLink2Label.Caption := RHint2Link2;
    FHintLink2Index := RHint2Index2;
  end
  else if not HasSignedKey then
  begin
    // Signing others' keys hint.
    HintHeadingLabel.Caption := RHint3Title;
    HintLine1Label.Caption := RHint3Label1;
    HintLink1Label.Caption := RHint3Link1;
    FHintLink1Index := RHint3Index1;
    HintLine2Label.Caption := RHint3Label2;
    HintLink2Label.Caption := RHint3Link2;
    FHintLink2Index := RHint3Index2;
  end
  else if not HasAssignedTrust then
  begin
    // Setting trust levels hint.
    HintHeadingLabel.Caption := RHint4Title;
    HintLine1Label.Caption := RHint4Label1;
    HintLink1Label.Caption := RHint4Link1;
    FHintLink1Index := RHint4Index1;
    HintLine2Label.Caption := RHint4Label2;
    HintLink2Label.Caption := RHint4Link2;
    FHintLink2Index := RHint4Index2;
  end
  else
  begin
    // General how to use Cryptophane hint.
    HintHeadingLabel.Caption := RHint5Title;
    HintLine1Label.Caption := RHint5Label1;
    HintLink1Label.Caption := RHint5Link1;
    FHintLink1Index := RHint5Index1;
    HintLine2Label.Caption := RHint5Label2;
    HintLink2Label.Caption := RHint5Link2;
    FHintLink2Index := RHint5Index2;
  end;

  HintLink1Label.Left := HintLine1Label.Left + HintLine1Label.Width + 3;
  HintLink2Label.Left := HintLine2Label.Left + HintLine2Label.Width + 3;
end;

procedure TMainForm.Contents1Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS, 0);
end;

procedure TMainForm.Index1Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_KEY, 0);
end;

procedure TMainForm.De1Click(Sender: TObject);
var
  op: TCryptoOperation;
  fn: string;
  r: boolean;
  tempPath: array [0..1024] of char;
  tempName: array [0..MAX_PATH] of char;
begin
  GetMessageForm := TGetMessageForm.Create(Application);
  r := GetMessageForm.Display(op, fn);
  FreeAndNil(GetMessageForm);

  if not r then Exit;
  if op = coVerify then
    FCrypto.Verify(fn)
  else
  begin
    if GetTempPath(1024, tempPath) < 1 then
    begin
      MessageDlg(RMainNoTempPath, mtError, [mbOK], 0);
      Exit;
    end;

    if GetTempFileName(tempPath, 'Cryptophane', 0, tempName) = 0 then
    begin
      MessageDlg(RMainNoTempFile, mtError, [mbOK], 0);
      Exit;
    end;

    FCrypto.AlwaysOverwrite := true;
    try
      if op in [coEncrypt, coSign, coEncryptSign] then FCrypto.EncryptSign(op, fn, '', tempName);
      if op = coDecrypt then FCrypto.Decrypt(fn, tempName);
    finally
      FCrypto.AlwaysOverwrite := false;
    end;

    if FileExists(tempName) then
    begin
      DisplayDataForm := TDisplayDataForm.Create(self);
      DisplayDataForm.DisplayFile(tempName);
      DisplayDataForm.Free;

      DeleteFile(tempName);
    end;
  end;

  DeleteFile(fn);
end;

procedure TMainForm.HintLink1LabelClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_KEY, integer(PChar(FHintLink1Index)));
end;

procedure TMainForm.HintLink2LabelClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_KEY, integer(PChar(FHintLink2Index)));
end;

procedure TMainForm.Folders1Click(Sender: TObject);
begin
  GConfig.ShowFolders := not GConfig.ShowFolders;
  UpdateFolders;
  UpdateStuff;
end;

procedure TMainForm.SplitterMoved(Sender: TObject);
begin
  GConfig.FolderWidth := TreeView.Width;
end;

procedure TMainForm.UpdateFolders;
var
  i: integer;
  key: TCryptophaneKey;
  selectedFolder: string;
  tn: TTreeNode;
begin
  // Save the currently selected folder so we can restore it.
  selectedFolder := '';
  if Assigned(TreeView.Selected) then selectedFolder := GetTreeFolderName(TreeView.Selected);

  TreeView.Items.Clear;

  // Make the folders as per our folder list.
  for i := 0 to GConfig.Folders.Count - 1 do
  begin
    tn := MakeFolder(GConfig.Folders[i]);
    if (GConfig.Folders[i] = selectedFolder) and Assigned(tn) then tn.Selected := true;
  end;

  // Make sure the folders exist for all the current entries.
  for i := 0 to FCrypto.PublicKeys.Count - 1 do
  begin
    key := TCryptophaneKey(FCrypto.PublicKeys[i]);
    tn := MakeFolder(key.Folder);
    if (key.Folder = selectedFolder) and Assigned(tn) then tn.Selected := true;
  end;

  if not Assigned(TreeView.Selected) and Assigned(TreeView.TopItem) then
  begin
    TreeView.TopItem.Selected := true;
  end;

  TreeView.AlphaSort;
  UpdateView;
end;

procedure TMainForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  UpdateView;
end;

function TMainForm.GetCurrentFolder: string;
begin
  if GConfig.ShowFolders and Assigned(TreeView.Selected) then
    result := GetTreeFolderName(TreeView.Selected)
  else
    result := '';
end;

procedure TMainForm.TreeViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  key: TCryptophaneKey;
begin
  if source <> ListView then Exit;
  if not Assigned(ListView.Selected) then Exit;
  if not Assigned(TreeView.GetNodeAt(x, y)) then Exit;  

  key := TCryptophaneKey(ListView.Selected.Data);
  key.Folder := GetTreeFolderName(TreeView.GetNodeAt(x, y));
  GConfig.KeyFolders[key.LongID] := key.Folder;
  UpdateView;
end;

procedure TMainForm.TreeViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  accept :=
    (source = ListView) and
    Assigned(ListView.Selected) and
    Assigned(TreeView.GetNodeAt(x, y));
end;

function TMainForm.GetTreeFolderName(tn: TTreeNode): string;
begin
  result := '';
  result := tn.Text;
  tn := tn.Parent;
  while Assigned(tn) do
  begin
    result := tn.Text + '/' + result;
    tn := tn.Parent;
  end;
end;

function TMainForm.MakeFolder(folder: string): TTreeNode;
var
  ss: TStringList;
  tn, tnc: TTreeNode;
begin
  result := nil;
  ss := TStringList.Create;
  try
    Split('/', folder, ss);
    tn := nil;
    tnc := TreeView.TopItem;
    while ss.Count > 0 do
    begin
      while Assigned(tnc) do
      begin
        if tnc.Text = ss[0] then break;
        tnc := tnc.GetNextSibling;
      end;

      if not Assigned(tnc) then
      begin
        tnc := TreeView.Items.AddChild(tn, ss[0]);
        tnc.MakeVisible;
      end;
      result := tnc;

      tn := tnc;
      tnc := tnc.GetFirstChild;
      ss.Delete(0);
    end;
  finally
    ss.Free;
  end;

  TreeView.AlphaSort;
end;

procedure TMainForm.TreeViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tn: TTreeNode;
  p: TPoint;
begin
  if button = mbRight then
  begin
    tn := TreeView.GetNodeAt(x, y);
    if not Assigned(tn) then Exit;
    p := TreeView.ClientToScreen(Point(x, y));
    FTreeNodeMenu := tn;
    TreeMenu.Popup(p.x, p.y);
  end;
end;

procedure TMainForm.Delete1Click(Sender: TObject);
var
  i: integer;
  folder: string;
begin
  folder := GetTreeFolderName(FTreeNodeMenu);
  if Pos('/', folder) = 0 then
  begin
    MessageDlg(RMainCannotDeleteRoot, mtError, [mbOK], 0);
    Exit;
  end;

  for i := 0 to FCrypto.PublicKeys.Count - 1 do
  begin
    if Copy(TCryptophaneKey(FCrypto.PublicKeys[i]).Folder, 1, Length(folder)) = folder then
    begin
      MessageDlg(RMainFolderNotEmpty, mtError, [mbOK], 0);
      Exit;
    end;
  end;

  i := GConfig.Folders.IndexOf(folder);
  if i > -1 then GConfig.Folders.Delete(i);
  FTreeNodeMenu.Delete;
end;

procedure TMainForm.Add1Click(Sender: TObject);
var
  aff: TAddFolderForm;
  tn: TTreeNode;
  folder: string;
begin
  aff := TAddFolderForm.Create(self);
  try
    if aff.ShowModal <> mrOK then Exit;
    folder := GetTreeFolderName(FTreeNodeMenu) + '/' + aff.FolderEdit.Text;
    tn := MakeFolder(folder);
    if Assigned(tn) then
    begin
      tn.Selected := true;
      if GConfig.Folders.IndexOf(folder) = -1 then GConfig.Folders.Add(folder); 
    end;
  finally
    aff.Free;
  end;
end;

procedure TMainForm.TreeViewEdited(Sender: TObject; Node: TTreeNode;
  var S: String);
var
  i: integer;
  oldFolder, newFolder, tf: string;
  tn: TTreeNode;
begin
  if s = Node.Text then Exit;
  s := Trim(s);

  if s = '' then
  begin
    MessageDlg('You must specify a folder name.', mtError, [mbOK], 0);
    s := Node.Text;
    Exit;
  end;
  
  for i := 1 to Length(s) do
  begin
    if (Ord(s[i]) < 32) or (Ord(s[i]) > 126) or (s[i] in ['/']) then
    begin
      MessageDlg('Invalid character in folder name.', mtError, [mbOK], 0);
      s := Node.Text;
      Exit;
    end;
  end;

  // Search our sibilings for nodes already with the new name. 
  tn := Node;
  while tn.GetPrevSibling <> nil do tn := tn.GetPrevSibling;
  while Assigned(tn) do
  begin
    if tn.Text = s then
    begin
      MessageDlg('There is already a folder with that name.', mtError, [mbOK], 0);
      s := Node.Text;
      Exit;
    end;
    tn := tn.GetNextSibling;
  end;

  // Now we have to go rename all the folders.
  newFolder := s;
  oldFolder := Node.Text;
  tn := Node.Parent;
  while Assigned(tn) do
  begin
    newFolder := tn.Text + '/' + newFolder;
    oldFolder := tn.Text + '/' + oldFolder;
    tn := tn.Parent;
  end;

  // Update GConfig.Folders
  i := GConfig.Folders.IndexOf(oldFolder);
  if i > -1 then GConfig.Folders.Delete(i);
  i := GConfig.Folders.IndexOf(newFolder);
  if i = -1 then GConfig.Folders.Add(newFolder);

  // Update GConfig.KeyFolders
  for i := 0 to GConfig.KeyFolders.Count - 1 do
  begin
    tf := GConfig.KeyFolders.Values[i];
    if Copy(tf + '/', 1, Length(oldFolder) + 1) = oldFolder + '/' then
    begin
      GConfig.KeyFolders.Values[i] :=
        newFolder +
        Copy(tf, Length(oldFolder) + 1, Length(tf));
    end;
  end;

  // Update the TCryptophaneKey list.
  for i := 0 to FCrypto.PublicKeys.Count - 1 do
  begin
    tf := TCryptophaneKey(FCrypto.PublicKeys[i]).Folder;
    if Copy(tf + '/', 1, Length(oldFolder) + 1) = oldFolder + '/' then
    begin
      TCryptophaneKey(FCrypto.PublicKeys[i]).Folder :=
        newFolder +
        Copy(tf, Length(oldFolder) + 1, Length(tf));
    end;
  end;
end;

procedure TMainForm.Rename1Click(Sender: TObject);
begin
  FTreeNodeMenu.EditText;
end;

procedure TMainForm.TreeViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_F2) and
    not TreeView.IsEditing and
    Assigned(TreeView.Selected) then
  begin
    TreeView.Selected.EditText;
  end;

  if (key = vk_Delete) and
    not TreeView.IsEditing and
    Assigned(TreeView.Selected) then
  begin
    FTreeNodeMenu := TreeView.Selected;
    Delete1Click(sender);
  end;
end;

procedure TMainForm.DonatetowardsCryptophanedevelopment1Click(
  Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=paypal@ecosm.com&item_name=Cryptophane+Donation&no_note=1&currency_code=USD&tax=0'), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainForm.UpdateSecretTrustLevelsFromPublicKeys;
var
  p, s: integer;
  id: string;
  found: boolean;
  key: TCryptophaneKey;
begin
  for s := 0 to FCrypto.SecretKeys.Count - 1 do
  begin
    key := FCrypto.SecretKeys[s] as TCryptophaneKey;
    id := key.LongID;
    found := false;

    for p := 0 to FCrypto.PublicKeys.Count - 1 do
    begin
      if (FCrypto.PublicKeys[p] as TCryptophaneKey).LongID = id then
      begin
        key.UserTrust := (FCrypto.PublicKeys[p] as TCryptophaneKey).UserTrust;
        found := true;
        break;
      end;
    end;

    if not found then key.UserTrust := trustNoPublicKey;
  end;
end;

procedure TMainForm.Comments1Click(Sender: TObject);
begin
  GConfig.ViewComments := not GConfig.ViewComments;
  UpdateStuff;
  SetColumns;
end;

procedure TMainForm.GenerateRevocationCertificateforSelectedKey1Click(
  Sender: TObject);
var
  key: TGPGKey;
begin
  if not Assigned(ListView.Selected) then
  begin
    MessageDlg(RMainNoKeySelected, mtError, [mbOK], 0);
    Exit;
  end;

  key := TGPGKey(ListView.Selected.Data);
  FCrypto.RevokeKey(key);
end;

procedure TMainForm.SetColumns;
var
  oldColumnWidths: array [TCColumns] of integer;
  i: integer;
  c: TCColumns;
  lc: TListColumn;
begin
  ListView.Items.Clear;
  for c := Low(TCColumns) to High(TCColumns) do oldColumnWidths[c] := -1;
  for i := 0 to ListView.Columns.Count - 1 do
  begin
    oldColumnWidths[TCColumns(ListView.Columns[i].Tag)] := ListView.Columns[i].Width;
  end;
  ListView.Columns.Clear;

  for c := Low(TCColumns) to High(TCColumns) do
  begin
    if (c = cComment) and not GConfig.ViewComments then continue;

    lc := ListView.Columns.Add;
    lc.Caption := CColumnNames[c];
    lc.Alignment := CColumnAlignments[c];
    lc.Tag := integer(c);
    if oldColumnWidths[c] > -1 then
      lc.Width := oldColumnWidths[c]
    else
      lc.Width := CDefaultColumnWidths[c];
  end;

  UpdateView;
end;

procedure TMainForm.ChangePassphraseofSelectedKey1Click(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then exit;
  FCrypto.ChangeSecretKeyPassphrase(TGPGKey(ListView.Selected.Data));
end;

end.
