module clayui.sdl3_renderer;

version (clay_sdl3)
{

import bindbc.sdl;
import clayd;
import clayd.renderer.clay_sdl_renderer;
import clayui.irenderer;

// sdl3 renderer is typically the better option over raylib.
final class Sdl3ClayRenderer : IRenderer
{
	private Clay_SDL3RendererData data;

	this(SDL_Renderer* renderer, TTF_TextEngine* textEngine, TTF_Font** fonts)
	{
		data.renderer = renderer;
		data.textEngine = textEngine;
		data.fonts = fonts;
	}

	ref Clay_SDL3RendererData clayData() return
	{
		return data;
	}

	override void beginFrame()
	{
	}

	override void endFrame()
	{
	}

	override void render(const Clay_RenderCommandArray commands)
	{
		SDL_Clay_RenderClayCommands(&data, cast(Clay_RenderCommandArray) commands);
	}
}

}
