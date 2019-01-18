unit UNFCeWebModulle;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  FireDAC.DApt,

  MVCFramework, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB;

type
  TNFCEWebModule = class(TWebModule)
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
  private
    FMVC: TMVCEngine;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TNFCEWebModule;

const
  NOME_CONEXAO_FB = 'CONEXAO_SERVIDOR_DMC';

implementation

{$R *.dfm}

uses
  UNFCeController,
  UConfigClass,
  System.IOUtils,

  MVCFramework.Commons,
  MVCFramework.Middleware.Compression;

procedure TNFCEWebModule.WebModuleCreate(Sender: TObject);
var
  oParametros: TStringList;
begin
  FDManager.Close;
  try
    oParametros := TStringList.Create;
    oParametros.Clear;
    oParametros.Add('DriverID=FB');
    oParametros.Add('User_Name=sysdba');
    oParametros.Add('Password=masterkey');
    oParametros.Add('Protocol=TCPIP');
    oParametros.Add('CharacterSet=WIN1252');
    oParametros.Add('Server='   + ConfigServer.IP);
    oParametros.Add('Port='     + ConfigServer.Porta.ToString);
    oParametros.Add('Database=' + ConfigServer.Path);

    FDManager.AddConnectionDef(NOME_CONEXAO_FB, 'FB', oParametros);
    FDManager.Open;
  finally
    oParametros.Free;
  end;

  FMVC := TMVCEngine.Create(Self,
    procedure(Config: TMVCConfig)
    begin
      //enable static files
      Config[TMVCConfigKey.DocumentRoot] := TPath.Combine(ExtractFilePath(GetModuleName(HInstance)), 'www');
      // session timeout (0 means session cookie)
      Config[TMVCConfigKey.SessionTimeout] := '0';
      //default content-type
      Config[TMVCConfigKey.DefaultContentType] := TMVCConstants.DEFAULT_CONTENT_TYPE;
      //default content charset
      Config[TMVCConfigKey.DefaultContentCharset] := TMVCConstants.DEFAULT_CONTENT_CHARSET;
      //unhandled actions are permitted?
      Config[TMVCConfigKey.AllowUnhandledAction] := 'false';
      //default view file extension
      Config[TMVCConfigKey.DefaultViewFileExtension] := 'html';
      //view path
      Config[TMVCConfigKey.ViewPath] := 'templates';
      //Max Record Count for automatic Entities CRUD
      Config[TMVCConfigKey.MaxEntitiesRecordCount] := '20';
      //Enable Server Signature in response
      Config[TMVCConfigKey.ExposeServerSignature] := 'true';
      // Define a default URL for requests that don't map to a route or a file (useful for client side web app)
      Config[TMVCConfigKey.FallbackResource] := 'index.html';
      // Max request size in bytes
      Config[TMVCConfigKey.MaxRequestSize] := IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE);
    end);

  FMVC.AddController(TNFCeController);

  // To enable compression (deflate, gzip) just add this middleware as the last one
  FMVC.AddMiddleware(TMVCCompressionMiddleware.Create);
end;

procedure TNFCEWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

end.
base'] :=
