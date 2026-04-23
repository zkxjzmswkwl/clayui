module main;

import std.stdio;
import clayd;
import clayui;
import clayui_examples.demo_components;
import clayui.icomponent;
import clayui.sdl3_bootstrap;
import sdl.keyboard;

void main()
{
	const int rc = runWithSdlApplicationRuntime(delegate int() { return runClayuiSdl3Example(); });
	if (rc != 0)
		writeln("Exited with code ", rc);
}

private int runClayuiSdl3Example()
{
	enum width = 720;
	enum height = 480;

	Sdl3ClaySession session = Sdl3ClaySession.create("clayui — SDL3", width, height);
	if (session is null)
	{
		writeln("Failed to create SDL3 window/renderer.");
		return 1;
	}

	scope (exit)
		session.dispose();

	auto root = new Panel("root", Clay_LayoutDirection.topToBottom);
	root.setGrow();
	root.setBackgroundColor(50, 36, 34, 255);
	root.setPadding(28);
	root.setChildGap(20);

	auto intro = new Label("intro", "SDL3 renderer. Debug build. Running on arm64 at < 2mb of mem usage.");
	intro.setFontSize(18);
	intro.setTextColor(241, 217, 143, 255);
	root.addChild(intro);

	auto snippet = new ProfileSnippet("profile");
	root.addChild(snippet);

	auto imgUrlText = new TextInput("imgUrlText");
	imgUrlText.setPlaceholder("Enter image URL");
	imgUrlText.setMaxWidthPerc(0.5);
	imgUrlText.setFontSize(16);
	root.addChild(imgUrlText);

	auto image = new LoadRemoteImage("image", session.sdlRenderer);
	image.setMaxImageExtent(664, 400);
	root.addChild(image);

	IComponent rootComp = root;
	auto app = new Application(width, height, rootComp);
	app.setRenderer(session.clayRenderer);
	app.setMeasureFont(session.font);
	app.setTtfFontTable(session.fontArr.ptr, session.fontArr.length);

	imgUrlText.setOnFocusRequested((textInput) {
		app.setFocusedTextInput(textInput);
		SDL_StartTextInput(session.window);
	});

	auto btn = new Button("loadImageBtn", "Load Image");
	btn.setOnClick(() {
		image.setImageUrl(imgUrlText.getBuffer());
	});
	btn.setFontSize(16);
	root.addChild(btn);

	session.runDeferred(app, {
		image.setImageUrl("https://placehold.co/664x400");
	});
	return 0;
}
