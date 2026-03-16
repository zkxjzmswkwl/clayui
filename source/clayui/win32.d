module clayui.win32;

version (Windows) {
	import core.sys.windows.windows;
	import core.sys.windows.winuser;
	import core.stdc.stdio;

	class ClayWin32
	{
		static int toggleWindowDecorations(void* _hwnd, int nowState)
		{
			HWND hwnd = cast(HWND)_hwnd;
			if (!hwnd) return -1;

			LONG_PTR style = GetWindowLongPtr(hwnd, GWL_STYLE);

			if (nowState) {
				style |= (WS_CAPTION | WS_SIZEBOX | WS_BORDER);
				SetWindowLongPtr(hwnd, GWL_STYLE, style);
				UpdateWindow(hwnd);
				return 0;
			} else {
				style &= ~(WS_CAPTION | WS_SIZEBOX | WS_BORDER);
				SetWindowLongPtr(hwnd, GWL_STYLE, style);
				UpdateWindow(hwnd);
				return 1;
			}
		}
	}
}
