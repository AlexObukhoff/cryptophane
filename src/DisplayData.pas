unit DisplayData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScaledForm;

type
  TDisplayDataForm = class(TScaledForm)
    Memo: TMemo;
    Button1: TButton;
    CopiedLabel: TLabel;
    SaveButton: TButton;
    SaveDialog: TSaveDialog;
    procedure SaveButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure DisplayFile(fn: string; copyToClipboard: boolean = true);
    procedure DisplayData(data: string; copyToClipboard: boolean = true);
  end;

var
  DisplayDataForm: TDisplayDataForm;

implementation

uses clipbrd;

{$R *.dfm}

{ TDisplayDataForm }

procedure TDisplayDataForm.DisplayData(data: string; copyToClipboard: boolean);
begin
  Memo.Text := data;
  if copyToClipboard then Clipboard.SetTextBuf(PChar(data));
  CopiedLabel.Visible := copyToClipboard;
  ShowModal;
end;

procedure TDisplayDataForm.DisplayFile(fn: string; copyToClipboard: boolean);
var
  f: TFileStream;
  data: string;
  buf: PChar;
  br: longint;
begin
  buf := AllocMem(16384);
  f := nil;
  try
    f := TFileStream.Create(fn, fmOpenRead);
    data := '';
    while f.Position < f.Size do
    begin
      br := f.Read(buf^, 16383);
      buf[br] := #0;
      data := data + buf;
    end;
  finally
    f.Free;
    FreeMem(buf);
  end;

  DisplayData(data, copyToClipboard);
end;

procedure TDisplayDataForm.SaveButtonClick(Sender: TObject);
var
  f: TFileStream;
  s: TBytes;
begin
  if SaveDialog.Execute then
  begin
    f := TFileStream.Create(SaveDialog.Filename, fmCreate or fmOpenWrite);
    try
      s := TEncoding.UTF8.GetBytes(Memo.Text);
      f.Write(s[0], Length(s));
    finally
      f.Free;
    end;
  end;
end;

end.
