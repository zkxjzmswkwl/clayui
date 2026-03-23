module clayui.demo_components;

import clayd;
import clayui.component;
import clayui.label;
import clayui.ilayout_context;

final class Badge : Component
{
	private Label text;

	this(string id = "", string caption = "badge")
	{
		super(id);
		text = new Label("", caption);
		text.setFontSize(12);
		text.setTextColor(50, 36, 34, 255);

		setPadding(6);
		setCornerRadius(10);
		setBackgroundColor(241, 217, 143, 255);
		layout().sizing.width = claySizingFit();
		layout().sizing.height = claySizingFit();
		layout().childAlignment.x = Clay_LayoutAlignmentX.alignXCenter;
		layout().childAlignment.y = Clay_LayoutAlignmentY.alignYCenter;
	}

	override void buildChildren(ILayoutContext ctx)
	{
		text.build(ctx);
	}

	void setCaption(string s)
	{
		text.setText(s);
	}
}

final class Divider : Component
{
	this(string id = "")
	{
		super(id);
		setBackgroundColor(241, 217, 143, 255);
		layout().sizing.width = claySizingGrow();
		layout().sizing.height = claySizingFixed(1);
	}
}

version (clay_sdl3)
{

import bindbc.sdl;

final class LoadRemoteImage : Component
{
	private clayui.Image image;

	this(string id = "", SDL_Renderer* renderer = null)
	{
		super(id);
		image = new clayui.Image("", renderer);
		layout().sizing.width = claySizingGrow();
		layout().sizing.height = claySizingGrow();
		layout().childAlignment.x = Clay_LayoutAlignmentX.alignXCenter;
		layout().childAlignment.y = Clay_LayoutAlignmentY.alignYCenter;
		setBackgroundColor(50, 36, 34, 255);
		setCornerRadius(8);
		setBorderWidth(2);
		setBorderColor(241, 217, 143, 255);
	}

	override void buildChildren(ILayoutContext ctx)
	{
		image.build(ctx);
	}

	void setImageUrl(string url)
	{
		image.loadFromUrl(url);
	}

	void setImageData(void* data)
	{
		image.setImageData(data);
	}

	void setSdlRenderer(SDL_Renderer* renderer)
	{
		image.setRenderer(renderer);
	}
}

}
else
{

final class LoadRemoteImage : Component
{
	private clayui.Image image;

	this(string id = "")
	{
		super(id);
		image = new clayui.Image();
		layout().sizing.width = claySizingGrow();
		layout().sizing.height = claySizingGrow();
		layout().childAlignment.x = Clay_LayoutAlignmentX.alignXCenter;
		layout().childAlignment.y = Clay_LayoutAlignmentY.alignYCenter;
		setBackgroundColor(50, 36, 34, 255);
		setCornerRadius(8);
		setBorderWidth(2);
		setBorderColor(241, 217, 143, 255);
	}

	override void buildChildren(ILayoutContext ctx)
	{
		image.build(ctx);
	}

	void setImageUrl(string url)
	{
		image.loadFromUrl(url);
	}

	void setImageData(void* data)
	{
		image.setImageData(data);
	}
}
}

final class KeyValueRow : Component
{
	private Label keyLabel;
	private Label valueLabel;

	this(string id = "", string keyText = "", string valueText = "")
	{
		super(id);
		layout().layoutDirection = Clay_LayoutDirection.leftToRight;
		layout().childGap = 10;
		layout().sizing.width = claySizingGrow();
		layout().sizing.height = claySizingFit();
		layout().childAlignment.y = Clay_LayoutAlignmentY.alignYCenter;

		keyLabel = new Label("", keyText);
		valueLabel = new Label("", valueText);
		keyLabel.setFontSize(14);
		valueLabel.setFontSize(14);
		keyLabel.setTextColor(241, 217, 143, 255);
		valueLabel.setTextColor(241, 217, 143, 255);
	}

	override void buildChildren(ILayoutContext ctx)
	{
		keyLabel.build(ctx);
		valueLabel.build(ctx);
	}
}

final class ProfileSnippet : Component
{
	private Label title;
	private Badge status;
	private Divider sep;
	private KeyValueRow row1;
	private KeyValueRow row2;

	this(string id = "")
	{
		super(id);
		layout().layoutDirection = Clay_LayoutDirection.topToBottom;
		layout().childGap = 8;
		layout().sizing.width = claySizingGrow();
		layout().sizing.height = claySizingFit();
		setPadding(14);
		setCornerRadius(8);
		setBackgroundColor(50, 36, 34, 255);
		setBorderWidth(2);
		setBorderColor(241, 217, 143, 255);

		title = new Label("", "Custom components");
		title.setFontSize(18);
		title.setTextColor(241, 217, 143, 255);

		status = new Badge("statusBadge", "online");
		status.setCaption("badge");

		sep = new Divider("profileSep");

		row1 = new KeyValueRow("", "Key", "Value");
		row2 = new KeyValueRow("", "Key", "Value");
	}

	override void buildChildren(ILayoutContext ctx)
	{
		title.build(ctx);
		status.build(ctx);
		sep.build(ctx);
		row1.build(ctx);
		row2.build(ctx);
	}
}
