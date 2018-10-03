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

 Reutilisable template: About "Mario" window 
}
unit about;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ImgList, oldskool_font_vcl;

type
  TfrmAbout = class(TForm)
    iMario: TImage;
    iGround: TImage;
    iCloud2: TImage;
    iCloud1: TImage;
    tAnim: TTimer;
    ilMario: TImageList;
    iBmpFont: TImage;
    iPeach: TImage;
    iBkgnd: TImage;
    iYouSuck: TImage;
    iSiZLogo: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tAnimTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Déclarations privées }
    AccelerateText: Boolean;
    AnimTime: Integer;
    BrightnessBG: Integer;
    BrightnessPic: Integer;
    JumpGravity: Integer;
    Jumping: Boolean;
    JumpDone: Boolean;
    MarioAnimDone: Boolean;
    NextPart: Boolean;
    PrepareScroller: Boolean;
    TextDemo: Boolean;
    TextJumpValue: Integer;
    YouSuck: Boolean;
    Walking: Boolean;

    BitmapVcl: TOldskoolFontBitmapVcl;
    BmpBuf: TBitmap;

    procedure ResetAnim;
    procedure ChangeBrightness(Bitmap: TBitmap; Brightness: Integer);
    procedure DrawString;
    procedure InitBitmapFont;
  public
    { Déclarations publiques }
  end;

var
  frmAbout: TfrmAbout;
  FirstShow: Boolean = False;
  
implementation

uses
  uFMOD, GraphUtil, Math;
  
{$R *.dfm}

//------------------------------------------------------------------------------

procedure TfrmAbout.DrawString;
const
  Str = 'HEY HEY HEY PEOPLE!                              SIZIOUS IS VERY PROUD '
  + 'TO PRESENT YOU A NICE NEW PROGGY FOR YOUR PLEASURE! ...                     '
  + 'HEY HEY HEY !!!                     '
  + 'I HOPE YOU''LL BE ENJOYED BY THIS PRODUCTION ! ...            '
  + 'OK THAT''S ALL BOYS AND GIRLS...                     BUT ...                     I WANNA '
  + 'SAY ANOTHER LITTLE THING...                     MILY, I LOVE YOU !!!                     '
  + 'DEMO IS OVER... THANKS FOR WATCHING THIS LITTLE OLDSKOOL SCROLLER, AND YES '
  + 'IT SUCKS!!!                 BUT I LOVE IT, AND YOU CAN''T BLAME ME!!!    SO... CHEERZ !!!';

begin
  BmpBuf := TBitmap.Create;
  try
    BitmapVcl.DrawString(Str, BmpBuf);
    iBmpFont.Picture.Assign(BmpBuf);
    iBmpFont.AutoSize := True;
  finally
    BmpBuf.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  uFMOD_PlaySong(PChar('MUSIC'), 0, XM_RESOURCE);

  ResetAnim;
  BrightnessBG := 0;
  BrightnessPic := 0;
  TextJumpValue := 0;
  TextDemo := False;
  AccelerateText := False;
  YouSuck := False;
  PrepareScroller := False;

  InitBitmapFont;

  // le sol de démo
  iGround.Left := 0;
  iGround.Top := Self.Height;
  iGround.Visible := True;

  // cacher le logo SiZ!
  iSiZLogo.Top := - iSiZLogo.Height;
end;

//------------------------------------------------------------------------------

procedure TfrmAbout.FormDestroy(Sender: TObject);
begin
  uFMOD_StopSong;
  BitmapVcl.Free;
end;

procedure TfrmAbout.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then Close;  
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
end;

//------------------------------------------------------------------------------

procedure TfrmAbout.InitBitmapFont;
const
  FONT_RESNAME  = 'BMPFONT';
  FONT_LINES    = 3;
  FONT_COLS     = 20;
  FONT_NULLCHAR = '*';
  FONT_NULLIND  = 53;
  {FONT_MAP      =   ' !"****''()' +
                    '**,-. 0123' +
                    '456789:*<=' +
                    '>**ABCDEFG' +
                    'HIJKLMNOPQ' +
                    'RSTUVWXYZ*';}
  FONT_MAP      = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ*0123456789**********.'',!?';
  
var
  BufFont: TBitmap;

begin
  BufFont := TBitmap.Create;

  try
    // ici le "*" sert de caractère "à trou". C'est un choix. A chaque fois qu'il
    // y'aura un "*", ça représentera un index de 0 (car NullIndex = 0)
    BufFont.Handle := LoadBitmap(hInstance, FONT_RESNAME);
    BitmapVcl := TOldskoolFontBitmapVcl.Create(FONT_MAP, FONT_NULLIND,
      FONT_NULLCHAR, BufFont, FONT_LINES, FONT_COLS);
  finally
    BufFont.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmAbout.ResetAnim;
begin
  AnimTime := 0;
  Jumping := False;
  JumpDone := False;
  Walking := False;
  NextPart := False;
  MarioAnimDone := False;
end;

//------------------------------------------------------------------------------

procedure TfrmAbout.ChangeBrightness(Bitmap: TBitmap; Brightness: Integer);
var
  LUT: array[Byte] of Byte;
  v, i: Integer;
{$IFDEF ChangeBrightness24Bit}
  w, h, x, y: Integer;
  LineSize: LongInt;
  pLineStart: PByte;
{$ENDIF}
  p: PByte;
begin
  { create LUT }
  for i := 0 to 255 do
  begin
    v := i + Brightness;
    if v < 0 then
      v := 0
    else if v > 255 then
      v := 255;
    LUT[i] := v;
  end;

{$IFDEF ChangeBrightness24Bit}
  { edit bitmap }
  w := Bitmap.Width;
  h := Bitmap.Height - 1;
  Bitmap.PixelFormat := pf24Bit;
  pLineStart := PByte(Bitmap.ScanLine[h]);
  { pixel line is aligned to 32 Bit }
  LineSize := ((w * 3 + 3) div 4) * 4;
  w := w * 3 - 1;
  for y := 0 to h do
  begin
    p := pLineStart;
    for x := 0 to w do
    begin
      p^ := LUT[p^];
      Inc(p);
    end;
    Inc(pLineStart, LineSize);
  end;
{$ELSE}
  { edit bitmap }
  Bitmap.PixelFormat := pf32Bit;
  p := PByte(Bitmap.ScanLine[Bitmap.Height - 1]);
  for i := 0 to Bitmap.Width * Bitmap.Height - 1 do
  begin
    p^ := LUT[p^];
    Inc(p);
    p^ := LUT[p^];
    Inc(p);
    p^ := LUT[p^];
    Inc(p, 2);
  end;
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TfrmAbout.tAnimTimer(Sender: TObject);
begin
  Inc(AnimTime);

  if not MarioAnimDone then begin

    // au début, mario attend 60 millisecondes puis marche pendant 200 millisecondes
    if (not Walking) and (not Jumping) and (AnimTime > 50) and (AnimTime < 200) then
      Walking := True;

    // ça y est il marche avec une anim
    if Walking then begin
      iMario.Left := iMario.Left + 1;
      if (AnimTime mod 5) = 0 then begin
        iMario.Picture := nil;
        ilMario.GetBitmap(AnimTime mod 2, iMario.Picture.Bitmap);
      end;
    end;

    // Mario va sauter à la 200 millième seconde
    if (Walking) and (AnimTime > 200) then begin
      Walking := False;
      Jumping := True;
      AnimTime := 0;
      JumpGravity := -1;
      tAnim.Interval := 30; // on change le timer pour que le saut soit plus lent
      iMario.Picture := nil;
      ilMario.GetBitmap(3, iMario.Picture.Bitmap); // on charge l'image de saut
    end;

    // Mario saute dans le trou
    if Jumping then begin
      iMario.Left := iMario.Left + 1;
      iMario.Top := iMario.Top + (JumpGravity * AnimTime);

      // on peut même gérer ici la collision avec le sol :
      if (iMario.Top < 50) then begin
        JumpGravity := 1;
        AnimTime := 0;
        JumpDone := True;
      end;

      if (JumpDone) and (iMario.Top > Self.Height) then begin
        MarioAnimDone := True; // mario est tombé dans le trou
        // MessageBeep(0);
      end;
    end;

    // c'est bon on continue
    if MarioAnimDone then begin
      ResetAnim;
      MarioAnimDone := True;
      NextPart := True;
    end;

  end; // MarioAnimDone

  // on fait tout devenir noir
  if NextPart and (AnimTime > 8) then begin
    if (AnimTime mod 2 = 0) then begin
      Inc(BrightnessBG);
      Dec(BrightnessPic, 2);
      Self.Color := GetHighLightColor(Self.Color, BrightnessBG);
      ChangeBrightness(iBkgnd.Picture.Bitmap, BrightnessPic);
      ChangeBrightness(iCloud1.Picture.Bitmap, BrightnessPic);
      ChangeBrightness(iCloud2.Picture.Bitmap, BrightnessPic);
      ChangeBrightness(iPeach.Picture.Bitmap, BrightnessPic);
      if BrightnessBG >= 17 then begin
        NextPart := False;
        iBkgnd.Visible := False;
        iCloud1.Visible := False;
        iCloud2.Visible := False;
        iMario.Visible := False;
        iPeach.Visible := False;
        YouSuck := True;
        AnimTime := 0;
      end;
    end;
  end;

  // on affiche "you suck"
  if (YouSuck) and (AnimTime > 20) then begin
    iYouSuck.Visible := True;
  end;

  // on cache "you suck"
  if (YouSuck) and (AnimTime > 100) then begin
    iYouSuck.Visible := False;
    YouSuck := False;
    AnimTime := 0;
    PrepareScroller := True;
    iGround.Visible := True;
    iSiZLogo.Visible := True;
  end;

  // on fait glisser le sol ou le scroller va rebondir
  if PrepareScroller then begin
    if (iSiZLogo.Top < 5) then iSiZLogo.Top := iSiZLogo.Top + 1;
    if (iGround.Top > 170) then iGround.Top := iGround.Top - 1;
    if (iGround.Top <= 170) and (iSiZLogo.Top >= 5) then begin
      PrepareScroller := False;
      AnimTime := 0;
      TextDemo := True;
    end;
  end;

  // on prépare le texte
  if (TextDemo) and (AnimTime = 0) then begin
    Self.Color := clBlack;
    Self.iBmpFont.Left := 200 + Self.Width;
    DrawString;
    tAnim.Interval := 8;
    JumpGravity := -1;
    TextJumpValue := 1;
  end;

  // et on l'anime
  if TextDemo and (AnimTime > 0) then begin
    if (AccelerateText) and (AnimTime mod 2 = 0) then
      Inc(TextJumpValue);
    
    Self.iBmpFont.Left := Self.iBmpFont.Left - 2;
    Self.iBmpFont.Top := Self.iBmpFont.Top + (JumpGravity * TextJumpValue);

    if Self.iBmpFont.Top < 90 then begin
      JumpGravity := 1;
      TextJumpValue := 1; // le faire tomber
      AccelerateText := True;
    end else
      if Self.iBmpFont.Top > 146 then begin
        JumpGravity := -1;
        TextJumpValue := 1; // il faut remonter le texte
        AccelerateText := False;
      end;
  end;

  // fini
  if TextDemo and (AnimTime > 5040) then Close;  
end;

//------------------------------------------------------------------------------

end.
