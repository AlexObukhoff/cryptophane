unit KeyExport;

interface

uses
  GPGWrapper, 
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ScaledForm;

type
  TKeyExportForm = class(TScaledForm)
    ListView: TListView;
    Label1: TLabel;
    ExportAllCheck: TCheckBox;
    FileCheck: TCheckBox;
    OKButton: TButton;
    Button2: TButton;
    SaveDialog: TSaveDialog;
    procedure ExportAllCheckClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FSecret: boolean;
    FScrollTo: TListItem;
  public
    function Display(secretKeys: boolean; keys: TList; selectKey: TGPGKey): TModalResult;
  end;

var
  KeyExportForm: TKeyExportForm;

implementation

{$R *.dfm}

uses Resources, DisplayData, GPGOps, Config;

{ TKeyExportForm }

function TKeyExportForm.Display(secretKeys: boolean; keys: TList; selectKey: TGPGKey): TModalResult;
var
  i: integer;
  key: TGPGKey;
  li: TListItem;
begin
  FSecret := secretKeys;
  FScrollTo := nil;
  FileCheck.Checked := true;

  for i := 0 to keys.Count - 1 do
  begin
    key := TGPGKey(keys[i]);
    li := ListView.Items.Add;
    li.Caption := key.UserID;
    li.SubItems.Add(key.GetKeyID(GConfig.Show16DigitIDs));
    li.Data := keys[i];
    if Assigned(selectKey) and (key.LongID = selectKey.LongID) then
    begin
      li.Checked := true;
      FScrollTo := li;
    end;
  end;

  result := ShowModal;
end;

procedure TKeyExportForm.ExportAllCheckClick(Sender: TObject);
begin
  ListView.Enabled := not ExportAllCheck.Checked;
end;

procedure TKeyExportForm.OKButtonClick(Sender: TObject);
var
  ops: TGPGOps;
  f: TFileStream;
  data: string;
  ddf: TDisplayDataForm;
  keys: TList;
  i: integer;
  bytes: TBytes;
begin
  if ExportAllCheck.Checked then
    keys := nil
  else
  begin
    keys := TList.Create;
    for i := 0 to ListView.Items.Count - 1 do
    begin
      if ListView.Items[i].Checked then
      begin
        keys.Add(TGPGKey(ListView.Items[i].Data));
      end;
    end;
    if keys.Count = 0 then
    begin
      MessageDlg(RExportKeysMustSelect, mtError, [mbOK], 0);
      Exit;
    end;
  end;

  ops := TGPGOps.Create;
  try
    if FileCheck.Checked then
    begin
      SaveDialog.FileName := '';
      SaveDialog.DefaultExt := 'asc';
      SaveDialog.Filter := 'GPG Armoured Key File|*.asc|All Files|*.*';
      if not SaveDialog.Execute then Exit;
    end;

    try
      ops.ExportKeys(FSecret, keys, data);
    except
      MessageDlg(RMainExportFail, mtError, [mbOK], 0);
      Exit;
    end;

    if FileCheck.Checked then
    begin
      try
        f := TFileStream.Create(SaveDialog.FileName, fmCreate or fmOpenWrite);
        try
          bytes := TEncoding.UTF8.GetBytes(data);
          f.Write(bytes[0], Length(bytes));
        finally
          f.Free;
        end;
      except
        MessageDlg(RMainExportFail, mtError, [mbOK], 0);
        Exit;
      end;
    end
    else
    begin
      ddf := TDisplayDataForm.Create(self);
      ddf.DisplayData(data, not FSecret);
      ddf.Free;
    end;

    ModalResult := mrOK;
  finally
    ops.Free;
    keys.Free;
  end;
end;

procedure TKeyExportForm.FormShow(Sender: TObject);
begin
  if Assigned(FScrollTo) then FScrollTo.MakeVisible(false);
end;

end.
