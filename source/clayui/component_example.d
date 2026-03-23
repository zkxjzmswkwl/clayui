module clayui.component_example;

/// Runnable demo: `dub run -c component-example` from the clayui package directory.
///
/// Custom components live in [`clayui.demo_components`] and are shared with `sdl3_example`.

import std.stdio;
import std.string : toStringz;
import clayd;
import clayui;
import clayui.demo_components;
import raylib;
version (Windows)
{
	import core.sys.windows.windows;
}

enum int uiFontAtlasSize = 24;

struct UIFontResult
{
	Font font;
	bool loaded;
}

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
	enum int width = 720;
	enum int height = 480;

	InitWindow(width, height, "Component examples");
	SetTargetFPS(60);

	UIFontResult fontResult = loadUIFont();

	auto root = new Panel("root", Clay_LayoutDirection.topToBottom);
	root.setGrow();
	root.setBackgroundColor(245, 246, 250, 255);
	root.setPadding(28);
	root.setChildGap(20);

	auto intro = new Label("intro", "Below: Badge, Divider, KeyValueRow, and ProfileSnippet (all extend Component).");
	intro.setFontSize(15);
	intro.setTextColor(60, 60, 70, 255);
	root.addChild(intro);

	auto snippet = new ProfileSnippet("profile");
	root.addChild(snippet);

	auto btn = new Button("demoBtn", "Library Button (click)");
	btn.setOnClick(() { writeln("Button clicked — works alongside custom components."); });
	btn.setFontSize(16);
	root.addChild(btn);

	IComponent rootComponent = root;
	auto app = new Application(width, height, rootComponent);
	if (fontResult.loaded)
		app.setFont(&fontResult.font);

	while (!WindowShouldClose())
	{
		version (Windows)
		{
			if (GetAsyncKeyState('Q') & 1)
				CloseWindow();
		}
		BeginDrawing();
		ClearBackground(raylib.Color(238, 239, 244, 255));
		app.frame();
		EndDrawing();
	}

	if (fontResult.loaded)
		UnloadFont(fontResult.font);
	CloseWindow();
}
