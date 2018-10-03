unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, XPMan, StdCtrls, Buttons, JvComponent, JvBaseDlg,
  JvBrowseFolder, ShellApi, jpeg;

type
  TMain_Form = class(TForm)
    Shape1: TShape;
    Bevel1: TBevel;
    pButtons: TPanel;
    Bevel2: TBevel;
    XPManifest: TXPManifest;
    lTitle: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    GroupBox1: TGroupBox;
    eSrc: TEdit;
    BitBtn4: TBitBtn;
    GroupBox2: TGroupBox;
    eDest: TEdit;
    BitBtn5: TBitBtn;
    GroupBox3: TGroupBox;
    eVolumeName: TEdit;
    Panel1: TPanel;
    Image1: TImage;
    GroupBox5: TGroupBox;
    eIpBin: TEdit;
    BitBtn6: TBitBtn;
    odDir: TJvBrowseForFolderDialog;
    odIpBin: TOpenDialog;
    Label1: TLabel;
    sdDest: TSaveDialog;
    GroupBox4: TGroupBox;
    eISO: TEdit;
    BitBtn7: TBitBtn;
    odISO: TOpenDialog;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    function GetTempDir: string;
    function GetLongPath(PathName: string): string;
    { Déclarations privées }
  public
    { Déclarations publiques }
    function MsgBox(Text, Caption: string; Flags: Integer): Integer;
  end;

var
  Main_Form: TMain_Form;

implementation

{$R *.dfm}

uses
  Utils, about;
  
procedure TMain_Form.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  lTitle.Caption := Caption;
  pButtons.ParentBackground := False;

  if not LoadConfig then begin
    eIpBin.Text := GetToolsDir + 'IP.BIN';
    eISO.Text := GetTempDir + 'data.iso';
  end;
end;

procedure TMain_Form.FormDestroy(Sender: TObject);
begin
  SaveConfig;
end;

procedure TMain_Form.BitBtn3Click(Sender: TObject);
begin
  Close;
end;

procedure TMain_Form.BitBtn4Click(Sender: TObject);
begin
  with odDir do if Execute then eSrc.Text := Directory;
end;

procedure TMain_Form.BitBtn5Click(Sender: TObject);
begin
  with sdDest do if Execute then eDest.Text := FileName;
end;

procedure TMain_Form.BitBtn6Click(Sender: TObject);
begin
  with odIpBin do if Execute then eIpBin.Text := FileName;
end;

function GetLongPathNameA(lpFileName : LPCTSTR ; lpBuffer : LPTSTR;
         nBufferLength : DWORD) : Integer; stdcall; external 'kernel32.dll';
{ à mettre pour pouvoir d'utiliser GetLongPathNameA qui se trouve
{ dans la dll kernel32}

function TMain_Form.GetLongPath(PathName : string): string;
var
  Long : Cardinal;
  LongPath : array[0..MAX_PATH - 1] of Char;

begin
  long := GetLongPathNameA(PChar(PathName), nil, 0);
  if long > 0 then
    begin
      GetLongPathNameA(PChar(PathName), LongPath, long);
      Result := LongPath;
    end
  else Result := PathName; //Le path n''est pas bon
end;

function TMain_Form.GetTempDir : string;
var
  Dossier: array[0..MAX_PATH] of Char;

begin
  Result := '';
  if GetTempPath(SizeOf(Dossier), Dossier)<>0 then Result := IncludeTrailingPathDelimiter(GetLongPath(StrPas(Dossier)));
end;

procedure TMain_Form.BitBtn2Click(Sender: TObject);
var
  F : TextFile;
  
begin
  AssignFile(F, GetTempDir + 'start.bat');
  ReWrite(F);
  WriteLn(F, '@echo off');
  WriteLn(F, '"' + GetToolsDir + 'mkisofs" -C 0,11702 -V "' + eVolumeName.Text + '" -joliet -rock -l -o "' + eISO.Text + '" "' + eSrc.Text + '"');
  WriteLn(F, 'echo.');
  WriteLn(F, '"' + GetToolsDir + 'ipinj" "' + eIpBin.Text + '" "' + eISO.Text + '"');
  WriteLn(F, '"' + GetToolsDir + 'cdi4dc" "' + eISO.Text + '" "' + eDest.Text + '"'); 
  WriteLn(F, 'del "' + eISO.Text + '"');
  WriteLn(F, 'pause');
  WriteLn(F, ':deletebat');
  WriteLn(F, 'del "' + GetTempDir + 'start.bat' + '"');
  WriteLn(F, 'if exists "' + GetTempDir + 'start.bat' + '" goto deletebat');
  CloseFile(F);

  ShellExecute(Handle, 'open', PChar(GetTempDir + 'start.bat'), '', '', SW_SHOWNORMAL);
end;

procedure TMain_Form.BitBtn7Click(Sender: TObject);
begin
  with odISO do if Execute then eISO.Text := FileName;
end;

procedure TMain_Form.BitBtn1Click(Sender: TObject);
begin
  frmAbout := TfrmAbout.Create(Application);
  try
    frmAbout.ShowModal;
  finally
    frmAbout.Free;
  end;
end;

function TMain_Form.MsgBox(Text, Caption : string ; Flags : Integer) : Integer;
begin
  Result := MessageBoxA(Handle, PChar(Text), PChar(Caption), Flags);
end;

end.
