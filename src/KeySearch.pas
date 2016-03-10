unit KeySearch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Contnrs, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ScaledForm;

type
  TKeySearchForm = class(TScaledForm)
    Label1: TLabel;
    KeyserverCombo: TComboBox;
    Label2: TLabel;
    KeyEdit: TEdit;
    Bevel1: TBevel;
    ListView: TListView;
    SearchButton: TButton;
    Button1: TButton;
    AddButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure KeyEditEnter(Sender: TObject);
    procedure ListViewEnter(Sender: TObject);
    procedure KeyserverComboEnter(Sender: TObject);
  private
    FSearchFor: string;
    FSortColumn: integer;
    FSortDesc: boolean;
    FKeys: TObjectList;
    procedure AddKeys;
  public
    function Search(s: string): integer;
  published
    Destructor Destroy; override;
  end;

var
  KeySearchForm: TKeySearchForm;

implementation

{$R *.dfm}

uses GPGOps, GPGWrapper, Config, Utils, Math;

destructor TKeySearchForm.Destroy;
begin
  if Assigned(FKeys) then FKeys.Free;

  inherited;
end;

procedure TKeySearchForm.FormShow(Sender: TObject);
begin
  KeyserverCombo.Items.Clear;
  KeyserverCombo.Items.Assign(GConfig.KeyServers);
  if GConfig.Keyservers.Count > 0 then KeyserverCombo.ItemIndex := 0;

  KeyEdit.Clear;
  KeyEdit.SetFocus;

  FSortColumn := 0;
  FSortDesc := false;

  ListView.Items.Clear;

  if FSearchFor <> '' then
  begin
    KeyEdit.Text := FSearchFor;
    FSearchFor := '';
    SearchButton.Click;
  end;
end;

procedure TKeySearchForm.SearchButtonClick(Sender: TObject);
var
  ops: TGPGOps;
  key: TGPGKey;
  i: integer;
  li: TListItem;
begin
  if KeyEdit.Text = '' then Exit;

  ListView.Items.Clear;
  ops := TGPGOps.Create;
  if not Assigned(FKeys) then FKeys := TObjectList.Create else FKeys.Clear;
  Screen.Cursor := crHourGlass;
  SearchButton.Enabled := false;
  Application.ProcessMessages;
  try
    try
      try
        ops.SearchKeys(Trim(KeyEdit.Text), KeyServerCombo.Text, GConfig.ProxySetting, GConfig.ProxyHost, GConfig.ProxyPort, FKeys);
      except
        on ce: GPGConnectException do
        begin
          Screen.Cursor := crDefault;
          MessageDlg(ce.Message, mtError, [mbOK], 0);
        end
        else
        begin
          Screen.Cursor := crDefault;
          MessageDlg('An error occurred while searching the keyserver.', mtError, [mbOK], 0);
        end;
      end;

      for i := 0 to FKeys.Count - 1 do
      begin
        key := FKeys[i] as TGPGKey;
        li := ListView.Items.Add;
        li.Data := key;
        li.Caption := key.UserID;
        li.SubItems.Add(DateTimeToYMD(key.CreatedDate));
        li.SubItems.Add(key.GetKeyID(GConfig.Show16DigitIDs));
        li.SubItems.Add(IntToStr(key.KeyLength));
      end;
    except
    end;

    if FKeys.Count = 0 then ListView.Items.Add.Caption := 'No results returned.';
    ListView.SetFocus;

  finally
    SearchButton.Enabled := true;
    Screen.Cursor := crDefault;
    ops.Free;
  end;
end;

procedure TKeySearchForm.AddButtonClick(Sender: TObject);
begin
  AddKeys;
end;

procedure TKeySearchForm.AddKeys;
var
  i: integer;
  sl, ids: TStringList;
  ops: TGPGOps;
  key: TGPGKey;
  msg: string;
  imported: cardinal;
begin
  sl := TStringList.Create;
  ids := TStringList.Create;
  ops := TGPGOps.Create;
  Screen.Cursor := crHourGlass;
  AddButton.Enabled := false;
  Application.ProcessMessages;
  try
    for i := 0 to ListView.Items.Count - 1 do
    begin
      if ListView.Items[i].Selected then
      begin
        if (ListView.Items[i].SubItems.Count > 1) and
           (ListView.Items[i].SubItems[1] <> '') then
        begin
          key := ListView.Items[i].Data;
          sl.Add(key.GetKeyID(true));
        end;
      end;
    end;

    if sl.Count > 0 then
    begin
      msg := '';

      try
        ops.RecvKeys(KeyServerCombo.Text, GConfig.ProxySetting, GConfig.ProxyHost, GConfig.ProxyPort, sl, imported, ids);
        for i := 0 to ids.Count - 1 do msg := msg + '   ' + ids[i] + #13#10;
        Screen.Cursor := crDefault;
        MessageDlg('Keys imported successfully:'#13#10 + msg, mtInformation, [mbOK], 0)
      except
        on ce: GPGConnectException do
        begin
          Screen.Cursor := crDefault;
          MessageDlg(ce.Message, mtError, [mbOK], 0);
        end
        else
        begin
          Screen.Cursor := crDefault;
          MessageDlg('Unable to receive keys from keyserver.', mtError, [mbOK], 0);
        end;
      end;
    end;
  finally
    AddButton.Enabled := true;
    Screen.Cursor := crDefault;
    ids.Free;
    sl.Free;
    ops.Free;
  end;
end;

function TKeySearchForm.Search(s: string): integer;
begin
  FSearchFor := s;
  result := ShowModal;
end;

procedure TKeySearchForm.ListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if FSortColumn = column.Index then
    FSortDesc := not FSortDesc
  else
    FSortDesc := false;

  FSortColumn := column.Index;
  ListView.AlphaSort;
end;

procedure TKeySearchForm.ListViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if not Assigned(item1.Data) or not Assigned(item2.Data) then Exit;

  case FSortColumn of
    0: compare := CompareText(item1.Caption, item2.Caption);
    3: compare := CompareValue(StrToIntDef(item1.SubItems[FSortColumn-1], 0), StrToIntDef(item2.SubItems[FSortColumn-1], 0));
    else compare := CompareText(item1.SubItems[FSortColumn-1], item2.SubItems[FSortColumn-1]);
  end;

  if FSortDesc then compare := -compare;
end;

procedure TKeySearchForm.KeyEditEnter(Sender: TObject);
begin
  SearchButton.Default := true;
  AddButton.Default := false;
end;

procedure TKeySearchForm.ListViewEnter(Sender: TObject);
begin
  SearchButton.Default := false;
  AddButton.Default := true;
end;

procedure TKeySearchForm.KeyserverComboEnter(Sender: TObject);
begin
  SearchButton.Default := true;
  AddButton.Default := false;
end;

end.
