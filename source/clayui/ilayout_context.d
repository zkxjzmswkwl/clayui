module clayui.ilayout_context;

import clayd;

// passed to components when building layout 
interface ILayoutContext
{
	void openElement(Clay_ElementId id, ref const Clay_ElementDeclaration decl);

	void openElementAutoId(ref const Clay_ElementDeclaration decl);

	 // element must have previously been opened
	void closeElement();

	// apply declaration to current (open) element.
	void configureCurrentElement(ref const Clay_ElementDeclaration decl);

	void addText(Clay_String text, ref Clay_TextElementConfig config);

 	// only valid until next layout
	Clay_TextElementConfig* storeTextConfig(Clay_TextElementConfig config);

	// for scrolled containers, returns current scroll offset
	Clay_Vector2 getScrollOffset();

	bool hovered();

	// whether element clicked this frame
	bool clicked();

	// same as hovered, but for a specific element.
	// intended to cover cases where elements change can be changed between hover->click.
	// name is bad
	bool pointerOver(Clay_ElementId id);

	bool pointerPressedThisFrame();

	Clay_ElementId elementId(const char[] label);

	Clay_ElementId elementIdWithIndex(const char[] label, uint index);
}
