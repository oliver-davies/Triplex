/** 
 * By using LX Studio, you agree to the terms of the LX Studio Software
 * License and Distribution Agreement, available at: http://lx.studio/license
 *
 * Please note that the LX license is not open-source. The license
 * allows for free, non-commercial use.
 *
 * HERON ARTS MAKES NO WARRANTY, EXPRESS, IMPLIED, STATUTORY, OR
 * OTHERWISE, AND SPECIFICALLY DISCLAIMS ANY WARRANTY OF
 * MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR A PARTICULAR
 * PURPOSE, WITH RESPECT TO THE SOFTWARE.
 */

// ---------------------------------------------------------------------------
//
// Welcome to LX Studio! Getting started is easy...
// 
// (1) Quickly scan this file
// (2) Look at "Model" to define your model
// (3) Move on to "Patterns" to write your animations
// 
// ---------------------------------------------------------------------------

// Reference to top-level LX instance
heronarts.lx.studio.LXStudio lx;

void setup() 
{
  // Processing setup, constructs the window and the LX instance
  size(1920, 1020, P3D);

  // Start Triplex
  TripleHelix triplex = buildModel();

  lx = new heronarts.lx.studio.LXStudio(this, triplex, MULTITHREADED);
  lx.ui.setResizable(RESIZABLE);
  lx.ui.setBackgroundColor(0);


  // Initialize networking
  try 
  {
    LXDatagramOutput datagramOutput = new LXDatagramOutput(lx); 
    lx.engine.output.addChild(datagramOutput);

    // // 1, 2, 3, 4, 5, 6, 7, 8, 9, H1, H2, H3
    // for (int i = 0; i < 12; i++)
    // {
    //   TriangleDatagram td = new TriangleDatagram(lx, triplex.structure.fixtures.get(i), (byte) 0x00);
    //   td.setAddress("192.168.1."+ (i + 40)).setPort(6969);
    //   datagramOutput.addDatagram(td);
    // }
    TriangleDatagram td = new TriangleDatagram(lx, triplex.structure.fixtures.get(0), (byte) 0x00);
    td.setAddress("192.168.1.51").setPort(6969);
    datagramOutput.addDatagram(td);
  }
  catch (Exception x) 
  {
    println("BAD ADDRESS: " + x.getLocalizedMessage());
    x.printStackTrace();
    exit();
  }

}

void initialize(heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) 
{

}

void onUIReady(heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) 
{
  // Add custom UI components here
  //UICollapsibleSection t = new UIBoardTest(ui, lx).setExpanded(true);
}

void draw() 
{
  // All is handled by LX Studio
}

// Configuration flags
final static boolean MULTITHREADED = true;
final static boolean RESIZABLE = true;

// Helpful global constants
final static float INCHES = 1;
final static float IN = INCHES;
final static float FEET = 12 * INCHES;
final static float FT = FEET;
final static float CM = 2.54 * IN;
final static float MM = CM * .1;
final static float M = CM * 00;
