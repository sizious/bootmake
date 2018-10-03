{
                    * * * [b i g _ f u r y ] S i Z i O U S * * *
        _____________    _____________    _____________________________________
       /            /   /            /   /           /    /      /            /
      /     _______/___/_______     /___/           /    /      /     _______/
     /     /      /   /            /   /     /     /    /      /     /      /
    /            /   /            /   /     /     /    /      /            /
   /________/   /   /     _______/   /     /     /    /__    /_________/  /
  /            /   /            /   /           /           /            /
 /____________/___/____________/___/___________/___________/____________/
 
  OldSkool Font par [big_fury]SiZiOUS, basé sur le commentaire de f0xi écrit le
  29/11/2006 03:04:21 sur http://www.delphifr.com/

  Version..: 2.0
  Date.....: 18 Octobre 2007 @19:10
  URL......: http://sbibuilder.shorturl.com/
  Auteur...: f0xi et moi

  Implémentation simple pour la VCL de Delphi de oldskool_font_mapper.
  
}
unit oldskool_font_vcl;

interface

uses
  SysUtils, Types, Graphics, oldskool_font_mapper;

type
  TOldskoolFontBitmapVcl = class
  private
    BitmapFont: TBitmap;
    CharsMap: TCharsMap;
    BCols: Integer;
    CharWidth, CharHeight: Integer;
    function IndexToPoint(const Index: Integer): TPoint;
  public
    constructor Create(CharsEnum: string; const NullIndex: Byte;
      const NullChar: Char; BFont: TBitmap; const Lines, Cols: Integer);
    destructor Destroy; override;
    procedure DrawString(const S: string; var Output: TBitmap);
  end;

implementation

//------------------------------------------------------------------------------
// TOldskoolFontBitmapVcl
//------------------------------------------------------------------------------

{
  CharsEnum : La table de caractères
  NullIndex : Correspond a l'index "vide" pour les caractères non présents (0 par exemple)
  NullChar  : Caractère correspondant aux trous dans CharsEnum.
  BFont     : Correspond au bitmap contenant la font.
  BLines    : Indique le nombre de lignes de caractères dans BFont.
  BCols     : Indique le nombre de colonnes de caractères dans BFont.
}
constructor TOldskoolFontBitmapVcl.Create(CharsEnum: string; const NullIndex: Byte;
      const NullChar: Char; BFont: TBitmap; const Lines, Cols: Integer);
begin
  CharsEnum := UpperCase(CharsEnum); // sysutils pour uppercase, vous pouvez coder vous même la fonction
  CreateCharsMap(CharsEnum, NullIndex, Self.CharsMap);
  CharsMap[NullChar] := NullIndex; // NullChar indique tous les trous dans CharsEnum
  CopyUpIndexToLo(CharsMap);

  Self.BitmapFont := TBitmap.Create;
  
  Self.BitmapFont.Height := BFont.Height;
  Self.BitmapFont.Width := BFont.Width;
  Self.BitmapFont.Assign(BFont);
  CharHeight := BitmapFont.Height div Lines;
  CharWidth := BitmapFont.Width div Cols;
  BCols := Cols;
end;

//------------------------------------------------------------------------------

destructor TOldskoolFontBitmapVcl.Destroy;
begin
  Self.BitmapFont.Free;
  
  inherited;
end;

//------------------------------------------------------------------------------

function TOldskoolFontBitmapVcl.IndexToPoint(const Index: Integer): TPoint;
begin
  Result.X := (Index mod BCols) * CharWidth;
  Result.Y := (Index div BCols) * CharHeight;
end;

//------------------------------------------------------------------------------

procedure TOldskoolFontBitmapVcl.DrawString(const S: string; var Output: TBitmap);
const
  OFFSET_X = 0;
  OFFSET_Y = 0;
  
var
  P: PChar;
  i, len: integer;
  Dr, Sr: TRect;

begin
  P := PChar(S);

  len := Length(S);
  Output.Height := CharHeight;
  Output.Width := (len * CharWidth);
  
  for i := 0 to len - 1 do begin
    Sr.TopLeft     := IndexToPoint(CharsMap[P[i]]);
    Sr.BottomRight := Point(Sr.Left+CharWidth, Sr.Top+CharHeight);

    Dr.TopLeft     := Point(OFFSET_X + (CharWidth*i), OFFSET_Y);
    Dr.BottomRight := Point(OFFSET_X + (CharWidth*(i+1)), OFFSET_Y + CharHeight);

    Output.Canvas.CopyRect(Dr, BitmapFont.Canvas, Sr);
  end;
end;

end.
