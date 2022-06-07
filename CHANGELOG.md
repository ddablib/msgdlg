# Change Log for Message Dialogue Components

## v3.0.0 of 08 February 2014

+ Deleted the deprecated _TPJMessageDialog_ component and its associated data types. Refactored and flattened class hierarchy as a result.
+ Component help calls are now made via the _Application_ object so that help calls use whichever help system is installed for the host program.
+ Fixed 64 bit data type incompatibility that was causing the unit to fail to compile with Delphi XE2 and later.
+ Fixed problem with compiler directives in component source files that was causing compilation to fail on Delphi XE5.
+ References to unit names in the component and demo source files are now qualified with their namespaces when compiled with Delphi XE2 and later.
+ Removed component and demo project WinHelp help files.
+ Demo project heavily revised re the deletion of the _TPJMessageDialog_ component and the removal of the demo help files. The UI was also updated with a new font, scaling switched off and window location improved. Delphi 7 is now required to compile the demo.
+ License changes:
  + Component source license changed to Mozilla Public License v2.0, which has also been applied to the main documentation.
  + Demo source code and documentation placed in public domain (Creative Commons CC0 1.0 Universal).
+ Documentation revised:
  + Read-me file heavily revised re changes.
  + New read-me file describing demo program.
  + MPL license file renamed and now contains Mozilla Public License v2.0 instead of v1.1.
  + Online documentation short-cut now renamed and its URL changed.

## v2.3 of 28 August 2010

+ Added new _DlgType_ property to _TPJVCLMsgDlg_ and _TPJWinMsgDlg_ that allows button group and dialogue box type to be specified using same flags that are passed to Windows _MessageBox_ API function. ~~(Issue #9).~~
+ Added new _mkUnknown_ value to _TPJMsgDlgKind_ to handle dialogue type error conditions in _DlgType_ property.
+ Added new _ButtonGroup_ value that displays "Cancel", "Try Again" and "Continue" buttons when using _TPJWinMsgDlg_ and Windows 2000 or later.
+ Added new option to _TPJVCLMsgDlg_ that ignores help buttons when matching _Buttons_ property to _ButtonGroup_ property.
+ Modified demo program to work correctly with new _mdoGroupIgnoresHelp_ _Options_ value in _TPJVCLMsgDlg_.
+ Updated help file re changes and regenerated a-link keywords file.

## v2.2.1 of 17 August 2010

+ Fixed problems that were preventing compilation with Delphi 2010.
+ Ensured Unicode supported.
+ Switched off unsafe warnings for Delphi 7 and later.
+ Updated documentation.

## v2.2 of 31 March 2006

+ Added new _OnShow_ and _OnHide_ events to _TPJVCLMsgDlg_ that expose dialogue box's form to permit customisation.
+ Added new _TPJVCLMsgDlgFormEvent_ type for _TPJVCLMsgDlg_'s OnShow and OnHide events.
+ Added new _OnHelp_ event to _TPJVCLMsgDlg_ and _TPJWinMsgDlg_.
+ Enabled _TPJVCLMsgDlg_ to trigger help when F1 pressed.
+ Updated help file re new _TPJVCLMdgDlg_ features and added example of customising dialogue box.
+ Updated demo program to show use of new _OnHelp_ event and new _TPJVCLMsgDlg_ for customization.

## v2.1 of 28 December 2005

+ Removed separate design unit and multi-line property editor. The separate extended string property editor can now be used instead.
+ Fixed bug in later Delphis handling help button click in _TPJVCLMsgDlg_.
+ Removal of property editor means that the components will install in Delphi 2005 and later.
+ Updated help file re removal of property editor.
+ Added new a-link keyword file for use with Delphi 6/7.
+ Fixed problem displaying help in demo program in later versions of Delphi.
+ Changed to Mozilla public license v1.1.

## v2.0 of 05 October 2003

+ Added new base classes for all components.
+ Modified _TPJMessageDialog_ to descend from common base class with new _TPJWinMsgDlg_.
+ Fixed the following bugs in _TPJMessageDialog_:
  + Setting the _IconKind_ property to miUser and leaving the _IconResource_ property empty now displays `MAINICON` rather than nothing.
  + Failure to to display user icons under Win NT fixed by referencing resources in Unicode when NT used.
  + _MakeSound_ property now works for all values of _IconKind_ rather than just _miUser_.
+ Added new _TPJWinMsgDlg_ component that also wraps the Windows _MessageBoxIndirect_ call. This new component is compatible with, and has properties that are a subset of, those of _TPJVCLMsgDlg_.
+ Added new _TPJVCLMsgDlg_ component that wraps the Delphi VCL _CreateMessageDialog_ function call that is used to implement the _MessageDlgXXXX_ Delphi functions. This component permits finer control over buttons and positioning than is available from the _MessageBoxIndirect_ API call.
+ Added new design time unit for new property editor and component registration.
+ Added new property editor to permit entry of multi-line text for dialogue boxes.
+ Moved component registration to new design time unit.
+ Complete rewrite of help file adding information about new components and property editor.
+ Added demo project.

## v1.0 of 06 April 2001

+ Original version with help file and HTML documentation.
