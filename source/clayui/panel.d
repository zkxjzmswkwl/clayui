module clayui.panel;

import clayd;
import clayui.container;
import clayui.icomponent;
import clayui.ilayout_context;

class Panel : Container
{
	this(string id = "", Clay_LayoutDirection direction = Clay_LayoutDirection.topToBottom)
	{
		super(id, direction);
	}

	override void build(ILayoutContext ctx)
	{
		// need bg color so clay will emit properly
		if (decl.backgroundColor.r == 0 && decl.backgroundColor.g == 0 &&
			decl.backgroundColor.b == 0 && decl.backgroundColor.a == 0)
			decl.backgroundColor = clayColor(240, 240, 240, 255);
		super.build(ctx);
	}
}
