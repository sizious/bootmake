program bootmake;

{$R 'externrc.res' 'externrc.rc'}

uses
  Windows,
  SysUtils,
  Forms,
  main in 'main.pas' {Main_Form},
  utils in 'utils.pas',
  about in 'about\about.pas' {frmAbout},
  oldskool_font_mapper in 'about\oldskool_font_mapper.pas',
  oldskool_font_vcl in 'about\oldskool_font_vcl.pas',
  uFMOD in 'about\uFMOD.pas';

{$R *.res}

begin
  if not CheckBinaries then Halt(1);  
  Application.Initialize;
  Application.CreateForm(TMain_Form, Main_Form);
  Application.Run;
end.
