{
 * Main form file for DelphiDabbler Message Dialogue Components demo program.
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
}

unit FmPJMessageDialogDemo;

{$UNDEF Supports_RTLNameSpaces}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 24.0} // Delphi XE3 and later
    {$LEGACYIFEND ON}  // NOTE: this must come before all $IFEND directives
  {$IFEND}
  {$IF CompilerVersion >= 23.0} // Delphi XE2 and later
    {$DEFINE Supports_RTLNameSpaces}
  {$IFEND}
{$ENDIF}

interface

uses
  // Delphi
  {$IFNDEF Supports_RTLNameSpaces}
  Classes,
  Dialogs,
  StdCtrls,
  Controls,
  CheckLst,
  ExtCtrls,
  ComCtrls,
  Forms,
  {$ELSE}
  System.Classes,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.CheckLst,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Forms,
  {$ENDIF}
  PJMessageDialog;

type
  TDemoForm = class(TForm)
    dlgWinMsg: TPJWinMsgDlg;
    dlgVCLMsg: TPJVCLMsgDlg;
    tabCtrl: TTabControl;
    lblAlign: TLabel;
    cbAlign: TComboBox;
    lblOffsetLeft: TLabel;
    edOffsetLeft: TEdit;
    lblOffsetTop: TLabel;
    edOffsetTop: TEdit;
    btnExecute: TButton;
    lblButtonGroup: TLabel;
    cbButtonGroup: TComboBox;
    lblButtons: TLabel;
    lbButtons: TCheckListBox;
    dlgVCLDummy: TPJVCLMsgDlg;
    lblDefButton: TLabel;
    cbDefButton: TComboBox;
    lblHelpContext: TLabel;
    lblHelpFile: TLabel;
    btnHelpFile: TButton;
    dlgHelpFile: TOpenDialog;
    lblIconResource: TLabel;
    cbIconResource: TComboBox;
    lblKind: TLabel;
    cbKind: TComboBox;
    chkMakeSound: TCheckBox;
    lblMakeSound: TLabel;
    lblOptions: TLabel;
    lbOptions: TCheckListBox;
    lblText: TLabel;
    edText: TMemo;
    lblTitle: TLabel;
    edTitle: TEdit;
    bvlVertical: TBevel;
    chkHelpEvent: TCheckBox;
    chkCustomise: TCheckBox;
    edHelpContext: TEdit;
    edHelpFile: TEdit;
    procedure edNumKeyPress(Sender: TObject; var Key: Char);
    procedure tabCtrlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbButtonGroupChange(Sender: TObject);
    procedure lbButtonsClickCheck(Sender: TObject);
    procedure btnHelpFileClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure lbOptionsClickCheck(Sender: TObject);
  private
    fOldKeyDownEvent: TMethod;
    procedure UpdateControls;
    procedure HelpEventHandler(Sender: TObject);
    procedure ShowEventHandler(Sender: TObject; Dlg: TForm);
    procedure HideEventHandler(Sender: TObject; Dlg: TForm);
    procedure CustomKeyDownHandler(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UpdateOptions;
  end;

var
  DemoForm: TDemoForm;

implementation

uses
  {$IFNDEF Supports_RTLNameSpaces}
  SysUtils,
  TypInfo,
  Windows;
  {$ELSE}
  System.SysUtils,
  System.TypInfo,
  System.UITypes,
  Winapi.Windows;
  {$ENDIF}

{$R *.DFM}

const
  cPJWinMsgDlgId = 0;
  cPJVCLMsgDlgId = 1;

  cCmpNames: array[0..1] of string = (
    'TPJWinMsgDlg', 'TPJVCLMsgDlg'
  );

function SLObjToIdx(SL: TStrings; Obj: TObject): Integer;
  // Returns index of first item in given string list that has given object in
  // Objects[] property.
var
  Idx: Integer;
begin
  Result := -1;
  for Idx := 0 to Pred(SL.Count) do
    if Obj = SL.Objects[Idx] then
    begin
      Result := Idx;
      Break;
    end;
end;


procedure TDemoForm.edNumKeyPress(Sender: TObject; var Key: Char);
  // Prevents non-numeric entry into edit boxes used to enter numbers
begin
  {$IFDEF UNICODE}
  if not CharInSet(Key, ['0'..'9', #8]) then
    Key := #0;
  {$ELSE}
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
  {$ENDIF}
end;

procedure TDemoForm.tabCtrlChange(Sender: TObject);
begin
  UpdateControls;
end;

procedure TDemoForm.UpdateControls;
var
  TabIdx: Integer;
  TI: PTypeInfo;
  TD: PTypeData;
  Idx: Integer;
begin
  TabIdx := tabCtrl.TabIndex;
  btnExecute.Tag := TabIdx;

  // Common property set up
  // ButtonGroup
  cbButtonGroup.Clear;
  TI := TypeInfo(TPJMsgDlgButtonGroup);
  TD := GetTypeData(TI);
  for Idx := TD.MinValue to TD.MaxValue do
    cbButtonGroup.Items.AddObject(GetEnumName(TI, Idx), Pointer(Idx));

  // IconResource
  cbIconResource.ItemIndex := 0;

  // Variable property set up and common property values
  case TabIdx of
    cPJVCLMsgDlgId:
    begin
      // Align property
      lblAlign.Enabled := True;
      cbAlign.Enabled := True;
      cbAlign.Clear;
      TI := TypeInfo(TPJMsgDlgAlign);
      TD := GetTypeData(TI);
      for Idx := TD.MinValue to TD.MaxValue do
        cbAlign.Items.AddObject(GetEnumName(TI, Idx), Pointer(Idx));
      cbAlign.ItemIndex := SLObjToIdx(
        cbAlign.Items, Pointer(dlgVCLMsg.Align)
      );

      // ButtonGroup property
      cbButtonGroup.ItemIndex := SLObjToIdx(
        cbButtonGroup.Items, Pointer(dlgVCLMsg.ButtonGroup)
      );

      // Buttons property
      lblButtons.Enabled := True;
      lbButtons.Enabled := True;
      lbButtons.Clear;
      TI := TypeInfo(TMsgDlgBtn);
      TD := GetTypeData(TI);
      for Idx := TD.MinValue to TD.MaxValue do
      begin
        lbButtons.Items.AddObject(GetEnumName(TI, Idx), Pointer(Idx));
        if (TMsgDlgBtn(Idx) in dlgVCLMsg.Buttons) then
          lbButtons.Checked[Idx] := True;
      end;

      // DefButton property
      lblDefButton.Enabled := True;
      cbDefButton.Enabled := True;
      cbDefButton.Clear;
      TI := TypeInfo(TMsgDlgBtn);
      TD := GetTypeData(TI);
      for Idx := TD.MinValue to TD.MaxValue do
        cbDefButton.Items.AddObject(GetEnumName(TI, Idx), Pointer(Idx));
      cbDefButton.ItemIndex :=
        SLObjToIdx(cbDefButton.Items, Pointer(dlgVCLMsg.DefButton));

      // HelpContext property
      edHelpContext.Text := IntToStr(dlgVCLMsg.HelpContext);

      // HelpFile property
      edHelpFile.Text := dlgVCLMsg.HelpFile;

      // OnHelp event
      chkHelpEvent.Enabled := True;

      // IconResource property
      if dlgVCLMsg.IconResource <> '' then
        cbIconResource.ItemIndex :=
          cbIconResource.Items.IndexOf(dlgVCLMsg.IconResource);

      // Kind property
      lblKind.Enabled := True;
      cbKind.Enabled := True;
      cbKind.Clear;
      TI := TypeInfo(TPJMsgDlgKind);
      TD := GetTypeData(TI);
      for Idx := TD.MinValue to TD.MaxValue do
        cbKind.Items.AddObject(GetEnumName(TI, Idx), Pointer(Idx));
      cbKind.ItemIndex := SLObjToIdx(cbKind.Items, Pointer(dlgVCLMsg.Kind));

      // MakeSound property
      chkMakeSound.Checked := dlgVCLMsg.MakeSound;

      // OffsetLeft property
      lblOffsetLeft.Enabled := True;
      edOffsetLeft.Enabled := True;
      edOffsetLeft.Text := IntToStr(dlgVCLMsg.OffsetLeft);

      // OffsetTop property
      lblOffsetTop.Enabled := True;
      edOffsetTop.Enabled := True;
      edOffsetTop.Text := IntToStr(dlgVCLMsg.OffsetLeft);

      // Options property
      lblOptions.Enabled := True;
      lbOptions.Enabled := True;
      lbOptions.Clear;
      TI := TypeInfo(TPJMsgDlgOption);
      TD := GetTypeData(TI);
      for Idx := TD.MinValue to TD.MaxValue do
      begin
        lbOptions.Items.AddObject(GetEnumName(TI, Idx), Pointer(Idx));
        if (TPJMsgDlgOption(Idx) in dlgVCLMsg.Options) then
          lbOptions.Checked[Idx] := True;
      end;

      // Text property
      edText.Text := dlgVCLMsg.Text;

      // Title property
      edTitle.Text := dlgVCLMsg.Title;

      // OnShow and OnHide events
      chkCustomise.Enabled := True;

    end;

    cPJWinMsgDlgId:
    begin
      // Align property not supported
      lblAlign.Enabled := False;
      cbAlign.Enabled := False;
      cbAlign.Clear;

      // ButtonGroup property
      cbButtonGroup.ItemIndex := SLObjToIdx(
        cbButtonGroup.Items, Pointer(dlgWinMsg.ButtonGroup)
      );

      // Buttons property
      lblButtons.Enabled := False;
      lbButtons.Enabled := False;
      lbButtons.Clear;

      // DefButton property
      lblDefButton.Enabled := False;
      cbDefButton.Enabled := False;
      cbDefButton.Clear;

      // HelpContext property
      edHelpContext.Text := IntToStr(dlgWinMsg.HelpContext);

      // HelpFile property
      edHelpFile.Text := dlgWinMsg.HelpFile;

      // OnHelp event
      chkHelpEvent.Enabled := True;

      // IconResource property
      if dlgWinMsg.IconResource <> '' then
        cbIconResource.ItemIndex :=
          cbIconResource.Items.IndexOf(dlgWinMsg.IconResource);

      // Kind property
      lblKind.Enabled := True;
      cbKind.Enabled := True;
      cbKind.Clear;
      TI := TypeInfo(TPJMsgDlgKind);
      TD := GetTypeData(TI);
      for Idx := TD.MinValue to TD.MaxValue do
        cbKind.Items.AddObject(GetEnumName(TI, Idx), Pointer(Idx));
      cbKind.ItemIndex := SLObjToIdx(cbKind.Items, Pointer(dlgWinMsg.Kind));

      // MakeSound property
      chkMakeSound.Checked := dlgWinMsg.MakeSound;

      // OffsetLeft property not supported
      lblOffsetLeft.Enabled := False;
      edOffsetLeft.Enabled := False;
      edOffsetLeft.Text := '';

      // OffsetTop property not supported
      lblOffsetTop.Enabled := False;
      edOffsetTop.Enabled := False;
      edOffsetTop.Text := '';

      // Options property
      lblOptions.Enabled := False;
      lbOptions.Enabled := False;
      lbOptions.Clear;

      // Text property
      edText.Text := dlgWinMsg.Text;

      // Title property
      edTitle.Text := dlgWinMsg.Title;

      // OnShow and OnHide events
      chkCustomise.Enabled := False;

    end;

  end;

end;

procedure TDemoForm.UpdateOptions;
var
  Idx: Integer;
begin
  for Idx := 0 to Pred(lbOptions.Items.Count) do
    if lbOptions.Checked[Idx] then
      dlgVCLDummy.Options := dlgVCLDummy.Options + [TPJMsgDlgOption(Idx)]
    else
      dlgVCLDummy.Options := dlgVCLDummy.Options - [TPJMsgDlgOption(Idx)];
end;

procedure TDemoForm.FormCreate(Sender: TObject);
begin
  UpdateControls;
end;

procedure TDemoForm.cbButtonGroupChange(Sender: TObject);
var
  TI: PTypeInfo;
  TD: PTypeData;
  Idx: Integer;
begin
  UpdateOptions;
  if tabCtrl.TabIndex = cPJVCLMsgDlgId then
  begin
    dlgVCLDummy.ButtonGroup :=
      TPJMsgDlgButtonGroup(
        cbButtonGroup.Items.Objects[cbButtonGroup.ItemIndex]
      );
    TI := TypeInfo(TMsgDlgBtn);
    TD := GetTypeData(TI);
    for Idx := TD.MinValue to TD.MaxValue do
    begin
      if (TMsgDlgBtn(Idx) in dlgVCLDummy.Buttons) then
        lbButtons.Checked[Idx] := True
      else
        lbButtons.Checked[Idx] := False;
    end;
  end;
end;

procedure TDemoForm.lbButtonsClickCheck(Sender: TObject);
var
  Idx: Integer;
begin
  UpdateOptions;
  if tabCtrl.TabIndex = cPJVCLMsgDlgId then
  begin
    dlgVCLDummy.Buttons := [];
    for Idx := 0 to Pred(lbButtons.Items.Count) do
      if lbButtons.Checked[Idx] then
        dlgVCLDummy.Buttons := dlgVCLDummy.Buttons + [TMsgDlgBtn(Idx)];
    cbButtonGroup.ItemIndex := SLObjToIdx(
      cbButtonGroup.Items, Pointer(dlgVCLDummy.ButtonGroup)
    );
  end;
end;

procedure TDemoForm.lbOptionsClickCheck(Sender: TObject);
begin
  lbButtonsClickCheck(lbButtons);
end;

procedure TDemoForm.btnHelpFileClick(Sender: TObject);
  // Display file open dialog and copy input into text field.
begin
  dlgHelpFile.FileName := edHelpFile.Text;
  if dlgHelpFile.Execute then
    edHelpFile.Text := dlgHelpFile.FileName;
end;

procedure TDemoForm.btnExecuteClick(Sender: TObject);
var
  Idx: Integer;
begin
  case btnExecute.Tag of
    cPJVCLMsgDlgId:
    begin
      dlgVCLMsg.Align := TPJMsgDlgAlign(
        cbAlign.Items.Objects[cbAlign.ItemIndex]
      );
      dlgVCLMsg.ButtonGroup := TPJMsgDlgButtonGroup(
        cbButtonGroup.Items.Objects[cbButtonGroup.ItemIndex]
      );
      for Idx := 0 to Pred(lbButtons.Items.Count) do
        if lbButtons.Checked[Idx] then
          dlgVCLMsg.Buttons := dlgVCLMsg.Buttons + [TMsgDlgBtn(Idx)]
        else
          dlgVCLMsg.Buttons := dlgVCLMsg.Buttons - [TMsgDlgBtn(Idx)];
      dlgVCLMsg.DefButton := TMsgDlgBtn(
        cbDefButton.Items.Objects[cbDefButton.ItemIndex]
      );
      dlgVCLMsg.HelpContext := StrToIntDef(edHelpContext.Text, 0);
      if (edHelpFile.Text <> '')
        and (ExtractFileName(edHelpFile.Text) = edHelpFile.Text) then
        dlgVCLMsg.HelpFile := ExtractFilePath(ParamStr(0)) + edHelpFile.Text
      else
        dlgVCLMsg.HelpFile := edHelpFile.Text;
      if chkHelpEvent.Checked then
        dlgVCLMsg.OnHelp := HelpEventHandler
      else
        dlgVCLMsg.OnHelp := nil;
      if cbIconResource.ItemIndex = 0 then
        dlgVCLMsg.IconResource := ''
      else
        dlgVCLMsg.IconResource := cbIconResource.Text;
      dlgVCLMsg.Kind := TPJMsgDlgKind(
        cbKind.Items.Objects[cbKind.ItemIndex]
      );
      dlgVCLMsg.MakeSound := chkMakeSound.Checked;
      dlgVCLMsg.OffsetLeft := StrToIntDef(edOffsetLeft.Text, 0);
      dlgVCLMsg.OffsetTop := StrToIntDef(edOffsetTop.Text, 0);
      for Idx := 0 to Pred(lbOptions.Items.Count) do
        if lbOptions.Checked[Idx] then
          dlgVCLMsg.Options := dlgVCLMsg.Options + [TPJMsgDlgOption(Idx)]
        else
          dlgVCLMsg.Options := dlgVCLMsg.Options - [TPJMsgDlgOption(Idx)];
      dlgVCLMsg.Text := edText.Text;
      dlgVCLMsg.Title := edTitle.Text;
      if chkCustomise.Checked then
      begin
        dlgVCLMsg.OnShow := ShowEventHandler;
        dlgVCLMsg.OnHide := HideEventHandler;
      end
      else
      begin
        dlgVCLMsg.OnShow := nil;
        dlgVCLMsg.OnHide := nil;
      end;
      dlgVCLMsg.Execute;
    end;
    cPJWinMsgDlgId:
    begin
      dlgWinMsg.ButtonGroup := TPJMsgDlgButtonGroup(
        cbButtonGroup.Items.Objects[cbButtonGroup.ItemIndex]
      );
      dlgWinMsg.HelpContext := StrToIntDef(edHelpContext.Text, 0);
      if (edHelpFile.Text <> '')
        and (ExtractFileName(edHelpFile.Text) = edHelpFile.Text) then
        dlgWinMsg.HelpFile := ExtractFilePath(ParamStr(0)) + edHelpFile.Text
      else
        dlgWinMsg.HelpFile := edHelpFile.Text;
      if chkHelpEvent.Checked then
        dlgWinMsg.OnHelp := HelpEventHandler
      else
        dlgWinMsg.OnHelp := nil;
      if cbIconResource.ItemIndex = 0 then
        dlgWinMsg.IconResource := ''
      else
        dlgWinMsg.IconResource := cbIconResource.Text;
      dlgWinMsg.Kind := TPJMsgDlgKind(
        cbKind.Items.Objects[cbKind.ItemIndex]
      );
      dlgWinMsg.MakeSound := chkMakeSound.Checked;
      dlgWinMsg.Text := edText.Text;
      dlgWinMsg.Title := edTitle.Text;
      dlgWinMsg.Execute;
    end;
  end;
end;

procedure TDemoForm.HelpEventHandler(Sender: TObject);
  {Custom help handling for component: just display message}
begin
  MessageDlg(
    Format(
      'Help requested:'#10'Help file: "%s"'#10'Context: %s',
      [edHelpFile.Text, edHelpContext.Text]
    ),
    mtInformation,
    [mbOK],
    0
  );
end;

{
  The following code customises TPJVCLMsgDlg as follows:
    1) A check box is placed at the bottom of the dialog
    2) The dialog is grown in height to accomodate it
    3) Ctrl+F2 can be used to toggle the check box's state
    4) A dialog box showing the check state is displayed when the dialog is
       closed

  We use three methods to do this:
    1) ShowEventHandler handles the component's OnShow event to set up the
       customisation.
    2) HideEventHandler handles the component's OnHide event to display the
       check box state when the dialog is closed
    3) CustomKeyDownHandler replaces the dialog form's own OnKeyDown event
       handler to trap the Ctrl+F2 key press. This event handler also calls the
       OnKeyDown event handler of the dialog form that it replaced. If we didn't
       call this we would loose the dialog's ability to display help when the F1
       key is pressed.

  We also use a field, fOldKeyDownEvent, of type TMethod, to store a reference
  to the dialog form's old OnKeyDown event.
}

procedure TDemoForm.ShowEventHandler(Sender: TObject; Dlg: TForm);
  {Customised dialog to have check box below buttons}

  function FindImage: TImage;
    {Finds dialog's image control: we align check box with this}
  var
    Idx: Integer;
  begin
    Result := nil;
    for Idx := 0 to Pred(Dlg.ComponentCount) do
    begin
      if Dlg.Components[Idx] is TImage then
      begin
        Result := Dlg.Components[Idx] as TImage;
        Break;
      end;
    end;
  end;

var
  CB: TCheckBox;
  Img: TImage;
begin
  // Create check box on dialog box
  CB := TCheckBox.Create(Dlg);
  CB.Parent := Dlg;
  CB.Caption := 'Check this?';
  CB.Checked := False;
  // Name check box - we use this name in the OnHide event handler
  CB.Name := 'chkCustom';
  // Align left edge of checkbox with form's image
  Img := FindImage;
  if Assigned(Img) then
    CB.Left := Img.Left
  else
    CB.Left := 8;
  // Increase height of dialog and place check box at bottom below buttons
  Dlg.ClientHeight := Dlg.ClientHeight + CB.Height;
  CB.Top := Dlg.ClientHeight - CB.Height - 4;
  // Record dialog form's old OnKeyDown event handler and replace with new one
  fOldKeyDownEvent := TMethod(Dlg.OnKeyDown);
  Dlg.OnKeyDown := CustomKeyDownHandler;
end;

procedure TDemoForm.HideEventHandler(Sender: TObject; Dlg: TForm);
  {Handle closing of dialog box: check if custom check box placed in dialog by
  OnShow handler is check or not}
var
  CB: TCheckBox;
begin
  // Replace the old OnKeyDown event handler for tidyness sake
  Dlg.OnKeyDown := TKeyEvent(fOldKeyDownEvent);
  // Find check box by name: error if we can't find it
  CB := Dlg.FindComponent('chkCustom') as TCheckBox;
  if not Assigned(CB) then
    raise Exception.Create('Can''t find check box added in OnShow handler');
  // Display state of check box
  if CB.Checked then
    MessageDlg('Check box is CHECKED', mtInformation, [mbOK], 0)
  else
    MessageDlg('Check box is CLEAR', mtInformation, [mbOK], 0);
end;

procedure TDemoForm.CustomKeyDownHandler(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CB: TCheckBox;
  Dlg: TForm;
begin
  // Check for original OnKeyDown event and call it if present
  if Assigned(fOldKeyDownEvent.Code) then
    TKeyEvent(fOldKeyDownEvent)(Sender, Key, Shift);
  // Now check for Ctrl+F2 and find and toggle check box if present
  // Note that dialog box form is passed as Sender parameter since this is an
  // event of the dialog form, not of the TPJVCLMsgDlg component
  if (ssCtrl in Shift) and (Key = VK_F2) then
  begin
    Dlg := Sender as TForm;
    CB := Dlg.FindComponent('chkCustom') as TCheckBox;
    if not Assigned(CB) then
      raise Exception.Create(
        'Can''t find check box added in CustomKeyDownHandler handler'
      );
    CB.Checked := not CB.Checked;
  end;
end;

end.
