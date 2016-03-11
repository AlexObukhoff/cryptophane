unit SymPassphrase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSymPassphraseForm = class(TForm)
    Label1: TLabel;
    PassphraseEdit: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
  private
  public
    function Display(passphrase: PChar): boolean;
  end;

implementation

{$R *.dfm}

{ TSymPassphraseForm }

function TSymPassphraseForm.Display(passphrase: PChar): boolean;
var
  blank: string;
  i: integer;
begin
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
