module clayui.component;

import clayd;
import clayui.icomponent;
import clayui.ilayout_context;
import clayui.style;

abstract class Component : IComponent
{
	protected string idValue;
	protected Clay_ElementDeclaration decl;

	this(string id = "")
	{
		idValue = id;
		decl = clayElementDeclaration();
	}

	override void build(ILayoutContext ctx)
	{
		Clay_ElementId eid;
		if (idValue.length > 0)
			eid = ctx.elementId(idValue);
		else
			eid = Clay_ElementId.init;

		if (idValue.length > 0)
			ctx.openElement(eid, decl);
		else
			ctx.openElementAutoId(decl);

		scope (exit) ctx.closeElement();
		buildChildren(ctx);
	}

	protected void buildChildren(ILayoutContext ctx){}

	ref Clay_LayoutConfig layout()
	{
		return decl.layout;
	}

	Component setBackgroundColor(float r, float g, float b, float a = 255)
	{
		decl.backgroundColor = clayColor(r, g, b, a);
		return this;
	}

	Component setPadding(ushort p)
	{
		decl.layout.padding = clayPaddingAll(p);
		return this;
	}

	// rounding, impacts all corners
	Component setCornerRadius(float r)
	{
		decl.cornerRadius = clayCornerRadius(r);
		return this;
	}

	Component setBorderColor(float r, float g, float b, float a = 255)
	{
		decl.border.color = clayColor(r, g, b, a);
		return this;
	}

	Component setBorderWidth(ushort width)
	{
		decl.border.width.left = width;
		decl.border.width.right = width;
		decl.border.width.top = width;
		decl.border.width.bottom = width;
		return this;
	}

	Component setBorderWidth(ushort left, ushort right, ushort top, ushort bottom)
	{
		decl.border.width.left = left;
		decl.border.width.right = right;
		decl.border.width.top = top;
		decl.border.width.bottom = bottom;
		return this;
	}

	Component setGrow()
	{
		decl.layout.sizing.width = claySizingGrow();
		decl.layout.sizing.height = claySizingGrow();
		return this;
	}

	Component setStyle(Style style)
	{
		// TODO: look at what ldc2 outputs here.
		//       High chance it's wasteful. Not because the compiler is bad, but this is 5 function invocations
		//       for the sake of an API I *kinda* like.
		decl.backgroundColor = Clay_Color(style.red(), style.green(), style.blue(), style.alpha());
		// ditto
		decl.layout.padding = Clay_Padding(style.paddingLeft(), style.paddingRight(), style.paddingBottom(), style.paddingTop());
		return this;
	}

	Component setMaxWidthPerc(float perc)
	{
		decl.layout.sizing.width = claySizingPercent(perc);
		return this;
	}

	Component setMaxHeightPerc(float perc)
	{
		decl.layout.sizing.height = claySizingPercent(perc);
		return this;
	}

	Component setMaxWidth(float maxPixels)
	{
		decl.layout.sizing.width = claySizingGrow(0, maxPixels);
		return this;
	}

	Component setMaxHeight(float maxPixels)
	{
		decl.layout.sizing.height = claySizingGrow(0, maxPixels);
		return this;
	}

	const(char)[] layoutElementId() const pure nothrow @nogc @safe
	{
		return idValue;
	}
}
