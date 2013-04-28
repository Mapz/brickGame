unit brickgame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DB, ADODB,hsframeA;

type
  BoardMoveStatus = (up,down,stop);
  GameStatus = (init,inGame,pause,dead);
  TMainForm = class(TForm)
    gamePanel: TPanel;
    board: TButton;
    frameControl: TTimer;
    ball: TButton;
    statusText: TLabel;
    cnnSqlite: TADOConnection;
    highScoreButton: TButton;
    sQry: TADOQuery;
    scoreLabel: TLabel;
    statusDialogPanel: TPanel;
    statusDialog: TLabel;
    statusDialogYes: TButton;
    statusDialogNo: TButton;
    highScoreForm: hsframeA.ThighScoreForm;
    NameInput: TEdit;
    LabelNameText: TLabel;
    procedure gamePanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure moveBoard;
    procedure moveBall;
    procedure initGame;
    procedure gamedead;
    procedure insertHighScore;
    procedure drawScore;
    procedure switchStatus(curStatus,nextStatus:GameStatus);
    procedure frameControlTimer(Sender: TObject);
    procedure gamePanelEnter(Sender: TObject);
    procedure gamePanelExit(Sender: TObject);
    procedure statusTextClick(Sender: TObject);
    procedure statusDialogYesClick(Sender: TObject);
    procedure statusDialogNoClick(Sender: TObject);
    procedure highScoreButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  bms:BoardMoveStatus = BoardMoveStatus.stop;
  gs:GameStatus = GameStatus.init;
  canControl:boolean = false;
  boardSpeed:integer = 4;
  ballSpeedx:integer = 5;
  ballSpeedy:integer = 1;
  score:integer = 0;
  timerpause:boolean = false;
  subStatus:integer = 0;

implementation

{$R *.dfm}
procedure TMainForm.switchStatus(curStatus,nextStatus:GameStatus);
begin
  subStatus:= 0;
  if curStatus =  GameStatus.inGame then
    if nextstatus = gamestatus.dead then
            begin
            statusText.Caption := '死了，点击我重来';
            statusDialogPanel.Visible := true;
            nameInput.Visible := true;
            statusDialog.Caption := '是否保存你的分数？';
            gs:=Gamestatus.dead;
            end;

   if curStatus =  GameStatus.init then
    if nextstatus = gamestatus.ingame then
            begin
            statusText.Caption := '游戏中';
            gs := Gamestatus.inGame;
            end;
   if curStatus =  GameStatus.dead then
    if nextstatus = gamestatus.init then
            begin
            statusText.Caption := '游戏中';
            statusDialogPanel.Visible := false;
            gs := Gamestatus.init;
            end;
   if curStatus =  GameStatus.ingame then
    if nextstatus = gamestatus.pause then
            begin
            statusText.Caption := '暂停';
            gs := Gamestatus.pause;
            end;
   if curStatus =  GameStatus.pause then
    if nextstatus = gamestatus.ingame then
            begin
            statusText.Caption := '游戏中';
            gs := Gamestatus.ingame;
            end;
end;

procedure TMainForm.insertHighScore;
begin
  if NameInput.Text = '' then NameInput.Text := '匿名';
   try
    if cnnSqlite.Connected=false then cnnSqlite.open;
    if sQry.Active then sQry.Close;
    sQry.sql.clear;
    sQry.sql.text := 'select * from highscore';
    sQry.open;
    sQry.Append;
    sQry.FieldByName('playerName').AsString := NameInput.Text;
    sQry.fieldbyname('score').AsInteger := score;
    sQry.Post;
  finally
    cnnSqlite.Close;
  end;
end;

procedure TMainForm.gamedead;
begin
  ;
end;
procedure TMainForm.initGame;
begin
    statusText.Caption := '初始化';
    ball.Top := 50;
    ball.Left := 50;
    boardSpeed:= 4;
    ballSpeedx:= 5;
    ballSpeedy:= 1;
    score:= 0;
    board.top := gamepanel.Height div 2 - board.Height div 2;
    switchstatus(gs,gamestatus.inGame);
end;

procedure TMainForm.moveBoard;
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

procedure TMainForm.highScoreButtonClick(Sender: TObject);
begin
   if highScoreForm = nil then
    highScoreForm := ThighScoreForm.Create(self);
   highScoreForm.show;
   highScoreForm.qeuryHighScore;
   switchStatus(gs,gamestatus.pause);
end;

procedure TMainForm.drawScore;
begin
  scoreLabel.caption := 'score:' + inttostr(score);
end;

procedure TMainForm.statusDialogNoClick(Sender: TObject);
begin
     if gs <> Gamestatus.dead then exit;
     switchstatus(gs,gamestatus.init);
end;

procedure TMainForm.statusDialogYesClick(Sender: TObject);
begin
  if gs <> Gamestatus.dead then exit;
  if subStatus = 0 then
  begin
    insertHighScore;
    statustext.Caption := '保存成功，再来一局？';
    nameInput.Visible := false;
    subStatus := subStatus + 1;
  end;
   if subStatus = 1 then
  begin
    switchstatus(gs,gamestatus.init);
  end;
end;

procedure TMainForm.statusTextClick(Sender: TObject);
begin
    if gs = Gamestatus.dead then
      gs := init;
end;

procedure TMainForm.moveBall;
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
        switchstatus(gs,gamestatus.dead);
    end;
  if templeft + ball.width > gamepanel.width then
    begin
        templeft := gamepanel.width - ball.width;
        ballspeedx := - ballspeedx;
        score:= score + 1;
    end;
   ball.Top := temptop;
   ball.Left := templeft;
end;



procedure TMainForm.FormCreate(Sender: TObject);
begin
  ;
end;

procedure TMainForm.frameControlTimer(Sender: TObject);
begin
  if timerpause then
         exit;
  case gs of
    GameStatus.init:
      begin
      drawScore;
      initGame;
      end;
    GameStatus.inGame:
      begin
        moveBoard;
        moveBall;
        drawScore;
      end;
    GameStatus.dead:
      begin

        gameDead;
      end;
    GameStatus.pause:
      ;
  end;

end;

procedure TMainForm.gamePanelEnter(Sender: TObject);
begin
  canControl :=true;
end;

procedure TMainForm.gamePanelExit(Sender: TObject);
begin
  canControl :=false;
end;

procedure TMainForm.gamePanelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

    if Y>board.Top + board.Height then
         bms := BoardMoveStatus.down
    else if Y < board.Top then
         bms := BoardMoveStatus.up
    else bms := BoardMoveStatus.stop

end;

end.
