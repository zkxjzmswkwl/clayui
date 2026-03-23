module clayui.app_runner;

import clayd;
import clayui.layout_engine;
import clayui.layout_context;
import clayui.irenderer;
import clayui.icomponent;
import clayui.ilayout_context;

version (clay_sdl3)
{
	import bindbc.sdl;
}
else
{
	import clayui.raylib_renderer;
	import raylib;
}

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
		version (clay_sdl3)
		{
			renderer = null;
		}
		else
		{
			renderer = new RaylibRenderer();
		}
	}

	void setRenderer(IRenderer r)
	{
		renderer = r;
	}

	version (clay_sdl3)
	{
		void setMeasureFont(TTF_Font* font)
		{
			engine.setMeasureFont(font);
		}

		void setTtfFontTable(TTF_Font** fonts, size_t count)
		{
			engine.setTtfFontTable(fonts, count);
		}
	}
	else
	{
		void setMeasureFont(Font* font)
		{
			engine.setMeasureFont(font);
		}

		/// Sets the font used for both layout text measurement and rendering.
		void setFont(Font* font)
		{
			engine.setMeasureFont(font);
			auto r = cast(RaylibRenderer) renderer;
			if (r !is null)
				r.setFont(font);
		}
	}

	void frame()
	{
		Clay_Vector2 mouse;
		bool down;
		version (clay_sdl3)
		{
			float mx, my;
			SDL_MouseButtonFlags flags = SDL_GetMouseState(&mx, &my);
			down = (flags & SDL_MouseButtonFlags.left) != 0;
			mouse.x = mx;
			mouse.y = my;
		}
		else
		{
			Vector2 m = GetMousePosition();
			mouse.x = m.x;
			mouse.y = m.y;
			down = IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT);
		}
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
}
