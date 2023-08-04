import 'package:ui_win32_demo/ui_win32_demo.dart';

void main() {
  var editorClass = WindowClassColors(
    textColor: RGB(0, 0, 0),
    bgColor: RGB(42, 40, 38),
  );

  WindowClass.editColors = editorClass;
  WindowClass.staticColors = editorClass;

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

  late final RichEdit textOutput;

  MainWindow({super.width, super.height})
      : super(
          windowName: 'Main Window',
          windowClass: mainWindowClass,
          windowStyles: WS_MINIMIZEBOX | WS_SYSMENU,
        ) {
    textOutput = RichEdit(parentHwnd: hwnd);
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

    textOutput.callRepaint();
  }
}
