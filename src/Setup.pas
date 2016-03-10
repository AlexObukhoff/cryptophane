unit Setup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Crypto, ScaledForm;

type
  TSetupForm = class(TScaledForm)
    OKButton: TButton;
    Button2: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    DefaultKeyCombo: TComboBox;
    GroupBox1: TGroupBox;
    KeyServersList: TListBox;
    AddButton: TButton;
    DeleteButton: TButton;
    KeyServersEdit: TEdit;
    UpButton: TButton;
    DownButton: TButton;
    Label2: TLabel;
    DebugCheck: TCheckBox;
    Label3: TLabel;
    GPGRadio: TRadioButton;
    PGPRadio: TRadioButton;
    KeyInfoLabel: TLabel;
    Show16DigitIDsCheck: TCheckBox;
    Label4: TLabel;
    ProxyNoneRadio: TRadioButton;
    ProxyWindowsRadio: TRadioButton;
    ProxyManualRadio: TRadioButton;
    ProxyHostLabel: TLabel;
    ProxyHostEdit: TEdit;
    ProxyPortLabel: TLabel;
    ProxyPortEdit: TEdit;
    ShowSuccessDialogsCheck: TCheckBox;
    UseUntrustedKeyCheck: TCheckBox;
    procedure OKButtonClick(Sender: TObject);
    procedure KeyServersListClick(Sender: TObject);
    procedure KeyServersEditChange(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure KeyServersEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UpButtonClick(Sender: TObject);
    procedure DownButtonClick(Sender: TObject);
    procedure DefaultKeyComboChange(Sender: TObject);
    procedure ProxyNoneRadioClick(Sender: TObject);
    procedure ProxyWindowsRadioClick(Sender: TObject);
    procedure ProxyManualRadioClick(Sender: TObject);
  private
    FSecretKeys: TList;
    procedure UpdateProxyInfo;
  public
    function Display(crypto: TCrypto): TModalResult;
  end;

var
  SetupForm: TSetupForm;

implementation

{$R *.dfm}

uses GPGWrapper, Config, RegExpr, Utils, GPGOps;

{ TSetupForm }

function TSetupForm.Display(crypto: TCrypto): TModalResult;
var
  i: integer;
  key, pkey: TGPGKey;
begin
  FSecretKeys := crypto.SecretKeys;

  DefaultKeyCombo.Clear;
  for i := 0 to FSecretKeys.Count - 1 do
  begin
    key := TGPGKey(FSecretKeys[i]);
    if not key.IsValid then continue;
    pkey := crypto.GetUserKey(key.LongID);
    if Assigned(pkey) and not pkey.IsValid then continue;
    DefaultKeyCombo.AddItem(key.UserID, key);
    if key.LongID = GConfig.DefaultSecretKey then DefaultKeyCombo.ItemIndex := DefaultKeyCombo.Items.Count - 1;
  end;
  DefaultKeyComboChange(nil);

  KeyServersList.Items.Clear;
  for i := 0 to GConfig.KeyServers.Count - 1 do
  begin
    KeyServersList.AddItem(GConfig.KeyServers[i], nil);
  end;
  KeyServersList.ItemIndex := -1;
  KeyServersEdit.Text := '';
  KeyServersEdit.Enabled := false;

  case GConfig.DefaultExt of
    dePGP: PGPRadio.Checked := true;
    else GPGRadio.Checked := true;
  end;

  DebugCheck.Checked := GConfig.DebugMode;
  Show16DigitIDsCheck.Checked := GConfig.Show16DigitIDs;

  case GConfig.ProxySetting of
    psDirectConnection: ProxyNoneRadio.Checked := true;
    psUseWindows: ProxyWindowsRadio.Checked := true;
    psManual: ProxyManualRadio.Checked := true;
  end;
  ProxyHostEdit.Text := GConfig.ProxyHost;
  ProxyPortEdit.Text := IntToStr(GConfig.ProxyPort);
  ShowSuccessDialogsCheck.Checked := GConfig.ShowSuccessDialogs;
  UseUntrustedKeyCheck.Checked := GConfig.UseUntrustedKey;

  result := ShowModal;
end;

procedure TSetupForm.OKButtonClick(Sender: TObject);
var
  i: integer;
  r: TRegExpr;
begin
  r := TRegExpr.Create;
  try
    r.Expression := '^[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_\.]+$';

    for i := 0 to KeyServersList.Count - 1 do
    begin
      if (KeyServersList.Items[i] <> '') and not r.Exec(KeyServersList.Items[i]) then
      begin
        MessageDlg('Key server "' + KeyServersList.Items[i] + '" is not a valid server name.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if ProxyManualRadio.Checked then
    begin
      if (Length(ProxyHostEdit.Text) = 0) or
         (StrToIntDef(ProxyPortEdit.Text, 0) < 1) or
         (StrToIntDef(ProxyPortEdit.Text, 0) > 65535) then
      begin
        MessageDlg('Invalid proxy information.', mtError, [mbOK], 0);
        if Length(ProxyHostEdit.Text) = 0 then
          ProxyHostEdit.SetFocus
        else
          ProxyPortEdit.SetFocus;
        exit;
      end;

      if not r.Exec(ProxyHostEdit.Text) then
      begin
        MessageDlg('Proxy host is not a valid hostname.', mtError, [mbOK], 0);
        ProxyHostEdit.SetFocus;
        exit;
      end;
    end;

    i := 0;
    while i < KeyServersList.Count do
    begin
      if KeyServersList.Items[i] = '' then
        KeyServersList.Items.Delete(i)
      else
        Inc(i);
    end;
  
    if DefaultKeyCombo.ItemIndex >= 0 then
    begin
      GConfig.DefaultSecretKey := TGPGKey(DefaultKeyCombo.Items.Objects[DefaultKeyCombo.ItemIndex]).LongID;
    end;

    if PGPRadio.Checked then
      GConfig.DefaultExt := dePGP
    else
      GConfig.DefaultExt := deGPG;

    GConfig.KeyServers.Clear;
    for i := 0 to KeyServersList.Count - 1 do GConfig.KeyServers.Add(KeyServersList.Items[i]);

    GConfig.Show16DigitIDs := Show16DigitIDsCheck.Checked;
    GConfig.DebugMode := DebugCheck.Checked;

    if ProxyNoneRadio.Checked then
    begin
      GConfig.ProxyHost := '';
      GConfig.ProxyPort := 0;
      GConfig.ProxySetting := psDirectConnection;
    end
    else if ProxyWindowsRadio.Checked then
      GConfig.ProxySetting := psUseWindows
    else
    begin
      GConfig.ProxyHost := ProxyHostEdit.Text;
      GConfig.ProxyPort := StrToInt(ProxyPortEdit.Text);
      GConfig.ProxySetting := psManual;
    end;

    GConfig.ShowSuccessDialogs := ShowSuccessDialogsCheck.Checked;
    GConfig.UseUntrustedKey := UseUntrustedKeyCheck.Checked;

    GConfig.Save;
    ModalResult := mrOK;
  finally
    r.Free;
  end;
end;

procedure TSetupForm.KeyServersListClick(Sender: TObject);
begin
  if KeyServersList.ItemIndex >= 0 then
  begin
    KeyServersEdit.Text := KeyServersList.Items[KeyServersList.ItemIndex];
    KeyServersEdit.Enabled := true;
    KeyServersEdit.SelStart := 0;
    KeyServersEdit.SelLength := Length(KeyServersEdit.Text);
    KeyServersEdit.SetFocus;
  end
  else
  begin
    KeyServersEdit.Text := '';
    KeyServersEdit.Enabled := false;
  end;
end;

procedure TSetupForm.KeyServersEditChange(Sender: TObject);
begin
  if KeyServersList.ItemIndex >= 0 then KeyServersList.Items[KeyServersList.ItemIndex] := KeyServersEdit.Text;
end;

procedure TSetupForm.AddButtonClick(Sender: TObject);
begin
  KeyServersList.AddItem('New server', nil);
end;

procedure TSetupForm.DeleteButtonClick(Sender: TObject);
begin
  KeyServersList.DeleteSelected;
  KeyServersEdit.Text := '';
  KeyServersEdit.Enabled := false;
end;

procedure TSetupForm.KeyServersEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_UP then
  begin
    if KeyServersList.ItemIndex > 0 then
    begin
      KeyServersList.ItemIndex := KeyServersList.ItemIndex - 1;
      KeyServersListClick(Sender);
    end;
    key := 0;
  end;

  if key = VK_DOWN then
  begin
    if KeyServersList.ItemIndex < KeyServersList.Items.Count - 1 then
    begin
      KeyServersList.ItemIndex := KeyServersList.ItemIndex + 1;
      KeyServersListClick(Sender);
    end;
    key := 0;
  end;
end;

procedure TSetupForm.UpButtonClick(Sender: TObject);
var
  s: string;
begin
  if KeyServersList.ItemIndex > 0 then
  begin
    s := KeyServersList.Items[KeyServersList.ItemIndex - 1];
    KeyServersList.Items[KeyServersList.ItemIndex - 1] := KeyServersList.Items[KeyServersList.ItemIndex];
    KeyServersList.Items[KeyServersList.ItemIndex] := s;
    KeyServersList.ItemIndex := KeyServersList.ItemIndex - 1;
  end;
end;

procedure TSetupForm.DownButtonClick(Sender: TObject);
var
  s: string;
begin
  if KeyServersList.ItemIndex < KeyServersList.Items.Count - 1 then
  begin
    s := KeyServersList.Items[KeyServersList.ItemIndex + 1];
    KeyServersList.Items[KeyServersList.ItemIndex + 1] := KeyServersList.Items[KeyServersList.ItemIndex];
    KeyServersList.Items[KeyServersList.ItemIndex] := s;
    KeyServersList.ItemIndex := KeyServersList.ItemIndex + 1;
  end;
end;

procedure TSetupForm.DefaultKeyComboChange(Sender: TObject);
var
  key: TGPGKey;
begin
  if DefaultKeyCombo.ItemIndex = -1 then
  begin
    KeyInfoLabel.Caption := '';
    exit;
  end;
  
  key := TGPGKey(DefaultKeyCombo.Items.Objects[DefaultKeyCombo.ItemIndex]);
  KeyInfoLabel.Caption := key.GetKeyID(GConfig.Show16DigitIDs) + '; created ' + DateTimeToYMD(key.CreatedDate);
  if key.ExpiryDate > 0 then
  begin
    KeyInfoLabel.Caption := KeyInfoLabel.Caption + '; expires ' + DateTimeToYMD(key.ExpiryDate);
  end;
end;

procedure TSetupForm.UpdateProxyInfo;
begin
  ProxyHostLabel.Enabled := ProxyManualRadio.Checked;
  ProxyPortLabel.Enabled := ProxyManualRadio.Checked;
  ProxyHostEdit.Enabled := ProxyManualRadio.Checked;
  ProxyPortEdit.Enabled := ProxyManualRadio.Checked;
end;

procedure TSetupForm.ProxyNoneRadioClick(Sender: TObject);
begin
  UpdateProxyInfo;
end;

procedure TSetupForm.ProxyWindowsRadioClick(Sender: TObject);
begin
  UpdateProxyInfo;
end;

procedure TSetupForm.ProxyManualRadioClick(Sender: TObject);
begin
  UpdateProxyInfo;
end;

end.
