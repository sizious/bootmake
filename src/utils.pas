unit utils;

interface

uses
  Windows, SysUtils, Forms;

procedure SaveConfig;
function LoadConfig: Boolean;
function GetToolsDir : string;
function CheckBinaries: Boolean;

implementation

uses
  XMLDom, XMLIntf, MSXMLDom, XMLDoc, ActiveX, Main;

var
  ConfigFileName: TFileName;
  
procedure SaveConfig;
var
  XMLDoc: IXMLDocument;

  CurrentNode: IXMLNode;
  procedure AddXMLNode(var XML: IXMLDocument; const Key, Value: string); overload;
  begin
    CurrentNode := XMLDoc.CreateNode(Key);
    CurrentNode.NodeValue := Value;
    XMLDoc.DocumentElement.ChildNodes.Add(CurrentNode);
  end;

  procedure AddXMLNode(var XML: IXMLDocument; const Key: string; const Value: Integer); overload;
  begin
    CurrentNode := XMLDoc.CreateNode(Key);
    CurrentNode.NodeValue := Value;
    XMLDoc.DocumentElement.ChildNodes.Add(CurrentNode);
  end;

  procedure AddXMLNode(var XML: IXMLDocument; const Key: string; const Value: Boolean); overload;
  begin
    CurrentNode := XMLDoc.CreateNode(Key);
    CurrentNode.NodeValue := Value;
    XMLDoc.DocumentElement.ChildNodes.Add(CurrentNode);
  end;
  
begin
  XMLDoc := TXMLDocument.Create(nil);
  try
    with XMLDoc do begin                  
      Options := [doNodeAutoCreate, doAttrNull];
      ParseOptions:= [];
      NodeIndentStr:= '  ';
      Active := True;
      Version := '1.0';
      Encoding := 'ISO-8859-1';
    end;

    // On crée la racine
    XMLDoc.DocumentElement := XMLDoc.CreateNode('bootmakecfg');

    AddXMLNode(XMLDoc, 'source', Main_Form.eSrc.Text);
    AddXMLNode(XMLDoc, 'destination', Main_Form.eDest.Text);
    AddXMLNode(XMLDoc, 'volumename', Main_Form.eVolumeName.Text);
    AddXMLNode(XMLDoc, 'ipbin', Main_Form.eIpBin.Text);
    AddXMLNode(XMLDoc, 'iso', Main_Form.eISO.Text);
    
    XMLDoc.SaveToFile(ConfigFileName);
  finally
    XMLDoc.Active := False;
    XMLDoc := nil;
  end;
end;

function LoadConfig: Boolean;
var
  XMLDoc: IXMLDocument;
  Node: IXMLNode;

begin
  Result := False;
  if not FileExists(ConfigFileName) then Exit;

  XMLDoc := TXMLDocument.Create(nil);
  try
    with XMLDoc do begin
      Options := [doNodeAutoCreate];
      ParseOptions:= [];
      NodeIndentStr:= '  ';
      Active := True;
      Version := '1.0';
      Encoding := 'ISO-8859-1';
    end;

    XMLDoc.LoadFromFile(ConfigFileName);

    if XMLDoc.DocumentElement.NodeName <> 'bootmakecfg' then Exit;

    try
      Node := XMLDoc.DocumentElement.ChildNodes.FindNode('source');
      if Assigned(Node) then Main_Form.eSrc.Text := Node.NodeValue;
    except end;

    try
      Node := XMLDoc.DocumentElement.ChildNodes.FindNode('destination');
      if Assigned(Node) then Main_Form.eDest.Text := Node.NodeValue;
    except end;

    try
      Node := XMLDoc.DocumentElement.ChildNodes.FindNode('volumename');
      if Assigned(Node) then Main_Form.eVolumeName.Text := Node.NodeValue;
    except end;

    try
      Node := XMLDoc.DocumentElement.ChildNodes.FindNode('ipbin');
      if Assigned(Node) then Main_Form.eIpBin.Text := Node.NodeValue;
    except end;

    try
      Node := XMLDoc.DocumentElement.ChildNodes.FindNode('iso');
      if Assigned(Node) then Main_Form.eISO.Text := Node.NodeValue;
    except end;

    Result := True;
  finally
    XMLDoc.Active := False;
    XMLDoc := nil;
  end;
end;

function GetToolsDir : string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'Tools\';
end;

function CheckBinaries: Boolean;

  procedure MsgBox(Text: string);
  begin
    MessageBoxA(Application.Handle, PChar(Text), 'Error', MB_ICONERROR);  
  end;

const
  FILES_NAMES_TO_CHECK : array[0..3] of string = ('cdi4dc.exe', 'ipinj.exe', 'mkisofs.exe', 'cygwin1.dll');

var
  i : Integer;

begin
  Result := False;
  if not DirectoryExists(GetToolsDir) then
  begin
    MsgBox('Tools directory not found !');
    Exit;
  end;

  for i := Low(FILES_NAMES_TO_CHECK) to High(FILES_NAMES_TO_CHECK) do
  begin

    if not FileExists(GetToolsDir + FILES_NAMES_TO_CHECK[i]) then
    begin
      MsgBox('File ' + FILES_NAMES_TO_CHECK[i] + ' not found !' + #13#10
        + 'Make sure you have this file in Tools directory !');
      Exit;
    end;

  end;

  Result := True;
end;

initialization
  ConfigFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'config.xml';
  
end.
