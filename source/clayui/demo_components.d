module clayui.demo_components;

/// Shared custom [`Component`]s used by `component_example` and `sdl3_example`.

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
		text.setTextColor(255, 255, 255, 255);

		setPadding(6);
		setCornerRadius(10);
		setBackgroundColor(88, 101, 242, 255);
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
		setBackgroundColor(210, 210, 220, 255);
		layout().sizing.width = claySizingGrow();
		layout().sizing.height = claySizingFixed(1);
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
		keyLabel.setTextColor(110, 110, 120, 255);
		valueLabel.setTextColor(30, 30, 35, 255);
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
		setBackgroundColor(255, 255, 255, 255);
		setBorderWidth(1);
		setBorderColor(220, 220, 230, 255);

		title = new Label("", "Custom components");
		title.setFontSize(18);
		title.setTextColor(40, 40, 50, 255);

		status = new Badge("statusBadge", "online");
		status.setCaption("online");

		sep = new Divider("profileSep");

		row1 = new KeyValueRow("", "Role", "Contributor");
		row2 = new KeyValueRow("", "Repo", "clayui");
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
