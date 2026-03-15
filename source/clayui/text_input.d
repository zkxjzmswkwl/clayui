module clayui.text_input;

import clayd;
import clayui.panel;
import clayui.label;
import clayui.icomponent;
import clayui.ilayout_context;
import std.utf;

class TextInput : Panel
{
	private string buffer;
	private string placeholder = "";
	private ushort fontSizeValue = 18;
	private bool focusedValue;
	private void delegate(TextInput) onFocusRequested;

	this(string id = "textInput")
	{
		super(id, Clay_LayoutDirection.leftToRight);
		setBackgroundColor(255, 255, 255);
		setPadding(12);
	}

	override void build(ILayoutContext ctx)
	{
		Clay_ElementId eid = idValue.length > 0 ? ctx.elementId(idValue) : Clay_ElementId.init;
		if (idValue.length > 0)
			ctx.openElement(eid, decl);
		else
			ctx.openElementAutoId(decl);

		scope (exit) ctx.closeElement();

		buildChildren(ctx);
		if (idValue.length > 0 && ctx.pointerOver(eid) && ctx.pointerPressedThisFrame() && onFocusRequested)
		{
			onFocusRequested(this);
		}
	}

	override void buildChildren(ILayoutContext ctx)
	{
		string displayText = buffer.length ? buffer : placeholder;
		auto label = new Label("", displayText);
		label.setFontSize(fontSizeValue);
		if (buffer.length)
			label.setTextColor(0, 0, 0);
		else
			label.setTextColor(128, 128, 128);
		label.build(ctx);
	}

	void setFocused(bool focused)
	{
		focusedValue = focused;
	}

	bool focused() const
	{
		return focusedValue;
	}

	void setOnFocusRequested(void delegate(TextInput) dg)
	{
		onFocusRequested = dg;
	}

	void appendChar(dchar c)
	{
		// printable + space. no control.
		if (c >= 32 && c != 127)
			buffer ~= std.utf.toUTF8([c]);
	}

	void backspace()
	{
		if (buffer.length > 0)
		{
			size_t drop = 1;
			while (drop <= buffer.length && (buffer[buffer.length - drop] & 0xC0) == 0x80)
				drop++;
			buffer = buffer[0 .. buffer.length - drop];
		}
	}

	string getBuffer() const
	{
		return buffer;
	}

	void clearBuffer()
	{
		buffer = null;
	}

	void setPlaceholder(string s)
	{
		placeholder = s;
	}

	void setFontSize(ushort size)
	{
		fontSizeValue = size;
	}
}
