// ignore_for_file: constant_identifier_names

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

final hInstance = GetModuleHandle(nullptr);

late Canvas canvas;

void main() {
  final szAppName = 'Menu Ici - Fuse'.toNativeUtf16();

  final wc = calloc<WNDCLASS>()
    ..ref.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC
    ..ref.lpfnWndProc = Pointer.fromFunction<WindowProc>(mainWindowProc, 0)
    ..ref.hInstance = hInstance
    ..ref.hIcon = LoadIcon(NULL, IDI_APPLICATION)
    ..ref.hCursor = LoadCursor(NULL, IDC_ARROW)
    ..ref.hbrBackground = CreateSolidBrush(RGB(42, 40, 38))
    ..ref.lpszClassName = szAppName;
  RegisterClass(wc);

  final hWnd = CreateWindowEx(
      0, // Optional window styles.
      szAppName, // Window class
      szAppName, // Window text
      WS_MINIMIZEBOX | WS_SYSMENU, // Window style

      // Size and position
      CW_USEDEFAULT,
      CW_USEDEFAULT,
      640,
      480,
      NULL, // Parent window
      NULL, // Menu
      hInstance, // Instance handle
      nullptr // Additional application data
      );

  if (hWnd == 0) {
    stderr.writeln('CreateWindowEx failed with error: ${GetLastError()}');
    exit(-1);
  }

  ShowWindow(hWnd, SW_SHOWNORMAL);
  UpdateWindow(hWnd);

  // Run the message loop.

  final msg = calloc<MSG>();
  while (GetMessage(msg, NULL, 0, 0) != 0) {
    TranslateMessage(msg);
    DispatchMessage(msg);
  }

  free(szAppName);
}

final useDarkMode = malloc<BOOL>()..value = 1;
final titleColor = malloc<COLORREF>()..value = RGB(42, 40, 38);

int mainWindowProc(int hwnd, int uMsg, int wParam, int lParam) {
  int hdc;
  var result = 0;

  final ps = calloc<PAINTSTRUCT>();

  switch (uMsg) {
    case WM_CREATE:
      hdc = GetDC(hwnd);

      DwmSetWindowAttribute(
          hwnd,
          DWMWINDOWATTRIBUTE.DWMWA_USE_IMMERSIVE_DARK_MODE,
          useDarkMode,
          sizeOf<BOOL>());

      DwmSetWindowAttribute(hwnd, DWMWINDOWATTRIBUTE.DWMWA_CAPTION_COLOR,
          titleColor, sizeOf<COLORREF>());

      canvas = Canvas(hdc, hwnd);

      ReleaseDC(hwnd, hdc);

    case WM_PAINT:
      hdc = BeginPaint(hwnd, ps);
      canvas.repaint();
      canvas.loadScreen(hwnd);
      EndPaint(hwnd, ps);

    case WM_DESTROY:
      PostQuitMessage(0);

    case WM_INITDIALOG:
      final str = 'This is a string'.toNativeUtf16();
      SetDlgItemText(hwnd, 102, str);
    // SetDlgItemInt(hwnd, IDC_NUMBER, 5, FALSE);

    default:
      result = DefWindowProc(hwnd, uMsg, wParam, lParam);
  }

  free(ps);

  return result;
}

class Canvas {
  /// Handle to DC
  final int hdc;

  /// Handle to window
  final int hwnd;

  /// Rectangle for drawing. This will last for the lifetime of the app and
  /// memory will be released at app termination.
  final rect = calloc<RECT>();

  /// Initiate the drawing canvas
  Canvas(this.hdc, this.hwnd) {
    GetClientRect(hwnd, rect);

    SaveDC(hdc);

    // Set up coordinate system
    SetMapMode(hdc, MM_ISOTROPIC);
    SetViewportExtEx(hdc, 1, 1, nullptr);
    SetWindowExtEx(hdc, 1, 1, nullptr);

    // Set default colors
    SetTextColor(hdc, RGB(255, 255, 255));
    SetBkColor(hdc, RGB(42, 40, 38));
    //SetBkMode(hdc, TRANSPARENT);
  }

  void repaint() {
    drawBG();

    drawText('Hello World!', 50, 60);
    //drawListBox('This is a string');
    drawOutputBox('Qualquer texto ');
  }

  void drawBG() {
    final hBrush = CreateSolidBrush(RGB(42, 40, 38));

    rect.ref
      ..top = 10
      ..right = 200
      ..bottom = 100
      ..left = 20;

    FillRect(hdc, rect, hBrush);
    DeleteObject(hBrush);
  }

  void drawText(String text, int x, int y) {
    final lpString = text.toNativeUtf16();
    TextOut(hdc, x, y, lpString, text.length);
    free(lpString);
  }

  void drawTextOpaque(String text, int x, int y) {
    SetBkMode(hdc, OPAQUE);
    drawText(text, x, y);
    SetBkMode(hdc, TRANSPARENT);
  }

  void loadScreen(int hwnd) {
    GetClientRect(hwnd, rect);

    final hdc = GetDC(hwnd);

    final imgPath = r'C:\menuici\menuici-logo-24.bmp'.toNativeUtf16();
    //final imgPath = r'C:\menuici\calc.bmp'.toNativeUtf16();

    final bitmapW = 512;
    final bitmapH = 512;

    final hbitmap = LoadImage(
        NULL, imgPath, IMAGE_BITMAP, bitmapW, bitmapH, LR_LOADFROMFILE);

    print('!!! hbitmap: $hbitmap');

    final errorCode = GetLastError();
    print('!!! errorCode: $errorCode');

    final width = rect.ref.right - rect.ref.left;
    final height = rect.ref.bottom - rect.ref.top;

    print('!!! WH: $width x $height');

    final hmemdc = CreateCompatibleDC(hdc);

    SelectObject(hmemdc, hbitmap);

    // BitBlt(hdc, width ~/ 2 - bitmapW ~/ 2, height ~/ 2 - bitmapH ~/ 2, bitmapW,
    //    bitmapH, hmemdc, 0, 0, SRCCOPY);

    final hSpace = (width - bitmapW);
    final vSpace = (height - bitmapH);
    final xCenter = hSpace ~/ 2;
    final yCenter = vSpace ~/ 2;

    final x = xCenter;
    final y = vSpace;

    BitBlt(hdc, x, y, bitmapW, bitmapH, hmemdc, 0, 0, SRCCOPY);

    DeleteObject(hbitmap);
    DeleteObject(hmemdc);

    ReleaseDC(hwnd, hdc);
  }

  void drawListBox(String text) {
    final lpString = text.toNativeUtf16();

    SetDlgItemText(hwnd, 102, lpString);

//    int index = SendDlgItemMessage(hwnd, IDC_LIST, LB_ADDSTRING, 0, 'Hi there!');

    final lpClassName = 'listbox'.toNativeUtf16();
    final lpWindowName = 'tracklist'.toNativeUtf16();

    var hListBox = CreateWindowEx(WS_EX_CLIENTEDGE, lpClassName, lpWindowName,
        WS_CHILD | WS_VISIBLE, 4, 360, 626, 90, hwnd, NULL, hInstance, nullptr);

    //SetWindowText(hListBox, lpClassName);
    var lbAddString = 384;

    SendMessage(hListBox, lbAddString, 0, lpWindowName.address);
    SendMessage(hListBox, lbAddString, 0, lpWindowName.address);
    SendMessage(hListBox, lbAddString, 0, lpWindowName.address);

    //SetWindowText(hListBox, lpClassName);

    final errorCode = GetLastError();
    print('!!! errorCode: $errorCode');

    free(lpString);
  }

  void drawOutputBox(String text) {
    var editId = 1;

    var hwndEdit = CreateWindowEx(
        0,
        TEXT('edit'),
        nullptr,
        WS_CHILD |
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
        4,
        360,
        626,
        90,
        hwnd,
        editId,
        hInstance,
        nullptr);

    //var hdc = GetDC(hwndEdit);

    SetTextColor(hwndEdit, RGB(255, 255, 255));
    SetBkColor(hwndEdit, RGB(42, 40, 38));

    SetWindowText(hwndEdit,
        TEXT("Hello\r\nWorld!!!\r\n-------------------\r\n Bla bla bla\r\n"));
  }
}
