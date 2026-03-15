module clayui.app;

import clayui;
import clayd : Clay_LayoutDirection;
import raylib;

void main()
{
	enum int width = 800;
	enum int height = 600;

	InitWindow(width, height, "build test");
	SetTargetFPS(60);

	auto root = new Panel("root", Clay_LayoutDirection.topToBottom);
	root.setGrow();
	root.setBackgroundColor(250, 250, 255);
	root.setPadding(24);
	root.setChildGap(16);

	auto titleLabel = new Label("title", "does it build? that is the question.");
	titleLabel.setFontSize(24);
	root.addChild(titleLabel);

	auto btn = new Button("demoButton", "Click me");
	root.addChild(btn);

	IComponent rootComponent = root;
	auto app = new Application(width, height, rootComponent);

	while (!WindowShouldClose())
	{
		BeginDrawing();
		ClearBackground(raylib.Color(245, 245, 245, 255));
		app.frame();
		EndDrawing();
	}

	CloseWindow();
}
