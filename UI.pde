//public class UIRightPaneExtended extends UIRightPane
//{
//  public UIRightPaneExtended(final heronarts.lx.studio.LXStudio.UI ui, heronarts.lx.studio.LXStudio lx)
//  {
//    super(ui, lx);
//  }
  
//  @Override
//  public void onDraw(UI ui, PGraphics pg)
//  {
//    pg.stroke(#FFFFFF);
//    pg.fill(#000000);
//  }
//}

public class UIBoardTest extends UICollapsibleSection 
{
	public UIBoardTest(final heronarts.lx.studio.LXStudio.UI ui, LX lx) 
	{
		super(ui, 0, 0, ui.leftPane.global.getContentWidth(), 60);
		setTitle("Fixture Test");

		new UIButton(0, 20, getContentWidth(), 16)
		.setParameter(lx.engine.output.enabled)
		.setLabel("Test")
		.addToContainer(this);
	}
}
