unit Config;

interface

uses Classes, Types, Registry, Utils, GPGOps;

type
  TDefaultExt = (deGPG, dePGP);
  TCColumns = (cName, cEmail, cComment, cTrust, cSigs, cCreated, cExpires, cKeyID);

const
  CDefaultExt: array [deGPG..dePGP] of string = ( 'gpg', 'pgp' );

type
  TConfig = class
  private
    procedure SetProxySetting(const value: TProxySetting);
    procedure SetUseUntrustedKey(const value: boolean);
    function GetUseUntrustedKey(): boolean;
  protected
    FNoRegistryLoadSave: boolean;

    FKeyServers: TStringList;
    FShowExpiredKeys: boolean;
    FShowFolders: boolean;
    FSortDesc: boolean;
    FSortColumn: TCColumns;
    FViewDetails: boolean;
    FViewHints: boolean;
    FViewComments: boolean;
    FWindowRect: TRect;
    FFolderWidth: integer;
    FDefaultSecretKey: string;
    FDebugMode: boolean;
    FKeyFolders: TStringPairList;
    FFolders: TStringList;
    FDefaultExt: TDefaultExt;
    FShow16DigitIDs: boolean;
    FProxySetting: TProxySetting;
    FProxyHost: string;
    FProxyPort: integer;
    FShowSuccessDialogs: boolean;

    procedure LoadWindowsProxySettings;

  public
    constructor Create(noRegistryLoadSave: boolean);
    destructor Destroy; override;

    procedure SetDefaults;
    procedure Load;
    procedure Save;

    property KeyServers: TStringList read FKeyServers write FKeyServers;
    property ShowExpiredKeys: boolean read FShowExpiredKeys write FShowExpiredKeys;
    property ShowFolders: boolean read FShowFolders write FShowFolders;
    property SortColumn: TCColumns read FSortColumn write FSortColumn;
    property SortDesc: boolean read FSortDesc write FSortDesc;
    property ViewDetails: boolean read FViewDetails write FViewDetails;
    property ViewHints: boolean read FViewHints write FViewHints;
    property ViewComments: boolean read FViewComments write FViewComments;
    property WindowRect: TRect read FWindowRect write FWindowRect;
    property FolderWidth: integer read FFolderWidth write FFolderWidth;
    property DefaultSecretKey: string read FDefaultSecretKey write FDefaultSecretKey;
    property DebugMode: boolean read FDebugMode write FDebugMode;
    property KeyFolders: TStringPairList read FKeyFolders;
    property Folders: TStringList read FFolders;
    property DefaultExt: TDefaultExt read FDefaultExt write FDefaultExt;
    property Show16DigitIDs: boolean read FShow16DigitIDs write FShow16DigitIDs;
    property ProxySetting: TProxySetting read FProxySetting write SetProxySetting;
    property ProxyHost: string read FProxyHost write FProxyHost;
    property ProxyPort: integer read FProxyPort write FProxyPort;
    property ShowSuccessDialogs: boolean read FShowSuccessDialogs write FShowSuccessDialogs;
    property UseUntrustedKey: boolean read GetUseUntrustedKey write SetUseUntrustedKey;
  end;

var
  GConfig: TConfig;

implementation

uses SysUtils, DefaultRegistry, RegExpr, ProxyInfo;

{ TConfig }

constructor TConfig.Create(noRegistryLoadSave: boolean);
begin
  FNoRegistryLoadSave := noRegistryLoadSave;
  FKeyServers := TStringList.Create;
  FKeyServers.Duplicates := dupIgnore;
  FKeyServers.CaseSensitive := false;
  FKeyFolders := TStringPairList.Create;
  FFolders := TStringList.Create;
  FDefaultExt := deGPG;
end;

destructor TConfig.Destroy;
begin
  FFolders.Free;
  FKeyFolders.Free;
  FKeyServers.Free;
end;

procedure TConfig.SetDefaults;
begin
  FKeyServers.Clear;
  FKeyServers.Add('pgp.mit.edu');
  FKeyServers.Add('wwwkeys.au.pgp.net');
  FShowExpiredKeys := true;
  FShowFolders := false;
  FSortColumn := cName;
  FSortDesc := false;
  FViewDetails := true;
  FViewHints := true;
  FViewComments := false;
  FWindowRect := Rect(0, 0, 0, 0);
  FFolderWidth := 100;
  FDefaultSecretKey := '';
  FDebugMode := false;
  Show16DigitIDs := false;
  FProxySetting := psUseWindows; { this sets ProxyHost/ProxyPort }
  FShowSuccessDialogs := true;

  FKeyFolders.Clear;
  FFolders.Clear;
  FFolders.Add('Keys');
end;

procedure TConfig.Load;
var
  re: TRegExpr;
  r: TDefaultRegistry;
  i, n: integer;
  s: string;
  ss: TStringList;
  de: TDefaultExt;
begin
  SetDefaults;
  if FNoRegistryLoadSave then exit;

  r := TDefaultRegistry.Create;
  re := TRegExpr.Create;
  ss := TStringList.Create;
  try
    if not r.OpenKey('SOFTWARE\eCOSM\Cryptophane', false) then Exit;

    ShowExpiredKeys := r.ReadBool('ShowExpiredKeys', ShowExpiredKeys);
    ShowFolders := r.ReadBool('ShowFolders', ShowFolders);
    SortColumn := TCColumns(r.ReadInteger('SortColumn', Integer(SortColumn)));
    SortDesc := r.ReadBool('SortDesc', SortDesc);
    ViewDetails := r.ReadBool('ViewDetails', ViewDetails);
    ViewHints := r.ReadBool('ViewHints', ViewHints);
    ViewComments := r.ReadBool('ViewComments', ViewComments);
    DefaultSecretKey := r.ReadString('DefaultSecretKey', DefaultSecretKey);
    DebugMode := r.ReadBool('DebugMode', DebugMode);
    FolderWidth := r.ReadInteger('FolderWidth', FolderWidth);
    Show16DigitIDs := r.ReadBool('Show16DigitIDs', Show16DigitIDs);
    ShowSuccessDialogs := r.ReadBool('ShowSuccessDialogs', ShowSuccessDialogs);
    UseUntrustedKey := r.ReadBool('UseUntrustedKey', UseUntrustedKey);

    // Important: must load Host/Port first.
    ProxyHost := r.ReadString('ProxyHost', ProxyHost);
    ProxyPort := r.ReadInteger('ProxyPort', ProxyPort);
    ProxySetting := TProxySetting(r.ReadInteger('ProxySetting', Integer(ProxySetting)));

    s := r.ReadString('DefaultExt', CDefaultExt[DefaultExt]);
    de := Low(CDefaultExt);
    while de <= High(CDefaultExt) do
    begin
      if CDefaultExt[de] = s then
      begin
        DefaultExt := de;
        break;
      end;
      Inc(de);
    end;

    re.Expression := '^(\d+),(\d+),(\d+),(\d+)$';
    if re.Exec(r.ReadString('WindowRect', '')) then
    begin
      WindowRect := Rect(StrToInt(re.Match[1]), StrToInt(re.Match[2]), strToInt(re.Match[3]), StrToInt(re.Match[4]));
    end;

    n := r.ReadInteger('KeyServer.Count', 0);
    if n > 0 then
    begin
      FKeyServers.Clear;
      for i := 0 to n - 1 do
      begin
        s := r.ReadString('KeyServer.' + IntToStr(i), '');
        if s <> '' then FKeyServers.Add(s);
      end;
    end;

    r.CloseKey;
    if r.OpenKey('SOFTWARE\eCOSM\Cryptophane\KeyFolders', false) then
    begin
      r.GetValueNames(ss);
      for i := 0 to ss.Count - 1 do KeyFolders.Add(ss[i], r.ReadString(ss[i]));
    end;

    r.CloseKey;
    if r.OpenKey('SOFTWARE\eCOSM\Cryptophane\Folders', false) then
    begin
      r.GetValueNames(ss);
      Folders.Clear;
      for i := 0 to ss.Count - 1 do Folders.Add(r.ReadString(ss[i]));
    end;

  finally
    r.Free;
    re.Free;
    ss.Free;
  end;
end;

procedure TConfig.Save;
var
  r: TDefaultRegistry;
  i: integer;
begin
  if FNoRegistryLoadSave then exit;

  r := TDefaultRegistry.Create;
  try
    if not r.OpenKey('SOFTWARE\eCOSM\Cryptophane', true) then Exit;

    r.WriteBool('ShowExpiredKeys', ShowExpiredKeys);
    r.WriteBool('ShowFolders', ShowFolders);
    r.WriteInteger('SortColumn', Integer(SortColumn));
    r.WriteBool('SortDesc', SortDesc);
    r.WriteBool('ViewDetails', ViewDetails);
    r.WriteBool('ViewHints', ViewHints);
    r.WriteBool('ViewComments', ViewComments);
    r.WriteString('DefaultSecretKey', DefaultSecretKey);
    with WindowRect do r.WriteString('WindowRect', IntToStr(Left)+','+IntToStr(Top)+','+IntToStr(Right)+','+IntToStr(Bottom));
    r.WriteBool('DebugMode', DebugMode);
    r.WriteInteger('FolderWidth', FolderWidth);
    r.WriteString('DefaultExt', CDefaultExt[DefaultExt]);
    r.WriteBool('Show16DigitIDs', Show16DigitIDs);
    r.WriteInteger('ProxySetting', Integer(ProxySetting));
    r.WriteString('ProxyHost', ProxyHost);
    r.WriteInteger('ProxyPort', ProxyPort);
    r.WriteBool('ShowSuccessDialogs', ShowSuccessDialogs);
    r.WriteBool('UseUntrustedKey', UseUntrustedKey);

    r.WriteInteger('KeyServer.Count', FKeyServers.Count);
    for i := 0 to FKeyServers.Count - 1 do
    begin
      r.WriteString('KeyServer.' + IntToStr(i), FKeyServers[i]);
    end;

    r.CloseKey;
    r.DeleteKey('SOFTWARE\eCOSM\Cryptophane\KeyFolders');
    if not r.OpenKey('SOFTWARE\eCOSM\Cryptophane\KeyFolders', true) then Exit;
    for i := 0 to KeyFolders.Count - 1 do
    begin
      r.WriteString(KeyFolders.Keys[i], KeyFolders.Values[i]);
    end;
    
    r.CloseKey;
    r.DeleteKey('SOFTWARE\eCOSM\Cryptophane\Folders');
    if not r.OpenKey('SOFTWARE\eCOSM\Cryptophane\Folders', true) then Exit;
    for i := 0 to Folders.Count - 1 do r.WriteString(IntToStr(i), Folders[i]);

  finally
    r.Free;
  end;
end;

procedure TConfig.LoadWindowsProxySettings;
var
  proxyServerList: TProxyServers;
  bypassList: string;
  accessType: TProxyAccessType;
begin
  // Preset the defaults incase the call to GetDefaultProxyServer fails
  accessType := patDirectConnection;

  // Set the defaults to match windows/IE settings
  GetDefaultProxyServer(proxyServerList, bypassList, accessType);
  if (accessType = patProxyConnection) and
     (proxyServerList[ppHTTP].Port > 0) and
     (proxyServerList[ppHTTP].Port <= 65535) and
     (Length(proxyServerList[ppHTTP].Host) > 0) then
  begin
    ProxyHost := proxyServerList[ppHTTP].Host;
    ProxyPort := proxyServerList[ppHTTP].Port;
  end
  else
  begin
    ProxyHost := '';
    ProxyPort := 0;
  end;
end;

procedure TConfig.SetProxySetting(const value: TProxySetting);
begin
  if (value < Low(TProxySetting)) or (value > High(TProxySetting)) then exit;
   
  case value of
    psDirectConnection:
    begin
      FProxyHost := '';
      FProxyPort := 0;
    end;
    psUseWindows: LoadWindowsProxySettings;
  end;

  FProxySetting := value;
end;

procedure TConfig.SetUseUntrustedKey(const value: boolean);
begin
  GPGOps.UseUntrustedKey := value;
end;

function TConfig.GetUseUntrustedKey(): boolean;
begin
  result := GPGOps.UseUntrustedKey;
end;

end.
