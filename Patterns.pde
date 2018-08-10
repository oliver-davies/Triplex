public abstract class TrianglePattern extends LXModelPattern<TripleHelix> 
{

    protected final Triangle[] triangles = model.triangles;
    protected final Edge[] edges = model.edges;

    public TrianglePattern(LX lx) 
    {
        super(lx);
    }

    public <T extends Comparable<T>> T clamp(T val, T min, T max) 
    {
        if (val.compareTo(min) < 0) return min;
        else if (val.compareTo(max) > 0) return max;
        else return val;
    }
}

// Note: there is alredy a SolidColorPattern with a nice UI. Recommend removing this...
// Find it in Browser | Patterns | Color
public class PatternSolid extends LXPattern 
{

    public final CompoundParameter h = new CompoundParameter("Hue", 0, 360);
    public final CompoundParameter s = new CompoundParameter("Sat", 0, 100);
    public final CompoundParameter b = new CompoundParameter("Brt", 100, 100);

    public PatternSolid(LX lx) 
    {
        super(lx);
        addParameter("h", this.h);
        addParameter("s", this.s);
        addParameter("b", this.b);
    }

    public void run(double deltaMs) 
    {
        setColors(LXColor.hsb(this.h.getValue(), this.s.getValue(), this.b.getValue()));
    }
}

public class PatternSweepTwirl extends TrianglePattern 
{
    public final CompoundParameter depthSweep = new CompoundParameter("DepthSweep", 0, 100);
    public final CompoundParameter radialSpread = new CompoundParameter("RadialSpread", 0, 16);

    //private LXModulator azimuthRotation = startModulator(new SawLFO(0, 1, 15000).randomBasis());
    //private LXModulator thetaRotation = startModulator(new SawLFO(0, 1, 13000).randomBasis());

    public PatternSweepTwirl(LX lx) 
    {
        super(lx);
        addParameter("depthSweep", this.depthSweep);
        addParameter("radialSpread", this.radialSpread);
    }

    public void run(double deltaMs) 
    {
        float rSpread = this.radialSpread.getValuef();
        float dSweep = this.depthSweep.getValuef();

        for (Triangle tri : triangles) 
        {
            double val = tri.index * 10 + dSweep;
            for (LXPoint p : tri.points)
            {
                double xDist = (tri.center.x - p.x);
                double yDist = (tri.center.y - p.y);
                
                // NOTE: gray expects values 0-100, you are depending on strange clipping behavior here
                setColor(p.index, LXColor.gray(val + ((xDist*xDist + yDist*yDist) * rSpread)));
            }
        }
    }
}

public class PatternRadialWarp extends TrianglePattern 
{
    public final CompoundParameter warpRadius = new CompoundParameter("Radius", 0, 16);
    public final CompoundParameter warpWidth = new CompoundParameter("Width", 0, 16);
    public final CompoundParameter crawl = new CompoundParameter("Crawl", 0, 6.28);

    public PatternRadialWarp(LX lx) 
    {
        super(lx);
        addParameter("depthSweep", this.warpRadius);
        addParameter("radialSpread", this.warpWidth);
        addParameter("crawl", this.crawl);
    }

    public void run(double deltaMs) 
    {
        float wRadius = (float)this.warpRadius.getValue();
        float wWidth = (float)this.warpWidth.getValue();
        float crawl = (float)this.crawl.getValue();

        for (Triangle tri : triangles) 
        {
            for (LXPoint p : tri.points)
            {
                double xDist = cos((float)(tri.center.x - p.x) + sin(crawl) * 2);
                double yDist = sin((float)(tri.center.y - p.y) + cos(crawl) * 2);
                // NOTE: you are depending upon weird clipping of negative and out of bounds values
                // to the gray function here... it seems to work, but this is brittle...
                setColor(p.index, LXColor.gray(((xDist*xDist + yDist*yDist) * wRadius - wWidth)));
            }
        }
    }
}

public class PatternOuterDash extends TrianglePattern 
{
    public final CompoundParameter speed = new CompoundParameter("Speed", 0, -1, 1);
    
    // NOTE: check out Accumulator: http://lx.studio/api/heronarts/lx/modulator/Accumulator.html
    // It will do this but handle the overflow problem
    private float timePassed = 0;

    public PatternOuterDash(LX lx) 
    {
        super(lx);
        addParameter("Speed", this.speed);
    }

    public void run(double deltaMs) 
    {
        float speed = (float)this.speed.getValue();
        timePassed += (float)deltaMs * speed * 0.05;
        for (Edge l : edges) 
        { 
            for (LXPoint point : l.points) 
            { 
                // NOTE: gray expects values in range 0-100
                double z = 50 + 50 * cos((float)(point.z) + timePassed);
                setColor(point.index, LXColor.gray(z));
            }
        }
    }
}

public class PatternOuterLineSweep extends TrianglePattern 
{
    public final CompoundParameter distance = new CompoundParameter("Distance", 0, -20, 50);
    public final CompoundParameter x = new CompoundParameter("X", 0, 1);
    public final CompoundParameter y = new CompoundParameter("Y", 0, 1);
    public final CompoundParameter z = new CompoundParameter("Z", 0, 1);
    public final CompoundParameter w = new CompoundParameter("Width", 0, 10);
    public final CompoundParameter amp = new CompoundParameter("Amplitude", 0, 20);

    public PatternOuterLineSweep(LX lx) 
    {
        super(lx);
        addParameter("Distance", this.distance);
        addParameter("X", this.x);
        addParameter("Y", this.y);
        addParameter("Z", this.z);
        addParameter("Width", this.w);
        addParameter("Amplitude", this.amp);
    }

    public void run(double deltaMs) 
    {
        float offset = (float)this.distance.getValue();
        float w = (float)this.w.getValue();
        float amp = (float)this.amp.getValue();
        PVector dir = new PVector(this.x.getValuef(), this.y.getValuef(), this.z.getValuef());
        for (Edge l : edges) 
        { 
            for (LXPoint p : l.points) 
            { 
                double xDist = Wave(p.x, amp, offset, w) * dir.x;
                double yDist = Wave(p.y, amp, offset, w) * dir.y;
                double zDist = Wave(p.z, amp, offset, w) * dir.z;
                float s = Sphere(new PVector(p.x, p.y, p.z), new PVector(0,0,0), 2);
                setColor(p.index, LXColor.gray(clamp(((float)(xDist + yDist + zDist) * 10), 0.0, 100.0)));
            }
        }
    }

    protected float Wave(float x, float amp, float offset, float width)
    {
        return amp * exp(-((x - offset) * (x - offset))/(2 * width * width));
    }

    protected float Sphere(PVector center, PVector position, float radius)
    {
        return Wave((float)position.copy().sub(center).mag(), 100.0f, 1.0f, radius);
    }
}

public class PatternSpheroid extends TrianglePattern 
{
    public final CompoundParameter offset = new CompoundParameter("Offset", 0, -50, 50);
    public final CompoundParameter x = new CompoundParameter("X", 0, -50, 50);
    public final CompoundParameter y = new CompoundParameter("Y", 0, -50, 50);
    public final CompoundParameter z = new CompoundParameter("Z", 0, -50, 50);
    public final CompoundParameter w = new CompoundParameter("Width", 0, 10);
    public final CompoundParameter amp = new CompoundParameter("Amplitude", 0, 100);

    public PatternSpheroid(LX lx) 
    {
        super(lx);
        addParameter("X", this.x);
        addParameter("Y", this.y);
        addParameter("Z", this.z);
        addParameter("Width", this.w);
        addParameter("Amplitude", this.amp);
        addParameter("Offset", this.offset);
    }

    public void run(double deltaMs) 
    {
        float offset = (float)this.offset.getValue();
        float w = (float)this.w.getValue();
        float amp = (float)this.amp.getValue();
        PVector origin = new PVector(this.x.getValuef(), this.y.getValuef(), this.z.getValuef());

        for (LXPoint p : model.points) 
        { 
            float s = Sphere(new PVector(p.x, p.y, p.z), origin, amp, w, offset);
            setColor(p.index, LXColor.gray(s));
        }
    }

    protected float Wave(float x, float amp, float offset, float width)
    {
        return amp * exp(-((x - offset) * (x - offset))/(2 * width * width));
    }

    protected float Sphere(PVector center, PVector position, float amp, float radius, float offset)
    {
        return Wave((float)position.copy().sub(center).mag(), amp, offset, radius);
    }
}

public static class ImprovedNoise 
{
   public static double noise(double x, double y, double z) {
      int X = (int)Math.floor(x) & 255,                  // FIND UNIT CUBE THAT
          Y = (int)Math.floor(y) & 255,                  // CONTAINS POINT.
          Z = (int)Math.floor(z) & 255;
      x -= Math.floor(x);                                // FIND RELATIVE X,Y,Z
      y -= Math.floor(y);                                // OF POINT IN CUBE.
      z -= Math.floor(z);
      double u = fade(x),                                // COMPUTE FADE CURVES
             v = fade(y),                                // FOR EACH OF X,Y,Z.
             w = fade(z);
      int A = p[X  ]+Y, AA = p[A]+Z, AB = p[A+1]+Z,      // HASH COORDINATES OF
          B = p[X+1]+Y, BA = p[B]+Z, BB = p[B+1]+Z;      // THE 8 CUBE CORNERS,

      return lerp(w, lerp(v, lerp(u, grad(p[AA  ], x  , y  , z   ),  // AND ADD
                                     grad(p[BA  ], x-1, y  , z   )), // BLENDED
                             lerp(u, grad(p[AB  ], x  , y-1, z   ),  // RESULTS
                                     grad(p[BB  ], x-1, y-1, z   ))),// FROM  8
                     lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  // CORNERS
                                     grad(p[BA+1], x-1, y  , z-1 )), // OF CUBE
                             lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
                                     grad(p[BB+1], x-1, y-1, z-1 ))));
   }
   static double fade(double t) { return t * t * t * (t * (t * 6 - 15) + 10); }
   static double lerp(double t, double a, double b) { return a + t * (b - a); }
   static double grad(int hash, double x, double y, double z) {
      int h = hash & 15;                      // CONVERT LO 4 BITS OF HASH CODE
      double u = h<8 ? x : y,                 // INTO 12 GRADIENT DIRECTIONS.
             v = h<4 ? y : h==12||h==14 ? x : z;
      return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
   }
   static final int p[] = new int[512], permutation[] = { 151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
   };
   static { for (int i=0; i < 256 ; i++) p[256+i] = p[i] = permutation[i]; }
}
