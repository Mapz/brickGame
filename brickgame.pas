unit brickgame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  BoardMoveStatus = (up,down,stop);
  GameStatus = (init,inGame,pause,dead);
  TForm1 = class(TForm)
    gamePanel: TPanel;
    board: TButton;
    frameControl: TTimer;
    ball: TButton;
    statusText: TLabel;
    procedure gamePanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure moveBoard;
    procedure moveBall;
    procedure initGame;
    procedure gameDead;
    procedure frameControlTimer(Sender: TObject);
    procedure gamePanelEnter(Sender: TObject);
    procedure gamePanelExit(Sender: TObject);
    procedure statusTextClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  bms:BoardMoveStatus = BoardMoveStatus.stop;
  gs:GameStatus = GameStatus.init;
  canControl:boolean = false;
  boardSpeed:integer = 4;
  ballSpeedx:integer = 5;
  ballSpeedy:integer = 1;

implementation

{$R *.dfm}

procedure TForm1.gameDead;
begin
  ;
end;

procedure TForm1.initGame;
begin
    statusText.Caption := '初始化';
    ball.Top := 50;
    ball.Left := 50;
    boardSpeed:= 4;
    ballSpeedx:= 5;
    ballSpeedy:= 1;
    board.top := gamepanel.Height div 2 - board.Height div 2;
    gs := Gamestatus.inGame;
    statusText.Caption := '游戏中';
end;

procedure TForm1.moveBoard;
begin
  if not cancontrol then
    exit;
  case bms of
  BoardMoveStatus.up:
    if board.Top > 0 then
      board.Top := board.Top - boardSpeed;
  BoardMoveStatus.down:
     if board.Top + board.Height < gamepanel.Height then
      board.Top := board.Top + boardSpeed;
  BoardMoveStatus.stop:
      ;
  end;
end;

procedure TForm1.statusTextClick(Sender: TObject);
begin
    if gs = Gamestatus.dead then
      gs := init;
end;

procedure TForm1.moveBall;
var
  tempTop,tempLeft:integer;
begin
  temptop := ball.Top + ballspeedy;
  templeft := ball.Left + ballspeedx;
  if templeft < board.left + board.width then
      if board.Top < temptop + ball.Height then
            if board.Top  > temptop - board.Height then
            begin
              templeft := board.left + board.width;
              ballspeedx := -ballspeedx;
            end;
  if temptop < 0  then
    begin
        temptop := 0;
        ballspeedy := - ballspeedy;
    end;
  if temptop + ball.Height > gamepanel.Height then
    begin
        temptop := gamepanel.Height - ball.Height;
        ballspeedy := - ballspeedy;
    end;
  if templeft + ball.width < 0  then
    begin
        statusText.Caption := '死了，点击我重来';
        gs:=Gamestatus.dead;
    end;
  if templeft + ball.width > gamepanel.width then
    begin
        templeft := gamepanel.width - ball.width;
        ballspeedx := - ballspeedx;
    end;
   ball.Top := temptop;
   ball.Left := templeft;
end;

procedure TForm1.frameControlTimer(Sender: TObject);
begin
  case gs of
    GameStatus.init:
      initGame;
    GameStatus.inGame:
      begin
        moveBoard;
        moveBall;
      end;
    GameStatus.dead:
      gameDead;
    GameStatus.pause:
      ;
  end;

end;

procedure TForm1.gamePanelEnter(Sender: TObject);
begin
  canControl :=true;
end;

procedure TForm1.gamePanelExit(Sender: TObject);
begin
  canControl :=false;
end;

procedure TForm1.gamePanelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

    if Y>board.Top + board.Height then
         bms := BoardMoveStatus.down
    else if Y < board.Top then
         bms := BoardMoveStatus.up
    else bms := BoardMoveStatus.stop


end;

end.
