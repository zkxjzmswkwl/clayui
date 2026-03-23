module clayui.sdl3_example;

import std.stdio;
import clayd;
import clayui;
import clayui.demo_components;
import clayui.icomponent;
import clayui.sdl3_bootstrap;

void main()
{
	enum width = 720;
	enum height = 480;

	if (!loadSdl3SharedLibraries())
	{
		writeln("Failed to load SDL3 shared libraries (SDL3.dll, SDL3_image.dll, SDL3_ttf.dll).");
		return;
	}

	Sdl3ClaySession session = Sdl3ClaySession.create("clayui — SDL3", width, height);
	if (session is null)
	{
		writeln("Failed to create SDL3 window/renderer.");
		return;
	}
	scope (exit)
		session.dispose();

	auto root = new Panel("root", Clay_LayoutDirection.topToBottom);
	root.setGrow();
	root.setBackgroundColor(245, 246, 250, 255);
	root.setPadding(28);
	root.setChildGap(20);

	auto intro = new Label("intro", "Same component tree as component-example: Panel, Label, ProfileSnippet, Button.");
	intro.setFontSize(15);
	intro.setTextColor(60, 60, 70, 255);
	root.addChild(intro);

	auto snippet = new ProfileSnippet("profile");
	root.addChild(snippet);

	auto btn = new Button("demoBtn", "Library Button (click)");
	btn.setOnClick(() { writeln("Button clicked — SDL3 + clayui."); });
	btn.setFontSize(16);
	root.addChild(btn);

	IComponent rootComp = root;
	auto app = new Application(width, height, rootComp);
	app.setRenderer(session.clayRenderer);
	app.setMeasureFont(session.font);
	app.setTtfFontTable(session.fontArr.ptr, session.fontArr.length);

	session.run(app);
}
