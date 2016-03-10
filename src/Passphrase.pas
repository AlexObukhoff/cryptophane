unit Passphrase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScaledForm, GPGWrapper;

type
  TPassphraseForm = class(TScaledForm)
    Label1: TLabel;
    PassphraseEdit: TEdit;
    Button1: TButton;
    Button2: TButton;
    UserIDLabel: TLabel;
    KeyInfoLabel: TLabel;
  private
  public
    function Display(passphrase: PChar; longID: string; key: TGPGKey): boolean;
  end;

implementation

{$R *.dfm}

uses Utils, Config;

function TPassphraseForm.Display(passphrase: PChar; longID: string; key: TGPGKey): boolean;
var
  blank: string;
  i: integer;
begin
  if Assigned(key) then
  begin
    UserIDLabel.Caption := key.UserID;
    KeyInfoLabel.Caption := 'ID ' + key.GetKeyID(GConfig.Show16DigitIDs) + ' (created ' + DateTimeToYMD(key.CreatedDate) + ')';
  end
  else
  begin
    UserIDLabel.Caption := 'Unknown user ID ' + longID;
    KeyInfoLabel.Caption := '';
  end;

  PassphraseEdit.MaxLength := 1024;
  PassphraseEdit.Text := '';
  try
    result := false;
    if ShowModal <> mrOK then Exit;
    StrLCopy(passphrase, PChar(PassphraseEdit.Text), 1023);
    result := true;
  finally
    blank := '';
    for i := 1 to Length(PassphraseEdit.Text) do blank := blank + ' ';
    PassphraseEdit.Text := blank;
    PassphraseEdit.Text := '';
  end;
end;

end.
