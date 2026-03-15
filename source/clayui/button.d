module clayui.button;

import clayd;
import clayui.panel;
import clayui.label;
import clayui.icomponent;
import clayui.ilayout_context;

class Button : Panel
{
	private string labelTextValue;
	private float textR = 0;
	private float textG = 0;
	private float textB = 0;
	private float textA = 255;
	private ushort fontSizeValue = 16;
	private bool centerText = true;
	private void delegate() onClick;

	this(string id = "", string labelText = "Button")
	{
		super(id, Clay_LayoutDirection.leftToRight);
		labelTextValue = labelText;
		setBackgroundColor(200, 200, 200, 255);
		setPadding(12);
	}

	override void build(ILayoutContext ctx)
	{
		// need to open first so hovered + clicked will return data for correct element
		Clay_ElementId eid = idValue.length > 0 ? ctx.elementId(idValue) : Clay_ElementId.init;
		if (idValue.length > 0)
			ctx.openElement(eid, decl);
		else
			ctx.openElementAutoId(decl);
		scope (exit)
			ctx.closeElement();

		if (ctx.clicked() && onClick)
			onClick();

		buildChildren(ctx);
	}

	override void buildChildren(ILayoutContext ctx)
	{
		// text alignment.
		Clay_ElementDeclaration innerDecl = clayElementDeclaration();
		innerDecl.layout.layoutDirection = Clay_LayoutDirection.leftToRight;
		innerDecl.layout.sizing.width = claySizingGrow();
		innerDecl.layout.sizing.height = claySizingFit();
		// no support for RTL text. should prob add.
		if (centerText)
			innerDecl.layout.childAlignment.x = Clay_LayoutAlignmentX.alignXCenter;
		else
			innerDecl.layout.childAlignment.x = Clay_LayoutAlignmentX.alignXLeft;
		innerDecl.layout.childAlignment.y = Clay_LayoutAlignmentY.alignYCenter;

		ctx.openElementAutoId(innerDecl);
		scope (exit) ctx.closeElement();

		Label label = new Label("", labelTextValue);
		label.setFontSize(fontSizeValue);
		label.setTextColor(textR, textG, textB, textA);
		if (centerText)
			label.setTextAlignment(Clay_TextAlignment.textAlignCenter);
		else 
			label.setTextAlignment(Clay_TextAlignment.textAlignLeft);
		label.build(ctx);
	}

	void setLabel(string s)
	{
		labelTextValue = s;
	}

	string label() const
	{
		return labelTextValue;
	}

	void setTextColor(float r, float g, float b, float a = 255)
	{
		textR = r;
		textG = g;
		textB = b;
		textA = a;
	}

	void setFontSize(ushort size)
	{
		fontSizeValue = size;
	}

	void setTextCentered(bool centered)
	{
		centerText = centered;
	}

	bool textCentered() const
	{
		return centerText;
	}

	void setOnClick(void delegate() dg)
	{
		onClick = dg;
	}
}
