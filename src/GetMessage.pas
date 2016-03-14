unit GetMessage;

interface

uses
  Crypto,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScaledForm;

type
  TGetMessageForm = class(TScaledForm)
    Label1: TLabel;
    OKButton: TButton;
    Button2: TButton;
    Memo: TMemo;
    procedure OKButtonClick(Sender: TObject);
  private
    FOp: TCryptoOperation;
    FFn: string;
  public
    function Display(var op: TCryptoOperation; var fn: string): boolean;
  end;

var
  GetMessageForm: TGetMessageForm;

implementation

{$R *.dfm}

function TGetMessageForm.Display(var op: TCryptoOperation;
  var fn: string): boolean;
begin
  result := false;
  if ShowModal = mrOK then
  begin
    op := FOp;
    fn := FFn;
    result := true;
  end;
end;

procedure TGetMessageForm.OKButtonClick(Sender: TObject);
var
  tempPath: array [0..1024] of char;
  tempName: array [0..MAX_PATH] of char;
  ss: TStringList;
  i: integer;
  f: TFileStream;
  bytes: TBytes;
begin
  if GetTempPath(1024, tempPath) < 1 then
  begin
    MessageDlg('Couldn''t get temp path.', mtError, [mbOK], 0);
    Exit;
  end;

  if GetTempFileName(tempPath, 'Cryptophane', 0, tempName) = 0 then
  begin
    MessageDlg('Couldn''t create temporary file.', mtError, [mbOK], 0);
    Exit;
  end;

  ss := TStringList.Create;
  try
    f := nil;
    try
      f := TFileStream.Create(tempName, fmCreate or fmOpenWrite);
      bytes := TEncoding.UTF8.GetBytes(Memo.Text);
      f.Write(bytes[0], Length(bytes));
      f.Free;
    except
      f.Free;
      DeleteFile(tempName);
      MessageDlg('Couldn''t write to temporary file.', mtError, [mbOK], 0);
    end;

    FFn := tempName;

    // OK, we've written it to a temporary file now.
    // Let's see what it is and pass it to the relevant function.
    ss.Text := Memo.Text;
    ModalResult := mrOK;
    for i := 0 to ss.Count - 1 do
    begin
      if ss[i] = '-----BEGIN PGP SIGNED MESSAGE-----' then
      begin
        FOp := coVerify;
        Exit;
      end;

      if ss[i] = '-----BEGIN PGP MESSAGE-----' then
      begin
        FOp := coDecrypt;
        Exit;
      end;
    end;

    FOp := coEncrypt;

  finally
    ss.Free;
  end;
end;

end.
