module clayui.app_runner;

import clayd;
import clayui.layout_engine;
import clayui.layout_context;
import clayui.irenderer;
import clayui.icomponent;
import clayui.raylib_renderer;
import clayui.ilayout_context;
import raylib;

final class Application
{
	private LayoutEngine engine;
	private IRenderer renderer;
	private IComponent rootComponent;
	private int widthValue;
	private int heightValue;

	this(int width, int height, IComponent rootComponent)
	{
		widthValue = width;
		heightValue = height;
		this.rootComponent = rootComponent;
		engine = new LayoutEngine();
		engine.initialize(width, height);
		renderer = new RaylibRenderer();
	}

	void setRenderer(IRenderer renderer)
	{
		this.renderer = renderer;
	}

	void setMeasureFont(Font* font)
	{
		engine.setMeasureFont(font);
	}

	void frame()
	{
		Clay_Vector2 mouse = getMousePosition();
		bool down = IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT);
		engine.setPointer(cast(int) mouse.x, cast(int) mouse.y, down);
		engine.updateScroll(true, 0.016f, 0, 0);

		Clay_RenderCommandArray commands = engine.runLayout(
			(ILayoutContext ctx) {
				rootComponent.build(ctx);
			}
		);

		renderer.beginFrame();
		renderer.render(commands);
		renderer.endFrame();
	}

	void resize(int width, int height)
	{
		widthValue = width;
		heightValue = height;
		engine.setDimensions(width, height);
	}

	private static Clay_Vector2 getMousePosition()
	{
		Vector2 m = GetMousePosition();
		Clay_Vector2 v;
		v.x = m.x;
		v.y = m.y;
		return v;
	}
}
