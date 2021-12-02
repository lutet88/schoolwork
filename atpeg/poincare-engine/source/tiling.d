module poincare.tiling;

import std.stdio;
import std.math;
import std.conv;
import std.algorithm.comparison;

import raylib;

import poincare.euclidean;
import poincare.poincare;
import poincare.rendering;


double tilingDistance(int p, int q) {
    return sqrt((tan(raylib.PI / 2 - raylib.PI / q) - tan(raylib.PI / p)) / (tan(raylib.PI / 2 - raylib.PI / q) + tan(raylib.PI / p)));
}


class HypPolygon : RenderBase {
    HypSegment[] sides;
    Point[] vertices;
    Point center;
    int p;

    // HypPolygon is a really basic class just used to make construction easier
    this(Circle disk, HypSegment radius, Point center, int p) {
        this.p = p;
        vertices = new Point[p];
        for (int i = 0; i < p; i++) {
            vertices[i] = radius
                                .rotateAroundPoint(disk, center, i * (2 * raylib.PI) / p)
                                .nonMatchingPoint(center);
        }
        sides = new HypSegment[p];
        for (int i = 0; i < p; i++) {
            sides[i] = new HypSegment(disk, vertices[i], vertices[(i+1) % p]);
            sides[i].color = color;
        }
        center = radius.c;
    }

    // centered constructor
    this(Circle disk, double radius, int p) {
        this.p = p;
        vertices = new Point[p];
        for (int i = 0; i < p; i++) {
            vertices[i] = Point(radius * cos(i * (2 * raylib.PI) / p), radius * sin(i * (2 * raylib.PI) / p));
        }
        sides = new HypSegment[p];
        for (int i = 0; i < p; i++) {
            sides[i] = new HypSegment(disk, vertices[i], vertices[(i+1) % p]);
            sides[i].color = color;
        }
        center = Point(0, 0);
    }

    this(Circle disk, HypSegment[] sides) {
        this.sides = sides;
        for (int i = 0; i < p; i++) {
            sides[i] = new HypSegment(disk, vertices[i], vertices[(i+1) % p]);
            sides[i].color = color;
        }
        p = cast(int) sides.length;
        // center is not defined...
    }

    override void render(Screen screen) {
        for (int i = 0; i < p; i++) {
            sides[i].render(screen);
        }
    }

    alias setColor = RenderBase.setColor;
    void setColor(Color color) {
        for (int i = 0; i < p; i++) {
            sides[i].color = color;
        }
    }
}


class HypTile {
    HypPolygon poly;
    int p;
    int q;
    HypTile* parent;
    HypTile*[] neighbors;

    this(HypPolygon poly, int p, int q) {
        this.poly = poly;
        this.p = p;
        this.q = q;
        this.neighbors = new HypTile*[p * (q - 2)];
    }

    void render(Screen screen) {
        poly.render(screen);

        foreach (HypTile* n; neighbors) {
            if (n == null) continue;
            HypTile neighbor = *n;
            if (neighbor !is null) {
                neighbor.render(screen);
            }
        }
    }
}


class CenteredTiling : RenderBase {
    HypTile center;
    Point[] outerVertices;
    HypTile[] tiles;
    int p;
    int q;

    this(Circle disk, int p, int q, int size) {
        this.p = p;
        this.q = q;

        // generate first HypTile
        double d = tilingDistance(p, q);
        center = new HypTile(new HypPolygon(disk, d, p), p, q);

        outerVertices = center.poly.vertices;

        // generate the tiling
        for (int i = 0; i < size; i++) {
            Point[] newOuterVertices = new Point[0];
            // for each outer vertex, there must be
            // - one edge polygon
            // - (q-3) corner polygons
            for (int v = 0; v < outerVertices.length; v++) {
                // generate (q-2) polygons
                for (int c = 0; c < q-2; c++) {
                    HypSegment[] cornerPolygon = new HypSegment[p];
                    cornerPolygon[0] = new HypSegment(
                                            disk,
                                            outerVertices[v],
                                            outerVertices[(v+1) % outerVertices.length])
                                        .rotateAroundPoint(
                                            disk,
                                            outerVertices[(v+1) % outerVertices.length],
                                            (c+1) * (2 * raylib.PI) / q);

                    for (int j = 1; j < p; j++) {
                        cornerPolygon[j] = cornerPolygon[j-1].rotateAroundPoint(disk, cornerPolygon[j-1].d, 2 * raylib.PI / q);
                    }
                    tiles ~= [new HypTile(new HypPolygon(disk, cornerPolygon), p, q)];
                    // center.neighbors[v*(q-2)+c] = &(tiles[tiles.length-1]);
                    for (int j = p - 2; j >= 1; j--) {
                        if (p != 3) newOuterVertices ~= cornerPolygon[j].d;
                    }
                    newOuterVertices ~= cornerPolygon[0].d;
                }
            }
            writeln(newOuterVertices.length);
            outerVertices = newOuterVertices;
        }
    }

    override void render(Screen screen) {
        // writeln(&center);
        // writeln(center.neighbors);
        //this.center.render(screen);
        foreach (HypTile ht; tiles) {
            ht.render(screen);
        }
    }

    alias setColor = RenderBase.setColor;
    void setColor(Color color) {
        for (int i = 0; i < tiles.length; i++) {
            tiles[i].poly.setColor(color);
        }
    }
}

class OffsetTiling : RenderBase {
    HypTile center;
    Point[] outerVertices;
    HypTile[] tiles;
    int p;
    int q;

    this(Circle disk, Point center, int p, int q, int angle, int size) {
        this.p = p;
        this.q = q;

        if (center == Point(0, 0)) {
            // simply generate centered tiling
            double d = tilingDistance(p, q);
            double angle_prime = 2 * raylib.PI - angle;
            Point pt = Point(d*cos(angle_prime), d*sin(angle_prime));

            HypSegment radius = new HypSegment(disk, center, pt);

            center = new HypTile(new HypPolygon(disk, radius, center, p), p, q);
        } else
            // generate point with length tilingDistance
            double d = tilingDistance(p, q);
            double angle_prime = 2 * raylib.PI - angle;
            Point pt = Point(d*cos(angle_prime), d*sin(angle_prime));

            // circular invert it over the perpendicular bisector of origin and center
            HypLine ppb = HypPerpendicularBisector(disk, origin, center);
            Point pt_prime = ppb.euC.circularInversion(pt);

            // set the polygon's radius to be that segment
            HypSegment radius = new HypSegment(disk, center, pt_prime);

            center = new HypTile(new HypPolygon(disk, radius, center, p), p, q);
        }

        outerVertices = center.poly.vertices;

        // generate the tiling
        for (int i = 0; i < size; i++) {
            Point[] newOuterVertices = new Point[0];
            // for each outer vertex, there must be
            // - one edge polygon
            // - (q-3) corner polygons
            for (int v = 0; v < outerVertices.length; v++) {
                // generate (q-2) polygons
                for (int c = 0; c < q-2; c++) {
                    HypSegment[] cornerPolygon = new HypSegment[p];
                    cornerPolygon[0] = new HypSegment(
                                            disk,
                                            outerVertices[v],
                                            outerVertices[(v+1) % outerVertices.length])
                                        .rotateAroundPoint(
                                            disk,
                                            outerVertices[(v+1) % outerVertices.length],
                                            (c+1) * (2 * raylib.PI) / q);

                    for (int j = 1; j < p; j++) {
                        cornerPolygon[j] = cornerPolygon[j-1].rotateAroundPoint(disk, cornerPolygon[j-1].d, 2 * raylib.PI / q);
                    }
                    tiles ~= [new HypTile(new HypPolygon(disk, cornerPolygon), p, q)];
                    // center.neighbors[v*(q-2)+c] = &(tiles[tiles.length-1]);
                    for (int j = p - 2; j >= 1; j--) {
                        if (p != 3) newOuterVertices ~= cornerPolygon[j].d;
                    }
                    newOuterVertices ~= cornerPolygon[0].d;
                }
            }
            writeln(newOuterVertices.length);
            outerVertices = newOuterVertices;
        }
    }

    override void render(Screen screen) {
        foreach (HypTile ht; tiles) {
            ht.render(screen);
        }
    }

    alias setColor = RenderBase.setColor;
    void setColor(Color color) {
        for (int i = 0; i < tiles.length; i++) {
            tiles[i].poly.setColor(color);
        }
    }
}
