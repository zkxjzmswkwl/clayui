module clayui.container;

import clayd;
import clayui.component;
import clayui.icomponent;
import clayui.ilayout_context;
import std.array;

// lays children out in row or column. gap optional.
class Container : Component
{
	private Clay_LayoutDirection directionValue;
	private ushort childGapValue;
	private IComponent[] children;

	this(string id = "", Clay_LayoutDirection direction = Clay_LayoutDirection.topToBottom)
	{
		super(id);
		directionValue = direction;
		decl.layout.layoutDirection = direction;
	}

	override void buildChildren(ILayoutContext ctx)
	{
		foreach (child; children)
			child.build(ctx);
	}

	void addChild(IComponent child)
	{
		children ~= child;
	}

	void clearChildren()
	{
		children.length = 0;
	}

	void setChildGap(ushort gap)
	{
		childGapValue = gap;
	}

	ushort childGap() const
	{
		return childGapValue;
	}

	override void build(ILayoutContext ctx)
	{
		decl.layout.childGap = childGapValue;
		super.build(ctx);
	}

	void setLayoutDirection(Clay_LayoutDirection d)
	{
		directionValue = d;
		decl.layout.layoutDirection = d;
	}

	Clay_LayoutDirection layoutDirection() const
	{
		return directionValue;
	}
}
