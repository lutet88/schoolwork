import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

class Pentagon {
    public int layer;

    public static Pentagon createPentaGrid(int maxDepth) {
        return new Pentagon(maxDepth-1, 0);
    }

    private Pentagon[] neighbors = new Pentagon[10];
    private Vec2[] vertices = new Vec2[5];
    private Line[] lines = new Line[5];
    private Vec2[] points = new Vec2[10];
    private Vec2 center;
    private double size;

    public Pentagon(Pentagon parent, int parentSide, int layer) {
        neighbors[parentSide] = parent;
        this.size = parent.size / 2;
        generateGeometry(parent, parentSide);
        this.layer = layer;
    }

    public void populate(int maxLayers) {
        if (layer >= maxLayers) return;
        for (int i = 0; i < 10; i++){
            if (neighbors[i] == null) neighbors[i] = new Pentagon(this, (i+5) % 10, layer+1);
        }
        for (int i = 0; i < 10; i++){
            if (neighbors[i].layer <= layer) continue;
            setStartingNeighbors(i, neighbors);
            neighbors[i].generateGeometry(this, (i+5) % 10);
            neighbors[i].populate(maxLayers);
        }
    }
    public Pentagon(int maxLayers, int layer) {
        this.layer = layer;
        this.size = 100;
        this.center = new Vec2(500, 500); // TODO: make this work for any window size
        generateDefaultGeometry();
        this.populate(maxLayers);
    }

    private void setStartingNeighbors(int i, Pentagon[] nbs) {
        if (i % 2 == layer % 2) {
            // side
            nbs[i].setNeighbor((i+4) % 10, nbs[(i+2) % 10]);
            nbs[i].setNeighbor((i+6) % 10, nbs[(i+8) % 10]);
            nbs[i].setNeighbor((i+3) % 10, nbs[(i+1) % 10]);
            nbs[i].setNeighbor((i+7) % 10, nbs[(i+9) % 10]);
        } else {
            // corner
            nbs[i].setNeighbor((i+4) % 10, nbs[(i+1) % 10]);
            nbs[i].setNeighbor((i+6) % 10, nbs[(i+9) % 10]);
        }
    }

    public Pentagon getNeighbor(int side){
        return neighbors[side];
    }

    public void setNeighbor(int side, Pentagon p){
        neighbors[side] = p;
    }

    public void generateDefaultGeometry() {
        for (int i = 0; i < 5; i++){
            double a1 = i * (Math.PI * 2 / 5);                     // multiples of 2pi/5 (72 degrees)
            double a2 = a1 + 0.7 * Math.PI;                        // 7pi/10 rotation from each end
            double l2 = size * 2 * Math.sin(Math.PI * 2 / 10);      // each side length is 2*sin(36)*center-vertex distance
            vertices[i] = center.polarOffset(a1, size);             // assign vertex to be polar offset with angle a1
            lines[i] = Line.createFromAngle(vertices[i], a2, l2);  // assign line to start at vertex and move a2 for l2
        }

        for (int i = 0; i < 5; i++) {
            points[(i*2+9) % 10] = vertices[i];
            points[(i*2) % 10] = vertices[i].average(vertices[(i+1) % 5]);
        }
    }

    // you're just gonna have to take my word that this method works.
    // all the calculations here are derived from my implementation of the Pentagon.
    public void generateGeometry(Pentagon parent, int parentSide) {
        // find and generate all the known sides

        if (parentSide % 2 == layer % 2) { // case: two sides meeting
            // vertices
            int lineAnchor = ((parentSide + 9) % 10) / 2;


            vertices[(lineAnchor + 1) % 5] = parent.vertices[((parentSide + 5) % 10) / 2];
            vertices[lineAnchor] = parent.vertices[((parentSide + 7) % 10) / 2];

            // known line
            lines[lineAnchor] = parent.lines[((parentSide + 5) % 10) / 2];

            // generate additional lines
            lines[(lineAnchor + 1) % 5] = Line.createFromAngle(vertices[(lineAnchor + 1) % 5],
                    parent.lines[((((parentSide + 5) % 10) + 8) % 10) / 2].getAngle(), size);
            lines[(lineAnchor + 4) % 5] = Line.createFromAngle(vertices[(lineAnchor) % 5],
                    Math.PI + parent.lines[((((parentSide + 5) % 10) + 2) % 10) / 2].getAngle(), size);

            vertices[(lineAnchor + 2) % 5] = lines[(lineAnchor + 1) % 5].p2;
            vertices[(lineAnchor + 4) % 5] = lines[(lineAnchor + 4) % 5].p2;

            // there will be two unknown sides, so we obtain the mean distance to the sides
            points[parentSide] = vertices[lineAnchor].average(vertices[(lineAnchor + 1) % 5]);
            double length = (
                    new Line(vertices[(lineAnchor + 2) % 5], points[parentSide]).getMagnitude() +
                    new Line(vertices[(lineAnchor + 4) % 5], points[parentSide]).getMagnitude())
                    / 2;

            // get the bisection of the angle from the point on the parentSide to each vertex
            double angle = new Line(points[parentSide], vertices[(lineAnchor + 2) % 5]
                                                .average(vertices[(lineAnchor + 4) % 5])).getAngle();

            // find the final vertex
            Vec2 finalVertex = points[parentSide].polarOffset(angle, length);
            vertices[(lineAnchor + 3) % 5] = finalVertex;

            // assign the last two lines
            lines[(lineAnchor + 2) % 5] = new Line(vertices[(lineAnchor + 2) % 5], finalVertex);
            lines[(lineAnchor + 3) % 5] = new Line(finalVertex, vertices[(lineAnchor + 4) % 5]);

        } else { // case: two corners meeting
            System.out.print(parentSide+": ");
            // points and vertices
            points[parentSide] = parent.points[(parentSide + 5) % 10];
            vertices[((parentSide + 1) % 10) / 2] = parent.vertices[((parentSide + 6) % 10) / 2];

            // generate additional lines
            int connectingVertex = ((parentSide + 1) % 10) / 2;
            lines[connectingVertex] = Line.createFromAngle(vertices[connectingVertex],
                    parent.lines[((parentSide + 5) % 10) / 2].getAngle(), size);
            lines[(connectingVertex + 4) % 5] = Line.createFromAngle(vertices[connectingVertex],
                    Math.PI + parent.lines[((((parentSide + 5) % 10) + 2) % 10) / 2].getAngle(), size);

            vertices[(connectingVertex + 1) % 5] = lines[connectingVertex].p2;
            vertices[(connectingVertex + 4) % 5] = lines[(connectingVertex + 4) % 5].p2;

            // there will be three unknown sides, so we perform an angle trisection
            Line l1 = new Line(points[parentSide], vertices[(connectingVertex + 1) % 5]);
            Line l2 = new Line(points[parentSide], vertices[(connectingVertex + 4) % 5]);

            System.out.println(points[parentSide]);
            System.out.println(connectingVertex);
            System.out.println(Arrays.toString(vertices));
            System.out.println(Arrays.toString(lines));

            double l1a = l1.getAngle();
            double l2a = l2.getAngle();
            if (Math.abs(l2a-l1a) > Math.PI) { // deal with discontinuity of arctan()
                l1a = Vec2.mod2Pi(l1a);
                l2a = Vec2.mod2Pi(l2a);
            }

            double a1 = (l1a * 2 + l2a) / 3;
            double a2 = (l1a + l2a * 2) / 3;

            System.out.println("angle "+l1.getAngle()+" and "+l2.getAngle()+", resulting in "+(l2.getAngle() - l1.getAngle()));

            // find length by taking a value between l1.mag and l2.mag
            double len1 = (l1.getMagnitude() * 2 + l2.getMagnitude()) / 3;
            double len2 = (l1.getMagnitude() + l2.getMagnitude() * 2) / 3;

            // create the rest of the vertices
            vertices[(connectingVertex + 2) % 5] = points[parentSide].polarOffset(a1, len1);
            vertices[(connectingVertex + 3) % 5] = points[parentSide].polarOffset(a2, len2);

            // generate the rest of the lines
            for (int i = 1; i <= 3; i++) {
                lines[(connectingVertex + i) % 5] = new Line(vertices[(connectingVertex + i) % 5],
                                                                vertices[(connectingVertex + i + 1) % 5]);
            }
        }

        // finish by generating points
        for (int i = 0; i < 5; i++) {
            points[(i*2+9) % 10] = vertices[i];
            // points[(i*2) % 10] = vertices[i].average(vertices[(i+1) % 5]);
        }
    }

    public Line[] getGeometry() {
        return lines;
    }

    public HashSet<Line[]> getGeometries(int maxDepth) {
        HashSet<Line[]> lines = new HashSet<Line[]>();
        for (int i = 0; i < 10; i++) {
            this.neighbors[i].getGeometries(lines, maxDepth, i);
        }
        return lines;
    }

    public void getGeometries(HashSet<Line[]> arr, int maxDepth, int direction) {
        if (layer >= maxDepth) return;
        arr.add(lines);
        for (int i = direction-1; i < direction+2; i++) {
            if (neighbors[(i+10) % 10] != null) neighbors[(i+10) % 10].getGeometries(arr, maxDepth, direction);
        }
    }

    @Override
    public String toString() {
        // simple redirect to toString(3) (default)
        return this.toString(3);
    }

    public String toString(int maxDepth) {
        StringBuilder sb = new StringBuilder();
        sb.append("Pentagon on layer ")
                .append(layer)
                .append("\n");
        for(int i = 0; i < 10; i++){
            if (neighbors[i] == null) continue;
            sb.append("\t"+i+": "+neighbors[i].toString(i, 2, maxDepth)+"\n");
        }
        return sb.toString();
    }

    public String toString(int side, int tabs, int maxDepth) {
        if (tabs > maxDepth) return "[" + this.hashCode() + "]";
        StringBuilder sb = new StringBuilder();

        sb.append("Pentagon ")
                .append(this.hashCode())
                .append(" on layer ")
                .append(layer);

        for (int i = 0; i < 10; i++) {
            if (neighbors[i % 10] == null) continue;

            sb.append("\n");
            for (int j = 0; j < tabs; j++) sb.append("\t");

            if ((i + 5) % 10 == side) {
                sb.append(i % 10)
                        .append(": Parent");
                continue;
            }

            sb.append(i % 10)
                    .append(": ")
                    .append(neighbors[i % 10].toString(i % 10, tabs + 1, maxDepth));
        }
        return sb.toString();
    }
}
