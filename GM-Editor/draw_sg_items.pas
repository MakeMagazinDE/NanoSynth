procedure hide_checkbits;
begin
  with Form1 do begin
    CheckBit7.Visible := false;
    CheckBit6.Visible := false;
    CheckBit5.Visible := false;
    CheckBit4.Visible := false;
    CheckBit3.Visible := false;
    CheckBit2.Visible := false;
    CheckBit1.Visible := false;
    CheckBit0.Visible := false;
  end;
end;

procedure draw_trackbar_in_sg(bounding_rec: TRect; trackbar: Ttrackbar; my_val, my_max: Integer);
var
  r: TRect;
  my_offset: Integer;
begin
  with trackbar do begin
    Max:= my_max;
    Position:= my_val;
    my_offset:= bounding_rec.Width  div 5;

    CopyRect(r, bounding_rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    r.Left:= r.Left + my_offset;
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
    Visible := true;
    BringToFront; // ScrollBar in Vordergrund bringen
  end;
end;

procedure draw_simple_dropdown_in_sg(cb: TComboBox; rec: Trect; my_val: Integer);
// ComboBox-Inhalt in DropDownStringList-Abschnitt mit gleichem Parameter
var
  r: TRect;
begin
  with Form1 do
      with cb do begin
      // ComboBox aufbauen
      CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
      // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
      r.BottomRight := Parent.ScreenToClient
        (Form1.StringGrid1.ClientToScreen(r.BottomRight));
      r.TopLeft := Parent.ScreenToClient
        (Form1.StringGrid1.ClientToScreen(r.TopLeft));
      // Positionierung der ComboBoxButtonAssign (Left, Top, Width und Height werden zugewiesen):
      SetBounds(r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
      ItemIndex:= my_val;
      Visible := true;
      BringToFront; // Panel-Button in Vordergrund bringen
    end;
end;

{
procedure draw_dropdown_in_sg(var rec: Trect; my_param, my_val, my_max: Integer);
// ComboBox-Inhalt in DropDownStringList-Abschnitt mit gleichem Parameter
var
  r: TRect;
  my_offset, i: Integer;
  my_str: String;
  my_SL: TSTringList;
begin
  with Form1.ComboBoxDropDown do begin
    // ComboBox aufbauen
    Items.Clear;
    my_SL:= TSTringList.Create;
    for i:= 0 to DropDownStringList.Count - 1 do begin
      my_SL.CommaText:= DropDownStringList[i];
      if my_SL[0] = InttoSTr(my_Param) then begin
        my_offset:= i;
        Items.Add(my_SL[1]);
      end;
    end;
    my_SL.Free;
    my_offset:= rec.Width div 5;
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    r.Left:= r.Left + my_offset;
    // Positionierung der ComboBoxButtonAssign (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
    ItemIndex:= my_val;
    Visible := true;
    BringToFront; // Panel-Button in Vordergrund bringen
  end;
end;


procedure draw_combobox_in_sg(var rec: Trect; sg_list: Tstringgrid; combobox: Tcombobox; my_val: Integer);
// ComboBox-Inhalt in sg_list
var
  r: TRect;
  my_offset, i: Integer;
  my_str: String;
begin
  with combobox do begin
    my_offset:= rec.Width div 5;
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    r.Left:= r.Left + my_offset;
    // Positionierung der ComboBoxButtonAssign (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
    my_str:= IntToStr(my_val);
    for i := 0 to sg_list.RowCount-1 do // finde Eintrag mit my_val
       if my_str = sg_list.Cells[0,i] then
         break;
    ItemIndex:= i;
    Visible := true;
    BringToFront; // Panel-Button in Vordergrund bringen
  end;
end;
}
// Positionierung von 8 Bit-Checkboxen
procedure draw_checkbits_in_sg(rec: TRect);
var
  r: TRect;
  my_offs_left, my_offs_top, my_height, my_width, my_spacing: Integer;
begin
  my_height:= (rec.Height * 100) div 150;
  my_offs_left := rec.Width div 4;
  my_offs_top := my_height div 4;
  my_height := my_height;
  my_width := my_height;
  my_spacing := my_height + 1;
  with Form1.CheckBit7 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
  my_offs_left := my_offs_left + my_spacing;
  with Form1.CheckBit6 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
  my_offs_left := my_offs_left + my_spacing;
  with Form1.CheckBit5 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
  my_offs_left := my_offs_left + my_spacing;
  with Form1.CheckBit4 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
  my_offs_left := my_offs_left + my_spacing + (my_spacing div 8);
  with Form1.CheckBit3 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
  my_offs_left := my_offs_left + my_spacing;
  with Form1.CheckBit2 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
  my_offs_left := my_offs_left + my_spacing;
  with Form1.CheckBit1 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
  my_offs_left := my_offs_left + my_spacing;
  with Form1.CheckBit0 do
  begin
    CopyRect(r, rec); // rec => r (Eck-Koordinaten an Hilfsrechteck übergeben)
    // Umrechnung der Eck-Koordinaten des Hilfsrechtecks:
    r.BottomRight := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.BottomRight));
    r.TopLeft := Parent.ScreenToClient
      (Form1.StringGrid1.ClientToScreen(r.TopLeft));
    // Positionierung der Combobox (Left, Top, Width und Height werden zugewiesen):
    SetBounds(r.Left + my_offs_left, r.Top + my_offs_top, my_width, my_height);
    Visible := true;
    BringToFront; // Combobox in Vordergrund bringen
  end;
end;
