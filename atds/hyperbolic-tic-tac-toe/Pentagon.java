/*
** Oct 2021
** https://github.com/lutet88
*/

import java.util.*;


// Enumerator for which player owns a Pentagon.
enum Player {
    NONE,
    ONE,
    TWO
}

// Pentagon class is the Node class.
// each Pentagon is connected with 10 other Pentagons through Pentagon.neighbors[i]
class Pentagon {

    // ----------------------------------------- //
    // ----------------VARIABLES---------------- //
    // ----------------------------------------- //

    // recursive depth value, public for ease of use
    public int layer;

    // neighbors, containing the node's connections
    private Pentagon[] neighbors = new Pentagon[10];

    // geometry variables for rendering
    private Vec2[] vertices = new Vec2[5];  // vertices[i] points in the direction of neighbors[i*2-1]
    private Line[] lines = new Line[5];     // lines[i] faces the direction of neighbors[i*2]
    private Vec2[] points = new Vec2[10];   // formed where points[i*2] = vertices[i]
                                            //          and points[i*2+1] = lines[i].midpoint()
    private Vec2 center;  // calculated center of Pentagon in current projection
    private double size;  // center-to-corner length of Pentagon in current projection

    // each Pentagon contains a owner value indicating which player it currently belongs to
    private Player owner = Player.NONE;

    // ----------------------------------------- //
    // ---------------CONSTRUCTOR--------------- //
    // ----------------------------------------- //

    // createPentaGrid is an overload for Pentagon(int maxLayers, int layer) with default values.
    // maxDepth: Number of layers to form around the origin Pentagon.
    public static Pentagon createPentaGrid(int maxDepth) {
        return new Pentagon(maxDepth-1, 0);
    }

    // constructor as origin.
    // calls recursive method populate() to form Pentagons around itself.
    private Pentagon(int maxLayers, int layer) {
        this.layer = layer;
        this.size = 250;
        this.center = new Vec2(500, 500); // TODO: make this work for any window size
        generateDefaultGeometry();
        this.populate(maxLayers);
    }

    // constructor with parent.
    // simply creates and returns a Pentagon.
    private Pentagon(Pentagon parent, int parentSide, int layer) {
        neighbors[parentSide] = parent;
        this.size = parent.size / Math.sqrt(5);
        generateGeometry(parent, parentSide);
        this.layer = layer;
    }

    // recursive populate() method.
    // maxLayers: maximum layer (exclusive, origin=0) to populate
    // creates all neighbors then populates them.
    private void populate(int maxLayers) {
        // base case: too deep -> return
        if (layer >= maxLayers) return;

        // create all null neighbors
        for (int i = 0; i < 10; i++){
            if (neighbors[i] == null) neighbors[i] = new Pentagon(this, (i+5) % 10, layer+1);
        }

        // iterate back through neighbors
        for (int i = 0; i < 10; i++){
            // if it's closer to the origin or on the same layer as this,
            // don't set its neighbors or populate it (it's already been populated)
            if (neighbors[i].layer <= layer) continue;

            // set its neighbors on this layer
            setStartingNeighbors(i, neighbors);

            // generate geometry for rendering
            neighbors[i].generateGeometry(this, (i+5) % 10);

            // populate this neighbor (recursive call)
            neighbors[i].populate(maxLayers);
        }
    }

    // sets a Pentagon neighbor i's neighbors on its layer.
    // precondition: nbs is completely filled with Pentagons
    // precondition: 0 <= i < 10 (index in nbs to write neighbors for)
    private void setStartingNeighbors(int i, Pentagon[] nbs) {
        if (i % 2 == layer % 2) {
            // nbs[i] is a side-side connection
            nbs[i].setNeighbor((i+4) % 10, nbs[(i+2) % 10]);
            nbs[i].setNeighbor((i+6) % 10, nbs[(i+8) % 10]);
            nbs[i].setNeighbor((i+3) % 10, nbs[(i+1) % 10]);
            nbs[i].setNeighbor((i+7) % 10, nbs[(i+9) % 10]);
        } else {
            // nbs[i] is a corner-corner connection
            nbs[i].setNeighbor((i+4) % 10, nbs[(i+1) % 10]);
            nbs[i].setNeighbor((i+6) % 10, nbs[(i+9) % 10]);
        }
    }

    // returns the neighbor on {side} side of this Pentagon
    public Pentagon getNeighbor(int side) {
        return neighbors[side];
    }

    // sets a neighbor of this Pentagon
    private void setNeighbor(int side, Pentagon p) {
        neighbors[side] = p;
    }

    // ----------------------------------------- //
    // ---------------NAVIGATION---------------- //
    // ----------------------------------------- //

    // public navigate method.
    // redirects towards navigate(instructions, index)
    // instructions: int[] containing ints [0, 10) as directions to go
    public Pentagon navigate(int[] instructions) {
        return navigate(instructions, 0);
    }

    // recursive navigation function.
    private Pentagon navigate(int[] instructions, int index) throws NullPointerException{
        // base case: if no more instructions, return this Pentagon
        if (index >= instructions.length) return this;

        if (neighbors[instructions[index]] == null) throw new NullPointerException();
        // continue navigating, increment index
        return neighbors[instructions[index]].navigate(instructions, index+1);
    }

    // ----------------------------------------- //
    // ---------------GAME RULES---------------- //
    // ----------------------------------------- //

    // sets the owner of this tile.
    public void setOwner(Player p) {
        owner = p;
    }

    // gets the owner of this tile.
    public Player getOwner() {
        return owner;
    }

    // initial case for recursive hasWon()
    // runs hasWon(x, dir) for each direction from origin
    // checks if there are x-in-a-row through directionalTraverse()
    // returns Player that has won, otherwise Player.NONE
    // precondition: Pentagon must be origin!!!!!!
    public Player hasWon(int x) {
        for (int i = 0; i < 10; i++) {
            Player p = hasWon(x, i);
            if (p != Player.NONE) return p;
        }
        return Player.NONE;
    }

    // recursive case for hasWon()
    private Player hasWon(int x, int dir) {
        if (this.owner != Player.NONE) { // if this is not owned, not worth traversing for
            // for each direction,
            for (int i = 0; i < 10; i++) {
                // return the winning player if directionalTraverse returns them
                Player p = directionalTraverse(i, x, this.owner);
                if (p != Player.NONE) return p;
            }
        }

        // continue to run hasWon() for next 4 nodes in this direction
        // recursive base case is where all of its neighbors in the outer direction are null.
        for (int i = dir - 1; i < dir + 3; i++) {
            if (neighbors[(i + 10) % 10] == null) continue;
            Player p = neighbors[(i + 10) % 10].hasWon(x, dir);
            if (p != Player.NONE) return p;
        }

        // if no winning player has been returned, return default
        return Player.NONE;
    }

    // recursive traversal in a single direction.
    // tries to match with the match defined in the original tile.
    private Player directionalTraverse(int dir, int len, Player match) {
        if (len <= 0) return match;
        if (match != this.owner) return Player.NONE;
        return neighbors[dir].directionalTraverse(dir, len-1, match);
    }

    // ----------------------------------------- //
    // ----------STRING REPRESENTATION---------- //
    // ----------------------------------------- //

    // simple redirect to toString(3) (default)
    @Override
    public String toString() {
        return this.toString(3);
    }

    // builds the base string for recursively printing out Pentagons
    public String toString(int maxDepth) {
        StringBuilder sb = new StringBuilder();
        sb.append("Pentagon ")
            .append(this.hashCode())
            .append(" on layer ")
            .append(layer)
            .append(", owner: ")
            .append(owner)
            .append("\n");

        // for each neighbor,
        for(int i = 0; i < 10; i++) {
            // don't bother if there's no neighbor there
            if (neighbors[i] == null) continue;

            // add their toString(side, tabs, maxDepth) to the output StringBuilder
            sb.append("\t")
                .append(i)
                .append(": ")
                .append(neighbors[i].toString(i, 2, maxDepth))
                .append(", owner: ")
                .append(neighbors[i].getOwner())
                .append("\n");
        }
        return sb.toString();
    }

    // recursive toString case.
    // side: direction of this Pentagon from the caller
    // tabs: cumulative tabs from previous recursion
    private String toString(int side, int tabs, int maxDepth) {
        // base case: return hashCode if max depth is reached
        if (tabs > maxDepth) return "[" + this.hashCode() + "]";

        // build string header
        StringBuilder sb = new StringBuilder();
        sb.append("Pentagon ")
            .append(this.hashCode())
            .append(" on layer ")
            .append(layer);

        // for each neighbor,
        for (int i = 0; i < 10; i++) {
            // don't bother if there's no neighbor there
            if (neighbors[i % 10] == null) continue;

            // newline then tab {tabs} times
            sb.append("\n");
            sb.append("\t".repeat(Math.max(0, tabs)));

            // if it's the parent, just mark as Parent
            if ((i + 5) % 10 == side) {
                sb.append(i).append(": Parent");
                continue;
            }

            // add their toString(side, tabs, maxDepth) to the StringBuilder
            sb.append(i % 10)
                .append(": ")
                .append(neighbors[i % 10].toString(i % 10, tabs + 1, maxDepth));
        }
        return sb.toString();
    }

    // ----------------------------------------- //
    // ----------------RENDERING---------------- //
    // ----------------------------------------- //

    // generates default geometry for the origin Pentagon.
    public void generateDefaultGeometry() {
        // create vertices and lines
        for (int i = 0; i < 5; i++){
            double a1 = i * (Math.PI * 2 / 5);                     // multiples of 2pi/5 (72 degrees)
            double a2 = a1 + 0.7 * Math.PI;                        // 7pi/10 rotation from each end
            double l2 = size * 2 * Math.sin(Math.PI * 2 / 10);     // each side length is 2*sin(36)*center-vertex distance
            vertices[i] = center.polarOffset(a1, size);            // assign vertex to be polar offset with angle a1
            lines[i] = Line.createFromAngle(vertices[i], a2, l2);  // assign line to start at vertex and move a2 for l2
        }

        // generate points from vertices and their averages
        for (int i = 0; i < 5; i++) {
            points[(i*2+9) % 10] = vertices[i];
            points[(i*2) % 10] = vertices[i].average(vertices[(i+1) % 5]);
        }
    }

    // you're just gonna have to take my word on this method.
    // it only works up to a depth of 2. then it breaks. I don't have enough time to debug this.
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
                    new Line(vertices[(lineAnchor + 2) % 5], points[parentSide]).getLength() +
                    new Line(vertices[(lineAnchor + 4) % 5], points[parentSide]).getLength()
            ) / 2;

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
            //System.out.print(parentSide+": ");
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

            /*System.out.println(points[parentSide]);
            System.out.println(connectingVertex);
            System.out.println(Arrays.toString(vertices));
            System.out.println(Arrays.toString(lines));*/

            double l1a = l1.getAngle();
            double l2a = l2.getAngle();
            if (Math.abs(l2a-l1a) > Math.PI) { // deal with discontinuity of arctan()
                l1a = Vec2.mod2Pi(l1a);
                l2a = Vec2.mod2Pi(l2a);
            }

            double a1 = (l1a * 2 + l2a) / 3;
            double a2 = (l1a + l2a * 2) / 3;

            // System.out.println("angle "+l1.getAngle()+" and "+l2.getAngle()+", resulting in "+(l2.getAngle() - l1.getAngle()));

            // find length by taking a value between l1.mag and l2.mag
            double len1 = (l1.getLength() * 2 + l2.getLength()) / 3;
            double len2 = (l1.getLength() + l2.getLength() * 2) / 3;

            // create the rest of the vertices
            vertices[(connectingVertex + 2) % 5] = points[parentSide].polarOffset(a1, len1);
            vertices[(connectingVertex + 3) % 5] = points[parentSide].polarOffset(a2, len2);

            // generate the rest of the lines
            for (int i = 1; i <= 3; i++) {
                lines[(connectingVertex + i) % 5] = new Line(vertices[(connectingVertex + i) % 5],
                        vertices[(connectingVertex + i + 1) % 5]);
            }
        }

        // generate all remaining points
        for (int i = 0; i < 5; i++) {
            points[(i*2+9) % 10] = vertices[i];
            points[(i*2) % 10] = vertices[i].average(vertices[(i+1) % 5]);
        }

        // get center from all points
        center = Vec2.average(points);
    }

    // returns all renderable objects for this Pentagon (all of its lines)
    public Line[] getGeometry() {
        return lines;
    }

    // public call for obtaining all renderable lines
    // maxDepth: maximum depth of recursion
    // returns a HashSet containing all unique outlines of Pentagons.
    public HashSet<Line[]> getGeometries(int maxDepth) {
        HashSet<Line[]> lines = new HashSet<Line[]>();
        for (int i = 0; i < 10; i++) {
            this.neighbors[i].getGeometries(lines, maxDepth, i);
        }
        return lines;
    }

    // recursively add Line[] to pointer to output HashSet
    // because it's a HashSet, only unique sets of Lines are returned
    private void getGeometries(HashSet<Line[]> arr, int maxDepth, int direction) {
        if (layer >= maxDepth) return;
        arr.add(lines);
        for (int i = direction-1; i < direction+2; i++) {
            if (neighbors[(i+10) % 10] != null) neighbors[(i+10) % 10].getGeometries(arr, maxDepth, direction);
        }
    }
}
