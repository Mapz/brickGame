unit brickgame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DB, ADODB, hsframeA, InputName, winForm,
  WinSkinData;

type
  BrickButton = class(TButton)

  end;

  BoardMoveStatus = (up, down, stop);
  GameStatus = (init, inGame, pause, dead, load, win, allOver, unkonwn);

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
    Stage: TLabel;
    brickleftlabel: TLabel;
    SkinData1: TSkinData;
    procedure gamePanelMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure moveBoard;
    procedure moveBall;
    procedure initGame;
    procedure gamedead;
    procedure checkBrickLeft;
    function loadStage(stageName: string): boolean;
    procedure load(stageName: string);
    function isRecInteracted(rectX, rectY, rectWidth, rectHeight, objX, objY,
      objWidth, objHeight: Integer): boolean;
    procedure drawScore;
    procedure checkContact(var X: Integer; var Y: Integer);
    procedure createBrick(X, Y, w, h: Integer);
    procedure switchStatus(curStatus, nextStatus: GameStatus);
    procedure frameControlTimer(Sender: TObject);
    procedure gamePanelEnter(Sender: TObject);
    procedure gamePanelExit(Sender: TObject);
    procedure statusTextClick(Sender: TObject);
    procedure highScoreButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  bms: BoardMoveStatus = BoardMoveStatus.stop;
  gs: GameStatus = GameStatus.init;
  lastStatus: GameStatus = GameStatus.unkonwn;
  canControl: boolean = false;
  boardSpeed: Integer = 4;
  ballSpeedx: Integer = 5;
  ballSpeedy: Integer = 1;
  score: Integer = 0;
  timerpause: boolean = false;
  subStatus: Integer = 0;
  stageCount: Integer = 1;
  stageName: string;
  brickLeft: Integer;

implementation

{$R *.dfm}

function TMainForm.isRecInteracted(rectX, rectY, rectWidth, rectHeight, objX,
  objY, objWidth, objHeight: Integer): boolean;
begin
  if ((rectX + rectWidth > objX) and (rectX < objX + objWidth) and
      (rectY + rectHeight > objY) and (rectY < objY + objHeight)) then

    result := true
  else
    result := false;
end;

procedure TMainForm.checkBrickLeft;
var
  i: Integer;
begin
  brickLeft := 0;
  for i := ComponentCount - 1 downto 0 do
  begin
    if Components[i] is BrickButton then
      brickLeft := brickLeft + 1;
  end;
  if brickLeft = 0 then
    switchStatus(gs, GameStatus.win);
end;

procedure TMainForm.load(stageName: string);
begin
  if loadStage(stageName) then
    switchStatus(gs, inGame)
  else
    switchStatus(gs, allOver);
end;

function TMainForm.loadStage(stageName: string): boolean;
var
  icount, i: Integer;
begin
  try
    if cnnSqlite.Connected = false then
      cnnSqlite.open;
    if sQry.Active then
      sQry.Close;
    sQry.sql.clear;
    sQry.sql.text := 'select * from stage where stageName =' + stageName;
    sQry.open;
    icount := sQry.RecordCount;
    for i := 0 to icount - 1 do
    begin
      createBrick(sQry.FieldByName('xpos').AsInteger,
        sQry.FieldByName('ypos').AsInteger,
        sQry.FieldByName('width').AsInteger,
        sQry.FieldByName('height').AsInteger);
      sQry.Next;
    end;
  finally
    cnnSqlite.Close;
  end;
  if icount = 0 then
    result := false
  else
    result := true;
end;

procedure TMainForm.checkContact(var X: Integer; var Y: Integer);
var
  i, xOff, yOff, xNow, yNow: Integer;
  af: double;
  br: BrickButton;
begin
  af := (Y - ball.Top) / (X - ball.left);
  if ball.left < X then
  begin
    for xNow := ball.left to X do
    begin
      yNow := Y + round((xNow - X) * af);
      for i := ComponentCount - 1 downto 0 do
      begin
        if Components[i] is BrickButton then
        begin
          br := BrickButton(Components[i]);
          if isRecInteracted(xNow, yNow, ball.Width, ball.Height, br.left,
            br.Top, br.Width, br.Height) then
          begin
            X := xNow;
            Y := yNow;
            if ballSpeedx < 0 then
              xOff := br.left + br.Width - X
            else
              xOff := X - br.left;
            if ballSpeedy < 0 then
              yOff := br.Top + br.Height - Y
            else
              yOff := Y - br.Top;
            if ballSpeedy = 0 then
              ballSpeedx := -ballSpeedx
            else if xOff / abs(ballSpeedx) > yOff / abs(ballSpeedy) then
            begin
              ballSpeedy := -ballSpeedy;
            end
            else
              ballSpeedx := -ballSpeedx;
            br.Free;
            score := score + 1;
            exit;
          end;
        end;
      end;
    end;
  end
  else if ball.left > X then
  begin
    for xNow := ball.left downto X do
    begin
      yNow := Y + round((xNow - X) * af);
      for i := ComponentCount - 1 downto 0 do
      begin
        if Components[i] is BrickButton then
        begin
          br := BrickButton(Components[i]);
          if isRecInteracted(xNow, yNow, ball.Width, ball.Height, br.left,
            br.Top, br.Width, br.Height) then
          begin
            X := xNow;
            Y := yNow;
            if ballSpeedx < 0 then
              xOff := br.left + br.Width - X
            else
              xOff := X - br.left;
            if ballSpeedy < 0 then
              yOff := br.Top + br.Height - Y
            else
              yOff := Y - br.Top;
            if xOff / abs(ballSpeedx) > yOff / abs(ballSpeedy) then
            begin
              ballSpeedy := -ballSpeedy;
            end
            else
              ballSpeedx := -ballSpeedx;
            score := score + 1;
            br.Free;
            exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TMainForm.createBrick(X, Y, w, h: Integer);
var
  brick: BrickButton;
begin
  brick := BrickButton.Create(self);
  brick.Parent := gamePanel;
  brick.left := X;
  brick.Top := Y;
  brick.Width := w;
  brick.Height := h;
end;

procedure TMainForm.switchStatus(curStatus, nextStatus: GameStatus);
begin
  subStatus := 0;
  if curStatus = GameStatus.win then
  begin
    if nextStatus = GameStatus.init then
    begin
      winforma.Close;
      stageCount := stageCount + 1;
      gs := GameStatus.init;
    end;
  end;
  if curStatus = GameStatus.inGame then
  begin
    if nextStatus = GameStatus.dead then
    begin
      statusText.Caption := '游戏结束';
      if inputNameDialog = nil then
        inputNameDialog := TInputNameDialog.Create(self);
      inputNameDialog.show;
      gs := GameStatus.dead;
    end
    else if nextStatus = GameStatus.win then
    begin
      statusText.Caption := '胜利';
      if winforma = nil then
        winforma := TwinFormA.Create(self);
      gs := GameStatus.win;
      winforma.show;
    end;
  end;

  if curStatus = GameStatus.init then
  begin
    if nextStatus = GameStatus.inGame then
    begin
      statusText.Caption := '游戏中';
      gs := GameStatus.inGame;
    end
    else if nextStatus = GameStatus.load then
    begin
      statusText.Caption := '载入中';
      gs := GameStatus.load;
    end;
  end;

  if curStatus = GameStatus.load then
  begin
    if nextStatus = GameStatus.inGame then
    begin
      statusText.Caption := '游戏中';
      gs := GameStatus.inGame;
    end
    else if nextStatus = allOver then
    begin
      statusText.Caption := '你完成了所有关卡！';
      if winforma = nil then
      begin
        winforma := TwinFormA.Create(self);
      end;
      gs := GameStatus.allOver;
      winforma.show;
    end;

  end;

  if curStatus = GameStatus.dead then
    if nextStatus = GameStatus.init then
    begin
      statusText.Caption := '游戏中';
      gs := GameStatus.init;
    end;
  if curStatus = GameStatus.inGame then
    if nextStatus = GameStatus.pause then
    begin
      statusText.Caption := '暂停';
      gs := GameStatus.pause;
    end;
  if curStatus = GameStatus.pause then
    if nextStatus = GameStatus.inGame then
    begin
      statusText.Caption := '游戏中';
      gs := GameStatus.inGame;
    end;
  if curStatus = GameStatus.allOver then
    if nextStatus = GameStatus.init then
    begin
      stagecount := 1;
      statusText.Caption := '初始化';
      gs := GameStatus.init;
    end;
  lastStatus := curStatus;
end;

procedure TMainForm.gamedead;
begin ;
end;

procedure TMainForm.initGame;
var
  i: Integer;
begin
  statusText.Caption := '初始化';
  ball.Top := 50;
  ball.left := 300;
  boardSpeed := 4;
  ballSpeedx := 5;
  ballSpeedy := 1;
  score := 0;
  board.Top := gamePanel.Height div 2 - board.Height div 2;
  stageName := inttostr(stageCount);
  for i := ComponentCount - 1 downto 0 do
  begin
    if Components[i] is BrickButton then
      Components[i].Free;
  end;
  switchStatus(gs, GameStatus.load);
end;

procedure TMainForm.moveBoard;
begin
  if not canControl then
    exit;
  case bms of
    BoardMoveStatus.up:
      if board.Top > 0 then
        board.Top := board.Top - boardSpeed;
    BoardMoveStatus.down:
      if board.Top + board.Height < gamePanel.Height then
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
  switchStatus(gs, GameStatus.pause);
end;

procedure TMainForm.drawScore;
begin
  scoreLabel.Caption := 'score:' + inttostr(score);
  brickleftlabel.Caption := '剩余砖块：' + inttostr(brickLeft);
end;

procedure TMainForm.statusTextClick(Sender: TObject);
begin
  if gs = GameStatus.dead then
    gs := init;
end;

procedure TMainForm.moveBall;
var
  tempTop, tempLeft: Integer;
begin
  tempTop := ball.Top + ballSpeedy;
  tempLeft := ball.left + ballSpeedx;
  checkContact(tempLeft, tempTop);
  if tempLeft < board.left + board.Width then
    if board.Top < tempTop + ball.Height then
      if board.Top > tempTop - board.Height then
      begin
        tempLeft := board.left + board.Width;
        ballSpeedx := -ballSpeedx;
        case bms of
          BoardMoveStatus.up:
            ballSpeedy := ballSpeedy - 1;
          BoardMoveStatus.down:
            ballSpeedy := ballSpeedy + 1;
        end;
      end;
  if tempTop < 0 then
  begin
    tempTop := 0;
    ballSpeedy := -ballSpeedy;
  end;
  if tempTop + ball.Height > gamePanel.Height then
  begin
    tempTop := gamePanel.Height - ball.Height;
    ballSpeedy := -ballSpeedy;
  end;
  if tempLeft + ball.Width < 0 then
  begin
    switchStatus(gs, GameStatus.dead);
  end;
  if tempLeft + ball.Width > gamePanel.Width then
  begin
    tempLeft := gamePanel.Width - ball.Width;
    ballSpeedx := -ballSpeedx;
  end;
  ball.Top := tempTop;
  ball.left := tempLeft;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin;
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
        checkBrickLeft;
      end;
    GameStatus.dead:
      begin
        gamedead;
      end;
    GameStatus.pause:
      ;
    GameStatus.load:
      load(stageName);
  end;

end;

procedure TMainForm.gamePanelEnter(Sender: TObject);
begin
  canControl := true;
end;

procedure TMainForm.gamePanelExit(Sender: TObject);
begin
  canControl := false;
end;

procedure TMainForm.gamePanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin

  if Y > board.Top + board.Height then
    bms := BoardMoveStatus.down
  else if Y < board.Top then
    bms := BoardMoveStatus.up
  else
    bms := BoardMoveStatus.stop

end;

end.
