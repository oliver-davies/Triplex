public int NUM_LIGHTS = 144 * 3;

TripleHelix buildModel() 
{
    return new TripleHelix();
}

public class Vector3 
{
    public double x, y, z;

    public Vector3(double ix, double iy, double iz) 
    {
        x = ix;
        y = iy;
        z = iz;
    }

    public Vector3(LXPoint p) 
    {
        x = p.x;
        y = p.y;
        z = p.z;
    }

    public Vector3 mult(double f) 
    {
        return new Vector3(x * f, y * f, z * f);
    }

    public Vector3 multVect(Vector3 v) 
    {
        return new Vector3(x * v.x, y * v.y, z * v.z);
    }

    public Vector3 add(Vector3 b)
    {
        return new Vector3(x + b.x, y + b.y, z + b.z);
    }

    public Vector3 sub(Vector3 b)
    {
        return new Vector3(x - b.x, y - b.y, z - b.z);
    }

    public double magnitude() 
    {
        return Math.sqrt(x*x+y*y+z*z);
    }

    public void normalizeInPlace() 
    {
        double mag = magnitude();
        x /= mag;
        y /= mag;
        z /= mag;
    }

    public LXPoint toLXPoint()
    {
        return new LXPoint(x,y,z);
    }
}

public class Edge
{
    public Vector3[] fillerPoints;

    public Edge(Vector3[] points, int ledCount)
    {
        fillerPoints = new Vector3[ledCount];
        int perSection = (int)(ledCount/(points.length - 1));
        for (int i = 0; i < points.length - 1; i++)
        {
            Vector3 direction = points[i+1].sub(points[i]);
            for(int j = 0; j < perSection; j++)
            {
                fillerPoints[(i * perSection) + j] = points[i].add(direction.mult((float)j/perSection));
            }
        }
    }
}

public class Triangle 
{
    public Vector3 center;
    public Vector3 v1, v2, v3;
    public Vector3[] fillerPoints;

    public Triangle(Vector3 c, float rotation, float radius, int countPerEdge)
    {
        center = c;

        v1 = c.add(new Vector3(radius * cos(radians(0 + rotation)), radius * sin(radians(0 + rotation)), 0));
        v2 = c.add(new Vector3(radius * cos(radians(120 + rotation)), radius * sin(radians(120 + rotation)), 0));
        v3 = c.add(new Vector3(radius * cos(radians(240 + rotation)), radius * sin(radians(240 + rotation)), 0));

        fillerPoints = new Vector3[countPerEdge * 3];

        // v1 -> v2
        Vector3 v12 = v2.sub(v1);
        for (int i = 0; i < countPerEdge; i++)
        {
            fillerPoints[i] = v1.add(v12.mult( ((float)i)/countPerEdge));
        }

        // v2 -> v3
        Vector3 v23 = v3.sub(v2);
        for (int i = 0; i < countPerEdge; i++)
        {
            fillerPoints[i + countPerEdge] = v2.add(v23.mult( ((float)i)/countPerEdge));
        }

        // v3 -> v1
        Vector3 v31 = v1.sub(v3);
        for (int i = 0; i < countPerEdge; i++)
        {
            fillerPoints[i + (countPerEdge * 2)] = v3.add(v31.mult( ((float)i)/countPerEdge));
        }
    }
}

public class TripleHelix extends LXModel 
{
    public final int SIZE = 9;
    public Triangle[] triangles;
    public Edge[] edges;

    public int triangleLength = 0;
    public int edgesLength = 0;

    public TripleHelix() 
    {
        // Broken here, this is a super frustrating limitation.
        // Yay inheritance =/
        super(PopulateFixtures());
    }

    private void PopulateFixtures()
    {
        ArrayList<LXAbstractFixture> fixtures = new ArrayList<LXAbstractFixture>();

        // Triangles
        triangles = new Triangle[SIZE];
        for (int z = 0; z <= SIZE - 1; ++z) 
        {
            triangles[z] = new Triangle(new Vector3(5, 5, z*5 - 10), 90 + (z * 15), 10, 144);

            LXTriangle tri = new LXTriangle(triangles[z]);
            triangleLength += tri.getPoints().size();

            fixtures.add(tri);
        }

        // Edges
        Vector3[] v1s = new Vector3[triangles.length];
        Vector3[] v2s = new Vector3[triangles.length];
        Vector3[] v3s = new Vector3[triangles.length];

        for(int i = 0; i < triangles.length; i++)
        {
            v1s[i] = triangles[i].v1;
            v2s[i] = triangles[i].v2;
            v3s[i] = triangles[i].v3;
        }

        edges[0] = new Edge(v1s, 296);
        edges[1] = new Edge(v2s, 296);
        edges[2] = new Edge(v3s, 296);

        LXEdge helix1 = new LXEdge(edges[0]);
        LXEdge helix2 = new LXEdge(edges[1]);
        LXEdge helix3 = new LXEdge(edges[2]);
        
        edgesLength += helix1.getPoints().size();
        edgesLength += helix2.getPoints().size();
        edgesLength += helix3.getPoints().size();

        fixtures.add(helix1);
        fixtures.add(helix2);
        fixtures.add(helix3);
        
        return fixtures.toArray(new LXAbstractFixture[fixtures.size()]);
    }

    private class LXEdge extends LXAbstractFixture 
    {
        LXEdge(Edge edge)
        {
            PopulateFixture(edge);
        }

        private void PopulateFixture(Edge edge)
        {
            for (int i = 0; i < edge.fillerPoints.length; i++)
            {
                if(edge.fillerPoints[i] == null) continue;
                addPoint(edge.fillerPoints[i].toLXPoint());
            }
        }
    }

    private class LXTriangle extends LXAbstractFixture 
    {
        LXTriangle(Triangle triangle) 
        {
            PopulateFixture(triangle);
        }

        private void PopulateFixture(Triangle triangle)
        {
            Vector3[] fillerPoints = triangle.fillerPoints;
            for (int i = 0; i < fillerPoints.length; i++)
            {
                addPoint(fillerPoints[i].toLXPoint());
            }
        }
    }
}
