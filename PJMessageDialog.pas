{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2001-2014, Peter Johnson (www.delphidabbler.com).
 *
 * Components that provide customisable message dialogue boxes that wrap the
 * Windows MessageBoxIndirect API call and the Delphi VCL CreateMessageDialog
 * function.
}


unit PJMessageDialog;


{$UNDEF Supports_THelpEventData}
{$UNDEF Supports_RTLNameSpaces}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 24.0} // Delphi XE3 and later
    {$LEGACYIFEND ON}  // NOTE: this must come before all $IFEND directives
  {$IFEND}
  {$IF CompilerVersion >= 23.0} // Delphi XE2 and later
    {$DEFINE Supports_THelpEventData}
    {$DEFINE Supports_RTLNameSpaces}
  {$IFEND}
  {$IF CompilerVersion >= 15.0} // Delphi 7 and later
    {$WARN UNSAFE_CAST OFF}
  {$IFEND}
{$ENDIF}


interface


uses
  // Delphi
  {$IFNDEF Supports_RTLNameSpaces}
  Classes,
  Windows,
  Controls,
  StdCtrls,
  Dialogs,
  Forms;
  {$ELSE}
  System.Classes,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Dialogs,
  Vcl.Forms;
  {$ENDIF}


const
  // Windows message dialogue flag missing from Windows unit
  {$EXTERNALSYM MB_CANCELTRYCONTINUE}
  MB_CANCELTRYCONTINUE = $00000006;

  // Flags for use with DlgType property to test for features that are not
  // supported by API constants and cannot be displayed natively by MessageBox
  // family of functions.
  UNKNOWN_BUTTONGROUP = $0000000F;
    // No API constant for button group. Test for this using
    //   if DlgType and MB_TYPEMASK = UNKNOWN_BUTTONGROUP then ...
  UNKNOWN_ICON = $000000F0;
    // No API constant for dialogue kind. Test for this using
    //   if DlgType and MB_ICONMASK = UNKNOWN_ICON then ...

type

  {
  TPJMsgDlgButtonGroup:
    Various groups of buttons that can be displayed in the message boxes
    implemented by each component in this unit.
  }
  TPJMsgDlgButtonGroup = (
    bgAbortRetryIgnore, // Abort, Retry and Ignore buttons
    bgOK,               // A single OK button
    bgOKCancel,         // OK and a Cancel buttons
    bgRetryCancel,      // Retry and Cancel buttons
    bgYesNo,            // Yes and No buttons
    bgYesNoCancel,      // Yes, No and Cancel buttons
    bgUnknown,          // An unsupported or unknown group of buttons
    bgCancelTryContinue // Cancel, Try Again and Continue buttons
                        // Same as bgAbortRetryIgnore in TPJVCLMsgDlg or
                        // in TPJWinMsgDlg on OSs that don't support it
  );

  {
  TPJMsgDlgKind:
    Kinds of dialogue boxes (icons, sounds, titles) that can be displayed by
    message dialogue components that export the Kind property. Note that the
    appearance of the icons depends on the underlying OS. For example, on
    Windows XP mkApplication and mkWinLogo display the same icon.
  }
  TPJMsgDlgKind = (     // Icon         Default Title     Sound
    mkWarning,          // warning      "Warning"         MB_ICONEXCLAMATION
    mkInformation,      // information  "Information"     MB_ICONASTERISK
    mkQuery,            // query        "Confirm"         MB_ICONQUESTION
    mkError,            // error        "Error"           MB_ICONHAND
    mkUser,             // user-defined Application.Title MB_OK
    mkApplication,      // application  Application.Title MB_OK
    mkWinLogo,          // Windows logo Application.Title MB_OK
    mkUnknown           // An unknown or unsupported dialogue type
  );

  {$IFNDEF Supports_THelpEventData}
  THelpEventData = Integer;
  {$ENDIF}

  {
  TPJMsgDlgBase:
    Abstract base class for all message box components in this unit. Provides
    a framework and common functionality and defines some abstract methods to be
    overridden by descendant classes to implement the actual dialogue box using
    different underlying APIs.
  }
  TPJMsgDlgBase = class(TComponent)
  private // property fields
    fTitle: TCaption;
    fKind: TPJMsgDlgKind;
    fText: string;
    fMakeSound: Boolean;
    fIconResource: string;
    fButtonGroup: TPJMsgDlgButtonGroup;
    fHelpContext: THelpContext;
    fHelpFile: string;
    fOnHelp: TNotifyEvent;
  protected // property methods
    procedure SetButtonGroup(const Value: TPJMsgDlgButtonGroup); virtual;
      {Virtual write access method for ButtonGroup property. Simply sets field
      value. May be overridden by descendant classes}
    function GetDlgType: LongWord; virtual;
      {Virtual read accessor for the DlgType property. Provides functionality
      common to all message boxes}
    procedure SetDlgType(const Value: LongWord); virtual;
      {Virtual write accessor for DlgType property. Provides functionality
      common to all message boxes. Value is not recorded but sets values of
      ButtonGroup and Kind properties}
  protected // properties
    property ButtonGroup: TPJMsgDlgButtonGroup
      read fButtonGroup write SetButtonGroup default bgOK;
      {Determines group of buttons displayed in dialogue box}
    property DlgType: LongWord
      read GetDlgType write SetDlgType stored False;
      {Dialogue type in terms of a bit-mask approximating to the flags passed to
      the Windows MessageBox API function to create a similar dialogue box}
    property HelpContext: THelpContext
      read fHelpContext write fHelpContext default 0;
      {ID of help topic accessed when Help button clicked or F1 pressed}
    property HelpFile: string
      read fHelpFile write fHelpFile;
      {Help file to be used to find help topic identified by HelpContext. If
      this property is '' then owner form help file is used if specified}
    property IconResource: string
      read fIconResource write fIconResource;
      {Resource ID of icon displayed when Kind = mkUser}
    property Kind: TPJMsgDlgKind
      read fKind write fKind default mkInformation;
      {Kind of dialogue box: determines the icon to be displayed, any sound
      played and the default title of the dialogue}
    property MakeSound: Boolean
      read fMakeSound write fMakeSound default False;
      {Determines whether a sound is played when the dialogue appears. Actual
      sound depends on value of Kind property}
    property Text: string
      read fText write fText;
      {Text displayed in dialogue box body}
    property Title: TCaption
      read fTitle write fTitle;
      {Text displayed in window caption. If no text is supplied a default title
      is used that depends on the Kind property}
    property OnHelp: TNotifyEvent
      read fOnHelp write fOnHelp;
      {Event triggered when dialogue box's help button is pressed. If this event
      is assigned the component's default help handling is inhibited}
  protected
    function GetDefaultTitle: string;
      {Returns default title for window based on kind of dialogue}
    function GetWindowTitle: string;
      {Returns window tile: either value of Title property or default title if
      Title is ''}
    function GetHWND: THandle;
      {Returns the window handle of the form or control (if any) that owns this
      component}
    function GetIconResourceName: PChar;
      {Returns the name of the icon resource to be displayed. The icon depends
      on the Kind property and, when Kind=mkUser, the value of the IconResource
      property}
    function GetIconResNameFromStr(const Str: string): PChar; virtual; abstract;
      {Abstract function to be overridden to return a pointer to given string
      resource name}
    function GetIconResourceInstance: THandle;
      {Returns the handle of the module which includes the icon to be displayed
      as a resource. The handle depends on the Kind property}
    function GetHelpFileName: string;
      {Returns name of help file to be used: this is HelpFile property if set,
      otherwise it is the help file associated with the parent form}
    procedure Help;
      {Displays help. If OnHelp event handler is assigned then this event is
      triggered. Otherwise the help topic specified by HelpContext property in
      required help file is displayed using Delphi's built in help system}
    function Show: Integer; virtual; abstract;
      {Abstract method to be overridden to configure and display dialogue box
      and return code representing button pressed by user}
  public
    constructor Create(AOwner: TComponent); override;
      {Constructor. Sets default property values}
    function Execute: Integer;
      {Plays any required sound then displays the message box and returns a
      value relating to the button pressed to close the dialogue box}
  end;

  {
  TPJWinMsgDlg:
    Implements a dialogue box that is created and displayed by the Windows
    MessageBoxIndirect API call. The exposed properties are a subset of those
    exposed by TPJVCLMsgDlg.
  }
  TPJWinMsgDlg = class(TPJMsgDlgBase)
  protected
    function GetDlgType: LongWord; override;
      {Override of read accessor for DlgType property. Includes MB_HELP in
      bit-mask if help button displayed}
    function Show: Integer; override;
      {Configures and displays dialogue box and returns code representing button
      pressed by user}
    function GetIconResNameFromStr(const Str: string): PChar; override;
      {Returns a pointer to given string resource name in the format expected by
      the MessageBoxIndirect API call}
  published
    { Publishing inherited protected properties }
    property ButtonGroup;
    property DlgType;
    property HelpContext;
    property HelpFile;
    property IconResource;
    property Kind;
    property MakeSound;
    property Text;
    property Title;
    property OnHelp;
  end;

  {
  TPJMsgDlgAlign:
    Permitted values for TPJVCLMsgDlg.Align property that specifies where
    dialogue is displayed.
  }
  TPJMsgDlgAlign = (
    mdaScreenCentre,  // centred on screen
    mdaScreenOffset,  // offset on screen using OffsetLeft and OffsetTop
    mdaFormCentre,    // centred on owning form
    mdaFormOffset     // offset on owning form using OffsetLeft and OffsetTop
  );

  {
  TPJMsgDlgOption:
    Permitted values for inclusion in TPJMsgDlgOptions set.
  }
  TPJMsgDlgOption = (
    mdoInhibitCancel,   // dialogue can't cancel
    mdoAutoHelpBtn,     // help button displayed if HelpContext is non zero
    mdoShowCustomIcon,  // program icon is displayed when Kind=mtCustom
    mdoGroupIgnoresHelp // help button in Buttons has no effect on ButtonGroup
  );

  {
  TPJMsgDlgOptions:
    Set of options for TPJVCLMsgDlg component.
  }
  TPJMsgDlgOptions = set of TPJMsgDlgOption;

  {
  TPJVCLMsgDlgFormEvent:
    Type of event triggered when TPJVCLMsgDlg is shown. Provides access to
    dialogue box form object.
  }
  TPJVCLMsgDlgFormEvent = procedure(Sender: TObject; Dlg: TForm) of object;

  {
  TPJVCLMsgDlg:
    Implements a customisable dialogue that is created using the VCL's
    CreateMessageDialog function. The properties of the component are a superset
    of those exposed by TPJWinMsgDlg.
  }
  TPJVCLMsgDlg = class(TPJMsgDlgBase)
  private // properties
    fButtons: TMsgDlgButtons;
    fOptions: TPJMsgDlgOptions;
    fAlign: TPJMsgDlgAlign;
    fOffsetLeft: Integer;
    fOffsetTop: Integer;
    fDefButton: TMsgDlgBtn;
    fOnHide: TPJVCLMsgDlgFormEvent;
    fOnShow: TPJVCLMsgDlgFormEvent;
    procedure SetButtons(const Value: TMsgDlgButtons);
      {Write access method for Buttons property. Records value and updates
      ButtonGroup property to appropriate matching group (if any) or bgUnknown
      if Buttons set does not correspond to any predefined group}
    procedure SetOptions(const Value: TPJMsgDlgOptions);
      {Write accessor for Options property. Updates other properties when side
      effects occur}
  protected // properties
    function GetDlgType: LongWord; override;
      {Override of read accessor for DlgType property. Includes MB_HELP in
      bit-mask if help button displayed}
    procedure SetDlgType(const Value: LongWord); override;
      {Write accessor for DlgType property. Adds support for MB_HELP which
      includes help button in Buttons property}
    procedure SetButtonGroup(const Value: TPJMsgDlgButtonGroup); override;
      {Write access method override for inherited ButtonGroup property. Records
      value (in inherited method) and updates Buttons property to store set of
      buttons in group}
  private
    fOldAppHelpHandler: THelpEvent;
      {Records reference to any existing Application.OnHelp event handler to
      enable it to be restored when dialogue box form is hidden: we replace
      Application.OnHelp with custom version for life of form dialogue}
  protected
    function Show: Integer; override;
      {Configure and display dialogue box and return code representing button
      pressed by user}
    function GetIconResNameFromStr(const Str: string): PChar; override;
      {Returns a pointer to given string resource name}
    procedure PreventCloseOnCancel(Sender: TObject; var CanClose: Boolean);
      {OnCloseQuery event handler for dialogue form used when we wish to prevent
      dialogue from being closed on pressing cancel or clicking close button on
      dialogue}
    procedure FocusDefaultButton(const Dlg: TForm);
      {Sets focus to dialogue box's default button as specified by DefButton
      property, if valid}
    procedure FormShowHandler(Sender: TObject); virtual;
      {OnShow handler for dialogue box form. Sets any required default button
      and triggers component's OnShow event, passing reference to dialogue box
      form}
    procedure FormHideHandler(Sender: TObject); virtual;
      {OnHide event handler for dialogue box form. Triggers component's OnHide
      event, passing reference to dialogue box form}
    procedure FormKeyDownHandler(Sender: TObject; var Key: Word;
      Shift: TShiftState);
      {OnKeyDown event handler for dialogue box form. Triggers help if key is F1
      and dialogue box contains a help button}
    procedure HelpClickHandler(Sender: TObject); virtual;
      {OnClick handler for Help button. Overrides VCL message box's own help
      handling to enable us to handle display of help}
    function FindHelpBtn(const Dlg: TForm): TButton;
      {Finds reference to dialogue box form's help button}
    function AppHelpHandler(Command: Word; Data: THelpEventData;
      var CallHelp: Boolean): Boolean;
      {Event handler for Application.OnHelp event that prevents default help
      system being used when dialogue's own OnHelp handler is set}
  public
    constructor Create(AOwner: TComponent); override;
      {Constructor. Sets default property values}
    function CreateDialog: TForm;
      {Creates instance of dialogue and returns it: caller is responsible for
      displaying and freeing dialogue instance}
  published
    { Publishing inherited protected properties }
    property ButtonGroup; // property interacts with new Buttons property
    property DlgType;
    property HelpContext;
    property HelpFile;
    property IconResource;
    property Kind;
    property MakeSound;
    property Text;
    property Title;
    property OnHelp;
    { New properties }
    property Align: TPJMsgDlgAlign
      read fAlign write fAlign default mdaScreenCentre;
      {Determines alignment of dialogue box in relation to owner form or screen}
    property Buttons: TMsgDlgButtons
      read fButtons write SetButtons default [mbOK];
      {Determines the buttons displayed in the dialogue box - works in
      association with ButtonGroup property - i.e. making changes to one updates
      the other}
    property DefButton: TMsgDlgBtn
      read fDefButton write fDefButton default mbOK;
      {ID of default button: if the specified button is not in buttons list then
      this setting doesn't effect default button}
    property OffsetLeft: Integer
      read fOffsetLeft write fOffsetLeft default 0;
      {Horizontal offset of dialogue box relative to screen or owner form,
      depending on Align property. Ignored if Align is mdaFormCentre or
      mdaScreenCentre}
    property OffsetTop: Integer
      read fOffsetTop write fOffsetTop default 0;
      {Vertical offset of dialogue box relative to screen or owner form,
      depending on Align property. Ignored if Align is mdaFormCentre or
      mdaScreenCentre}
    property Options: TPJMsgDlgOptions
      read fOptions write SetOptions
      default [mdoAutoHelpBtn, mdoShowCustomIcon];
      {Component options: for explanation see TPJMsgDlgOptions type definition
      above}
    property OnShow: TPJVCLMsgDlgFormEvent
      read fOnShow write fOnShow;
      {Event triggered when component's dialogue box is shown. Provides access
      to the dialogue box's form to enable dialogue to be further customised.
      Form reference is valid only until OnHide event is triggered}
    property OnHide: TPJVCLMsgDlgFormEvent
      read fOnHide write fOnHide;
      {Event triggered when component's dialogue box is hidden before being
      destroyed. Provides reference to dialogue box's form. This form reference
      is invalid after this event completes}
  end;


procedure Register;
  {Registers components}


implementation


uses
  // Delphi
  {$IFNDEF Supports_RTLNameSpaces}
  SysUtils,
  Math,
  Consts,
  ExtCtrls;
  {$ELSE}
  System.SysUtils,
  System.Math,
  Vcl.Consts,
  Vcl.ExtCtrls;
  {$ENDIF}


procedure Register;
  {Registers components}
begin
  RegisterComponents(
    'DelphiDabbler',
    [TPJWinMsgDlg, TPJVCLMsgDlg]
  );
end;

{ TPJMsgDlgBase }

constructor TPJMsgDlgBase.Create(AOwner: TComponent);
  {Class constructor. Sets default property values}
begin
  inherited;
  ButtonGroup := bgOK;
  Kind := mkInformation;
  MakeSound := False;
  HelpContext := 0;
  Title := '';
end;

function TPJMsgDlgBase.Execute: Integer;
  {Plays any required sound then displays the message box and returns a value
  relating to the button pressed to close the dialogue box}
const
  // Table mapping dialogue box kinds to API flags for sound to be played
  cSounds: array[TPJMsgDlgKind] of Integer = (
    MB_ICONEXCLAMATION, MB_ICONASTERISK, MB_ICONQUESTION, MB_ICONHAND,
    MB_OK, MB_OK, MB_OK, MB_OK);
begin
  if MakeSound then
    MessageBeep(cSounds[Kind]);
  Result := Show;
end;

function TPJMsgDlgBase.GetDefaultTitle: string;
  {Returns default title for window based on kind of dialogue}
const
  // Table mapping dialogue box kinds to default window titles
  cDefTitles: array[TPJMsgDlgKind] of string = (
    sMsgDlgWarning, sMsgDlgInformation, sMsgDlgConfirm, sMsgDlgError,
    '', '', '', '');
begin
  Result := cDefTitles[Kind];
  if Result = '' then
    Result := Application.Title;    // use application title if no default
end;

function TPJMsgDlgBase.GetDlgType: LongWord;
  {Virtual read accessor for the DlgType property. Provides functionality common
  to all message boxes}
const
  // Tables mapping TPJMsgDlgButtonGroup and TPJMsgDlgKind to API flags
  cButtonFlags: array[TPJMsgDlgButtonGroup] of LongWord = (
    MB_ABORTRETRYIGNORE, MB_OK, MB_OKCANCEL, MB_RETRYCANCEL,
    MB_YESNO, MB_YESNOCANCEL, UNKNOWN_BUTTONGROUP, MB_CANCELTRYCONTINUE
  );
  cKindFlags: array[TPJMsgDlgKind] of LongWord = (
    MB_ICONWARNING, MB_ICONINFORMATION, MB_ICONQUESTION, MB_ICONERROR,
    MB_USERICON, UNKNOWN_ICON, UNKNOWN_ICON, UNKNOWN_ICON
  );
begin
  Result := cButtonFlags[ButtonGroup] or cKindFlags[Kind];
end;

function TPJMsgDlgBase.GetHelpFileName: string;
  {Returns name of help file to be used: this is HelpFile property if set,
  otherwise it is the help file associated with the parent form}
begin
  if HelpFile <> '' then
    // we have help file specified: use it
    Result := HelpFile
  else if Assigned(Owner) and (Owner is TForm) then
    // no user-specified help file: use help file of owner form
    Result := (Owner as TForm).HelpFile;
end;

function TPJMsgDlgBase.GetHWND: THandle;
  {Returns the window handle of the form or control (if any) that owns this
  component}
begin
  if (Owner <> nil) and (Owner is TWinControl) then
    Result := (Owner as TWinControl).Handle
  else
    Result := 0;
end;

function TPJMsgDlgBase.GetIconResourceInstance: THandle;
  {Returns the handle of the module which includes the icon to be displayed as a
  resource. The handle depends on the Kind property}
begin
  if fKind = mkUser then
    // User icon must come from host program module
    Result := HInstance
  else
    // System icon required
    Result := 0;
end;

function TPJMsgDlgBase.GetIconResourceName: PChar;
  {Returns the name of the icon resource to be displayed. The icon depends on
  the Kind property and, when Kind=mkUser, the value of the IconResource
  property}
const
  // name of program icon in Delphi executable
  cMainIcon = 'MAINICON';
  // Table mapping IconKind to icon API flags
  cIcons: array[TPJMsgDlgKind] of PChar = (
    IDI_EXCLAMATION, IDI_ASTERISK, IDI_QUESTION, IDI_HAND,
    nil, IDI_APPLICATION, IDI_WINLOGO, nil
  );
begin
  // Check to see if icon resource is predefined
  Result := cIcons[Kind];
  if Result = nil then
  begin
    // Icon resource not predefined: try to get from IconResource property
    // or use default value if property not set
    if IconResource = '' then
      Result := GetIconResNameFromStr(cMainIcon)
    else
      Result := GetIconResNameFromStr(IconResource);
  end;
end;

function TPJMsgDlgBase.GetWindowTitle: string;
  {Returns window tile: either value of Title property or default title if Title
  is ''}
begin
  if Title = '' then
    Result := GetDefaultTitle
  else
    Result := Title;
end;

procedure TPJMsgDlgBase.Help;
  {Displays help. If OnHelp event handler is assigned then this event is
  triggered. Otherwise the help topic specified by HelpContext property in
  required help file is displayed using Delphi's built in help system}
var
  SavedAppHelpFile: string;
begin
  if Assigned(fOnHelp) then
    fOnHelp(Self)
  else
  begin
    SavedAppHelpFile := Application.HelpFile;
    Application.HelpFile := GetHelpFileName;
    try
      Application.HelpContext(HelpContext);
    finally
      Application.HelpFile := SavedAppHelpFile;
    end;
  end;
end;

procedure TPJMsgDlgBase.SetButtonGroup(const Value: TPJMsgDlgButtonGroup);
  {Virtual write access method for ButtonGroup property. Simply sets field
  value. May be overridden by descendant classes}
begin
  fButtonGroup := Value;
end;

procedure TPJMsgDlgBase.SetDlgType(const Value: LongWord);
  {Virtual write accessor for DlgType property. Provides functionality common to
  all message boxes. Value is not recorded but sets values of ButtonGroup and
  Kind properties}
begin
  // Set button group
  case Value and MB_TYPEMASK of
    MB_OK: ButtonGroup := bgOK;
    MB_OKCANCEL: ButtonGroup := bgOKCancel;
    MB_ABORTRETRYIGNORE: ButtonGroup := bgAbortRetryIgnore;
    MB_YESNOCANCEL: ButtonGroup := bgYesNoCancel;
    MB_YESNO: ButtonGroup := bgYesNo;
    MB_RETRYCANCEL: ButtonGroup := bgRetryCancel;
    MB_CANCELTRYCONTINUE: ButtonGroup := bgCancelTryContinue;
    else ButtonGroup := bgUnknown;
  end;
  // Set dialogue kind
  case Value and MB_ICONMASK of
    MB_ICONEXCLAMATION {= MB_ICONWARNING}: Kind := mkWarning;
    MB_ICONINFORMATION {= MB_ICONASTERISK}: Kind := mkInformation;
    MB_ICONQUESTION: Kind := mkQuery;
    MB_ICONSTOP {= MB_ICONERROR, MB_ICONHAND}: Kind := mkError;
    MB_USERICON: Kind := mkUser;
    else Kind := mkUnknown;
  end;
  // Note: MB_HELP is ignored: help handled specially and differently to API
end;

{ TPJWinMsgDlg }

procedure HelpCallback(var HelpInfo: THelpInfo); stdcall;
  {Callback procedure for Execute method procedure. Starts win help with help
  context passed in HelpInfo parameter}
var
  Cmp: TPJMsgDlgBase; // reference to component that called this callback
begin
  // Get reference to owner component
  // we've subverted dwContextId to store this reference
  Cmp := TPJMsgDlgBase(HelpInfo.dwContextId);
  // call Help method of owner object
  Cmp.Help;
end;

function TPJWinMsgDlg.GetDlgType: LongWord;
  {Override of read accessor for DlgType property. Includes MB_HELP in bit-mask
  if help button displayed}
begin
  Result := inherited GetDlgType;
  if HelpContext <> 0 then
    Result := Result or MB_HELP;
end;

function TPJWinMsgDlg.GetIconResNameFromStr(const Str: string): PChar;
  {Returns a pointer to given string resource name in the format expected by the
  MessageBoxIndirect API call}
begin
  {$IFDEF UNICODE}
  Result := PChar(Str);                   // PWideChar pointer to Unicode string
  {$ELSE}
  if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := PChar(PWChar(WideString(Str))) // PAnsiChar pointer to wide string
  else
    Result := PChar(Str);                    // PAnsiChar pointer to ANSI string
  {$ENDIF}
end;

function TPJWinMsgDlg.Show: Integer;
  {Configures and displays dialogue box and returns code representing button
  pressed by user}
const
  // Table mapping TPJMsgDlgButtonGroup to API flags
  cButtonFlags: array[TPJMsgDlgButtonGroup] of Integer = (
    MB_ABORTRETRYIGNORE, MB_OK, MB_OKCANCEL, MB_RETRYCANCEL,
    MB_YESNO, MB_YESNOCANCEL, 0, MB_CANCELTRYCONTINUE
  );
var
  MsgBoxParams: TMsgBoxParams;  // parameters passed to MessageBoxIndirect
begin
  // Set up TMsgBoxParams structure
  FillChar(MsgBoxParams, SizeOf(MsgBoxParams), 0);
  with MsgBoxParams do
  begin
    cbSize := SizeOf(TMsgBoxParams);
    hwndOwner := GetHWND;
    hInstance := GetIconResourceInstance;
    lpszIcon := GetIconResourceName;
    lpszText := PChar(Text);
    lpszCaption := PChar(GetWindowTitle);
    // Set style flags for window: mapping unsupported flags per OS
    if ((Win32Platform <> VER_PLATFORM_WIN32_NT)
      or (Win32MajorVersion < 5)) and
      (fButtonGroup = bgCancelTryContinue) then
      // CancelTryContinue requires NT system with Win 2K or later. If we don't
      // have it we use AbortRetryIgnore instead
      dwStyle := MB_ABORTRETRYIGNORE
    else
      dwStyle := cButtonFlags[fButtonGroup];
    dwStyle := dwStyle or MB_USERICON;  // always use user specified icon
    // If user supplied help context record it, set help button and callback
    if HelpContext <> 0 then
    begin
      dwStyle := dwStyle or MB_HELP;
      // We *subvert* the dwContextHelpId field to store a reference to this
      // object so we can reference it in help callback. This reference is then
      // used to call the Help method.
      dwContextHelpId := DWORD(Self);
      lpfnMsgBoxCallback := @HelpCallback;
    end;
  end;
  // Display dialogue and return result
  Result := Integer(MessageBoxIndirect(MsgBoxParams));
end;

{ TPJVCLMsgDlg }

function TPJVCLMsgDlg.AppHelpHandler(Command: Word; Data: THelpEventData;
  var CallHelp: Boolean): Boolean;
  {Event handler for Application.OnHelp event that prevents default help system
  being used when dialogue's own OnHelp handler is set}
begin
  CallHelp := not Assigned(fOnHelp);
  Result := not CallHelp;
end;

constructor TPJVCLMsgDlg.Create(AOwner: TComponent);
  {Constructor. Sets default property values}
begin
  inherited;
  fAlign := mdaScreenCentre;
  fDefButton := mbOK;
  fOffsetLeft := 0;
  fOffsetTop := 0;
  fOptions := [mdoAutoHelpBtn, mdoShowCustomIcon];
  // Note: fButtons := [mbOK] set when ButtonGroup assigned in inherited
end;

function TPJVCLMsgDlg.CreateDialog: TForm;
  {Creates instance of dialogue and returns it: caller is responsible for
  displaying and freeing dialogue instance}

  // ---------------------------------------------------------------------------
  function FindImage(const Dlg: TForm): TImage;
    {Finds reference to dialogue box form's image control}
  var
    Idx: Integer; // loops through all components on form
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

  procedure InhibitCancelButtons(const Dlg: TForm);
    {Ensures no buttons on dialogue respond to escape key press}
  var
    Idx: Integer; // loops through all components on form
  begin
    // Switch off cancel property on all buttons
    for Idx := 0 to Pred(Dlg.ComponentCount) do
      if Dlg.Components[Idx] is TButton then
        (Dlg.Components[Idx] as TButton).Cancel := False;
  end;

  procedure AlignToScreen(const Dlg: TForm; UseOffset: Boolean;
    Left, Top: Integer);
    {Aligns given dialogue box to screen. If UseOffset is true then dialogue is
    set to given Left and Top position on screen. If UseOffset is false then
    dialogue is centred on screen}
  begin
    if UseOffset then
    begin
      Dlg.Left := Max(Min(Left, Screen.Width - Dlg.Width), 0);
      Dlg.Top := Max(Min(Top, Screen.Height - Dlg.Height), 0);
    end
    else
    begin
      Dlg.Left := (Screen.Width - Dlg.Width) div 2;
      Dlg.Top := (Screen.Height - Dlg.Height) div 2;
    end;
  end;

  procedure AlignToForm(const Owner, Dlg: TForm; UseOffset: Boolean;
    Left, Top: Integer);
    {Aligns given dialogue box over given owner form. If UseOffset is true then
    dialogue is set to given Left and Top position relative to form. If
    UseOffset is false then dialogue is centred over form}
  begin
    if UseOffset then
    begin
      Dlg.Left := Max(Min(Owner.Left + Left, Screen.Width - Dlg.Width), 0);
      Dlg.Top := Max(Min(Owner.Top + Top, Screen.Height - Dlg.Height), 0);
    end
    else
    begin
      Dlg.Left := Max(
        Min(
          Owner.Left + (Owner.Width - Dlg.Width) div 2,
          Screen.Width - Dlg.Width
        ),
        0
      );
      Dlg.Top := Max(
        Min(
          Owner.Top + (Owner.Height - Dlg.Height) div 2,
          Screen.Height - Dlg.Height
        ),
        0
      );
    end;
  end;
  // ---------------------------------------------------------------------------

const
  // Maps dialogue Kind property to dialogue types
  cDlgType: array[TPJMsgDlgKind] of TMsgDlgType = (
    mtWarning,        // dialogue has warning icon
    mtInformation,    // dialogue has information icon
    mtConfirmation,   // dialogue has query icon
    mtError,          // dialogue has error icon
    mtCustom,         // dialogue has user defined icon
    mtCustom,         // dialogue has Windows application icon
    mtCustom,         // dialogue has Windows logo
    mtCustom          // dialogue has user defined icon
  );

var
  Img: TImage;            // reference to dialogue's image that contains icon
  HelpBtn: TButton;       // reference to dialogue's help button
  Btns: TMsgDlgButtons;   // set of buttons to be displayed

begin

  // Set up buttons
  Btns := fButtons;
  // remove cancel button if we're inhibiting cancellation of dialogue
  if mdoInhibitCancel in Options then
    Exclude(Btns, mbCancel);
  // add or remove help button per help context if we're auto-detecting
  if mdoAutoHelpBtn in Options then
    if HelpContext = 0 then
      Exclude(Btns, mbHelp)
    else
      Include(Btns, mbHelp);
  // check if at least one button can close dialogue: use mbOK if not
  if (Btns = []) or (Btns = [mbHelp]) then
    Include(Btns, mbOK);

  // Create dialogue of required type
  if ((Kind = mkUser) and (mdoShowCustomIcon in Options))
    or (Kind in [mkApplication, mkWinLogo]) then
  begin
    // we need to display an icon not directly supported by VCL: create dialogue
    // with kind that has icon (mtCustom doesn't) then fetch icon from resources
    // and assign to the dialogue's image component to it
    Result := CreateMessageDialog(Text, mtInformation, Btns);
    Img := FindImage(Result);
    if Assigned(Img) then
      Img.Picture.Icon.Handle := LoadIcon(
        GetIconResourceInstance,  // gets handle to module with icon resource
        GetIconResourceName       // gets pointer to icon name
      )
  end
  else
    // we create with standard icon (or no icon if mtCustom and no icon needed)
    Result := CreateMessageDialog(Text, cDlgType[Kind], Btns);

  // Set caption of dialogue if required
  Result.Caption := GetWindowTitle;

  // Set help file and context
  Result.HelpFile := GetHelpFileName;
  Result.HelpContext := HelpContext;

  // Set help button event handler if present
  if (mbHelp in Btns) then
  begin
    HelpBtn := FindHelpBtn(Result);
    if Assigned(HelpBtn) then
      HelpBtn.OnClick := HelpClickHandler;
  end;

  // Arrange dialogue per align property and whether or not we have owner
  if Assigned(Owner) and (Owner is TForm)then
  begin
    // we have owner form: act per Align property
    case Align of
      mdaScreenCentre:
        AlignToScreen(Result, False, 0, 0);
      mdaScreenOffset:
        AlignToScreen(Result, True, fOffsetLeft, fOffsetTop);
      mdaFormCentre:
        AlignToForm(Owner as TForm, Result, False, 0, 0);
      mdaFormOffset:
        AlignToForm(Owner as TForm, Result, True, fOffsetLeft, fOffsetTop);
    end;
  end
  else
  begin
    // no owner form: can only align to screen
    case Align of
      mdaScreenCentre, mdaFormCentre:
        AlignToScreen(Result, False, 0, 0);
      mdaScreenOffset, mdaFormOffset:
        AlignToScreen(Result, True, fOffsetLeft, fOffsetTop);
    end;
  end;

  // Ensure form sees key presses before controls
  Result.KeyPreview := True;

  // Set dialogue form's show / hide / key down event handlers
  Result.OnShow := FormShowHandler;
  Result.OnHide := FormHideHandler;
  Result.OnKeyDown := FormKeyDownHandler;

  // Remove ability to cancel form if required
  if mdoInhibitCancel in Options then
  begin
    Result.OnCloseQuery := PreventCloseOnCancel;
    InhibitCancelButtons(Result);
    Result.BorderIcons := Result.BorderIcons - [biSystemMenu];
  end;

end;

function TPJVCLMsgDlg.FindHelpBtn(const Dlg: TForm): TButton;
  {Finds reference to dialogue box form's help button}
var
  Idx: Integer; // loops through all components on form
begin
  Result := nil;
  for Idx := 0 to Pred(Dlg.ComponentCount) do
  begin
    if (Dlg.Components[Idx] is TButton) and
       ((Dlg.Components[Idx] as TButton).Caption = sMsgDlgHelp) then
    begin
      Result := Dlg.Components[Idx] as TButton;
      Break;
    end;
  end;
end;

procedure TPJVCLMsgDlg.FocusDefaultButton(const Dlg: TForm);
  {Sets focus to dialogue box's default button as specified by DefButton
  property, if valid}
var
  Idx: Integer; // loops through all components on form
  Btn: TButton; // reference to button on form
const
  // Captions used for buttons of various kinds. Captions from Consts.pas
  cButtonCaptions: array[TMsgDlgBtn] of string = (
    sMsgDlgYes, sMsgDlgNo, sMsgDlgOK, sMsgDlgCancel, sMsgDlgAbort,
    sMsgDlgRetry, sMsgDlgIgnore, sMsgDlgAll, sMsgDlgNoToAll, sMsgDlgYesToAll,
    sMsgDlgHelp
    {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF High(TMsgDlgBtn) > mbHelp}
    , sMsgDlgClose
    {$IFEND}
    {$ENDIF}
    );
begin
  if not (DefButton in Buttons) then
    // No valid default button specified: do nothing (this means that default
    // button is decided by VCL's CreateMessageDialog function)
    Exit;
  // Loop through all controls, searching for default button
  for Idx := 0 to Pred(Dlg.ComponentCount) do
  begin
    if Dlg.Components[Idx] is TButton then
    begin
      // We have button
      Btn := Dlg.Components[Idx] as TButton;
      if Btn.Caption = cButtonCaptions[DefButton] then
      begin
        // button is the default one: set Default property and focus it
        Btn.Default := True;
        Btn.SetFocus;
      end
      else
        // button is not default: clear its Default property
        Btn.Default := False;
    end;
  end;
end;

procedure TPJVCLMsgDlg.FormHideHandler(Sender: TObject);
  {OnHide event handler for dialogue box form. Triggers component's OnHide
  event, passing reference to dialogue box form}
begin
  // Trigger component's OnHide event
  if Assigned(fOnHide) then
    fOnHide(Self, Sender as TForm);
  // Restore any earlier application help handler
  Application.OnHelp := fOldAppHelpHandler;
  fOldAppHelpHandler := nil;
end;

procedure TPJVCLMsgDlg.FormKeyDownHandler(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  {OnKeyDown event handler for dialogue box form. Triggers help if key is F1 and
  dialogue box contains a help button}
begin
  if (Key = VK_F1) and (Shift = []) then
  begin
    Key := 0;
    if FindHelpBtn(Sender as TForm) <> nil then
      Help;
  end;
end;

procedure TPJVCLMsgDlg.FormShowHandler(Sender: TObject);
  {OnShow handler for dialogue box form. Sets any required default button and
  triggers component's OnShow event, passing reference to dialogue box form}
begin
  // Disable application's default help processing: required for later Delphis
  // we use our own help event handler (restored when form hidden)
  fOldAppHelpHandler := Application.OnHelp;
  Application.OnHelp := AppHelpHandler;
  // Set required default button
  FocusDefaultButton(Sender as TForm);
  // Trigger component's OnShow event
  if Assigned(fOnShow) then
    fOnShow(Self, Sender as TForm);
end;

function TPJVCLMsgDlg.GetDlgType: LongWord;
  {Override of read accessor for DlgType property. Includes MB_HELP in bit-mask
  if help button displayed}
begin
  Result := inherited GetDlgType;
  if mdoAutoHelpBtn in Options then
  begin
    if HelpContext <> 0 then
      Result := Result or MB_HELP
    else
      Result := Result and not MB_HELP;
  end
  else
  begin
    if mbHelp in Buttons then
      Result := Result or MB_HELP
    else
      Result := Result and not MB_HELP;
  end;
end;

function TPJVCLMsgDlg.GetIconResNameFromStr(const Str: string): PChar;
  {Returns a pointer to given string resource name}
begin
  Result := PChar(Str);
end;

procedure TPJVCLMsgDlg.HelpClickHandler(Sender: TObject);
  {OnClick handler for Help button. Overrides VCL message box's own help
  handling to enable us to handle display of help}
begin
  // Call inherited Help method: we don't want default VCL message box help
  // handling since this causes exception in some Delphis
  Help;
end;

procedure TPJVCLMsgDlg.PreventCloseOnCancel(Sender: TObject;
  var CanClose: Boolean);
  {OnCloseQuery event handler for dialogue form used when we wish to prevent
  dialogue from being closed on pressing cancel or clicking close button on
  dialogue}
begin
  case (Sender as TForm).ModalResult of
    mrCancel: CanClose := False;
    else CanClose := True;
  end;
end;

procedure TPJVCLMsgDlg.SetButtonGroup(const Value: TPJMsgDlgButtonGroup);
  {Write access method override for inherited ButtonGroup property. Records
  value (in inherited method) and updates Buttons property to store set of
  buttons in group}
begin
  inherited;
  case Value of
    bgAbortRetryIgnore, bgCancelTryContinue:
      fButtons := [mbAbort, mbRetry, mbIgnore];
    bgOK:
      fButtons := [mbOK];
    bgOKCancel:
      fButtons := [mbOK, mbCancel];
    bgRetryCancel:
      fButtons := [mbRetry, mbCancel];
    bgYesNo:
      fButtons := [mbYes, mbNo];
    bgYesNoCancel:
      fButtons := [mbYes, mbNo, mbCancel];
    bgUnknown:
      fButtons := [];
  end;
end;

procedure TPJVCLMsgDlg.SetButtons(const Value: TMsgDlgButtons);
  {Write access method for Buttons property. Records value and updates
  ButtonGroup property to appropriate matching group (if any) or bgUnknown if
  Buttons set does not correspond to any predefined group}

  // ---------------------------------------------------------------------------
  function CheckValidButtonGroup(const Btns: TMsgDlgButtons): Boolean;
    {Checks buttons specified by Value form a recognised button group}
  begin
    if mdoGroupIgnoresHelp in Options then
      // group can optionally include help button
      Result := (Value = Btns) or (Value = Btns + [mbHelp])
    else
      // must be an exact match to group
      Result := Value = Btns;
  end;
  // ---------------------------------------------------------------------------

begin
  fButtons := Value;
  if CheckValidButtonGroup([mbAbort, mbRetry, mbIgnore]) then
    fButtonGroup := bgAbortRetryIgnore
  else if CheckValidButtonGroup([mbOK]) then
    fButtonGroup := bgOK
  else if CheckValidButtonGroup([mbOK, mbCancel]) then
    fButtonGroup := bgOKCancel
  else if CheckValidButtonGroup([mbRetry, mbCancel]) then
    fButtonGroup := bgRetryCancel
  else if CheckValidButtonGroup([mbYes, mbNo]) then
    fButtonGroup := bgYesNo
  else if CheckValidButtonGroup([mbYes, mbNo, mbCancel]) then
    fButtonGroup := bgYesNoCancel
  else if CheckValidButtonGroup([mbYes, mbNo, mbCancel]) then
    fButtonGroup := bgYesNoCancel
  else
    fButtonGroup := bgUnknown;
end;

procedure TPJVCLMsgDlg.SetDlgType(const Value: LongWord);
  {Write accessor for DlgType property. Adds support for MB_HELP which includes
  help button in Buttons property}
begin
  inherited;
  if Value and MB_HELP = MB_HELP then
    Buttons := Buttons + [mbHelp];
end;

procedure TPJVCLMsgDlg.SetOptions(const Value: TPJMsgDlgOptions);
  {Write accessor for Options property. Updates other properties when side
  effects occur}
var
  GroupIgnoresHelpChanged: Boolean; // whether named flag changes in Options
begin
  GroupIgnoresHelpChanged := (mdoGroupIgnoresHelp in (fOptions - Value))
    or (mdoGroupIgnoresHelp in (Value - fOptions));
  fOptions := Value;
  if GroupIgnoresHelpChanged then
    SetButtons(Buttons);  // causes ButtonGroup to update
end;

function TPJVCLMsgDlg.Show: Integer;
  {Configure and display dialogue box and return code representing button
  pressed by user}
begin
  with CreateDialog do
    try
      Result := ShowModal;
    finally
      Free;
    end;
end;

end.

