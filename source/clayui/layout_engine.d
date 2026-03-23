module clayui.layout_engine;

import clayd;
import core.stdc.stdlib;
import clayui.irenderer;
import clayui.ilayout_context;
import clayui.layout_context;

version (clay_sdl3)
{
	import bindbc.sdl;
}
else
{
	import raylib;
}

final class LayoutEngine
{
	private Clay_Arena arena;
	private void* arenaMemory;
	private Clay_Context* context;
	private Clay_Dimensions dimensions;
	private Clay_ErrorHandler errorHandler;
	private bool initialized;

	version (clay_sdl3)
	{
		private TTF_Font* measureFontTtf;
		private TTF_Font** fontTable;
		private size_t fontTableCount;
	}
	else
	{
		private Font* measureFont;
	}

	this()
	{
		errorHandler.errorHandlerFunction = &defaultErrorHandler;
		errorHandler.userData = null;
	}

	void initialize(int width, int height)
	{
		if (initialized) return;
		dimensions.width = cast(float) width;
		dimensions.height = cast(float) height;
		uint size = clayMinMemorySize();
		arenaMemory = malloc(size);
		if (arenaMemory is null) assert(0, "malloc failed");
		arena = clayCreateArenaWithCapacityAndMemory(size, arenaMemory);
		context = clayInitialize(arena, dimensions, errorHandler);
		claySetMeasureTextFunction(&defaultMeasureText, cast(void*) this);
		claySetMaxElementCount(4096);
		initialized = true;
	}

	version (clay_sdl3)
	{
		void setMeasureFont(TTF_Font* font)
		{
			measureFontTtf = font;
		}

		void setTtfFontTable(TTF_Font** fonts, size_t count)
		{
			fontTable = fonts;
			fontTableCount = count;
		}
	}
	else
	{
		void setMeasureFont(Font* font)
		{
			measureFont = font;
		}
	}

	void setDimensions(int width, int height)
	{
		dimensions.width = cast(float) width;
		dimensions.height = cast(float) height;
		claySetLayoutDimensions(dimensions);
	}

	void setPointer(int x, int y, bool down)
	{
		Clay_Vector2 pos;
		pos.x = cast(float) x;
		pos.y = cast(float) y;
		claySetPointerState(pos, down);
	}

	void updateScroll(bool enableDrag, float deltaTime, float scrollX = 0, float scrollY = 0)
	{
		Clay_Vector2 delta;
		delta.x = scrollX;
		delta.y = scrollY;
		clayUpdateScrollContainers(enableDrag, delta, deltaTime);
	}

	Clay_RenderCommandArray runLayout(void delegate(ILayoutContext) buildRoot)
	{
		claySetLayoutDimensions(dimensions);
		clayBeginLayout();
		LayoutContext ctx = new LayoutContext();
		buildRoot(ctx);
		return clayEndLayout();
	}

	void beginLayout()
	{
		claySetLayoutDimensions(dimensions);
		clayBeginLayout();
	}

	Clay_RenderCommandArray endLayout()
	{
		return clayEndLayout();
	}

	~this()
	{
		if (arenaMemory !is null)
			free(arenaMemory);
		arenaMemory = null;
	}

	private static extern (C) void defaultErrorHandler(Clay_ErrorData data)
	{
		import core.stdc.stdio;
		if (data.errorText.chars !is null && data.errorText.length > 0)
			printf("error: %.*s\n", data.errorText.length, data.errorText.chars);
	}

	private static extern (C) Clay_Dimensions defaultMeasureText(
		Clay_StringSlice text,
		Clay_TextElementConfig* config,
		void* userData
	) {
		Clay_Dimensions d;
		float fontSize = (config !is null && config.fontSize > 0) ? cast(float) config.fontSize : 16.0f;
		float letterSpacing = (config !is null) ? cast(float) config.letterSpacing : 0.0f;
		if (text.chars is null || text.length <= 0)
		{
			d.width = 0;
			d.height = fontSize;
			return d;
		}

		LayoutEngine engine = cast(LayoutEngine) userData;

		version (clay_sdl3)
		{
			TTF_Font* font = null;
			if (engine !is null)
			{
				if (engine.fontTable !is null && config !is null && config.fontId < engine.fontTableCount)
					font = engine.fontTable[config.fontId];
				if (font is null)
					font = engine.measureFontTtf;
			}
			if (font is null)
			{
				d.width = cast(float) text.length * fontSize * 0.5f;
				d.height = fontSize;
				return d;
			}
			TTF_SetFontSize(font, fontSize);
			int w, h;
			if (!TTF_GetStringSize(font, text.chars, cast(size_t) text.length, &w, &h))
			{
				d.width = cast(float) text.length * fontSize * 0.5f;
				d.height = fontSize;
				return d;
			}
			d.width = cast(float) w;
			if (letterSpacing > 0)
			{
				const int len = cast(int) text.length;
				if (len > 1)
					d.width += letterSpacing * cast(float)(len - 1);
			}
			d.height = (config !is null && config.lineHeight > 0) ? cast(float) config.lineHeight : cast(float) h;
			return d;
		}
		else
		{
			Font mfont = GetFontDefault();
			if (engine !is null && engine.measureFont !is null)
				mfont = *engine.measureFont;

			char* z = cast(char*) malloc(cast(size_t) text.length + 1);
			if (z is null)
			{
				d.width = cast(float) text.length * fontSize * 0.5f;
				d.height = fontSize;
				return d;
			}
			foreach (i; 0 .. text.length)
				z[i] = text.chars[i];
			z[text.length] = 0;

			Vector2 m = MeasureTextEx(mfont, cast(const(char)*) z, fontSize, letterSpacing);
			free(z);
			d.width = m.x;
			d.height = (config !is null && config.lineHeight > 0) ? cast(float) config.lineHeight : m.y;
			return d;
		}
	}
}

import clayui.layout_context : LayoutContext;
