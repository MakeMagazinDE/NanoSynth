unit gm2_midiremote_main;

// ##############################################################################
//
// Midi-Test-Utility und Monitor für HX3 mk5 Organ Module, C. Meyer 10/2017
//
// ##############################################################################

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Midi, StdCtrls, SyncObjs, CheckLst, Grids, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.XPMan, Vcl.ComCtrls;

type

  TAnoPipe = record
    Input: THandle; // Handle to send data to the pipe
    Output: THandle; // Handle to read data from the pipe
  end;

  TForm1 = class(TForm)
    StatusBar: TStatusBar;
    XPManifest1: TXPManifest;
    Memo1: TMemo;
    Label22: TLabel;
    lbxInputDevices: TCheckListBox;
    lbxOutputDevices: TCheckListBox;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    ScrollOctave: TScrollBar;
    Label25: TLabel;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    LabelCstart: TLabel;
    Label20: TLabel;
    LabeC2: TLabel;
    ScrollBarDyn: TScrollBar;
    Label34: TLabel;
    CheckBox25: TCheckBox;
    BtnSenSysExRaw: TBitBtn;
    EditSysExRaw: TEdit;
    Label36: TLabel;
    MidiDeviceRefresh: TButton;
    StringGrid1: TStringGrid;
    CheckBit0: TCheckBox;
    CheckBit1: TCheckBox;
    CheckBit2: TCheckBox;
    CheckBit3: TCheckBox;
    CheckBit4: TCheckBox;
    CheckBit5: TCheckBox;
    CheckBit6: TCheckBox;
    CheckBit7: TCheckBox;
    TabPanel: TPanel;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    LabelHelpText: TLabel;
    BtnSendAll: TBitBtn;
    BtnSaveAsH: TBitBtn;
    BtnSaveFile: TBitBtn;
    BtnOpenFile: TBitBtn;
    Label1: TLabel;
    Bevel1: TBevel;
    SaveDialog1: TSaveDialog;
    ComboBoxEditType: TComboBox;
    ComboBoxPrgmChange: TComboBox;
    ComboBoxCCch: TComboBox;
    ComboBoxKBch: TComboBox;
    OpenDialog1: TOpenDialog;
    SaveDialog2: TSaveDialog;
    ComboBoxSendType: TComboBox;
    LabelParamNumber: TLabel;
    BitBtn1: TBitBtn;

    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure Button1MouseEnter(Sender: TObject);
    procedure Button1MouseLeave(Sender: TObject);

    procedure lbxInputDevicesClickCheck(Sender: TObject);
    procedure lbxOutputDevicesClickCheck(Sender: TObject);
    procedure CheckBox25Click(Sender: TObject);
    procedure BtnSenSysExRawClick(Sender: TObject);
    procedure MidiDeviceRefreshClick(Sender: TObject);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid1TopLeftChanged(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure CheckBitClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnSendAllClick(Sender: TObject);
    procedure ScrollOctaveChange(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure BtnSaveFileClick(Sender: TObject);
    procedure ComboBoxEditTypeChange(Sender: TObject);
    procedure BtnSaveAsHClick(Sender: TObject);
    procedure ComboBoxPrgmChangeChange(Sender: TObject);
    procedure TabPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxSendTypeChange(Sender: TObject);
    procedure EditSysExRawChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);

  private
    fCriticalSection: TCriticalSection;
  public
    procedure DoMidiInData(const aDeviceIndex: Integer;
      const aStatus, aData1, aData2: byte);
    procedure DoSysExData(const aDeviceIndex: Integer;
      const aStream: TMemoryStream);
  end;

const
  // ### Länge des Parameter-EEPROMs
  VersionInfo = 'Version 0.1';

var
  Form1: TForm1;
  base_addr: Integer;

  DropDownList: TstringList;
  DropDownStringList: TstringList;
  LastControlName: String; // zuletzt verwendetes Control in StringGrids
  ParamFileName: String;
  ButtonDescList: TstringList;
  MidiCCList: TstringList;
  SelectedRow: Integer;

type
  t_sgr = (sgr_none, sgr_edit, sgr_eeprom, sgr_voice, sgr_init, sgr_header);
  t_edit_type = (et_none, et_track, et_button, et_bits, et_trigger, et_ignore);
  t_send_type = (st_cc, st_cc1, st_cc2, st_rpn, st_nrpn);

  t_sg_item = Record
    send_type: t_send_type;
    param_nr: Integer;
    row_type: t_sgr;
    edit_type: t_edit_type;
    value: Integer;
    scaled_value: Integer;
    max: Integer;
  end;

implementation

{$R *.dfm}

uses nrpn_calc;

var

  // SG-Reihenfolge: Param,Description,Value,Name,Max,Type,Search
  StringGridVals: Array of t_sg_item;
  RepaintStringGridRequest: Boolean;

  // ##############################################################################
{$I draw_sg_items.pas}
  // #############################################################################
  // #############################################################################


  // #############################################################################

procedure Delay(msecs: Longint);
var
  targettime: cardinal;
begin
  targettime := GetTickCount + msecs;
  while targettime > GetTickCount do
  begin
    Application.ProcessMessages;
    sleep(0);
  end;
end;

function FormatHexStr(const in_str: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to length(in_str) - 1 do
  begin
    Result := Result + pAnsiChar(in_str)[i];
    if i mod 2 = 1 then
      Result := Result + #32;
  end;
end;

// #############################################################################

procedure AddStatusMemo(device, cmd, data1, data2: byte; msg_str: String);
begin
  Form1.Memo1.Lines.BeginUpdate;
  try
    Form1.Memo1.Lines.Add(Format('Out %s: %.2x %.2x %.2x (%s)',
      [MidiOutput.Devices[device], cmd, data1, data2, msg_str]));
  finally
    Form1.Memo1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    Form1.Memo1.Lines.EndUpdate;
  end;
end;

procedure MidiNoteSend(ch_offs, my_note, my_dyn: Integer);
var
  i, cmd: Integer;
  msg_str: String;
begin
  ch_offs := ch_offs + Form1.ComboBoxKBch.ItemIndex;
  if my_dyn > 0 then
  begin
    cmd := $90 + ch_offs;
    msg_str := 'Note ON';
  end
  else
  begin
    cmd := $80 + ch_offs;
    msg_str := 'Note OFF';
  end;
  for i := MidiOutput.Devices.Count - 1 downto 0 do
    if Form1.lbxOutputDevices.Checked[i] then
    begin
      MidiOutput.Send(i, cmd, my_note, my_dyn);
      AddStatusMemo(i, cmd, my_note, my_dyn, msg_str)
    end;
end;

procedure MidiCCsend(ch_offs, my_cc, my_val: Integer);
// addiert ausgewählten Basiskanal!
var
  i, cmd: Integer;
begin
  ch_offs := ch_offs + Form1.ComboBoxCCch.ItemIndex;
  cmd := $B0 + ch_offs;
  for i := MidiOutput.Devices.Count - 1 downto 0 do
    if Form1.lbxOutputDevices.Checked[i] then
    begin
      MidiOutput.Send(i, cmd, my_cc, my_val);
      AddStatusMemo(i, cmd, my_cc, my_val, 'Controller');
    end;
end;

procedure MidiPrgChangeSend(ch_offs, my_val: Integer);
// addiert ausgewählten Basiskanal!
var
  i, cmd: Integer;
begin
  ch_offs := ch_offs + Form1.ComboBoxCCch.ItemIndex;
  cmd := $C0 + ch_offs;
  for i := MidiOutput.Devices.Count - 1 downto 0 do
    if Form1.lbxOutputDevices.Checked[i] then
    begin
      MidiOutput.Send(i, cmd, my_val, 0);
      AddStatusMemo(i, cmd, my_val, 0, 'PrgChange');
    end;
end;

procedure TForm1.Button1MouseEnter(Sender: TObject);
begin
  MidiNoteSend(0, (Sender as TButton).Tag - 36 + 12 * ScrollOctave.Position,
    ScrollBarDyn.Position);
end;

procedure TForm1.Button1MouseLeave(Sender: TObject);
begin
  MidiNoteSend(0, (Sender as TButton).Tag - 36 + 12 *
    ScrollOctave.Position, $00);
end;

procedure gm_send_rowVal(my_row: Integer);
// sende Werte einer Tabellenzeile
var
  my_cc, val_max, my_val, my_lsb, my_msb, my_ch_offset: Integer;
begin
  with Form1 do
  begin
    my_cc := StrToInt(StringGrid1.Cells[1, my_row]);
    val_max := StringGridVals[my_row].max;
    my_val := StringGridVals[my_row].value;
    if val_max = 0 then
      val_max := 127;
    StringGridVals[my_row].scaled_value := my_val * 100 div val_max;
    if StringGridVals[my_row].edit_type <> et_ignore then
    begin
      my_msb := my_cc shr 8;
      my_lsb := my_cc and $007F;
      case StringGridVals[my_row].send_type of
      st_cc..st_cc2:
        begin
          my_ch_offset:= ord(StringGridVals[my_row].send_type);
          MidiCCsend(my_ch_offset, my_cc, my_val);
        end;
      st_rpn:
        begin // RPN senden
          MidiCCsend(0, $65, my_msb);
          MidiCCsend(0, $64, my_lsb);
          MidiCCsend(0, $06, my_val);
          sleep(2);
        end;
      st_nrpn:
        begin // NRPN senden
          MidiCCsend(0, $63, my_msb);
          MidiCCsend(0, $62, my_lsb);
          MidiCCsend(0, $06, my_val);
          sleep(2);
        end;
      end;
    end;
  end;
end;

procedure gm_send_changed(my_row, my_val: Integer);
// Falls neuer Wert <> alter Wert,
// neuen Wert an HX3.5 senden, in Stringgrid undStringGridVals setzen
var
  my_cc, val_max, my_old_val: Integer;
begin
  with Form1 do
  begin
    my_old_val := StringGridVals[my_row].value;
    if (my_val <> my_old_val) then
    begin
      StringGrid1.Cells[3, my_row] := IntToStr(my_val);
      StringGridVals[my_row].value := my_val;
      gm_send_rowVal(my_row);
      RepaintStringGridRequest := true; // Balken anzeigen, SG aktualisieren
    end;
  end;
end;

procedure panel_state(const on_off: Boolean);
begin
  with Form1 do
    if on_off then
    begin
      TabPanel.Tag := 1;
      TabPanel.Color := cllime;
      TabPanel.Font.Color := clcream;
      TabPanel.Caption := 'ON';
      TabPanel.BevelOuter := bvLowered;
    end
    else
    begin
      TabPanel.Tag := 0;
      TabPanel.Font.Color := clgray;
      TabPanel.Color := $00004000;
      TabPanel.Caption := 'OFF';
      TabPanel.BevelOuter := bvRaised;
    end;
end;

procedure checkbit_state(const my_val: Integer);
begin
  with Form1 do
  begin
    CheckBit7.Checked := (my_val and 128) = 128;
    CheckBit6.Checked := (my_val and 64) = 64;
    CheckBit5.Checked := (my_val and 32) = 32;
    CheckBit4.Checked := (my_val and 16) = 16;
    CheckBit3.Checked := (my_val and 8) = 8;
    CheckBit2.Checked := (my_val and 4) = 4;
    CheckBit1.Checked := (my_val and 2) = 2;
    CheckBit0.Checked := (my_val and 1) = 1;
  end;
end;


// #############################################################################
// ########################### Formular Main  ##################################
// #############################################################################

procedure TForm1.ComboBoxEditTypeChange(Sender: TObject);
begin
  // Edit-Typ ändern
  StringGridVals[SelectedRow].edit_type :=
    t_edit_type(ComboBoxEditType.ItemIndex);
  StringGrid1.Cells[4, SelectedRow] := ComboBoxEditType.Text;
  StringGrid1TopLeftChanged(Sender);
end;

procedure TForm1.ComboBoxSendTypeChange(Sender: TObject);
begin
  // Edit-Typ ändern
  StringGridVals[SelectedRow].send_type :=
    t_send_type(ComboBoxSendType.ItemIndex);
  StringGrid1.Cells[0, SelectedRow] := ComboBoxSendType.Text;
  StringGrid1TopLeftChanged(Sender);
end;

// #############################################################################

procedure ChagedRowToStringGrid(StringGrid: TStringGrid; my_row: Integer);
var
  my_val, val_max: Integer;
begin
  with Form1 do
  begin
    StringGridVals[my_row].send_type := st_cc;
    if StringGrid.Cells[0, my_row] = 'CC+1' then
      StringGridVals[my_row].send_type := st_cc1;
    if StringGrid.Cells[0, my_row] = 'CC+2' then
      StringGridVals[my_row].send_type := st_cc2;
    if StringGrid.Cells[0, my_row] = 'RPN' then
      StringGridVals[my_row].send_type := st_rpn;
    if StringGrid.Cells[0, my_row] = 'NRPN' then
      StringGridVals[my_row].send_type := st_nrpn;

    StringGridVals[my_row].edit_type := et_none;
    if StringGrid.Cells[4, my_row] = 'Track' then
      StringGridVals[my_row].edit_type := et_track;
    if StringGrid.Cells[4, my_row] = 'Button' then
      StringGridVals[my_row].edit_type := et_button;
    if StringGrid.Cells[4, my_row] = 'Bits' then
      StringGridVals[my_row].edit_type := et_bits;
    if StringGrid.Cells[4, my_row] = 'Trigger' then
      StringGridVals[my_row].edit_type := et_trigger;
    if StringGrid.Cells[4, my_row] = 'Ignore' then
      StringGridVals[my_row].edit_type := et_ignore;
    val_max := StrToIntDef(StringGrid.Cells[5, my_row], 127);
    if val_max = 0 then
      val_max := 127;
    StringGridVals[my_row].max := val_max;
    StringGridVals[my_row].param_nr :=
      StrToIntDef(StringGrid.Cells[1, my_row], 0);
    StringGridVals[my_row].value := StrToIntDef(StringGrid.Cells[3, my_row], 0);
    StringGridVals[my_row].scaled_value := StringGridVals[my_row].value *
      100 div val_max;
  end;
end;

procedure LoadStringGrid(StringGrid: TStringGrid; const FileName: string);
var
  text_list, Line: TstringList;
  Row, Col: Integer;
begin
  StringGrid.RowCount := 0; // clear any previous data
  text_list := TstringList.Create;
  try
    Line := TstringList.Create;
    try
      Line.Delimiter := ',';
      text_list.LoadFromFile(FileName);
      StringGrid.RowCount := text_list.Count;
      for Row := 0 to text_list.Count - 1 do
      begin
        Line.DelimitedText := text_list[Row];
        for Col := 0 to StringGrid.ColCount - 1 do
          if Col < Line.Count then
          begin
            StringGrid.Cells[Col, Row] := Line[Col];
          end;
      end;
      StringGrid.FixedRows := 1;
    finally
      Line.Free;
    end;
  finally
    text_list.Free;
  end;
end;

procedure InitParamStringGrid(StringGrid: TStringGrid);
var
  my_row: Integer;
begin
  // Wird nur für schnellen Zugriff in StringGridDrawCell benötigt:
  // SG-Reihenfolge: Param, Description, Value, EditType, Max,Help
  setlength(StringGridVals, StringGrid.RowCount);

  for my_row := 0 to StringGrid.RowCount - 1 do
  begin
    ChagedRowToStringGrid(StringGrid, my_row);
  end;
  RepaintStringGridRequest := true; // Balken anzeigen
  StringGrid.Row := 1;
  StringGrid.Col := 3;
end;

procedure LoadParamStringGrid(StringGrid: TStringGrid; const FileName: string);
var
  Row, my_param, highest_param_nr, val_max: Integer;
begin
  LoadStringGrid(StringGrid, FileName);
  InitParamStringGrid(StringGrid);
end;

procedure SaveStringGrid(StringGrid: TStringGrid; const FileName: TFileName);
// Save a TStringGrid to a file, min. 3 Cols
var
  f: TextFile;
  my_col, my_row: Integer;
begin
  AssignFile(f, FileName);
  Rewrite(f);
  with StringGrid do
  begin
    for my_row := 0 to RowCount - 1 do
    begin
      for my_col := 0 to ColCount - 1 do
      begin
        if pos(#32, Cells[my_col, my_row]) > 0 then // enthält Leerzeichen
          write(f, '"' + Cells[my_col, my_row] + '",')
        else
          write(f, Cells[my_col, my_row] + ',')
      end;
      writeln(f);
    end;
  end;
  CloseFile(f);
end;

// #############################################################################

// Der folgende Eventhandler malt und versteckt die Bedienelemente,
// wenn sie aus dem StringGrid herausgescrollt werden:
procedure TForm1.StringGrid1TopLeftChanged(Sender: TObject);
var
  my_val, my_max, my_offset, my_param, my_channel_offset: Integer;
  // my_type: String;
  my_rect, r: TRect;
  my_edit_type: t_edit_type;
  my_send_type: t_send_type;
begin

  // Auswahl-Dropdown MIDI-Datentyp
  my_send_type := StringGridVals[SelectedRow].send_type;
  my_rect := StringGrid1.CellRect(0, SelectedRow);
  my_val := ord(my_send_type);
  draw_simple_dropdown_in_sg(ComboBoxSendType, my_rect, my_val);

  // Auswahl-Dropdown Edit-Type (Trackbar, Button etc.)
  my_edit_type := StringGridVals[SelectedRow].edit_type;
  my_rect := StringGrid1.CellRect(4, SelectedRow);
  my_val := ord(my_edit_type);
  draw_simple_dropdown_in_sg(ComboBoxEditType, my_rect, my_val);

  LabelHelpText.Caption := StringGrid1.Cells[6, SelectedRow];

  my_param := StrToIntDef(StringGrid1.Cells[1, SelectedRow], 0);
  if my_edit_type = et_ignore then
    LabelParamNumber.Font.Color := clgray
  else
    LabelParamNumber.Font.Color := clred;
  if StringGridVals[SelectedRow].send_type <= st_cc2 then begin
    my_channel_offset:= ord(StringGridVals[SelectedRow].send_type);
    if my_channel_offset > 0 then
      LabelParamNumber.Caption := IntToStr(my_param) + ' ($'
        + IntToHex(my_param, 2) + ')'
        + ', Channel Offset +' + IntToStr(my_channel_offset)
    else
      LabelParamNumber.Caption := IntToStr(my_param) + ' ($'
        + IntToHex(my_param, 2) + ')';
  end else begin
    LabelParamNumber.Caption:= IntToStr(my_param)
      + ' ($' + IntToHex(my_param, 4) + ')';
  end;

  if my_edit_type = et_none then
  begin
    TrackBar1.Visible := false;
    TabPanel.Visible := false;
    hide_checkbits;
    exit;
  end;

  my_rect := StringGrid1.CellRect(3, SelectedRow);
  my_val := StrToIntDef(StringGrid1.Cells[3, SelectedRow], 0);
  my_max := StrToIntDef(StringGrid1.Cells[5, SelectedRow], 0);

  if my_edit_type = et_track then
    draw_trackbar_in_sg(my_rect, TrackBar1, my_val, my_max)
  else
    TrackBar1.Visible := false;

  if (my_edit_type = et_button) or (my_edit_type = et_trigger) then
  // LED-Button (Panel)
    with Form1.TabPanel do
    begin
      if (my_edit_type = et_trigger) then
      begin
        StringGrid1.Cells[3, SelectedRow] := '0';
        my_val := 0;
        StringGridVals[SelectedRow].value := 0;
      end;

      my_offset := my_rect.Width div 3;
      CopyRect(r, my_rect);
      // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
      // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
      r.BottomRight := Parent.ScreenToClient
        (Form1.StringGrid1.ClientToScreen(r.BottomRight));
      r.TopLeft := Parent.ScreenToClient
        (Form1.StringGrid1.ClientToScreen(r.TopLeft));
      r.Left := r.Left + my_offset;
      r.Right := r.Right - my_offset;
      // Positionierung des Panel-Buttons (Left, Top, Width und Height werden zugewiesen):
      SetBounds(r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
      panel_state(my_val > 0);
      Visible := true;
      BringToFront; // Panel-Button in Vordergrund bringen

    end
  else
    TabPanel.Visible := false;

  if my_edit_type = et_bits then
  begin // 8 Checkboxen
    checkbit_state(my_val);
    draw_checkbits_in_sg(my_rect);
  end
  else
    hide_checkbits;

end;

// #############################################################################

procedure TForm1.ScrollOctaveChange(Sender: TObject);
begin
  LabelCstart.Caption := IntToStr(ScrollOctave.Position * 12);
  LabeC2.Caption := IntToStr(ScrollOctave.Position * 12 + 12);
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  balken_rect: TRect;
  bar_field_width: Integer;
begin
  StringGrid1.Font.Style := [];
  with StringGrid1, Canvas do
  begin
    if (ARow < 1) or (StringGridVals[ARow].row_type = sgr_header) then
    begin
      // Tabelle erste Zeile fett
      Font.Style := [fsBold];
      Font.Color := clblack;
      if (ACol < 3) or (ARow = 0) then
        TextRect(Rect, Rect.Left + 2, Rect.Top + 2, Cells[ACol, ARow])
      else if (ACol = 2) and (ARow > 0) then
      begin
        TextRect(Rect, Rect.Left + 2, Rect.Top + 2, ' ');
      end;
    end
    else
    begin
      if (StringGridVals[ARow].edit_type = et_ignore) then
      begin
        Font.Color := clgray;
        TextRect(Rect, Rect.Left + 2, Rect.Top + 1, Cells[ACol, ARow]);
      end
      else if (ACol = 2) and (Col <> 2) then
      begin
        if (StringGridVals[ARow].edit_type = et_track) then
        begin
          balken_rect := Rect;
          InflateRect(balken_rect, -1, -3);
          bar_field_width := balken_rect.Width * StringGridVals[ARow]
            .scaled_value div 101;
          balken_rect.Right := balken_rect.Left + bar_field_width;
          Brush.Color := clwindow;
          FillRect(Rect); // alten Text löschen
          Brush.Color := $00E0E0E0;
          FillRect(balken_rect);
          Brush.Style := bsClear; // Transparente Schrift
          TextRect(Rect, Rect.Left + 2, Rect.Top + 2, Cells[ACol, ARow]);
        end;
      end
      else if (ACol = 3) and (SelectedRow <> ARow) then
      begin
        // Value Column
        Font.Style := [fsBold];
        Font.Color := clblack; // sgr_flash, sgr_edit
        TextRect(Rect, Rect.Left + 2, Rect.Top + 2, Cells[ACol, ARow]);
      end;
    end;
  end;
end;

procedure TForm1.StringGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    StringGrid1TopLeftChanged(Sender);
    RepaintStringGridRequest := true;
  end;
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var my_ch_offset, my_cc: Integer;
begin
  StringGridVals[SelectedRow].param_nr :=
    StrToIntDef(StringGrid1.Cells[1, SelectedRow], 0);
  StringGridVals[SelectedRow].value :=
    StrToIntDef(StringGrid1.Cells[3, SelectedRow], 0);
  SelectedRow := ARow;

  RepaintStringGridRequest := true;
  StringGrid1TopLeftChanged(Sender);
end;

// #############################################################################

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  my_val: Integer;
begin
  my_val := TrackBar1.Position;
  gm_send_changed(SelectedRow, my_val);
  Delay(5);
end;

procedure TForm1.TabPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  my_val: Integer;
begin
  if StringGridVals[SelectedRow].edit_type <> et_trigger then
  begin
    panel_state(TabPanel.Tag = 0); // invertieren
    if TabPanel.Tag = 0 then
      my_val := 0
    else
      my_val := 127;
  end
  else
    my_val := 127;
  panel_state(my_val <> 0);
  gm_send_changed(SelectedRow, my_val);
end;

procedure TForm1.TabPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if StringGridVals[SelectedRow].edit_type = et_trigger then
  begin
    panel_state(false);
    gm_send_changed(SelectedRow, 0);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if RepaintStringGridRequest then
    StringGrid1.Repaint;
  RepaintStringGridRequest := false;
  {
    TrackBar1.Position:= StringGridVals[SelectedRow].value;
    checkbit_state(StringGridVals[SelectedRow].value);
  }
  panel_state(StringGridVals[SelectedRow].value > 0);
end;

procedure TForm1.CheckBitClick(Sender: TObject);
var
  my_val: Integer;
begin
  my_val := 0;
  if CheckBit0.Checked then
    my_val := 1;
  if CheckBit1.Checked then
    my_val := my_val or 2;
  if CheckBit2.Checked then
    my_val := my_val or 4;
  if CheckBit3.Checked then
    my_val := my_val or 8;
  if CheckBit4.Checked then
    my_val := my_val or 16;
  if CheckBit5.Checked then
    my_val := my_val or 32;
  if CheckBit6.Checked then
    my_val := my_val or 64;
  if CheckBit7.Checked then
    my_val := my_val or 128;
  gm_send_changed(SelectedRow, my_val);

end;

// #############################################################################

// #############################################################################

procedure TForm1.DoMidiInData(const aDeviceIndex: Integer;
  const aStatus, aData1, aData2: byte);
var
  i: Integer;
  aStr: String;
begin
  // skip active sensing signals from keyboard
  if aStatus = $FE then
    exit;

  fCriticalSection.Acquire;
  Memo1.Lines.BeginUpdate;
  try
    // print the message log
    aStr := '';
    if aStatus and $F0 = $B0 then
      aStr := 'Controller';
    if aStatus and $F0 = $80 then
      aStr := 'Note OFF';
    if aStatus and $F0 = $90 then
      if aData2 = 0 then
        aStr := 'Note OFF'
      else
        aStr := 'Note ON';
    Memo1.Lines.Add(Format('IN  %s: %.2x %.2x %.2x (%s)',
      [MidiInput.Devices[aDeviceIndex], aStatus, aData1, aData2, aStr]));
  finally
    Form1.Memo1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    Memo1.Lines.EndUpdate;
    fCriticalSection.Leave;
  end;
end;

procedure TForm1.DoSysExData(const aDeviceIndex: Integer;
  const aStream: TMemoryStream);
{
  c_err_cmd:       Byte = 0;    // Bit 0 = +1
  c_err_sd:        Byte = 1;    // Bit 1 = +2
  c_err_finalized: Byte = 2;    // Bit 2 = +4
  c_err_flash:     Byte = 3;    // Bit 3 = +8
  c_err_conf:      Byte = 4;    // Bit 4 = +16
  c_err_upd:       Byte = 5;    // Bit 5 = +32
}
const
  Errors: Array [0 .. 5] of String[15] = (' CmdErr', ' SDcardErr',
    ' NotFinalized', ' FlashErr', ' ConfErr', ' UpdateErr');
var
  i, err, my_val: Integer;
  aStr: String;
begin
  fCriticalSection.Acquire;
  Memo1.Lines.BeginUpdate;
  try
    // print the message log
    Memo1.Lines.Add(Format('IN  %s: (%d Bytes SysEx)',
      [MidiInput.Devices[aDeviceIndex], aStream.Size]));
    Memo1.Lines.Add(SysExStreamToStr(aStream));
    aStream.Position := 0;
    aStr := '';
    for i := 1 to aStream.Size - 2 do
      if byte(pAnsiChar(aStream.Memory)[i]) >= 32 then
        aStr := aStr + pAnsiChar(aStream.Memory)[i]
      else
        aStr := aStr + '#';
    if aStream.Size >= 11 then
    begin
      Memo1.Lines.Add('ASCII: <' + aStr + '>');
    end;
    aStr := SysExStreamToStr(aStream);
    if length(aStr) > 22 then
      if copy(aStr, 1, 17) = 'F0 00 20 04 33 06' then
      begin
        my_val := Integer(byte(pAnsiChar(aStream.Memory)[6])) shl 7;
        my_val := my_val or Integer(byte(pAnsiChar(aStream.Memory)[7])) and $7F;
        Memo1.Lines.Add('Value: <' + IntToStr(my_val) + '>');
      end;
    if copy(aStr, 1, 17) = 'F0 00 20 04 33 02' then
    begin
      my_val := Integer(byte(pAnsiChar(aStream.Memory)[6])) and $7F;
      err := my_val;
      if err > 0 then
      begin
        aStr := '[';
        for i := 0 to 5 do
        begin
          if (my_val and 1) = 1 then
            aStr := aStr + Errors[i];
          my_val := my_val shr 1;
        end
      end
      else
        aStr := '[ NoErr';
      aStr := 'Error: <' + IntToStr(err) + '> ' + aStr + ' ]';
      Memo1.Lines.Add(aStr);
    end;

  finally
    Form1.Memo1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    Memo1.Lines.EndUpdate;
    fCriticalSection.Leave;
  end;
end;

procedure TForm1.EditSysExRawChange(Sender: TObject);
begin

end;

// #############################################################################


procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.clear;
  Memo1.Lines.Add('### Welcome to GM2 MIDI Tester!');
  Memo1.Lines.Add('### (c) Carsten Meyer 1/2018');
  Memo1.Lines.Add('### cm@make-magazin.de');
  Memo1.Lines.Add('');
  Show;
  fCriticalSection := TCriticalSection.Create;
  lbxInputDevices.Items.Assign(MidiInput.Devices);
  lbxOutputDevices.Items.Assign(MidiOutput.Devices);
  MidiInput.OnMidiData := DoMidiInData;
  MidiInput.OnSysExData := DoSysExData;
  OpenDialog1.FileName := 'gm_ccvals.csv';
  Caption := 'GM MIDI Tester [' + OpenDialog1.FileName + ']';
  if FileExists(OpenDialog1.FileName) then begin
    LoadParamStringGrid(StringGrid1, OpenDialog1.FileName);
    StringGrid1.Row := 1;
    StringGrid1.Col := 3;
    StringGrid1TopLeftChanged(Sender);
  end else begin
    Memo1.Lines.Add('### Error: File ' + OpenDialog1.FileName + ' not found');
    Memo1.Lines.Add('### in application folder! Please open ');
    Memo1.Lines.Add('### valid CC Table file to proceed.');
    SetLength(StringGridVals,127);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := MidiInput.Devices.Count - 1 downto 0 do
    if Form1.lbxInputDevices.Checked[i] then
    begin
      MidiInput.Close(lbxInputDevices.ItemIndex)
    end;
  for i := MidiOutput.Devices.Count - 1 downto 0 do
    if Form1.lbxOutputDevices.Checked[i] then
    begin
      MidiOutput.Close(lbxOutputDevices.ItemIndex)
    end;
  FreeAndNil(fCriticalSection);
end;

// ##############################################################################

procedure TForm1.MidiDeviceRefreshClick(Sender: TObject);
var
  i: Integer;
begin
  for i := MidiInput.Devices.Count - 1 downto 0 do
    if Form1.lbxInputDevices.Checked[i] then
    begin
      MidiInput.Close(lbxInputDevices.ItemIndex)
    end;
  for i := MidiOutput.Devices.Count - 1 downto 0 do
    if Form1.lbxOutputDevices.Checked[i] then
    begin
      MidiOutput.Close(lbxOutputDevices.ItemIndex)
    end;
  FreeAndNil(fCriticalSection);

  fCriticalSection := TCriticalSection.Create;
  lbxInputDevices.Items.Assign(MidiInput.Devices);
  lbxOutputDevices.Items.Assign(MidiOutput.Devices);

  MidiInput.OnMidiData := DoMidiInData;
  MidiInput.OnSysExData := DoSysExData;
end;

procedure TForm1.lbxInputDevicesClickCheck(Sender: TObject);
begin
  if lbxInputDevices.Checked[lbxInputDevices.ItemIndex] then
    MidiInput.Open(lbxInputDevices.ItemIndex)
  else
    MidiInput.Close(lbxInputDevices.ItemIndex)
end;

procedure TForm1.lbxOutputDevicesClickCheck(Sender: TObject);
begin
  if lbxOutputDevices.Checked[lbxOutputDevices.ItemIndex] then
    MidiOutput.Open(lbxOutputDevices.ItemIndex)
  else
    MidiOutput.Close(lbxOutputDevices.ItemIndex)
end;

// ##############################################################################


procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  Form2.show;
end;

procedure TForm1.BtnOpenFileClick(Sender: TObject);
begin
  OpenDialog1.Title := 'Open CC list file:';
  OpenDialog1.FilterIndex := 1;
  OpenDialog1.DefaultExt := '*.csv';
  if OpenDialog1.Execute then
  begin
    LoadParamStringGrid(StringGrid1, OpenDialog1.FileName);
    StringGrid1TopLeftChanged(Sender);
    Form1.Caption := 'GM MIDI Tester [' + OpenDialog1.FileName + ']';
  end;
end;

procedure TForm1.BtnSaveAsHClick(Sender: TObject);
// Header-Datei für Arduino schreiben
var
  f: TextFile;
  my_row, my_lsb, my_msb: Integer;
begin
  SaveDialog2.Title := 'Save CC list as Arduino header file:';
  SaveDialog2.FilterIndex := 1;
  SaveDialog2.DefaultExt := '*.h';
  SaveDialog2.FileName := 'cc_instr_' + IntToStr(ComboBoxPrgmChange.ItemIndex +
    1) + '.h';
  if SaveDialog2.Execute then
  begin
    AssignFile(f, SaveDialog2.FileName);
    Rewrite(f);
    writeln(f, '// MIDI setup Ccommands for instrument ' +
      ComboBoxPrgmChange.Text);
    writeln(f, '#define CC_CMD_LIST {');
    with StringGrid1 do
    begin
      for my_row := 1 to RowCount - 1 do
      begin
        if StringGridVals[my_row].edit_type <> et_ignore then
        begin
          if StringGridVals[my_row].send_type <= st_cc2 then
          begin
            write(f, $B0 + ComboBoxCCch.ItemIndex
              + ord(StringGridVals[my_row].send_type), ', ');
            write(f, StringGridVals[my_row].param_nr, ', ');
            write(f, StringGridVals[my_row].value);
            writeln(f, ' // CC ' + Cells[2, my_row]);
          end;
          my_msb := StringGridVals[my_row].param_nr shr 8;
          my_lsb := StringGridVals[my_row].param_nr and $007F;
          if StringGridVals[my_row].send_type = st_rpn then
          begin
            write(f, $B0 + ComboBoxCCch.ItemIndex, ', 65, '); // RPN MSB
            write(f, my_msb, ', ');
            write(f, $B0 + ComboBoxCCch.ItemIndex, ', 64, '); // RPN LSB
            write(f, my_lsb, ', ');
            write(f, $B0 + ComboBoxCCch.ItemIndex, ', 6, '); // enter value
            write(f, StringGridVals[my_row].value, ', ');
            writeln(f, ' // RPN ' + Cells[2, my_row]);
          end;
          if StringGridVals[my_row].send_type = st_nrpn then
          begin
            write(f, $B0 + ComboBoxCCch.ItemIndex, ', 63, '); // NRPN MSB
            write(f, my_msb, ', ');
            write(f, $B0 + ComboBoxCCch.ItemIndex, ', 62, '); // NRPN LSB
            write(f, my_lsb, ', ');
            write(f, $B0 + ComboBoxCCch.ItemIndex, ', 6, '); // enter value
            write(f, StringGridVals[my_row].value, ', ');
            writeln(f, ' // NRPN ' + Cells[2, my_row]);
          end;
        end;
      end;
    end;
    CloseFile(f);
  end;
end;

procedure TForm1.BtnSaveFileClick(Sender: TObject);
begin
  SaveDialog1.Title := 'Save CC list file:';
  SaveDialog1.FilterIndex := 1;
  SaveDialog1.DefaultExt := '*.csv';
  SaveDialog1.FileName := OpenDialog1.FileName;
  if SaveDialog1.Execute then
  begin
    Form1.Caption := 'GM MIDI Tester [' + SaveDialog1.FileName + ']';
    SaveStringGrid(StringGrid1, SaveDialog1.FileName);
  end;
end;

procedure TForm1.BtnSendAllClick(Sender: TObject);
var
  i: Integer;
  my_val: Integer;
begin
  Memo1.Lines.Add('### Send all Panel Controls to MIDI');
  for i := 1 to StringGrid1.RowCount - 1 do
  begin
    gm_send_rowVal(i);
    sleep(10);
  end;
  Memo1.Lines.Add('### Done.');
  Memo1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TForm1.ComboBoxPrgmChangeChange(Sender: TObject);
begin
  MidiPrgChangeSend(0, ComboBoxPrgmChange.ItemIndex);
end;

procedure TForm1.BtnSenSysExRawClick(Sender: TObject);
var
  i, Count: Integer;
  sysex_str: AnsiString;
begin
  sysex_str := StringReplace(AnsiUpperCase(EditSysExRaw.Text), ' ', '',
    [rfReplaceAll]);
  Count := (length(sysex_str)) div 2; // 2 Zeichen pro Byte
  for i := MidiOutput.Devices.Count - 1 downto 0 do
    if Form1.lbxOutputDevices.Checked[i] then
    begin
      Memo1.Lines.BeginUpdate;
      try
        MidiOutput.SendSysEx(i, sysex_str);
        Memo1.Lines.Add(Format('OUT %s: (%d Bytes SysEx)',
          [MidiOutput.Devices[i], Count]));
        Memo1.Lines.Add(FormatHexStr(sysex_str));
      finally
        Memo1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
        Memo1.Lines.EndUpdate;
      end;
    end;
end;

procedure TForm1.CheckBox25Click(Sender: TObject);
begin
  if CheckBox25.Checked then
    MidiNoteSend(0, 9 + 12 * ScrollOctave.Position, ScrollBarDyn.Position)
  else
    MidiNoteSend(0, 9 + 12 * ScrollOctave.Position, 0);
end;

end.
