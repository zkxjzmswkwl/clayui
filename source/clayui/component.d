module clayui.component;

import clayd;
import clayui.icomponent;
import clayui.ilayout_context;

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

	Component setGrow()
	{
		decl.layout.sizing.width = claySizingGrow();
		decl.layout.sizing.height = claySizingGrow();
		return this;
	}
}
