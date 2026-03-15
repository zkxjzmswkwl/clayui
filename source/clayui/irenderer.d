module clayui.irenderer;

import clayd;

interface IRenderer
{
	void render(const Clay_RenderCommandArray commands);

	void beginFrame();

	void endFrame();
}
