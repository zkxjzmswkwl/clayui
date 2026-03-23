module clayui.sdl3_bootstrap;

version (clay_sdl3)
{

import bindbc.loader;
import bindbc.sdl;
import clayui.app_runner;
import clayui.sdl3_renderer;
import sdl.events;
import sdl.keyboard;
import sdl.mouse;
import std.string : toStringz;

bool loadSdl3SharedLibraries()
{
	if (loadSDL() != LoadMsg.success)
		return false;
	if (loadSDLImage() != LoadMsg.success)
		return false;
	if (loadSDLTTF() != LoadMsg.success)
		return false;
	return true;
}

final class Sdl3ClaySession
{
	SDL_Window* window;
	SDL_Renderer* sdlRenderer;
	TTF_Font* font;
	TTF_TextEngine* textEngine;
	TTF_Font*[1] fontArr;
	Sdl3ClayRenderer clayRenderer;

	private bool disposed;

	~this()
	{
		dispose();
	}

	void dispose()
	{
		if (disposed)
			return;
		disposed = true;
		if (textEngine !is null)
		{
			TTF_DestroyRendererTextEngine(textEngine);
			textEngine = null;
		}
		if (font !is null)
		{
			TTF_CloseFont(font);
			font = null;
		}
		if (sdlRenderer !is null)
		{
			SDL_DestroyRenderer(sdlRenderer);
			sdlRenderer = null;
		}
		if (window !is null)
		{
			SDL_StopTextInput(window);
			SDL_DestroyWindow(window);
			window = null;
		}
		TTF_Quit();
		SDL_Quit();
	}

	static Sdl3ClaySession create(string title, int width, int height)
	{
		if (!loadSdl3SharedLibraries())
			return null;

		if (!SDL_Init(SDL_INIT_VIDEO))
			return null;
		if (!TTF_Init())
		{
			SDL_Quit();
			return null;
		}

		string fontPath;
		version (Windows)
			fontPath = `C:\Windows\Fonts\arial.ttf`;
		else version (OSX)
			fontPath = "/System/Library/Fonts/Supplemental/Arial.ttf";
		else
			fontPath = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf";

		auto s = new Sdl3ClaySession();
		s.font = TTF_OpenFont(fontPath.toStringz, 20.0f);
		if (s.font is null)
		{
			TTF_Quit();
			SDL_Quit();
			return null;
		}

		s.window = SDL_CreateWindow(title.toStringz, width, height, SDL_WINDOW_RESIZABLE);
		if (s.window is null)
		{
			TTF_CloseFont(s.font);
			s.font = null;
			TTF_Quit();
			SDL_Quit();
			return null;
		}

		s.sdlRenderer = SDL_CreateRenderer(s.window, null);
		if (s.sdlRenderer is null)
		{
			SDL_DestroyWindow(s.window);
			s.window = null;
			TTF_CloseFont(s.font);
			s.font = null;
			TTF_Quit();
			SDL_Quit();
			return null;
		}

		s.textEngine = TTF_CreateRendererTextEngine(s.sdlRenderer);
		if (s.textEngine is null)
		{
			SDL_DestroyRenderer(s.sdlRenderer);
			s.sdlRenderer = null;
			SDL_DestroyWindow(s.window);
			s.window = null;
			TTF_CloseFont(s.font);
			s.font = null;
			TTF_Quit();
			SDL_Quit();
			return null;
		}

		s.fontArr[0] = s.font;
		s.clayRenderer = new Sdl3ClayRenderer(s.sdlRenderer, s.textEngine, s.fontArr.ptr);
		return s;
	}

	void run(Application app)
	{
		bool running = true;
		SDL_Event ev;
		while (running)
		{
			while (SDL_PollEvent(&ev))
			{
				if (ev.type == SDL_EVENT_QUIT)
				{
					running = false;
				}
				else if (ev.type == SDL_EVENT_MOUSE_BUTTON_DOWN)
				{
					if (ev.button.down && ev.button.button == SDL_MouseButton.left)
					{
						SDL_StopTextInput(window);
						app.clearFocusedTextInput();
					}
				}
				else if (ev.type == SDL_EVENT_TEXT_INPUT)
				{
					app.processSdlTextUtf8(ev.text.text);
				}
				else if (ev.type == SDL_EVENT_KEY_DOWN)
				{
					app.processSdlKeyDown(ev.key.key, ev.key.down, ev.key.repeat);
				}
			}

			SDL_SetRenderDrawColorFloat(sdlRenderer, 0.09f, 0.09f, 0.11f, 1f);
			SDL_RenderClear(sdlRenderer);
			app.frame();
			SDL_RenderPresent(sdlRenderer);
		}
	}
}

}
