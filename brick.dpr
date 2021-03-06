program brick;

uses
  Forms,
  brickgame in 'brickgame.pas' {MainForm},
  hsframeA in 'hsframeA.pas' {highScoreForm},
  InputName in 'InputName.pas' {InputNameDialog},
  winForm in 'winForm.pas' {winFormA};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(ThighScoreForm, highScoreForm);
  Application.CreateForm(TInputNameDialog, InputNameDialog);
  Application.CreateForm(TwinFormA, winFormA);
  Application.Run;
end.
