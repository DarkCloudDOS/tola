Program Tolaat;

Uses Crt;

Const
  Reka         = 5;
  TMaxLn       = 255;
  Long         = 3;
  TSpeed: Byte = 50;
  TCol         = Reka*16+1;
  Tchar        = 177;
  THead        = 178;
  THeadCol     = 16*Reka+1;
  Border       = $DB;
  WallChar     = $DB;
  BorderColor  = 10;
  ScrX         = 80-0 ;
  ScrY         = 50-5;
  MaxEat       = 5;
  MinEat       = 0;
  BadChars     = [5,10]; { 5 - You, 10 - Wall }
  FoodChar     = 1;
  BigFchance   = 100;
  MaxFChance = 96;
  FoodC        = Ord('*');
  FoodColMax   = 2;
  Score  : Word= 0;
  FoodInc: Byte= 3;
  ScoreX       = 3;
  ScoreY       = 48;
  WalCol       = 0;
  CurrLvl: Byte= 1;
  MaxLvl       = 9;
  Lives  : Byte= 50;
  Lx           = 3;
  Ly           = 49;
  PNL    : Array[1.. MaxLvl] Of Word = (200,500,1000,1500,2000,2700,3500,4300,5100);
  LvlName: Array[1..MaxLvl] Of String = ('1.LVL','2.lvl','3.lvl','4.lvl','5.lvl','6.lvl','7.lvl','8.lvl','9.lvl');
  EndMsg : Array[1..18] Of String = ('Be The Power With You','By Diego',
                                     'You Should Not Eat Your Self','By DGI',
                                     'The Mother Of All Games','Not By Me',
                                     'If You Are A Worm, Be Ware','By Ariel',
                                     'Keep Your Self Alive','By Fredy',
                                     'Always Look Left And Right Before You Cross The Road','By Bela',
                                     'Yo ! Isn''t A Great Game  ??!?!','By Y.B',
                                     'if ul be jurk ul be idiot',' by the best of course ofir',
                                     'You R A Fucking MORRON','By Stas');
Type
  Point    = Record
              X,Y : Byte;
  End;

  TScreen  = Array[1..ScrX,1..ScrY] of Byte;


Var
  Tola     : Array[1..TMaxLn] Of Point;
  Food     : Array[1..MaxEat] Of Point;
  FoodCol  : Array[1..FoodColMax] Of Byte;
  K        : Char;
  Screen   : TScreen;
  TC,
  EatCount,
  TLong    : Byte;
  LvlScore : Word;

Procedure LoadLevel;
Var
  F : File;
Begin
  Assign(F,LvlName[CurrLvl]);
  Reset(F,1);
  BlockRead(F,Screen,SizeOf(Screen));
  Close(F);
End;

Procedure PutChar(X,Y:Word; Ch,Col:Byte);
Begin
  Mem[$B800:160*(Y-1)+2*(X-1)]:=Ch;
  Mem[$B800:160*(Y-1)+2*(X-1)+1]:=Col;
End;

Procedure NewFood;
Var
  Xc,Yc : Byte;
Begin
  Repeat
    Xc:=Random(ScrX-2)+1;
    Yc:=Random(ScrY-2)+1;
  Until Not (Screen[Xc,Yc] In BadChars);
  Screen[Xc,Yc]:=FoodChar;
  PutChar(Xc,Yc,FoodC,FoodCol[Random(FoodColMax)+1]);
  Inc(EatCount);
  For Xc:=200 To 210 Do Begin Sound(Xc*11+10); Delay(1); End;Nosound;
End;

Procedure InitFood;
Var
  Count : Byte;
Begin
  If EatCount<MinEat Then For Count:=EatCount To MinEat Do NewFood;
{  Count:=BigFChance-(MaxEat Div (EatCount+1))*(BigFChance Div ;}
  If (Random(BigFChance)>MaxFChance-Count) And (EatCount<MaxEat) Then NewFood;
End;

Function Eat : Boolean;
Begin
  Eat:=Screen[Tola[TLong].X,Tola[TLong].Y]=FoodChar;
End;

Procedure Exchange;
Var
  Count : Byte;
Begin
  For Count:=TLong DownTo 2 Do
  Begin
    Tola[Count].X:=Tola[Count-1].X;
    Tola[Count].Y:=Tola[Count-1].Y;
  End;
End;

Procedure WriteScore;
Begin
  GotoXY(ScoreX+16,ScoreY);
  WriteLn(Score);
End;

Procedure WriteLvlScore;
Begin
  GotoXY(50,49);
  WriteLn('Level Score   : ');
  GotoXY(66,49);
  WriteLn(LvlScore);
End;

Procedure ExecuteEat;
Var
  Count : Byte;
Begin
  For Count:=1 To 100 Do Begin Sound(Count*9+256); Delay(1); End; NoSound;
  EatCount:=EatCount-1;
  Screen[Tola[TLong].X,Tola[TLong].Y]:=0;
  Score:=Score+TLong;
  LvlScore:=LvlScore+Tlong;
  For Count:=1 To FoodInc Do
    If TLong<TMaxLn Then Begin
      Inc(TLong);
      Exchange;
    End;
  WriteScore;
  WriteLvlScore;
  TSpeed:=Tspeed-1;
End;

Procedure InitScreen;
Var
  Xc,Yc : Byte;
Begin
  TextMode(c80+Font8x8);
  TextBackGround(Reka);
  ClrScr;
  For Xc:=1 To ScrX Do Begin
    Screen [Xc,1]:=10;
    PutChar(Xc,1 ,Border,BorderColor);
    Screen [Xc,ScrY]:=10;
    PutChar(Xc,ScrY,Border,BorderColor);
  End;
  For Yc:=1 To ScrY Do Begin
    Screen [1 ,Yc]:=10;
    PutChar(1 ,Yc,Border,BorderColor);
    Screen [ScrX,Yc]:=10;
    PutChar(ScrX,Yc,Border,BorderColor);
  End;
  For Xc:=2 To ScrX-1 Do
    For Yc:=2 To ScrY-1 Do
      If Screen[Xc,Yc]=10 Then PutChar(Xc,Yc,WallChar,WalCol);
  GotoXY(3,48);
  TextColor(15);
  WriteLn('Current Score : ');
  GotoXy(Lx,Ly);
  WriteLn('Current Lives : ');
  GotoXy(50,48);
  WriteLn('Current Level : ');
End;

Procedure DelLast;
Begin
  Screen [Tola[1].X,Tola[1].Y]:=0;
  PutChar(Tola[1].X,Tola[1].Y,$DB,Reka);
End;


Procedure PutNew;
Begin
  Screen [Tola[TLong].X,Tola[TLong].Y]:=5;
  PutChar(Tola[TLong].X,Tola[TLong].Y,Thead,THeadCol);
  PutChar(Tola[TLong-1].X,Tola[TLong-1].Y,Tchar,TCol);
End;


Function Pasul:Boolean;
Begin
  Pasul:=Screen[Tola[TLong].x,Tola[TLong].Y] In BadChars;
End;

Procedure SetVal;
Var
  Count,Tempx,TempY:Byte;
Begin
  Tspeed:=60;
  Tc:=1;
  Tlong:=Long+1;
  Inc(Tlong);
  Repeat
    TempX:=Random(ScrX);
    TempY:=Random(ScrY);
  Until Not (Screen[TempX,TempY] In BadChars);
  PutChar(TempX,TempY,THead,THeadCol);
  For Count:=1 To TLong Do Begin
    Tola[Count].X:=TempX;
    Tola[Count].Y:=TempY;
  End;
  For Count:=1 To FoodColMax Do
    Repeat
      FoodCol[Count]:=16*Reka+Random(15);
    Until FoodCol[Count]<>Reka*16+Reka;
End;

Procedure WriteLives;
Begin
  GotoXy(Lx+16,Ly);
  WriteLn(Lives);
End;

Procedure ExecutePasul;
Var
  Count : Word;
Begin
  For Count:=1       To 100 Do Begin Sound(Count*9+256); Delay(1); End;
  For Count:=100 DownTo 1   Do Begin Sound(Count*9+256); Delay(1); End;
  NoSound;
  If Lives>0 Then Dec(Lives);
  For Count:=1 To Tlong-1 Do
    PutChar(Tola[Count].X,Tola[Count].Y,WallChar,WalCol);
  WriteLives;
  SetVal;
  K:=ReadKey;
  If K=#0 Then K:=ReadKey;
End;

Function Finish : Boolean;
Begin
  Finish:=Lives=0;
End;

Procedure HandleKeys;
Var
  Count : Byte;
Begin
  For Count:=1 to TLong-1 do
  Begin
    Tola[Count].X:=Tola[Count+1].X;
    Tola[Count].Y:=Tola[Count+1].Y;
  End;
  Case K of
    #80 : Inc(Tola[TLong].Y);
    #72 : Dec(Tola[TLong].Y);
    #77 : Inc(Tola[TLong].X);
    #75 : Dec(Tola[TLong].X);
  End;
End;

Procedure WriteCurrLvl;
Begin
  GotoXY(50+16,48);
  WriteLn(CurrLvl);
End;

Procedure Init;
Begin
  LoadLevel;
  Randomize;
  InitScreen;
  SetVal;
  InitFood;
  EatCount:=0;
  TLong:=Long+1;

  WriteCurrLvl;
  WriteLives;
  WriteScore;
  WriteLvlScore;
End;

Procedure GetKey;
Var
  Temp : Char;
Begin
  Temp := ReadKey;
  If Temp<>#27 Then Begin
    If Temp=#0 Then Temp:=ReadKey;
    Case Temp Of
      #80 : If K<>#72 Then K:=Temp;
      #72 : If K<>#80 Then K:=Temp;
      #77 : If K<>#75 Then K:=Temp;
      #75 : If K<>#77 Then K:=Temp;
      '1' : TSpeed:=TSpeed-1;
      '2' : Tspeed:=TSpeed+1;
    End;
  End Else K:=Temp;
End;

Procedure ExitMsg;
VAr
 N: Byte;
Begin
  TextColor(7);
  TextMode(c80);
  GotoXy(1,3);
  N:=Random(9)*2+1;
  WriteLn(EndMsg[N]);
  GotoXy(10,5);
  WriteLn(' -  ',EndMsg[N+1]);
  WriteLn;
  WriteLn;
End;

Function LvlDone : Boolean;
Begin
  LvlDone:=(Score>PNL[CurrLvl]);
End;

Procedure ExecuteLvlDone;
Begin
  If CurrLvl<MaxLvl Then Inc(CurrLvl);
  LvlScore:=0;
  ClrScr;
  GotoXY(20,25);
  WriteLn('WELL DONE - YOU FINISHED THE LEVEL');
  GotoXY(30,28);
  WriteLn('NOW ENTERING LEVEL NUMBER ',CurrLvl);
  GotoXY(32,40);
  WriteLn('press any key to continue');
  If ReadKey=#0 Then ReadKey;
  Init;
  K:=ReadKey;
  If K=#0 Then K:=ReadKey;
End;

Begin
  Init;
  Repeat
    If Tc=1 Then GetKey;
    Repeat
      If Tc=TSpeed Then Begin
        PutNew;
        DelLast;
        HandleKeys;
        Tc:=0;
        InitFood;
        If Eat     Then ExecuteEat;
        If Pasul   Then ExecutePasul;
        If LvlDone Then ExecuteLvlDone;
      End;
      Delay(1);
      Inc(Tc);
    Until KeyPressed Or Pasul Or (K=#27) Or (Finish);
  Until (K=#27) Or Finish;
  ExitMsg;
End.