import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'ui_win32_demo_base.dart';

class RichEdit extends Window {
  static final bool richEditLoaded = WindowClass.loadRichEditLibrary();

  static final textOutputWindowClass = WindowClass.predefined(
    className: 'edit',
    bgColor: RGB(128, 128, 128),
  );

  static final textOutputWindowClassRich = WindowClass.predefined(
    className: 'RichEdit',
    bgColor: RGB(128, 128, 128),
  );

  static final int WM_USER = 1024;
  static final int EM_SETBKGNDCOLOR = WM_USER + 67;
  static final int EM_AUTOURLDETECT = WM_USER + 91;
  static final int EM_GETCHARFORMAT = WM_USER + 58;
  static final int EM_SETCHARFORMAT = WM_USER + 68;
  static final int CFM_COLOR = 0x40000000;

  static const int SCF_DEFAULT = 0x0000;
  static final int SCF_ALL = 0x0004;

  RichEdit({super.parentHwnd})
      : super(
          windowClass: richEditLoaded
              ? textOutputWindowClassRich
              : textOutputWindowClass,
          windowStyles: WS_CHILD |
              ES_READONLY |
              WS_VISIBLE |
              WS_HSCROLL |
              WS_VSCROLL |
              WS_BORDER |
              ES_LEFT |
              ES_MULTILINE |
              ES_NOHIDESEL |
              ES_AUTOHSCROLL |
              ES_AUTOVSCROLL,
          x: 4,
          y: 360,
          width: 626,
          height: 90,
        );

  @override
  void build(int hwnd, int hdc) {
    super.build(hwnd, hdc);

    SetTextColor(hdc, RGB(255, 255, 255));
    SetBkColor(hdc, RGB(42, 40, 38));

    setBkColor(hwnd, RGB(42, 40, 38));
    setAutoURLDetect(hwnd, true);
  }

  @override
  void repaint(int hwnd, int hdc) {
    SetTextColor(hdc, RGB(255, 0, 0)); // red

    setBkColor(hwnd, RGB(42, 40, 38));
    setAutoURLDetect(hwnd, true);

    /*
    SetWindowText(
        hwnd,
        TEXT(
            "Hello\r\nWorld!!!\r\n-------------------\r\n Bla bla bla: http://www.google.com/\r\n"));
     */

    SetWindowText(hwnd, TEXT("Hello\r\nWorld!!!\r\n"));

    appendText(hwnd, RGB(255,0,0), "Colored Text?".toNativeUtf16());
  }

  int setBkColor(int hwnd, int color) =>
      SendMessage(hwnd, EM_SETBKGNDCOLOR, 0, color);

  int setAutoURLDetect(int hwnd, bool autoDetect) =>
      SendMessage(hwnd, EM_AUTOURLDETECT, autoDetect ? 1 : 0, 0);

  int setCursorToBottom(int hwnd) => SendMessage(hwnd, EM_SETSEL, -2, -1);

  int scrollTo(int hwnd, int pos) => SendMessage(hwnd, WM_VSCROLL, pos, 0);

  int scrollToBottom(int hwnd) => scrollTo(hwnd, SB_BOTTOM);

  Pointer<CHARFORMAT> getCharFormat(int hwnd, [int range = SCF_DEFAULT]) {
    final cf = calloc<CHARFORMAT>();
    var r = SendMessage(hwnd, EM_GETCHARFORMAT, range, cf.address);
    print('!!! getCharFormat> $r');
    return cf;
  }

  int setCharFormat(int hwnd, Pointer<CHARFORMAT> cf,
          [int range = SCF_DEFAULT]) =>
      SendMessage(hwnd, EM_SETCHARFORMAT, range, cf.address);

  int replaceSel(int hwnd, Pointer<Utf16> str) =>
      SendMessage(hwnd, EM_REPLACESEL, 0, str.address);

  // this function is used to output text in different color
  void appendText(int hwnd, int clr, Pointer<Utf16> str) {
    setCursorToBottom(hwnd); // move cursor to bottom

    var cf = getCharFormat(hwnd); // get default char format
    cf.ref.cbSize = sizeOf<CHARFORMAT>();
    cf.ref.dwMask = CFM_COLOR; // change color
    cf.ref.dwEffects = 0;
    cf.ref.crTextColor = clr;

    var r1 = setCharFormat(hwnd, cf); // set default char format
    print('!!! setCharFormat> $r1');

    var r2 = replaceSel(hwnd, str); // code from google
    print('!!! replaceSel> $r2');

    var r3 = scrollToBottom(hwnd); // scroll to bottom
    print('!!! scrollToBottom> $r3');
  }
}

/*
typedef struct _charformat
{
	UINT		cbSize;
	_WPAD		_wPad1;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;			/* > 0 for superscript, < 0 for subscript */
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	TCHAR		szFaceName[LF_FACESIZE];
	_WPAD		_wPad2;
} CHARFORMAT;
 */

base class CHARFORMAT extends Struct {
  @Uint32()
  external int cbSize;

  @Uint32()
  external int dwMask;

  @Uint32()
  external int dwEffects;

  @Int32()
  external int yHeight;

  @Int32()
  external int yOffset;

  @Uint32()
  external int crTextColor;

  @Uint8()
  external int bCharSet;

  @Uint8()
  external int bPitchAndFamily;

  external Pointer<Utf16> szFaceName;
}

/*
base class WNDCLASS extends Struct {
  @Uint32()
  external int style;

  external Pointer<NativeFunction<WindowProc>> lpfnWndProc;

  @Int32()
  external int cbClsExtra;

  @Int32()
  external int cbWndExtra;

  @IntPtr()
  external int hInstance;

  @IntPtr()
  external int hIcon;

  @IntPtr()
  external int hCursor;

  @IntPtr()
  external int hbrBackground;

  external Pointer<Utf16> lpszMenuName;

  external Pointer<Utf16> lpszClassName;
}
 */
