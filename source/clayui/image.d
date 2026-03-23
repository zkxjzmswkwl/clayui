module clayui.image;

version (clay_sdl3)
{

import clayd;
import clayui.component;
import clayui.icomponent;
import clayui.ilayout_context;
import bindbc.sdl;
import sdl.iostream;
import std.string : toStringz;
import std.net.curl;

/// Displays a bitmap using an [`SDL_Texture`] pointer in [`Clay_ImageElementConfig.imageData`]
/// (see [`clayd.renderer.clay_sdl_renderer`]).
class Image : Component
{
	private SDL_Renderer* renderer;
	private void* imageDataValue;
	private SDL_Texture* ownedTexture;

	this(string id = "", SDL_Renderer* renderer = null, void* imageData = null)
	{
		super(id);
		this.renderer = renderer;
		imageDataValue = imageData;
	}

	~this()
	{
		unloadOwned();
	}

	void setRenderer(SDL_Renderer* r)
	{
		renderer = r;
	}

	SDL_Renderer* getRenderer() return
	{
		return renderer;
	}

	override void build(ILayoutContext ctx)
	{
		decl.image.imageData = imageDataValue;
		super.build(ctx);
	}

	override void buildChildren(ILayoutContext ctx)
	{
	}

	bool loadFromFile(const string path)
	{
		if (renderer is null)
			return false;
		unloadOwned();
		ownedTexture = IMG_LoadTexture(renderer, path.toStringz);
		if (ownedTexture is null)
			return false;
		imageDataValue = cast(void*) ownedTexture;
		if (!applyTextureSize(ownedTexture))
		{
			unloadOwned();
			return false;
		}
		return true;
	}

	bool loadFromMemory(const ubyte[] data, const string fileType)
	{
		if (renderer is null || data.length == 0)
			return false;
		unloadOwned();
		SDL_IOStream* io = SDL_IOFromConstMem(cast(const(void)*) data.ptr, data.length);
		if (io is null)
			return false;
		ownedTexture = IMG_LoadTextureTyped_IO(renderer, io, true, fileType.toStringz);
		if (ownedTexture is null)
			return false;
		imageDataValue = cast(void*) ownedTexture;
		if (!applyTextureSize(ownedTexture))
		{
			unloadOwned();
			return false;
		}
		return true;
	}

	bool loadFromUrl(string url, string imageType = ".png")
	{
		if (url.length == 0)
			return false;
		return loadFromMemory(std.net.curl.get!(HTTP, ubyte)(url), imageType);
	}

	private bool applyTextureSize(SDL_Texture* tex)
	{
		float w = 0;
		float h = 0;
		if (!SDL_GetTextureSize(tex, &w, &h))
			return false;
		setFixedSize(cast(ushort) w, cast(ushort) h);
		return true;
	}

	private void unloadOwned()
	{
		if (ownedTexture is null)
			return;
		void* texPtr = cast(void*) ownedTexture;
		if (imageDataValue == texPtr)
			imageDataValue = null;
		SDL_DestroyTexture(ownedTexture);
		ownedTexture = null;
	}

	void setImageData(void* ptr)
	{
		unloadOwned();
		imageDataValue = ptr;
	}

	const(void)* imageData() const
	{
		return imageDataValue;
	}

	void setFixedSize(ushort width, ushort height)
	{
		decl.layout.sizing.width = claySizingFixed(width);
		decl.layout.sizing.height = claySizingFixed(height);
	}
}

}
else
{

import clayd;
import clayui.component;
import clayui.icomponent;
import clayui.ilayout_context;
import raylib;
import std.string;
import std.net.curl;


class Image : Component
{
	private void* imageDataValue;
	// if id is nonzero, it means texture is owned by that instance of this component.
	// this component is then responsible for unloading it.
	private Texture2D ownedTexture;

	this(string id = "", void* imageData = null)
	{
		super(id);
		imageDataValue = imageData;
	}

	~this()
	{
		if (ownedTexture.id != 0)
			UnloadTexture(ownedTexture);
	}

	override void build(ILayoutContext ctx)
	{
		decl.image.imageData = imageDataValue;
		super.build(ctx);
	}

	override void buildChildren(ILayoutContext ctx){ /* no children */ }

	bool loadFromFile(const string path)
	{
		unloadOwned();
		ownedTexture = LoadTexture(toStringz(path));
		if (ownedTexture.id == 0)
			return false;
		imageDataValue = &ownedTexture;
		setFixedSize(cast(ushort) ownedTexture.width, cast(ushort) ownedTexture.height);
		return true;
	}

	bool loadFromMemory(const ubyte[] data, const string fileType)
	{
		if (data.length == 0)
			return false;
		unloadOwned();
		raylib.Image rlImg = LoadImageFromMemory(toStringz(fileType), cast(ubyte*) data.ptr, cast(int) data.length);
		if (rlImg.data is null)
			return false;
		ownedTexture = LoadTextureFromImage(rlImg);
		UnloadImage(rlImg);
		if (ownedTexture.id == 0)
			return false;
		imageDataValue = &ownedTexture;
		setFixedSize(cast(ushort) ownedTexture.width, cast(ushort) ownedTexture.height);
		return true;
	}

	// Loads image form URL, defaults imageType to .png
	bool loadFromUrl(string url, string imageType = ".png")
	{
		if (url.length == 0)  return false;
		// if the url doesn't return data we're fucked
		// TODO: fix.
		this.loadFromMemory(std.net.curl.get!(HTTP, ubyte)(url), imageType);
		return true;
	}

	private void unloadOwned()
	{
		if (ownedTexture.id != 0)
		{
			UnloadTexture(ownedTexture);
			ownedTexture = Texture2D.init;
		}
		if (imageDataValue == &ownedTexture)
			imageDataValue = null;
	}

	void setImageData(void* ptr)
	{
		unloadOwned();
		imageDataValue = ptr;
	}

	const(void)* imageData() const
	{
		return imageDataValue;
	}

	void setFixedSize(ushort width, ushort height)
	{
		decl.layout.sizing.width = claySizingFixed(width);
		decl.layout.sizing.height = claySizingFixed(height);
	}
}

}
