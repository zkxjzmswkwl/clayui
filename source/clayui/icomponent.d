module clayui.icomponent;

import clayui.ilayout_context;

// any ui component that can build itself into a layout context
interface IComponent
{
	void build(ILayoutContext ctx);
}
