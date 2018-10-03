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
  Date.....: 18 Octobre 2007 @17:46
  URL......: http://sbibuilder.shorturl.com/
  Auteur...: Quasiment pour la totalité, f0xi. Pour le reste, moi-même.

  Description :

  Cette unité permet de créer des chaines de caractères dessinées avec une
  grille de lettres bitmap. Il s'agit d'un remake de la source que j'avais
  posté, mais avec bien plus d'avantages :

  - Polyvalence : Elle permet d'utiliser des fontes bitmaps différentes plus ou
    moins complètes et une utilisation plus large sur les traitements graphique
    en aval avec la gdi, gdi+, DirectX ou OpenGL, grâce à son indépendance
    complète par rapport a ces derniers.

  - Performance : routines de traitements d'indexation et mapping plus simples,
    tout est pré-calculé avant les lourds traitements graphiques et reste stocké
    jusqu'a la fermeture du programme. Les ressources sont plus legères avec une
    consomation de 255 octets seulement pour chaque table d'index et un
    traitement rapide du mapping de chaine.

  - Ludique : un débutant saura l'utiliser et l'implémenter sans difficultées
    avec un minimum d'indications, un infographiste comprendra immédiatement
    comment construire l'image de la fonte, un développeur comprendra également
    très vite qu'il peut enregistrer dans un fichier la chaine de base pour
    l'indexation (CharsEnum) et cela pour chaque fonte, ce qui permet de
    construire des programmes plus élaborés et plus souples niveau customisation
    ou mise à jour.

  Comment tester l'unité :

  procedure TForm1.Button1Click(Sender: TObject);
  var
    CharsMap: TCharsMap;
    MapStr: TMappedString;
    i, NullIndex: Integer;
    string_to_map: string;
  
  begin
    // tout d'abord on initialise le tableau d'index faisant la correspondance
    // vrai caractère ASCII <-> index dans l'image
    NullIndex := 0;
    CreateCharsMap(' !"****''()'+
                   '**,-. 0123'+
                   '456789:*<='+
                   '>**ABCDEFG'+
                   'HIJKLMNOPQ'+
                   'RSTUVWXYZ*', NullIndex, CharsMap);
    CharsMap['*'] := NullIndex; // "*" indique tous les trous
    CopyUpIndexToLo(CharsMap);

    // on crée la chaine mappée
    string_to_map := 'Hello World!';
    CreateMappedStr(string_to_map, CharsMap, MapStr);

    // on affiche le tableau résultant
    for i := 0 to Length(string_to_map) - 1 do
      ShowMessage(IntToStr(MapStr[i]));
  end;
}
unit oldskool_font_mapper;

interface

uses
  Types;

type
  // contient les index des caractères dans l'image
  TCharsMap     = array[Char] of Byte;
  // permet de stocker une chaine "mappée"
  TMappedString = array of Byte;

procedure CreateCharsMap(const CharsEnum: string; const NullIndex: Byte; var CharsMap: TCharsMap);
procedure CreateMappedStr(const S : string; const CharsMap: TCharsMap; var MappedString: TMappedString);
procedure CopyUpIndexToLo(var CharsMap: TCharsMap);
procedure CopyLoIndexToUp(var CharsMap: TCharsMap);

implementation

//------------------------------------------------------------------------------

// Procédure à appeler en premier
// CharsEnum correspond aux lettres presente dans l'image
// dans l'ordre (gauche haut > droite bas) d'apparition
// NullIndex correspond a l'index "vide" pour les caracteres non presents (0 par exemple)
procedure CreateCharsMap(const CharsEnum: string; const NullIndex: Byte; var CharsMap: TCharsMap);
var
  N: integer;

begin
  // on remplit avec NullIndex
  FillChar(CharsMap, 256, NullIndex);
  
  // pour chaque caracteres présent on assigne l'index dans l'image
  for N := 1 to Length(CharsEnum) do
     CharsMap[CharsEnum[N]] := N-1;
end;

//------------------------------------------------------------------------------

// procédure permettant de transposer les index des caractères majuscule au caractères minuscule
procedure CopyUpIndexToLo(var CharsMap : TCharsMap);
var
  pS, pD: ^Char;

begin
  pS := @CharsMap;
  pD := @CharsMap;
  Inc(pS, $41); {'A'}
  Inc(pD, $61); {'a'}
  Move(pS^, pD^, 26); {de 'A'..'Z' a 'a'..'z'}
end;

//------------------------------------------------------------------------------

// procédure permettant de transposer les index des caractères minuscule au caractères majuscule
procedure CopyLoIndexToUp(var CharsMap : TCharsMap);
var
  pS, pD: ^Char;
  
begin
  pS := @CharsMap;
  pD := @CharsMap;
  Inc(pS, $61); {'a'}
  Inc(pD, $41); {'A'}
  Move(pS^, pD^, 26); {de 'a'..'z' a 'A'..'Z'}
end;

//------------------------------------------------------------------------------

// Permet d'effectuer le mapping d'une chaine
// S est la chaine a mapper
// CharsMap est la table d'index a utiliser pour le mapping
// MappedString est la table d'index resultante
procedure CreateMappedStr(const S: string; const CharsMap: TCharsMap; var MappedString: TMappedString);
var
  N: integer;
  
begin
  SetLength(MappedString, Length(S));
  for N := 1 to Length(S) do
    MappedString[N-1] := CharsMap[S[N]];
end;

//------------------------------------------------------------------------------

end.
