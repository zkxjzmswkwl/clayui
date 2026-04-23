module clayui.sdl3_bootstrap;

version (clay_sdl3)
{

import bindbc.loader;
import bindbc.sdl;
import clayui.app_runner;
import clayui.sdl3_renderer;
import sdl.error;
import sdl.events;
import sdl.keyboard;
import sdl.main;
import sdl.mouse;
import sdl.render;
import sdl.video;
import std.string : fromStringz, toStringz;
import std.stdio : stderr;

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

private void drainPendingSdlEvents()
{
	SDL_Event ev;
	SDL_PumpEvents();
	while (SDL_PollEvent(&ev))
	{
	}
}

private __gshared int delegate() sdlAppBody_;

extern (C) private int sdlRunAppTrampoline(int argc, char** argv)
{
	try
	{
		if (sdlAppBody_ !is null)
			return sdlAppBody_();
		return 0;
	}
	catch (Exception e)
	{
		stderr.writeln(e);
		return 1;
	}
}

// if on macos, call once from entry point **before** Sdl3ClaySession.create / Sdl3ClaySession.run
// solved problem for me, probably not only way to solve it. probably not best way either.
int runWithSdlApplicationRuntime(int delegate() appBody)
{
	if (!loadSdl3SharedLibraries())
	{
		stderr.writeln("loadSdl3SharedLibraries failed");
		return 1;
	}
	sdlAppBody_ = appBody;
	const int rc = SDL_RunApp(0, null, &sdlRunAppTrampoline, null);
	sdlAppBody_ = null;
	return rc;
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
		{
			stderr.writeln("SDL_Init boom: ", fromStringz(SDL_GetError()));
			return null;
		}
		if (!TTF_Init())
		{
			stderr.writeln("TTF_Init boom: ", fromStringz(SDL_GetError()));
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
			stderr.writeln("TTF_OpenFont failed (", fontPath, "): ", fromStringz(SDL_GetError()));
			TTF_Quit();
			SDL_Quit();
			return null;
		}

		SDL_Window* win;
		SDL_Renderer* ren;
		if (!SDL_CreateWindowAndRenderer(title.toStringz, width, height, SDL_WINDOW_RESIZABLE, &win, &ren))
		{
			stderr.writeln("SDL_CreateWindowAndRenderer failed: ", fromStringz(SDL_GetError()));
			TTF_CloseFont(s.font);
			s.font = null;
			TTF_Quit();
			SDL_Quit();
			return null;
		}
		s.window = win;
		s.sdlRenderer = ren;
		SDL_ShowWindow(s.window);
		SDL_RaiseWindow(s.window);
		drainPendingSdlEvents();

		s.textEngine = TTF_CreateRendererTextEngine(s.sdlRenderer);
		if (s.textEngine is null)
		{
			stderr.writeln("TTF_CreateRendererTextEngine failed: ", fromStringz(SDL_GetError()));
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
		drainPendingSdlEvents();
		return s;
	}

	void run(Application app)
	{
		runDeferred(app, null);
	}

	void runDeferred(Application app, void delegate() afterFirstPresent)
	{
		drainPendingSdlEvents();
		bool running = true;
		bool didDeferred = afterFirstPresent is null;
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
			if (!didDeferred)
			{
				didDeferred = true;
				afterFirstPresent();
			}
		}
	}
}

}
