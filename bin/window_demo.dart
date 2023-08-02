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
  static final mainWindowClass = WindowClass.custom(
    className: 'mainWindow',
    windowProc: Pointer.fromFunction<WindowProc>(mainWindowProc, 0),
    bgColor: RGB(42, 40, 38),
    useDarkMode: true,
    titleColor: RGB(42, 40, 38),
  );

  static int mainWindowProc(int hwnd, int uMsg, int wParam, int lParam) =>
      WindowClass.windowProcDefault(
          hwnd, uMsg, wParam, lParam, mainWindowClass);

  late final TextOutput textOutput;

  MainWindow({super.width, super.height})
      : super(
          windowName: 'Main Window',
          windowClass: mainWindowClass,
          windowStyles: WS_MINIMIZEBOX | WS_SYSMENU,
        ) {
    textOutput = TextOutput(parentHwnd: hwnd);
  }

  @override
  void build(int hwnd, int hdc) {
    super.build(hwnd, hdc);

    SetTextColor(hdc, RGB(255, 255, 255));
    SetBkColor(hdc, RGB(42, 40, 38));
  }

  @override
  void repaint(int hwnd, int hdc) {
    super.repaint(hwnd, hdc);

    final imgPath = r'C:\menuici\menuici-logo-24.bmp';
    var w = 512;
    var h = 512;

    var hBitmap = loadImageCached(hwnd, imgPath, w, h);

    final hSpace = (dimensionWidth - w);
    final vSpace = (dimensionHeight - h);
    final xCenter = hSpace ~/ 2;
    //final yCenter = vSpace ~/ 2;

    final x = xCenter;
    final y = vSpace;

    drawImage(hwnd, hdc, hBitmap, x, y, w, h);
  }
}

class TextOutput extends Window {
  static final textOutputWindowClass = WindowClass.predefined(
    className: 'edit',
    bgColor: RGB(128, 128, 128),
  );

  TextOutput({super.parentHwnd})
      : super(
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
    SetTextColor(hdc, RGB(255, 0, 0)); // red

    SetWindowText(hwnd,
        TEXT("Hello\r\nWorld!!!\r\n-------------------\r\n Bla bla bla\r\n"));
  }
}
