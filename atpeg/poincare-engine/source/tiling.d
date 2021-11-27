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
            writeln(n);
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
            // for each outer vertex, there must be
            // - one edge polygon
            // - (q-3) corner polygons
            for (int v = 0; v < outerVertices.length; v++) {
                writeln(outerVertices);
                // generate the edge polygon between v and v+1
                writeln("here");
                HypSegment[] edgePolygon = new HypSegment[q];
                edgePolygon[0] = new HypSegment(disk, outerVertices[v], outerVertices[(v+1) % outerVertices.length]);
                // generate rotated vertices, each by (q-2)*pi (interior angles)
                for (int j = 1; j < q; j++) {
                    edgePolygon[j] = edgePolygon[j-1].rotateAroundPoint(disk, edgePolygon[j-1].d, 2 * raylib.PI / q);
                    writeln(edgePolygon[j].d);
                }
                // TODO:
                tiles ~= [new HypTile(new HypPolygon(disk, edgePolygon), p, q)];
                center.neighbors[v*(q-2)] = &(tiles[tiles.length-1]);
                writeln("edge generated");

                // generate (q-3) corner polygons
                for (int c = 0; c < q-3; c++) {
                    HypSegment[] cornerPolygon = new HypSegment[q];
                    cornerPolygon[0] = new HypSegment(
                                            disk,
                                            outerVertices[v],
                                            outerVertices[(v+1) % outerVertices.length])
                                        .rotateAroundPoint(
                                            disk,
                                            outerVertices[(v+1) % outerVertices.length],
                                            (c+2) * (2 * raylib.PI) / q);

                    for (int j = 1; j < q; j++) {
                        cornerPolygon[j] = cornerPolygon[j-1].rotateAroundPoint(disk, cornerPolygon[j-1].d, 2 * raylib.PI / q);
                    }
                    tiles ~= [new HypTile(new HypPolygon(disk, cornerPolygon), p, q)];
                    center.neighbors[v*(q-2)+c+1] = &(tiles[tiles.length-1]);
                    writeln("corner generated");
                }
            }
        }
    }

    override void render(Screen screen) {
        // writeln(&center);
        // writeln(center.neighbors);
        this.center.render(screen);
    }
}