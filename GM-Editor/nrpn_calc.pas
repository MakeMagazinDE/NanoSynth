unit nrpn_calc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    EditDecimal: TEdit;
    Label36: TLabel;
    BtnSenSysExRaw: TBitBtn;
    EditHex14: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure EditDecimalChange(Sender: TObject);
    procedure BtnSenSysExRawClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

implementation

uses gm2_midiremote_main;

{$R *.dfm}

procedure TForm2.BtnSenSysExRawClick(Sender: TObject);
begin
  Form1.StringGrid1.Cells[1, SelectedRow]:= EditHex14.Text;
end;

procedure TForm2.EditDecimalChange(Sender: TObject);
var
  my_int14, my_lsb, my_msb: Integer;
begin
  my_msb := StrToInt(EditDecimal.Text) shr 7;
  my_lsb := StrToInt(EditDecimal.Text) and $007F;
  my_int14:= 256 * my_msb + my_lsb;
  EditHex14.Text:= '$' + IntToHex(my_int14, 4);
end;

end.
