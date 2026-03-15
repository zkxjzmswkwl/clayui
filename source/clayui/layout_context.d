module clayui.layout_context;

import clayd;
import clayui.ilayout_context;

// only valid between calls to beginLayout and endLayout
final class LayoutContext : ILayoutContext
{
	override void openElement(Clay_ElementId id, ref const Clay_ElementDeclaration decl)
	{
		clayOpenElementWithId(id);
		clayConfigureOpenElement(&decl);
	}

	override void openElementAutoId(ref const Clay_ElementDeclaration decl)
	{
		clayOpenElement();
		clayConfigureOpenElement(&decl);
	}

	override void closeElement()
	{
		clayCloseElement();
	}

	override void configureCurrentElement(ref const Clay_ElementDeclaration decl)
	{
		clayConfigureOpenElement(&decl);
	}

	override void addText(Clay_String text, ref Clay_TextElementConfig config)
	{
		clayOpenTextElement(text, &config);
	}

	override Clay_TextElementConfig* storeTextConfig(Clay_TextElementConfig config)
	{
		return clayStoreTextElementConfig(config);
	}

	override Clay_Vector2 getScrollOffset()
	{
		return clayGetScrollOffset();
	}

	override bool hovered()
	{
		return clayHovered();
	}

	override bool clicked()
	{
		return clayHovered() && clayGetPointerData().state == Clay_PointerDataInteractionState.pointerDataPressedThisFrame;
	}

	override bool pointerOver(Clay_ElementId id)
	{
		return clayPointerOver(id);
	}

	override bool pointerPressedThisFrame()
	{
		return clayGetPointerData().state == Clay_PointerDataInteractionState.pointerDataPressedThisFrame;
	}

	override Clay_ElementId elementId(const char[] label)
	{
		return clayId(label);
	}

	override Clay_ElementId elementIdWithIndex(const char[] label, uint index)
	{
		return clayIdWithIndex(label, index);
	}
}
