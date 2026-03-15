module clayui.label;

import clayd;
import clayui.component;
import clayui.icomponent;
import clayui.ilayout_context;

class Label : Component
{
	private string textValue;
	private Clay_TextElementConfig textConfig;

	this(string id = "", string text = "")
	{
		super(id);
		textValue = text;
		textConfig.fontSize = 16;
		textConfig.textColor = clayColor(0, 0, 0, 255);
	}

	override void build(ILayoutContext ctx)
	{
		if (idValue.length > 0)
		{
			Clay_ElementDeclaration decl = clayElementDeclaration();
			decl.layout.sizing.width = claySizingFit();
			decl.layout.sizing.height = claySizingFit();
			ctx.openElement(ctx.elementId(idValue), decl);
			scope (exit)
				ctx.closeElement();
		}
		Clay_TextElementConfig* cfg = ctx.storeTextConfig(textConfig);
		ctx.addText(clayString(textValue), *cfg);
	}

	void setText(string s)
	{
		textValue = s;
	}

	void setFontSize(ushort size)
	{
		textConfig.fontSize = size;
	}

	string text() const
	{
		return textValue;
	}

	void setTextColor(float r, float g, float b, float a = 255)
	{
		textConfig.textColor = clayColor(r, g, b, a);
	}

	void setTextAlignment(Clay_TextAlignment alignment)
	{
		textConfig.textAlignment = alignment;
	}
}
