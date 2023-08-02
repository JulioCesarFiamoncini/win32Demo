import 'dart:collection';
import 'dart:ffi';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

final hInstance = GetModuleHandle(nullptr);

typedef WindowProcFunction = int Function(
    int hwnd, int uMsg, int wParam, int lParam);

class WindowClass {
  final String className;
  final Pointer<NativeFunction<WindowProc>> windowProc;

  final int? bgColor;

  final bool useDarkMode;

  final int? titleColor;

  WindowClass(
      {required this.className,
      required this.windowProc,
      this.bgColor,
      this.useDarkMode = false,
      this.titleColor});

  Pointer<Utf16>? _classNameNative;

  Pointer<Utf16> get classNameNative =>
      _classNameNative ??= className.toNativeUtf16();

  static int windowProcDefault(
      int hwnd, int uMsg, int wParam, int lParam, WindowClass windowClass) {
    var result = 0;

    switch (uMsg) {
      case WM_CREATE:
        {
          final hdc = GetDC(hwnd);

          if (windowClass.useDarkMode) {
            DwmSetWindowAttribute(
                hwnd,
                DWMWINDOWATTRIBUTE.DWMWA_USE_IMMERSIVE_DARK_MODE,
                malloc<BOOL>()..value = 1,
                sizeOf<BOOL>());
          }

          final titleColor = windowClass.titleColor;
          if (titleColor != null) {
            DwmSetWindowAttribute(
              hwnd,
              DWMWINDOWATTRIBUTE.DWMWA_CAPTION_COLOR,
              malloc<COLORREF>()..value = titleColor,
              sizeOf<COLORREF>(),
            );
          }

          for (var w in windowClass._windows) {
            w.callBuild(hwnd, hdc);
          }

          ReleaseDC(hwnd, hdc);
        }
      case WM_PAINT:
        {
          final ps = calloc<PAINTSTRUCT>();
          final hdc = BeginPaint(hwnd, ps);

          for (var w in windowClass._windows) {
            w.callRepaint(hwnd, hdc);
          }

          EndPaint(hwnd, ps);
          free(ps);
        }

      case WM_DESTROY:
        {
          PostQuitMessage(0);
        }

      default:
        {
          result = DefWindowProc(hwnd, uMsg, wParam, lParam);
        }
    }

    return result;
  }

  final Set<Window> _windows = {};

  Set<Window> get windows => UnmodifiableSetView(_windows);

  bool registerWindow(Window window) => _windows.add(window);

  bool unregisterWindow(Window window) => _windows.remove(window);

  bool? _registered;

  bool get isRegisteredOK => _registered ?? false;

  bool register() => _registered ??= _registerWindowClass(this);

  static final Map<String, int> _registeredWindowClasses = {};

  static bool _registerWindowClass(WindowClass windowClass) {
    if (_registeredWindowClasses.containsKey(windowClass.className)) {
      return false;
    }

    final wc = calloc<WNDCLASS>();

    var wcRef = wc.ref;

    wcRef
      ..style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC
      ..lpfnWndProc = windowClass.windowProc
      ..hInstance = hInstance
      ..hIcon = LoadIcon(NULL, IDI_APPLICATION)
      ..hCursor = LoadCursor(NULL, IDC_ARROW)
      ..lpszClassName = windowClass.classNameNative;

    final bgColor = windowClass.bgColor;
    if (bgColor != null) {
      wcRef.hbrBackground = CreateSolidBrush(bgColor);
    }

    var id = RegisterClass(wc);

    _registeredWindowClasses[windowClass.className] = id;

    return true;
  }
}

class Window {
  static void runMessageLoop() {
    final msg = calloc<MSG>();
    while (GetMessage(msg, NULL, 0, 0) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
  }

  final WindowClass windowClass;
  final String windowName;

  final int windowStyles;

  int? x;
  int? y;
  int? width;
  int? height;

  int? bgColor;

  int? hwnd;
  int? parentHwnd;

  Window(
      {required this.windowClass,
      required this.windowName,
      this.windowStyles = 0,
      this.x,
      this.y,
      this.width,
      this.height,
      this.bgColor,
      this.parentHwnd}) {
    windowClass.register();

    var hwnd = create();
    if (hwnd == 0) {
      throw StateError("Can't create window: $this");
    }

    this.hwnd = hwnd;

    windowClass.registerWindow(this);
  }

  Pointer<Utf16>? _windowNameNative;

  Pointer<Utf16> get windowNameNative =>
      _windowNameNative ??= windowName.toNativeUtf16();

  int create() {
    final hwnd = CreateWindowEx(
        // Optional window styles:
        0,

        // Window class:
        windowClass.classNameNative,

        // Window text:
        windowNameNative,

        // Window style:
        windowStyles,

        // Size and position:
        x ?? CW_USEDEFAULT,
        y ?? CW_USEDEFAULT,
        width ?? CW_USEDEFAULT,
        height ?? CW_USEDEFAULT,

        // Parent window:
        parentHwnd ?? NULL,
        // Menu:
        NULL,
        // Instance handle:
        hInstance,
        // Additional application data:
        nullptr);

    if (hwnd != 0) {
      UpdateWindow(hwnd);
    }

    return hwnd;
  }

  void show({int? hwnd}) {
    hwnd ??= this.hwnd;

    if (hwnd != null) {
      ShowWindow(hwnd, SW_SHOWNORMAL);
      UpdateWindow(hwnd);
    }
  }

  final dimension = calloc<RECT>();

  void fetchDimension({int? hwnd}) {
    hwnd ??= this.hwnd;

    if (hwnd != null) {
      GetClientRect(hwnd, dimension);
    }
  }

  int get dimensionWidth => dimension.ref.right - dimension.ref.left;

  int get dimensionHeight => dimension.ref.bottom - dimension.ref.top;

  void callBuild(int hwnd, int hdc) {
    fetchDimension(hwnd: hwnd);

    build(hwnd, hdc);
  }

  void build(int hwnd, int hdc) {
    SetMapMode(hdc, MM_ISOTROPIC);
    SetViewportExtEx(hdc, 1, 1, nullptr);
    SetWindowExtEx(hdc, 1, 1, nullptr);
  }

  void callRepaint(int hwnd, int hdc) {
    fetchDimension(hwnd: hwnd);

    repaint(hwnd, hdc);
  }

  void repaint(int hwnd, int hdc) {
    drawBG(hdc);
  }

  void drawBG(int hdc) {
    final bgColor = this.bgColor;

    if (bgColor != null) {
      fillRect(hdc, bgColor, pRect: dimension);
    }
  }

  final _rect = calloc<RECT>();

  void fillRect(int hdc, int color,
      {math.Rectangle? rect, Pointer<RECT>? pRect}) {
    Pointer<RECT>? r;

    if (rect != null) {
      _rect.ref
        ..top = rect.top.toInt()
        ..right = rect.right.toInt()
        ..bottom = rect.bottom.toInt()
        ..left = rect.left.toInt();

      r = _rect;
    } else if (pRect != null) {
      r = pRect;
    }

    if (r != null) {
      final hBrush = CreateSolidBrush(color);
      FillRect(hdc, r, hBrush);
      DeleteObject(hBrush);
    }
  }

  void drawText(int hdc, String text, int x, int y) {
    final s = text.toNativeUtf16();
    TextOut(hdc, x, y, s, text.length);
    free(s);
  }

  final Map<String, int> _imagesCached = {};

  int loadImageCached(int hwnd, String imgPath, int imgWidth, int imgHeight) {
    return _imagesCached[imgPath] ??=
        loadImage(hwnd, imgPath, imgWidth, imgHeight);
  }

  int loadImage(int hwnd, String imgPath, int imgWidth, int imgHeight) {
    final hBitmap = LoadImage(NULL, imgPath.toNativeUtf16(), IMAGE_BITMAP,
        imgWidth, imgHeight, LR_LOADFROMFILE);

    return hBitmap;
  }

  void drawImage(
      int hwnd, int hdc, int hBitmap, int x, int y, int width, int height) {
    final hMemDC = CreateCompatibleDC(hdc);

    SelectObject(hMemDC, hBitmap);

    BitBlt(hdc, x, y, width, height, hMemDC, 0, 0, SRCCOPY);

    DeleteObject(hMemDC);
  }
}
