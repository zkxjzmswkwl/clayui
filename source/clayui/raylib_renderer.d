module clayui.raylib_renderer;

import clayd;
import clayui.irenderer;
import raylib;
import std.math.rounding : round;

final class RaylibRenderer : IRenderer
{
	private int defaultFontSizeValue = 16;
	// if not null, uses DrawTextEx
	private Font* fontPtr = null;

	void defaultFontSize(int size)
	{
		defaultFontSizeValue = size;
	}

	int defaultFontSize() const
	{
		return defaultFontSizeValue;
	}

	// if font is nullptr, uses raylib's god awful default font.
	void setFont(Font* font)
	{
		fontPtr = font;
	}

	const(Font)* font() const
	{
		return fontPtr;
	}

	override void beginFrame(){}
	override void endFrame(){}

	override void render(const Clay_RenderCommandArray commands)
	{
		if (commands.length <= 0)
		{
			DrawRectangle(50, 50, 400, 80, raylib.Color(180, 0, 0, 255));
			DrawText("Layout: 0 commands", 60, 70, 20, raylib.Color(255, 255, 255));
			return;
		}
		for (int i = 0; i < commands.length; i++)
		{
			Clay_RenderCommand* cmd = clayRenderCommandArrayGet(cast(Clay_RenderCommandArray*)&commands, i);
			if (cmd is null)
				continue;
			renderCommand(cmd);
		}
	}

	private void renderCommand(const Clay_RenderCommand* cmd)
	{
		final switch (cmd.commandType)
		{
		case Clay_RenderCommandType.renderCommandTypeNone:
			break;
		case Clay_RenderCommandType.renderCommandTypeRectangle:
			drawRectangle(cmd);
			break;
		case Clay_RenderCommandType.renderCommandTypeText:
			drawText(cmd);
			break;
		case Clay_RenderCommandType.renderCommandTypeScissorStart:
			BeginScissorMode(
				cast(int) cmd.boundingBox.x,
				cast(int) cmd.boundingBox.y,
				cast(int) cmd.boundingBox.width,
				cast(int) cmd.boundingBox.height);
			break;
		case Clay_RenderCommandType.renderCommandTypeScissorEnd:
			EndScissorMode();
			break;
		case Clay_RenderCommandType.renderCommandTypeBorder:
			drawBorder(cmd);
			break;
		case Clay_RenderCommandType.renderCommandTypeImage:
			drawImage(cmd);
			break;
		case Clay_RenderCommandType.renderCommandTypeCustom:
			break;
		}
	}

	private void drawRectangle(const Clay_RenderCommand* cmd)
	{
		const Clay_RectangleRenderData* rd = &cmd.renderData.rectangle;
		Color c = clayColorToRaylib(rd.backgroundColor);
		DrawRectangle(
			cast(int) cmd.boundingBox.x,
			cast(int) cmd.boundingBox.y,
			cast(int) cmd.boundingBox.width,
			cast(int) cmd.boundingBox.height,
			c
		);
	}

	// max buffer size of 4095
	private void drawText(const Clay_RenderCommand* cmd)
	{
		const Clay_TextRenderData* rd = &cmd.renderData.text;
		if (rd.stringContents.chars is null || rd.stringContents.length <= 0)
			return;

		float fontSize = cast(float) defaultFontSizeValue;
		if (rd.fontSize > 0)
			fontSize = cast(float) rd.fontSize;

		int len = rd.stringContents.length;
		if (len > 4095)
			len = 4095;

		ubyte[4096] buf = 0;
		foreach (i; 0 .. len)
			buf[i] = cast(ubyte) rd.stringContents.chars[i];
		buf[len] = 0;

		Color c = clayColorToRaylib(rd.textColor);

		Vector2 pos;
		pos.x = round(cmd.boundingBox.x);
		pos.y = round(cmd.boundingBox.y);

		float spacing = cast(float) rd.letterSpacing;
		if (fontPtr !is null)
			DrawTextEx(*fontPtr, cast(const(char)*)buf.ptr, pos, fontSize, spacing, c);
		else
			DrawText(cast(const(char)*)buf.ptr, cast(int)pos.x, cast(int)pos.y, cast(int)fontSize, c);
	}

	private void drawBorder(const Clay_RenderCommand* cmd)
	{
		const Clay_BorderRenderData* rd = &cmd.renderData.border;
		Color c = clayColorToRaylib(rd.color);
		float x = cmd.boundingBox.x;
		float y = cmd.boundingBox.y;
		float w = cmd.boundingBox.width;
		float h = cmd.boundingBox.height;
		if (rd.width.left > 0)
			DrawRectangle(cast(int) x, cast(int) y, rd.width.left, cast(int) h, c);
		if (rd.width.right > 0)
			DrawRectangle(cast(int)(x + w - rd.width.right), cast(int) y, rd.width.right, cast(int) h, c);
		if (rd.width.top > 0)
			DrawRectangle(cast(int) x, cast(int) y, cast(int) w, rd.width.top, c);
		if (rd.width.bottom > 0)
			DrawRectangle(cast(int) x, cast(int)(y + h - rd.width.bottom), cast(int) w, rd.width.bottom, c);
	}

	private void drawImage(const Clay_RenderCommand* cmd)
	{
		const Clay_ImageRenderData* rd = &cmd.renderData.image;
		if (rd.imageData is null)
			return;
		Texture2D* texPtr = cast(Texture2D*) rd.imageData;
		if (texPtr is null || texPtr.id == 0)
			return;
		Rectangle source = Rectangle(0, 0, cast(float) texPtr.width, cast(float) texPtr.height);
		Rectangle dest = Rectangle(
			cmd.boundingBox.x,
			cmd.boundingBox.y,
			cmd.boundingBox.width,
			cmd.boundingBox.height
		);
		Vector2 origin = Vector2(0, 0);
		Color tint;
		if (rd.backgroundColor.r == 0 && rd.backgroundColor.g == 0 && rd.backgroundColor.b == 0 && rd
			.backgroundColor.a == 0)
			tint = raylib.Color(255, 255, 255, 255);
		else
			tint = clayColorToRaylib(rd.backgroundColor);
		DrawTexturePro(*texPtr, source, dest, origin, 0, tint);
	}

	private static Color clayColorToRaylib(Clay_Color clayColor)
	{
		Color c;
		c.r = cast(ubyte) clayColor.r;
		c.g = cast(ubyte) clayColor.g;
		c.b = cast(ubyte) clayColor.b;
		c.a = cast(ubyte) clayColor.a;
		return c;
	}
}
