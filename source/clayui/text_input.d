module clayui.text_input;

import clayd;
import clayui.panel;
import clayui.label;
import clayui.icomponent;
import clayui.ilayout_context;
import std.algorithm;
import std.uni;
import std.utf;

class TextInput : Panel
{
	private string buffer;
	private string placeholder = "";
	private ushort fontSizeValue = 18;
	private bool focusedValue;
	private void delegate(TextInput) onFocusRequested;

	private size_t caret;
	private size_t selectionAnchor;

	this(string id = "textInput")
	{
		super(id, Clay_LayoutDirection.leftToRight);
		decl.clip.horizontal = true;
		decl.clip.vertical = false;
		decl.clip.childOffset = Clay_Vector2(0, 0);
		setBackgroundColor(255, 255, 255);
		setPadding(12);
	}

	private bool hasSelection() const
	{
		return selectionAnchor != caret;
	}

	private size_t selectionLo() const
	{
		return min(selectionAnchor, caret);
	}

	private size_t selectionHi() const
	{
		return max(selectionAnchor, caret);
	}

	private size_t prevCodepointStart(size_t pos) const
	{
		if (pos == 0 || !buffer.length)
			return 0;
		size_t i = pos;
		do
			i--;
		while (i > 0 && (buffer[i] & 0xC0) == 0x80);
		return i;
	}

	private size_t nextCodepointStart(size_t pos) const
	{
		if (pos >= buffer.length)
			return buffer.length;
		return pos + stride(buffer, pos);
	}

	private dchar dcharBeforeBytePos(size_t pos) const
	{
		assert(pos > 0 && pos <= buffer.length);
		const size_t p = prevCodepointStart(pos);
		size_t q = p;
		return decode(buffer, q);
	}

	private static bool isWordChar(dchar c) pure
	{
		return c == '_' || isAlphaNum(c);
	}

	private void replaceRange(size_t a, size_t b, string insert)
	{
		if (buffer is null)
			buffer = "";
		assert(a <= b && a <= buffer.length && b <= buffer.length);
		buffer = buffer[0 .. a] ~ insert ~ buffer[b .. $];
		caret = a + insert.length;
		selectionAnchor = caret;
	}

	private void deleteRange(size_t a, size_t b)
	{
		replaceRange(a, b, null);
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
		if (idValue.length > 0 && onFocusRequested && ctx.clicked())
			onFocusRequested(this);
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
		if (!focused)
			selectionAnchor = caret;
	}

	bool focused() const
	{
		return focusedValue;
	}

	void setOnFocusRequested(void delegate(TextInput) dg)
	{
		onFocusRequested = dg;
	}

	void moveCaretLeft(bool extendSelection)
	{
		if (extendSelection)
		{
			if (caret == 0)
				return;
			caret = prevCodepointStart(caret);
			return;
		}
		if (hasSelection())
		{
			caret = selectionLo();
			selectionAnchor = caret;
			return;
		}
		if (caret == 0)
			return;
		caret = prevCodepointStart(caret);
		selectionAnchor = caret;
	}

	void moveCaretRight(bool extendSelection)
	{
		if (extendSelection)
		{
			if (caret >= buffer.length)
				return;
			caret = nextCodepointStart(caret);
			return;
		}
		if (hasSelection())
		{
			caret = selectionHi();
			selectionAnchor = caret;
			return;
		}
		if (caret >= buffer.length)
			return;
		caret = nextCodepointStart(caret);
		selectionAnchor = caret;
	}

	void moveCaretHome(bool extendSelection)
	{
		if (extendSelection)
		{
			caret = 0;
			return;
		}
		if (hasSelection())
		{
			caret = selectionLo();
			selectionAnchor = caret;
			return;
		}
		caret = 0;
		selectionAnchor = 0;
	}

	void moveCaretEnd(bool extendSelection)
	{
		if (extendSelection)
		{
			caret = buffer.length;
			return;
		}
		if (hasSelection())
		{
			caret = selectionHi();
			selectionAnchor = caret;
			return;
		}
		caret = buffer.length;
		selectionAnchor = caret;
	}

	void appendChar(dchar c)
	{
		if (c >= 32 && c != 127)
			insertText(std.utf.toUTF8([c]));
	}

	void appendText(string s)
	{
		insertText(s);
	}

	void insertText(string s)
	{
		char[] filtered;
		foreach (dchar c; s)
		{
			if (c == '\r' || c == '\n')
				continue;
			if (c == '\t')
				c = ' ';
			if (c >= 32 && c != 127)
				filtered ~= std.utf.toUTF8([c]);
		}
		if (!filtered.length)
			return;
		if (hasSelection())
			deleteRange(selectionLo(), selectionHi());
		replaceRange(caret, caret, cast(string) filtered);
	}

	void backspace()
	{
		if (hasSelection())
		{
			deleteRange(selectionLo(), selectionHi());
			return;
		}
		if (caret == 0)
			return;
		deleteRange(prevCodepointStart(caret), caret);
	}

	void deleteWordLeft()
	{
		if (buffer is null || buffer.length == 0)
			return;
		if (hasSelection())
		{
			deleteRange(selectionLo(), selectionHi());
			return;
		}
		size_t pos = caret;
		if (pos == 0)
			return;
		size_t i = pos;
		while (i > 0)
		{
			const dchar c = dcharBeforeBytePos(i);
			if (!isWhite(c))
				break;
			i = prevCodepointStart(i);
		}
		while (i > 0)
		{
			const dchar c = dcharBeforeBytePos(i);
			if (!isWordChar(c))
				break;
			i = prevCodepointStart(i);
		}
		while (i > 0)
		{
			const dchar c = dcharBeforeBytePos(i);
			if (isWhite(c) || isWordChar(c))
				break;
			i = prevCodepointStart(i);
		}
		if (i < pos)
			deleteRange(i, pos);
	}

	void deleteForward()
	{
		if (hasSelection())
		{
			deleteRange(selectionLo(), selectionHi());
			return;
		}
		if (caret >= buffer.length)
			return;
		deleteRange(caret, nextCodepointStart(caret));
	}

	string getBuffer() const
	{
		return buffer;
	}

	void clearBuffer()
	{
		buffer = null;
		caret = 0;
		selectionAnchor = 0;
	}

	void setPlaceholder(string s)
	{
		placeholder = s;
	}

	void setFontSize(ushort size)
	{
		fontSizeValue = size;
	}

	ushort labelFontSize() const pure nothrow @nogc @safe
	{
		return fontSizeValue;
	}

	const(char)[] labelUtf8() const pure nothrow @nogc @safe
	{
		return buffer.length ? buffer : placeholder;
	}

	size_t caretByte() const pure nothrow @nogc @safe
	{
		return caret;
	}

	bool copySelectionBounds(out size_t lo, out size_t hi) const
	{
		if (!hasSelection())
			return false;
		lo = selectionLo();
		hi = selectionHi();
		return true;
	}

	float horizontalScrollPixels() const pure nothrow @nogc @safe
	{
		return -decl.clip.childOffset.x;
	}

	Clay_Padding inputPadding() const pure nothrow @nogc @safe
	{
		return decl.layout.padding;
	}

	void syncHorizontalScrollAfterLayout(
		ref const Clay_ElementData el,
		float delegate(const(char)[] utf8, size_t byteEnd) measurePrefix
	) {
		if (!el.found || !layoutElementId().length)
			return;
		const Clay_Padding p = decl.layout.padding;
		const float innerW = el.boundingBox.width - cast(float)(p.left + p.right);
		if (innerW <= 1f)
			return;
		const(char)[] text = buffer.length ? buffer : placeholder;
		if (!text.length)
		{
			decl.clip.childOffset = Clay_Vector2(0f, decl.clip.childOffset.y);
			return;
		}
		const float contentW = measurePrefix(text, text.length);
		const float caretX = measurePrefix(text, caret);
		const float maxScroll = contentW > innerW ? contentW - innerW : 0f;
		float scroll = -decl.clip.childOffset.x;
		enum float margin = 4f;
		float caretInView = caretX - scroll;
		if (caretInView < margin)
			scroll = caretX - margin;
		else if (caretInView > innerW - margin)
			scroll = caretX - innerW + margin;
		if (scroll < 0f) scroll = 0f;
		if (scroll > maxScroll) scroll = maxScroll;
		decl.clip.childOffset = Clay_Vector2(-scroll, decl.clip.childOffset.y);
	}
}