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

    setAutoURLDetect(hwnd, true);
  }

  @override
  void repaint(int hwnd, int hdc) {
    SetTextColor(hdc, RGB(255, 0, 0)); // red

    SendMessage(hwnd, EM_SETBKGNDCOLOR, 0, RGB(42, 40, 38));

    SetWindowText(hwnd,
        TEXT("Hello\r\nWorld!!!\r\n-------------------\r\n Bla bla bla: http://www.google.com/\r\n"));
  }

  void setBkColor(int hwnd, int color) =>
      SendMessage(hwnd, EM_SETBKGNDCOLOR, 0, color);

  void setAutoURLDetect(int hwnd, bool autoDetect) =>
      SendMessage(hwnd, EM_AUTOURLDETECT, autoDetect ? 1 : 0, 0);
}
