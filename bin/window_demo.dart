import 'package:ui_win32_demo/ui_win32_demo.dart';

void main() {
  var mainWindow = MainWindow(
    width: 640,
    height: 480,
  );

  mainWindow.show();

  Window.runMessageLoop();
}

class MainWindow extends Window {
  static final mainWindowClass =
      WindowClass(className: 'mainWindow', bgColor: RGB(42, 40, 38));

  MainWindow({super.width, super.height})
      : super(
          windowName: 'Main Window',
          windowClass: mainWindowClass,
          windowStyles: WS_MINIMIZEBOX | WS_SYSMENU,
        );

  @override
  void build(int hwnd, int hdc) {
    super.build(hwnd, hdc);

    SetTextColor(hdc, RGB(255, 255, 255));
    SetBkColor(hdc, RGB(42, 40, 38));
  }
}

class TextOutput extends Window {
  static final textOutputWindowClass =
      WindowClass(className: 'textOutput', bgColor: RGB(42, 40, 38));

  TextOutput()
      : super(
          windowName: 'Text Output',
          windowClass: textOutputWindowClass,
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
  }

  @override
  void repaint(int hwnd, int hdc) {
    SetWindowText(hwnd,
        TEXT("Hello\r\nWorld!!!\r\n-------------------\r\n Bla bla bla\r\n"));
  }
}
