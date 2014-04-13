unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls;

type
  { TForm1 }
  TForm1 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    ButtonHelp: TButton;
    ButtonDef: TButton;
    ButtonOpen: TButton;
    ButtonSave: TButton;
    ButtonFWPath: TButton;
    ButtonExit: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure ButtonDefClick(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonFWPathClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure ButtonOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1:TForm1;

implementation

{$R *.lfm}

{ TForm1 }

type
  key_rcrd = record
   x1, y1, x2, y2, cd   :byte;
   n1, n2               :string;
  end;

const
  pckeys: array[0..124] of key_rcrd = (
    (x1: 3;y1: 9;x2: 7;y2:13;cd:$ff; n1:'Esc';   n2:''),
    (x1:11;y1: 9;x2:15;y2:13;cd:$05; n1:'F1';    n2:''),
    (x1:15;y1: 9;x2:19;y2:13;cd:$06; n1:'F2';    n2:''),
    (x1:19;y1: 9;x2:23;y2:13;cd:$04; n1:'F3';    n2:''),
    (x1:23;y1: 9;x2:27;y2:13;cd:$0c; n1:'F4';    n2:''),
    (x1:29;y1: 9;x2:33;y2:13;cd:$03; n1:'F5';    n2:''),
    (x1:33;y1: 9;x2:37;y2:13;cd:$0b; n1:'F6';    n2:''),
    (x1:37;y1: 9;x2:41;y2:13;cd:$7f; n1:'F7';    n2:''),
    (x1:41;y1: 9;x2:45;y2:13;cd:$0a; n1:'F8';    n2:''),
    (x1:47;y1: 9;x2:51;y2:13;cd:$01; n1:'F9';    n2:''),
    (x1:51;y1: 9;x2:55;y2:13;cd:$09; n1:'F10';   n2:''),
    (x1:55;y1: 9;x2:59;y2:13;cd:$78; n1:'F11';   n2:''),
    (x1:59;y1: 9;x2:63;y2:13;cd:$ff; n1:'F12';   n2:''),
    (x1:65;y1: 9;x2:69;y2:13;cd:$ff; n1:'PrtScr';n2:'SysRq'),
    (x1:69;y1: 9;x2:73;y2:13;cd:$ff; n1:'Scroll';n2:'Lock'),
    (x1:73;y1: 9;x2:77;y2:13;cd:$ff; n1:'Pause'; n2:'Break'),

    (x1: 3;y1:15;x2: 7;y2:19;cd:$0e; n1:'~';     n2:'`'),
    (x1: 7;y1:15;x2:11;y2:19;cd:$16; n1:'!';     n2:'1'),
    (x1:11;y1:15;x2:15;y2:19;cd:$1e; n1:'@';     n2:'2'),
    (x1:15;y1:15;x2:19;y2:19;cd:$26; n1:'#';     n2:'3'),
    (x1:19;y1:15;x2:23;y2:19;cd:$25; n1:'$';     n2:'4'),
    (x1:23;y1:15;x2:27;y2:19;cd:$2e; n1:'%';     n2:'5'),
    (x1:27;y1:15;x2:31;y2:19;cd:$36; n1:'^';     n2:'6'),
    (x1:31;y1:15;x2:35;y2:19;cd:$3d; n1:'&';     n2:'7'),
    (x1:35;y1:15;x2:39;y2:19;cd:$3e; n1:'*';     n2:'8'),
    (x1:39;y1:15;x2:43;y2:19;cd:$46; n1:'(';     n2:'9'),
    (x1:43;y1:15;x2:47;y2:19;cd:$45; n1:')';     n2:'0'),
    (x1:47;y1:15;x2:51;y2:19;cd:$4e; n1:'_';     n2:'-'),
    (x1:51;y1:15;x2:55;y2:19;cd:$55; n1:'+';     n2:'='),
    (x1:55;y1:15;x2:59;y2:19;cd:$5d; n1:'|';     n2:'\'),
    (x1:59;y1:15;x2:63;y2:19;cd:$66; n1:'BkSp';  n2:''),
    (x1:65;y1:15;x2:69;y2:19;cd:$f0; n1:'Insert';n2:''),
    (x1:69;y1:15;x2:73;y2:19;cd:$ec; n1:'Home';  n2:''),
    (x1:73;y1:15;x2:77;y2:19;cd:$fd; n1:'Page';  n2:'Up'),
    (x1:79;y1:15;x2:83;y2:19;cd:$ff; n1:'Num';   n2:'Lock'),
    (x1:83;y1:15;x2:87;y2:19;cd:$ca; n1:'/';     n2:''),
    (x1:87;y1:15;x2:91;y2:19;cd:$7c; n1:'*';     n2:''),
    (x1:91;y1:15;x2:95;y2:19;cd:$7b; n1:'-';     n2:''),

    (x1: 3;y1:19;x2: 9;y2:23;cd:$0d; n1:'Tab';   n2:''),
    (x1: 9;y1:19;x2:13;y2:23;cd:$15; n1:'Q';     n2:''),
    (x1:13;y1:19;x2:17;y2:23;cd:$1d; n1:'W';     n2:''),
    (x1:17;y1:19;x2:21;y2:23;cd:$24; n1:'E';     n2:''),
    (x1:21;y1:19;x2:25;y2:23;cd:$2d; n1:'R';     n2:''),
    (x1:25;y1:19;x2:29;y2:23;cd:$2c; n1:'T';     n2:''),
    (x1:29;y1:19;x2:33;y2:23;cd:$35; n1:'Y';     n2:''),
    (x1:33;y1:19;x2:37;y2:23;cd:$3c; n1:'U';     n2:''),
    (x1:37;y1:19;x2:41;y2:23;cd:$43; n1:'I';     n2:''),
    (x1:41;y1:19;x2:45;y2:23;cd:$44; n1:'O';     n2:''),
    (x1:45;y1:19;x2:49;y2:23;cd:$4d; n1:'P';     n2:''),
    (x1:49;y1:19;x2:53;y2:23;cd:$54; n1:'[';     n2:'{'),
    (x1:53;y1:19;x2:57;y2:23;cd:$5b; n1:']';     n2:'}'),
    (x1:65;y1:19;x2:69;y2:23;cd:$f1; n1:'Delete';n2:''),
    (x1:69;y1:19;x2:73;y2:23;cd:$e9; n1:'End';   n2:''),
    (x1:73;y1:19;x2:77;y2:23;cd:$fa; n1:'Page';  n2:'Down'),
    (x1:79;y1:19;x2:83;y2:23;cd:$6c; n1:'7';     n2:'Home'),
    (x1:83;y1:19;x2:87;y2:23;cd:$75; n1:'8';     n2:'Up'),
    (x1:87;y1:19;x2:91;y2:23;cd:$7d; n1:'9';     n2:'PgUp'),

    (x1: 3;y1:23;x2:10;y2:27;cd:$58; n1:'Caps';  n2:'Lock'),
    (x1:10;y1:23;x2:14;y2:27;cd:$1c; n1:'A';     n2:''),
    (x1:14;y1:23;x2:18;y2:27;cd:$1b; n1:'S';     n2:''),
    (x1:18;y1:23;x2:22;y2:27;cd:$23; n1:'D';     n2:''),
    (x1:22;y1:23;x2:26;y2:27;cd:$2b; n1:'F';     n2:''),
    (x1:26;y1:23;x2:30;y2:27;cd:$34; n1:'G';     n2:''),
    (x1:30;y1:23;x2:34;y2:27;cd:$33; n1:'H';     n2:''),
    (x1:34;y1:23;x2:38;y2:27;cd:$3b; n1:'J';     n2:''),
    (x1:38;y1:23;x2:42;y2:27;cd:$42; n1:'K';     n2:''),
    (x1:42;y1:23;x2:46;y2:27;cd:$4b; n1:'L';     n2:''),
    (x1:46;y1:23;x2:50;y2:27;cd:$4c; n1:':';     n2:';'),
    (x1:50;y1:23;x2:54;y2:27;cd:$52; n1:#$22;    n2:#$27),
    (x1:54;y1:19;x2:63;y2:27;cd:$5a; n1:'';      n2:'Enter'),
    (x1:79;y1:23;x2:83;y2:27;cd:$6b; n1:'4';     n2:'Left'),
    (x1:83;y1:23;x2:87;y2:27;cd:$73; n1:'5';     n2:''),
    (x1:87;y1:23;x2:91;y2:27;cd:$74; n1:'6';     n2:'Right'),
    (x1:91;y1:19;x2:95;y2:27;cd:$79; n1:'+';     n2:''),

    (x1: 3;y1:27;x2:12;y2:31;cd:$12; n1:'Shift'; n2:''),
    (x1:12;y1:27;x2:16;y2:31;cd:$1a; n1:'Z';     n2:''),
    (x1:16;y1:27;x2:20;y2:31;cd:$22; n1:'X';     n2:''),
    (x1:20;y1:27;x2:24;y2:31;cd:$21; n1:'C';     n2:''),
    (x1:24;y1:27;x2:28;y2:31;cd:$2a; n1:'V';     n2:''),
    (x1:28;y1:27;x2:32;y2:31;cd:$32; n1:'B';     n2:''),
    (x1:32;y1:27;x2:36;y2:31;cd:$31; n1:'N';     n2:''),
    (x1:36;y1:27;x2:40;y2:31;cd:$3a; n1:'M';     n2:''),
    (x1:40;y1:27;x2:44;y2:31;cd:$41; n1:'<';     n2:','),
    (x1:44;y1:27;x2:48;y2:31;cd:$49; n1:'>';     n2:'.'),
    (x1:48;y1:27;x2:52;y2:31;cd:$4a; n1:'?';     n2:'/'),
    (x1:52;y1:27;x2:63;y2:31;cd:$59; n1:'Shift'; n2:''),
    (x1:69;y1:27;x2:73;y2:31;cd:$f5; n1:'Up';    n2:''),
    (x1:79;y1:27;x2:83;y2:31;cd:$69; n1:'1';     n2:'End'),
    (x1:83;y1:27;x2:87;y2:31;cd:$72; n1:'2';     n2:'Down'),
    (x1:87;y1:27;x2:91;y2:31;cd:$7a; n1:'3';     n2:'PgDn'),

    (x1: 3;y1:31;x2: 9;y2:35;cd:$14; n1:'Ctrl';  n2:''),
    (x1: 9;y1:31;x2:14;y2:35;cd:$9f; n1:'Win';   n2:''),
    (x1:14;y1:31;x2:19;y2:35;cd:$11; n1:'Alt';   n2:''),
    (x1:19;y1:31;x2:42;y2:35;cd:$29; n1:'Space'; n2:''),
    (x1:42;y1:31;x2:47;y2:35;cd:$91; n1:'Alt Gr';n2:''),
    (x1:47;y1:31;x2:52;y2:35;cd:$a7; n1:'Win';   n2:''),
    (x1:52;y1:31;x2:57;y2:35;cd:$af; n1:'Context'; n2:'Menu'),
    (x1:57;y1:31;x2:63;y2:35;cd:$94; n1:'Ctrl';  n2:''),
    (x1:65;y1:31;x2:69;y2:35;cd:$eb; n1:'Left';  n2:''),
    (x1:69;y1:31;x2:73;y2:35;cd:$f2; n1:'Down';  n2:''),
    (x1:73;y1:31;x2:77;y2:35;cd:$f4; n1:'Right'; n2:''),
    (x1:79;y1:31;x2:87;y2:35;cd:$70; n1:'0';     n2:'Ins'),
    (x1:87;y1:31;x2:91;y2:35;cd:$71; n1:'.';     n2:'Del'),
    (x1:91;y1:27;x2:95;y2:35;cd:$da; n1:'Enter'; n2:''),

    (x1: 5;y1: 3;x2: 9;y2: 7;cd:$c0; n1:'My';    n2:'Comp'),
    (x1: 9;y1: 3;x2:13;y2: 7;cd:$ab; n1:'Calc';  n2:''),
    (x1:13;y1: 3;x2:17;y2: 7;cd:$d0; n1:'Media'; n2:''),
    (x1:17;y1: 3;x2:21;y2: 7;cd:$95; n1:'Prev';  n2:'Track'),
    (x1:21;y1: 3;x2:25;y2: 7;cd:$b4; n1:'Play';  n2:'Pause'),
    (x1:25;y1: 3;x2:29;y2: 7;cd:$bb; n1:'Stop';  n2:''),
    (x1:29;y1: 3;x2:33;y2: 7;cd:$cd; n1:'Next';  n2:'Track'),
    (x1:33;y1: 3;x2:37;y2: 7;cd:$b2; n1:'Vol';   n2:'Up'),
    (x1:37;y1: 3;x2:41;y2: 7;cd:$a1; n1:'Vol';   n2:'Down'),
    (x1:41;y1: 3;x2:45;y2: 7;cd:$a3; n1:'Mute';  n2:''),
    (x1:45;y1: 3;x2:49;y2: 7;cd:$c8; n1:'E-Mail';n2:''),
    (x1:49;y1: 3;x2:53;y2: 7;cd:$b8; n1:'WWW';   n2:'Back'),
    (x1:53;y1: 3;x2:57;y2: 7;cd:$b0; n1:'WWW';   n2:'Frwrd'),
    (x1:57;y1: 3;x2:61;y2: 7;cd:$a0; n1:'WWW';   n2:'Rfrsh'),
    (x1:61;y1: 3;x2:65;y2: 7;cd:$a8; n1:'WWW';   n2:'Stop'),
    (x1:65;y1: 3;x2:69;y2: 7;cd:$ba; n1:'WWW';   n2:'Home'),
    (x1:69;y1: 3;x2:73;y2: 7;cd:$90; n1:'WWW';   n2:'Search'),
    (x1:73;y1: 3;x2:77;y2: 7;cd:$98; n1:'WWW';   n2:'Favor'),
    (x1:81;y1: 3;x2:85;y2: 7;cd:$b7; n1:'Power'; n2:''),
    (x1:85;y1: 3;x2:89;y2: 7;cd:$bf; n1:'Sleep'; n2:''),
    (x1:89;y1: 3;x2:93;y2: 7;cd:$de; n1:'Wake';  n2:'')
  );

  zxkeys: array[0..41] of key_rcrd = (
    (x1:27;y1:39;x2:31;y2:43;cd: 4; n1:'1'; n2:''),
    (x1:31;y1:39;x2:35;y2:43;cd:12; n1:'2'; n2:''),
    (x1:35;y1:39;x2:39;y2:43;cd:20; n1:'3'; n2:''),
    (x1:39;y1:39;x2:43;y2:43;cd:28; n1:'4'; n2:''),
    (x1:43;y1:39;x2:47;y2:43;cd:36; n1:'5'; n2:''),
    (x1:47;y1:39;x2:51;y2:43;cd:35; n1:'6'; n2:''),
    (x1:51;y1:39;x2:55;y2:43;cd:27; n1:'7'; n2:''),
    (x1:55;y1:39;x2:59;y2:43;cd:19; n1:'8'; n2:''),
    (x1:59;y1:39;x2:63;y2:43;cd:11; n1:'9'; n2:''),
    (x1:63;y1:39;x2:67;y2:43;cd: 3; n1:'0'; n2:''),

    (x1:29;y1:43;x2:33;y2:47;cd: 5; n1:'Q'; n2:''),
    (x1:33;y1:43;x2:37;y2:47;cd:13; n1:'W'; n2:''),
    (x1:37;y1:43;x2:41;y2:47;cd:21; n1:'E'; n2:''),
    (x1:41;y1:43;x2:45;y2:47;cd:29; n1:'R'; n2:''),
    (x1:45;y1:43;x2:49;y2:47;cd:37; n1:'T'; n2:''),
    (x1:49;y1:43;x2:53;y2:47;cd:34; n1:'Y'; n2:''),
    (x1:53;y1:43;x2:57;y2:47;cd:26; n1:'U'; n2:''),
    (x1:57;y1:43;x2:61;y2:47;cd:18; n1:'I'; n2:''),
    (x1:61;y1:43;x2:65;y2:47;cd:10; n1:'O'; n2:''),
    (x1:65;y1:43;x2:69;y2:47;cd: 2; n1:'P'; n2:''),

    (x1:30;y1:47;x2:34;y2:51;cd: 6; n1:'A'; n2:''),
    (x1:34;y1:47;x2:38;y2:51;cd:14; n1:'S'; n2:''),
    (x1:38;y1:47;x2:42;y2:51;cd:22; n1:'D'; n2:''),
    (x1:42;y1:47;x2:46;y2:51;cd:30; n1:'F'; n2:''),
    (x1:46;y1:47;x2:50;y2:51;cd:38; n1:'G'; n2:''),
    (x1:50;y1:47;x2:54;y2:51;cd:33; n1:'H'; n2:''),
    (x1:54;y1:47;x2:58;y2:51;cd:25; n1:'J'; n2:''),
    (x1:58;y1:47;x2:62;y2:51;cd:17; n1:'K'; n2:''),
    (x1:62;y1:47;x2:66;y2:51;cd: 9; n1:'L'; n2:''),
    (x1:66;y1:47;x2:70;y2:51;cd: 1; n1:'Enter'; n2:''),

    (x1:27;y1:51;x2:32;y2:55;cd: 7; n1:'Caps'; n2:'Shift'),
    (x1:32;y1:51;x2:36;y2:55;cd:15; n1:'Z'; n2:''),
    (x1:36;y1:51;x2:40;y2:55;cd:23; n1:'X'; n2:''),
    (x1:40;y1:51;x2:44;y2:55;cd:31; n1:'C'; n2:''),
    (x1:44;y1:51;x2:48;y2:55;cd:39; n1:'V'; n2:''),
    (x1:48;y1:51;x2:52;y2:55;cd:32; n1:'B'; n2:''),
    (x1:52;y1:51;x2:56;y2:55;cd:24; n1:'N'; n2:''),
    (x1:56;y1:51;x2:60;y2:55;cd:16; n1:'M'; n2:''),
    (x1:60;y1:51;x2:64;y2:55;cd: 8; n1:'Symb'; n2:'Shift'),
    (x1:64;y1:51;x2:70;y2:55;cd: 0; n1:'Space'; n2:''),

    (x1:17;y1:39;x2:23;y2:43;cd:127;n1:'Not'; n2:'mapped'),
    (x1:74;y1:39;x2:80;y2:43;cd:127;n1:'Not'; n2:'mapped')
  );

  defkbmap:array [0..511] of byte=(
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$07,$00,$07,$04,$7F,$7F,
    $7F,$7F,$7F,$7F,$07,$7F,$7F,$7F,$7F,$7F,$05,$7F,$04,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$0F,$7F,$0E,$7F,$06,$7F,$0D,$7F,$0C,$7F,$7F,$7F,
    $7F,$7F,$1F,$7F,$17,$7F,$16,$7F,$15,$7F,$1C,$7F,$14,$7F,$7F,$7F,
    $7F,$7F,$00,$7F,$27,$7F,$1E,$7F,$25,$7F,$1D,$7F,$24,$7F,$7F,$7F,
    $7F,$7F,$18,$7F,$20,$7F,$21,$7F,$26,$7F,$22,$7F,$23,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$10,$7F,$19,$7F,$1A,$7F,$1B,$7F,$13,$7F,$7F,$7F,
    $7F,$7F,$08,$18,$11,$7F,$12,$7F,$0A,$7F,$03,$7F,$0B,$7F,$7F,$7F,
    $7F,$7F,$08,$10,$08,$1F,$09,$7F,$08,$0F,$02,$7F,$08,$19,$7F,$7F,
    $7F,$7F,$7F,$7F,$08,$02,$7F,$7F,$08,$13,$08,$11,$7F,$7F,$7F,$7F,
    $07,$0C,$08,$7F,$01,$7F,$08,$0B,$7F,$7F,$08,$07,$7F,$7F,$7F,$7F,
    $7F,$7F,$08,$07,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$07,$03,$7F,$7F,
    $7F,$7F,$04,$7F,$7F,$7F,$1C,$7F,$1B,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $03,$7F,$08,$10,$0C,$7F,$24,$7F,$23,$7F,$13,$7F,$7A,$7F,$7F,$7F,
    $7F,$7F,$08,$11,$14,$7F,$08,$19,$08,$20,$0B,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$08,$27,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$01,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,
    $7F,$7F,$08,$15,$7F,$7F,$07,$24,$08,$05,$7F,$7F,$7F,$7F,$7F,$7F,
    $08,$0D,$07,$0B,$07,$23,$7F,$7F,$07,$13,$07,$1B,$7A,$7F,$7F,$7F,
    $7F,$7F,$7F,$7F,$07,$1C,$7F,$7F,$7F,$7F,$07,$14,$7F,$7F,$7F,$7F
   );

var
  hidbmp                :TBitmap;
  scale, x0, y0         :integer;
  kbmap                 :array [0..511] of byte;
  pckey_selected        :byte;
  was_mousedown         :boolean;

function CRC16_XModem( pb:PByte; count:integer ):word;
const
  tbl16:array [0..255] of word=(
    $0000,$1021,$2042,$3063,$4084,$50a5,$60c6,$70e7,
    $8108,$9129,$a14a,$b16b,$c18c,$d1ad,$e1ce,$f1ef,
    $1231,$0210,$3273,$2252,$52b5,$4294,$72f7,$62d6,
    $9339,$8318,$b37b,$a35a,$d3bd,$c39c,$f3ff,$e3de,
    $2462,$3443,$0420,$1401,$64e6,$74c7,$44a4,$5485,
    $a56a,$b54b,$8528,$9509,$e5ee,$f5cf,$c5ac,$d58d,
    $3653,$2672,$1611,$0630,$76d7,$66f6,$5695,$46b4,
    $b75b,$a77a,$9719,$8738,$f7df,$e7fe,$d79d,$c7bc,
    $48c4,$58e5,$6886,$78a7,$0840,$1861,$2802,$3823,
    $c9cc,$d9ed,$e98e,$f9af,$8948,$9969,$a90a,$b92b,
    $5af5,$4ad4,$7ab7,$6a96,$1a71,$0a50,$3a33,$2a12,
    $dbfd,$cbdc,$fbbf,$eb9e,$9b79,$8b58,$bb3b,$ab1a,
    $6ca6,$7c87,$4ce4,$5cc5,$2c22,$3c03,$0c60,$1c41,
    $edae,$fd8f,$cdec,$ddcd,$ad2a,$bd0b,$8d68,$9d49,
    $7e97,$6eb6,$5ed5,$4ef4,$3e13,$2e32,$1e51,$0e70,
    $ff9f,$efbe,$dfdd,$cffc,$bf1b,$af3a,$9f59,$8f78,
    $9188,$81a9,$b1ca,$a1eb,$d10c,$c12d,$f14e,$e16f,
    $1080,$00a1,$30c2,$20e3,$5004,$4025,$7046,$6067,
    $83b9,$9398,$a3fb,$b3da,$c33d,$d31c,$e37f,$f35e,
    $02b1,$1290,$22f3,$32d2,$4235,$5214,$6277,$7256,
    $b5ea,$a5cb,$95a8,$8589,$f56e,$e54f,$d52c,$c50d,
    $34e2,$24c3,$14a0,$0481,$7466,$6447,$5424,$4405,
    $a7db,$b7fa,$8799,$97b8,$e75f,$f77e,$c71d,$d73c,
    $26d3,$36f2,$0691,$16b0,$6657,$7676,$4615,$5634,
    $d94c,$c96d,$f90e,$e92f,$99c8,$89e9,$b98a,$a9ab,
    $5844,$4865,$7806,$6827,$18c0,$08e1,$3882,$28a3,
    $cb7d,$db5c,$eb3f,$fb1e,$8bf9,$9bd8,$abbb,$bb9a,
    $4a75,$5a54,$6a37,$7a16,$0af1,$1ad0,$2ab3,$3a92,
    $fd2e,$ed0f,$dd6c,$cd4d,$bdaa,$ad8b,$9de8,$8dc9,
    $7c26,$6c07,$5c64,$4c45,$3ca2,$2c83,$1ce0,$0cc1,
    $ef1f,$ff3e,$cf5d,$df7c,$af9b,$bfba,$8fd9,$9ff8,
    $6e17,$7e36,$4e55,$5e74,$2e93,$3eb2,$0ed1,$1ef0
  );
var
  i     :integer;
  crc   :word;
begin
  crc:=0;
  for i:=1 to count do
  begin
    crc:=tbl16[hi(crc) xor pb^] xor word(crc shl 8);
    inc(pb);
  end;
  result:=crc;
end;

function fw_version_str( pb:pbyte ):string;
var
  name, beta            :string;
  w                     :word;
  day, mouth, year      :byte;
begin
  name:='';
  for w:=0 to 11 do
  begin
   if pb^<>0 then name:=name+chr(pb^);
   inc(pb);
  end;
  w:=pb^;
  inc(pb);
  w:=w or (pb^ shl 8);
  day:=w and $1f;
  mouth:=(w shr 5) and $0f;
  year:=(w shr 9) and $3f;
  if (w and $8000)<>0 then beta:='' else beta:=' beta';
  result:=Format('%s %.2u.%.2u.20%.2u%s',[name,day,mouth,year,beta]);
end;

procedure recalc_and_rebuild;
var
  i, kb, sx, sy,
  kx1, ky1, kx2, ky2    :integer;
  zk1, zk2              :byte;
begin
  sx:=Form1.Width div 98;
  sy:=Form1.Bevel1.Top div 58;
  if sx<sy then scale:=sx else scale:=sy;
  kb:=scale div 3;

  x0:=(Form1.Width-scale*98) div 2;
  y0:=(Form1.Bevel1.Top-scale*58) div 2;

  Form1.Bevel2.Top:=y0+37*scale;

  hidbmp.Canvas.Brush.Color:=clBtnFace;
  hidbmp.Canvas.FillRect(0,0,Form1.Width,Form1.Height);

  hidbmp.Canvas.Pen.Color:=clBlack;
  hidbmp.Canvas.Brush.Color:=$d0d0d0;
  hidbmp.Canvas.Font.Size:=(scale*7) div 8;

  for i:=124 downto 0 do
  begin
    if pckey_selected=pckeys[i].cd then
      hidbmp.Canvas.Brush.Color:=$80d0ff
    else
      hidbmp.Canvas.Brush.Color:=$d0d0d0;
    if pckeys[i].cd=$ff then
      hidbmp.Canvas.Font.Color:=$808080
    else
      hidbmp.Canvas.Font.Color:=$000000;
    kx1:=x0+pckeys[i].x1*scale;
    ky1:=y0+pckeys[i].y1*scale;
    kx2:=x0+1+pckeys[i].x2*scale;
    ky2:=y0+1+pckeys[i].y2*scale;
    hidbmp.Canvas.Rectangle(kx1,ky1,kx2,ky2);
    inc(kx1,kb);
    inc(ky1,kb);
    dec(kx2,kb);
    dec(ky2,kb);
    if (pckeys[i].n1<>'') then
    begin
      hidbmp.Canvas.TextRect(rect(kx1,ky1,kx2,ky2),
                             kx1,ky1,pckeys[i].n1);
    end;
    if (pckeys[i].n2<>'') then
    begin
      ky1:=((ky1+ky2) div 2)+kb;
      hidbmp.Canvas.TextRect(rect(kx1,ky1,kx2,ky2),
                             kx1,ky1,pckeys[i].n2);
    end;
  end;

  hidbmp.Canvas.Font.Color:=$000000;
  zk1:=kbmap[pckey_selected*2];
  zk2:=kbmap[pckey_selected*2+1];
  for i:=41 downto 0 do
  begin
    if zk1=zxkeys[i].cd then
      hidbmp.Canvas.Brush.Color:=$80d0ff
    else if (zk2<>$7f) and (zk2=zxkeys[i].cd) then
      hidbmp.Canvas.Brush.Color:=$80f0ff
    else
      hidbmp.Canvas.Brush.Color:=$d0d0d0;
    kx1:=x0+zxkeys[i].x1*scale;
    ky1:=y0+zxkeys[i].y1*scale;
    kx2:=x0+1+zxkeys[i].x2*scale;
    ky2:=y0+1+zxkeys[i].y2*scale;
    hidbmp.Canvas.Rectangle(kx1,ky1,kx2,ky2);
    inc(kx1,kb);
    inc(ky1,kb);
    dec(kx2,kb);
    dec(ky2,kb);
    if (zxkeys[i].n1<>'') then
    begin
      hidbmp.Canvas.TextRect(rect(kx1,ky1,kx2,ky2),
                             kx1,ky1,zxkeys[i].n1);
    end;
    if (zxkeys[i].n2<>'') then
    begin
      ky1:=((ky1+ky2) div 2)+kb;
      hidbmp.Canvas.TextRect(rect(kx1,ky1,kx2,ky2),
                             kx1,ky1,zxkeys[i].n2);
    end;
  end;

end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.DoubleBuffered:=true;
  pckey_selected:=$29;
  was_mousedown:=false;
  Move(defkbmap,kbmap,512);
  hidbmp:=TBitmap.Create;
  hidbmp.Width:=1920;
  hidbmp.Height:=1080;
  hidbmp.Canvas.Brush.Style:=bsSolid;
  //hidbmp.Canvas.Font.Name:='Arial';
  recalc_and_rebuild;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  recalc_and_rebuild;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  Form1.Canvas.Draw(0,0,hidbmp);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  was_mousedown:=true;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i, kx, ky  :integer;
begin
  if was_mousedown then
  begin
    kx:=(X-x0) div scale;
    ky:=(Y-y0) div scale;
    if Button=mbLeft then
    begin
      for i:=0 to 125 do
      begin
        if (kx>=pckeys[i].x1) and (ky>=pckeys[i].y1) and
           (kx< pckeys[i].x2) and (ky< pckeys[i].y2) then
        begin
          if pckeys[i].cd<>$ff then
          begin
            if pckey_selected<>pckeys[i].cd then
            begin
              pckey_selected:=pckeys[i].cd;
              recalc_and_rebuild;
              Form1.Repaint;
            end;
            break;
          end;
        end;
      end;
    end;
    if (Button=mbLeft) or (Button=mbRight) then
    begin
      for i:=0 to 41 do
      begin
        if (kx>=zxkeys[i].x1) and (ky>=zxkeys[i].y1) and
           (kx< zxkeys[i].x2) and (ky< zxkeys[i].y2) then
        begin
          if Button=mbRight then
          begin
            if (kbmap[pckey_selected*2]<>$7f) and
               (kbmap[pckey_selected*2]<>zxkeys[i].cd) and
               (kbmap[pckey_selected*2+1]<>zxkeys[i].cd) then
            begin
              kbmap[pckey_selected*2+1]:=zxkeys[i].cd;
              recalc_and_rebuild;
              Form1.Repaint;
            end;
          end
          else if kbmap[pckey_selected*2]<>zxkeys[i].cd then
          begin
            kbmap[pckey_selected*2]:=zxkeys[i].cd;
            kbmap[pckey_selected*2+1]:=$7f;
            recalc_and_rebuild;
            Form1.Repaint;
          end;
        end;
      end;
    end;
  end;
  was_mousedown:=false;
end;

procedure TForm1.ButtonExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.ButtonDefClick(Sender: TObject);
begin
  if MessageDlg('Reset keyboard map to default?',
                mtConfirmation,[mbYes,mbNo],0)=mrYes then
  begin
    Move(defkbmap,kbmap,512);
    recalc_and_rebuild;
    Form1.Repaint;
  end;
end;

procedure TForm1.ButtonSaveClick(Sender: TObject);
var
  f1  :file;
begin
  SaveDialog1.FileName:='';
  if SaveDialog1.Execute then
  begin
    assignfile(f1,SaveDialog1.FileName);
    rewrite(f1,512);
    BlockWrite(f1,kbmap,1);
    CloseFile(f1);
  end;
end;

procedure TForm1.ButtonOpenClick(Sender: TObject);
var
  i64  :int64;
  f1  :file;
begin
  OpenDialog1.FileName:='';
  if OpenDialog1.Execute then
  begin
    if FileSize(OpenDialog1.FileName)=512 then
    begin
      AssignFile(f1,OpenDialog1.FileName);
      Reset(f1,512);
      BlockRead(f1,kbmap,1,i64);
      CloseFile(f1);
      recalc_and_rebuild;
      Form1.Repaint;
    end
    else
      MessageDlg('The file must be exactly 512 bytes long.',mtError,[mbOk],0);
  end;
end;

procedure TForm1.ButtonFWPathClick(Sender: TObject);
const
  singature:array [0..5] of byte=($5a,$58,$45,$56,$4f,$1a);
var
  buff  :array [0..127103] of byte;
  eeprom  :array [0..4095] of byte;
  fsz, i64  :int64;
  i, j, n, adr1, adr2  :integer;
  w  :word;
  b  :byte;
  f1  :file;
begin
  OpenDialog1.FileName:='zxevo_fw.bin';
  if OpenDialog1.Execute then
  begin
    fsz:=FileSize(OpenDialog1.FileName);
    if fsz<768 then
      MessageDlg('Hmm... This a very short file.',mtError,[mbOk],0)
    else if fsz>127104 then
      MessageDlg('Hmm... This a very long file.',mtError,[mbOk],0)
    else
    begin
      AssignFile(f1,OpenDialog1.FileName);
      Reset(f1,1);
      BlockRead(f1,buff,fsz,i64);
      CloseFile(f1);
      if CompareByte(buff,singature,6)<>0 then
        MessageDlg('The file is not ZX-Evo firmware.',mtError,[mbOk],0)
      else if CRC16_XModem(buff,128)<>$0000 then
        MessageDlg('The file is damaged!',mtError,[mbOk],0)
      else
      begin
        FillDWord(eeprom,1024,$ffffffff);
        //
        adr1:=$0080;
        for i:=$40 to $7b do
        begin
          b:=buff[i];
          for j:=1 to 8 do
          begin
            if (b and 1)<>0 then inc(adr1,$0100);
            b:=b shr 1;
          end;
        end;
        //
        i:=0;
        adr2:=adr1;
        w:=buff[$7c] or (buff[$7d] shl 8);
        for j:=1 to 16 do
        begin
          if (w and 1)<>0 then
            for n:=1 to $0100 do
            begin
              eeprom[i]:=buff[adr2];
              inc(i);
              inc(adr2);
            end
          else
            inc(i,$0100);
          w:=w shr 1;
        end;
        Move(kbmap,eeprom,512);
        eeprom[0]:=$4b;
        eeprom[1]:=$42;
        //
        w:=0;
        i:=0;
        adr2:=adr1;
        for j:=1 to 16 do
        begin
          w:=w shr 1;
          b:=$ff;
          for n:=0 to $00ff do  b:=b and eeprom[i+n];
          if b<>$ff then
          begin
            for n:=0 to $00ff do
            begin
              buff[adr2]:=eeprom[i];
              inc(i);
              inc(adr2);
            end;
            w:=w or $8000;
          end
          else
            inc(i,$0100);
        end;
        buff[$7c]:=byte(w and $ff);
        buff[$7d]:=byte((w shr 8) and $ff);
        w:=CRC16_XModem(buff,126);
        buff[$7e]:=byte((w shr 8) and $ff);
        buff[$7f]:=byte(w and $ff);
        //
        RenameFile(OpenDialog1.FileName,OpenDialog1.FileName+'.bak');
        //AssignFile(f1,OpenDialog1.FileName);
        ReWrite(f1,1);
        BlockWrite(f1,buff,adr2);
        CloseFile(f1);
        MessageDlg('ZX-Evo firmware'#13#10+fw_version_str(@buff[adr1-16])+
                   #13#10'patched successfully.',
                   mtInformation,[mbOk],0)
      end;
    end;
  end;
end;

procedure TForm1.ButtonHelpClick(Sender: TObject);
begin
  MessageDlg('Meanwhile no help, no setting.',mtInformation,[mbOk],0)
end;

end.

