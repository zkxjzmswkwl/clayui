module clayui.app;

import std.string : toStringz;
import clayui;
import clayd : Clay_LayoutDirection;
import raylib;
version (Windows) {
	import core.sys.windows.windows;
}

enum int uiFontAtlasSize = 24;

struct UIFontResult
{
	Font font;
	bool loaded;
}

// temp, this is ugly.
UIFontResult loadUIFont()
{
	string path;
	version (Windows)
		path = "C:\\Windows\\Fonts\\arial.ttf";
	else version (OSX)
		path = "/System/Library/Fonts/Supplemental/Arial.ttf";
	else
		path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf";
	Font f = LoadFontEx(toStringz(path), uiFontAtlasSize, null, 0);
	bool ok = (f.texture.id != 0);
	return UIFontResult(ok ? f : GetFontDefault(), ok);
}

void main()
{
	enum int width = 800;
	enum int height = 600;
	int decorationsHidden = 0;

	InitWindow(width, height, "build test");
	SetTargetFPS(60);

	UIFontResult fontResult = loadUIFont();

	auto root = new Panel("root", Clay_LayoutDirection.topToBottom);
	root.setGrow();
	root.setBackgroundColor(250, 250, 255);
	root.setPadding(24);
	root.setChildGap(16);

	auto titleLabel = new Label("title", "does it build? that is the question.");
	titleLabel.setFontSize(24);
	root.addChild(titleLabel);

	auto btn = new Button("demoButton", "Click me");
	btn.setFontSize(24);
	root.addChild(btn);

	IComponent rootComponent = root;
	auto app = new Application(width, height, rootComponent);
	if (fontResult.loaded)
		app.setFont(&fontResult.font);

	while (!WindowShouldClose())
	{
		version (Windows)
		{
			if (GetAsyncKeyState('F') & 1)
			{
				void* hwnd = GetWindowHandle();
				if (hwnd != null)
				{
					decorationsHidden = ClayWin32.toggleWindowDecorations(hwnd, decorationsHidden);
				}
			}
			if (GetAsyncKeyState('Q') & 1)
				CloseWindow();
		}
		BeginDrawing();
		ClearBackground(raylib.Color(245, 245, 245, 255));
		app.frame();
		EndDrawing();
	}

	if (fontResult.loaded)
		UnloadFont(fontResult.font);
	CloseWindow();
}
