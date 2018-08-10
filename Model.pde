TripleHelix buildModel() 
{
    return new TripleHelix();
}

public static class TripleHelix extends LXModel 
{
  
    public static final int TRIANGLE_COUNT = 9;
    public static final int EDGE_COUNT = 3;
    
    public final Triangle[] triangles;
    public final Edge[] edges;

    public TripleHelix() 
    {
        super(new Fixture());
        Fixture f = (Fixture) this.fixtures.get(0);
        this.triangles = f.triangles;
        this.edges = f.edges;
    }
    
    static class Fixture extends LXAbstractFixture
    {
        final Triangle[] triangles = new Triangle[TRIANGLE_COUNT];
        final Edge[] edges = new Edge[EDGE_COUNT];
        
        Fixture()
        {
            LXTransform t = new LXTransform();
            t.translate(5, 5);
            for (int i = 0; i < triangles.length; ++i)
            {
                addPoints(this.triangles[i] = new Triangle(t, i));
                t.translate(0, 0, 5);
                t.rotateZ(PI/12);
            }
            for (int i = 0; i < edges.length; ++i)
            {
                addPoints(this.edges[i] = new Edge(this.triangles, i));
            }
        }
    }
}

public static class Triangle extends LXModel
{
    // NOTE: an arbitrary 10 is fine... but you might want to define this as an
    // actual dimension, like setting SIDE_LENGTH = 8*FT and computing the
    // rest based upon that...
    public static final float RADIUS = 10;
    public static final float SIDE_LENGTH = RADIUS * sqrt(3); 
    public static final int SIDE_LED_COUNT = 144;
    public static final float LED_SPACING = SIDE_LENGTH / SIDE_LED_COUNT;
    
    public final int index;
    public final LXVector center;
    public final LXVector[] vertex;
    
    public Triangle(LXTransform center, int index)
    {
        super(new Fixture(center));
        this.index = index;
        Fixture f = (Fixture) this.fixtures.get(0);
        this.center = center.vector();
        this.vertex = f.vertex;
    }
    
    static class Fixture extends LXAbstractFixture
    {
        final LXVector[] vertex = new LXVector[3];
      
        Fixture(LXTransform t)
        {
            // t begins at the center of the triangle
            t.push();
            
            // Move to the top of the triangle
            t.translate(0, RADIUS);
            
            // Rotate to direction of first triangle side
            t.rotateZ(-2*PI/3);
            
            for (int side = 0; side < 3; ++side) {
              // Store the vertex position
              this.vertex[side] = t.vector();
              
              // Iterate along the side of the triangle
              t.translate(LED_SPACING/2., 0);
              for (int e = 0; e < SIDE_LED_COUNT; ++e) {
                addPoint(new LXPoint(t));
                t.translate(LED_SPACING, 0);
              }
              t.translate(-LED_SPACING/2., 0);
              
              // Rotate to next triangle side
              t.rotateZ(2*PI/3);
            }
            
            // Put t back how it started
            t.pop();
        }
    }
}

public static class Edge extends LXModel
{
  
    public static final int LED_COUNT = 296;
    
    public Edge(Triangle[] triangles, int v)
    {
       super(new Fixture(triangles, v));
    }
    
    public static class Fixture extends LXAbstractFixture
    {
        Fixture(Triangle[] triangles, int v)
        {
            int numSections = triangles.length - 1;
            int ledsPerSection = LED_COUNT / numSections;
            for (int t = 1; t < triangles.length; ++t)
            {
                LXVector from = triangles[t-1].vertex[v];
                LXVector to = triangles[t].vertex[v];
                LXVector step = to.copy().add(from.copy().mult(-1.));
                float stepSize = step.mag() / ledsPerSection;
                step.normalize().mult(stepSize);
                for (int l = 0; l < ledsPerSection; ++l) {
                  addPoint(new LXPoint(from));
                  from.add(step);
                }
            }
        }
    }
}
