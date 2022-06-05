# Message Dialogue Components

## Description

This unit implements two customisable message dialogue box components. They are:

* _TPJWinMsgDlg_ - This component wraps the Windows _MessageBoxIndirect_ API call and displays a message box based on that provided by Windows. It will be suitable for most purposes and has the lighter footprint.
* _TPJVCLMsgDlg_ - This component uses the Delphi VCL _CreateMessageDialog_ function to create a form based message box. (_CreateMessageDialog_ is used by the standard Delphi _MessageDlgXXX_ functions). The component provides more flexibility than either the Delphi functions or _TPJWinMsgDlg_. It should be used when it is necessary to display buttons or combinations of buttons that are not supported by the Windows API message box or when a finer degree of control over the appearance and behaviour of the message box is required. _TPJVCLMsgDlg_ supports all the features of _TPJWinMsgDlg_ and extends them. The dialogue box component's form can be customised by handling the _OnShow_ and _OnHide_ events.

For full details please see the [online documentation](https://delphidabbler.com/url/msgdlg-docs).

## Compatibility

The components have been tested with the 32-bit Windows compiler of Delphi 7 and Delphi 2006 to XE4 and the the 64-bit Windows compiler of Delphi XE2 to XE4. They are believed to compile with any version of Delphi from Delphi 4 onwards but this has not been tested.

The unit has dependencies on the VCL and therefore cannot be used with the FireMonkey framework or with non-Windows targets.

## Installation

The Message Dialogue Components and their associated files are supplied in a zip file. Before installing you need to extract all the files from the zip file, preserving the directory structure. The following files will be extracted:

* **`PJMessageDialog.pas`** – component source code.
* **`PJMessageDialog.dcr`** – component palette glyphs.
* `README.md` – this file.
* `CHANGELOG.md` – project change log.
* `MPL-2.txt` – the Mozilla Public License v2.0.
* `Documentation.url` – short-cut to the components' online documentation.

In addition to the above files you will find the source code of a [demo project](#demo-program) in the `Demo` sub-directory.

You can now install the components into the Delphi IDE. To do this, the files `PJMessageDialog.pas` and `PJMessageDialog.dcr` should be added to a design time package. If you need help doing this [see here](https://delphidabbler.com/url/install-comp).

## Demo Program

A demo program that exercises the components is included in the download.

This demo requires Delphi 7 as a minimum.

For more information about the demo see the file [`ReadMe.txt`](https://raw.githubusercontent.com/ddablib/msgdlg/main/Demo/ReadMe.txt) in the `Demo` directory.

## Update History

A complete change log is provided in [`CHANGELOG.md`](https://github.com/ddablib/msgdlg/blob/main/CHANGELOG.md) that is included in the download.

## License

The _Message Dialogue Components_ are released under the terms of the [Mozilla Public License v2.0](https://www.mozilla.org/MPL/2.0/).

All relevant trademarks are acknowledged.

## Bugs and Feature Requests

Bugs can be reported or new features requested via the project's [Issue Tracker](https://github.com/ddablib/msgdlg/issues). A GitHub account is required.

Please check if an issue has already been created for a similar report or request. If so then please add a comment containing as much information as you can to the existing issue, or if you've nothing to add, just add a :+1: (`:+1:`) comment. If there is no suitable existing issue then please add a new issue and give as much information as possible.

## About the Author

I'm Peter Johnson – a hobbyist programmer living in Ceredigion in West Wales, UK, writing mainly in Delphi. My programs and other library code are available from: [https://delphidabbler.com/](https://delphidabbler.com/).

This document is copyright © 2005-2022, [P D Johnson](https://gravatar.com/delphidabbler).
