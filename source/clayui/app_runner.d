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
	import clayui.sdl3_renderer;
	import clayui.text_input;
	import core.stdc.string;
	import sdl.clipboard;
	import sdl.keycode;
	import sdl.keyboard;
	import sdl.render;
	import sdl.stdinc;
	import sdl_ttf;
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
			focusedTextInput_.insertText(s);
		}

		void processSdlKeyDown(SDL_KeyCode key, bool down, bool repeat)
		{
			if (!down || focusedTextInput_ is null)
				return;

			const SDL_KeyMod mods = SDL_GetModState();
			const bool shift = (mods & SDL_KeyMod.shift) != 0;
			const bool ctrlOrCmd = (mods & SDL_KeyMod.ctrl) != 0 || (mods & SDL_KeyMod.gui) != 0;
			const bool pasteMod = ctrlOrCmd;

			if (key == SDL_KeyCode.backspace)
			{
				if (ctrlOrCmd)
					focusedTextInput_.deleteWordLeft();
				else
					focusedTextInput_.backspace();
				return;
			}
			if (key == SDL_KeyCode.delete_)
			{
				focusedTextInput_.deleteForward();
				return;
			}

			switch (key)
			{
			case SDL_KeyCode.left:
				focusedTextInput_.moveCaretLeft(shift);
				return;
			case SDL_KeyCode.right:
				focusedTextInput_.moveCaretRight(shift);
				return;
			case SDL_KeyCode.home:
				focusedTextInput_.moveCaretHome(shift);
				return;
			case SDL_KeyCode.end:
				focusedTextInput_.moveCaretEnd(shift);
				return;
			default:
				break;
			}

			if (repeat)
				return;

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
				focusedTextInput_.insertText(s);
			}
		}

		private void paintSdlTextInputOverlays()
		{
			if (focusedTextInput_ is null || !focusedTextInput_.focused())
				return;
			if (!focusedTextInput_.layoutElementId().length)
				return;
			auto sdlRen = cast(Sdl3ClayRenderer) renderer;
			if (sdlRen is null)
				return;
			SDL_Renderer* r = sdlRen.clayData().renderer;
			if (r is null)
				return;
			TTF_Font* font = engine.measureFontPtr();
			if (font is null)
				return;

			Clay_ElementData el = clayGetElementData(clayId(focusedTextInput_.layoutElementId()));
			if (!el.found)
				return;

			const(char)[] text = focusedTextInput_.labelUtf8();
			if (!text.length)
				return;

			const ushort fs = focusedTextInput_.labelFontSize();
			const float scroll = focusedTextInput_.horizontalScrollPixels();
			const Clay_Padding pad = focusedTextInput_.inputPadding();

			const float xBase = el.boundingBox.x + cast(float) pad.left - scroll;
			const float yBase = el.boundingBox.y + cast(float) pad.top;

			TTF_SetFontSize(font, cast(float) fs);
			int lineH = TTF_GetFontHeight(font);
			if (lineH < 1)
				lineH = cast(int) fs;

			float measure(const(char)[] u, size_t end)
			{
				return engine.measureSdlTextPrefix(fs, u, end);
			}

			size_t selLo, selHi;
			if (focusedTextInput_.copySelectionBounds(selLo, selHi))
			{
				const float sx = measure(text, selLo);
				const float sw = measure(text, selHi) - sx;
				SDL_FRect sr = SDL_FRect(xBase + sx, yBase, sw, cast(float) lineH);
				SDL_SetRenderDrawColorFloat(r, 0.25f, 0.50f, 0.95f, 0.35f);
				SDL_RenderFillRect(r, &sr);
			}

			size_t c = focusedTextInput_.caretByte();
			if (c > text.length)
				c = text.length;
			const float cx = measure(text, c);
			SDL_FRect caretRect = SDL_FRect(xBase + cx, yBase, 2f, cast(float) lineH);
			SDL_SetRenderDrawColorFloat(r, 0.05f, 0.05f, 0.08f, 1f);
			SDL_RenderFillRect(r, &caretRect);
		}

		private void syncFocusedTextInputScroll()
		{
			if (focusedTextInput_ is null || !focusedTextInput_.layoutElementId().length)
				return;
			Clay_ElementData el = clayGetElementData(clayId(focusedTextInput_.layoutElementId()));
			if (!el.found)
				return;
			TextInput t = focusedTextInput_;
			float delegate(const(char)[] u, size_t b) measure = (const(char)[] u, size_t b) {
				return engine.measureSdlTextPrefix(t.labelFontSize(), u, b);
			};
			t.syncHorizontalScrollAfterLayout(el, measure);
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
		version (clay_sdl3)
		{
			paintSdlTextInputOverlays();
			syncFocusedTextInputScroll();
		}
		renderer.endFrame();
	}

	void resize(int width, int height)
	{
		widthValue = width;
		heightValue = height;
		engine.setDimensions(width, height);
	}
}
