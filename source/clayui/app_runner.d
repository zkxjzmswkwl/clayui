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
	import clayui.text_input;
	import core.stdc.string;
	import sdl.clipboard;
	import sdl.keycode;
	import sdl.keyboard;
	import sdl.stdinc;
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

	version (clay_sdl3)
	{
		private TextInput focusedTextInput_;
	}

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

		void setFocusedTextInput(TextInput t)
		{
			if (focusedTextInput_ !is null && focusedTextInput_ !is t)
				focusedTextInput_.setFocused(false);
			focusedTextInput_ = t;
			if (t !is null)
				t.setFocused(true);
		}

		void clearFocusedTextInput()
		{
			if (focusedTextInput_ !is null)
			{
				focusedTextInput_.setFocused(false);
				focusedTextInput_ = null;
			}
		}

		void processSdlTextUtf8(const(char)* text)
		{
			if (focusedTextInput_ is null || text is null)
				return;
			size_t len = strlen(text);
			if (len == 0)
				return;
			string s = cast(string) text[0 .. len];
			foreach (dchar c; s)
				focusedTextInput_.appendChar(c);
		}

		void processSdlKeyDown(SDL_KeyCode key, bool down, bool repeat)
		{
			if (!down || focusedTextInput_ is null)
				return;
			if (key == SDL_KeyCode.backspace)
			{
				focusedTextInput_.backspace();
				return;
			}
			if (repeat)
				return;
			const SDL_KeyMod mods = SDL_GetModState();
			const bool pasteMod = (mods & SDL_KeyMod.ctrl) != 0 || (mods & SDL_KeyMod.gui) != 0;
			if (key == SDL_KeyCode.v && pasteMod)
			{
				if (!SDL_HasClipboardText())
					return;
				char* raw = SDL_GetClipboardText();
				if (raw is null)
					return;
				scope (exit)
					SDL_free(cast(void*) raw);
				const size_t len = strlen(raw);
				if (len == 0)
					return;
				string s = cast(string) raw[0 .. len];
				focusedTextInput_.appendText(s);
			}
		}
	}
	else
	{
		void setMeasureFont(Font* font)
		{
			engine.setMeasureFont(font);
		}

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
