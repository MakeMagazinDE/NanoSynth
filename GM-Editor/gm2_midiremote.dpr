program gm2_midiremote;

uses
  Vcl.Forms,
  gm2_midiremote_main in 'gm2_midiremote_main.pas' {Form1},
  midi in 'midi.pas',
  nrpn_calc in 'nrpn_calc.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
