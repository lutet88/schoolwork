module poincare.euclidean;

import std.math;
import std.stdio;

import poincare.rendering;

import raylib;


struct Point {
    double x;
    double y;

    Vector2 toScaledVector(Point center, double scale) {
        return Vector2(x*scale + center.x, y*scale + center.y);
    }

    Vector2 toScaledVector(Screen s) {
        return Vector2(x*s.unit + s.center.x, y*s.unit + s.center.y);
    }

    void draw(Screen screen) {
        DrawCircleV(toScaledVector(screen), 4, Colors.WHITE);
    }

    void draw(Screen screen, Color color) {
        DrawCircleV(toScaledVector(screen), 4, color);
    }
}

class TwoPoints : RenderBase {
    Point p1;
    Point p2;

    double distance() {
        return sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
    }

    static double distance(Point p1, Point p2) {
        return sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
    }
}

class Segment : TwoPoints {
    this(Point start, Point end) {
        p1 = start;
        p2 = end;
    }

    this(Point start, Point end, RenderQueue rq) {
        p1 = start;
        p2 = end;
        rq.add(cast(Renderable) this);
    }

    override void render(Screen screen) {
        DrawLineEx(p1.toScaledVector(screen), p2.toScaledVector(screen), 4, color);
        p1.draw(screen);
        p2.draw(screen);
        writeln("drawing segment");
    }
}

class Vector : TwoPoints {
    this(Point start, Point end) {
        p1 = start;
        p2 = end;
    }

    this(Point start, Point end, RenderQueue rq) {
        p1 = start;
        p2 = end;
        rq.add(cast(Renderable) this);
    }

    override void render(Screen screen) {
        DrawLineEx(p1.toScaledVector(screen), p2.toScaledVector(screen), 4, color);
        // draw circle on ending side to indicate Vector, radius=10px
        DrawCircleV(p2.toScaledVector(screen), 10, color);

        p1.draw(screen);
        p2.draw(screen);
    }
}

class RayLine : TwoPoints {
    this(Point start, Point end) {
        p1 = start;
        p2 = end;
    }

    this(Point start, Point end, RenderQueue rq) {
        p1 = start;
        p2 = end;
        rq.add(cast(Renderable) this);
    }

    override void render(Screen screen) {
        double theta = atan2(p2.y - p1.y, p2.x - p1.x);
        Point p3 = Point(p1.x + 10 * cos(theta), p1.y + 10 * sin(theta));

        DrawLineEx(p1.toScaledVector(screen), p3.toScaledVector(screen), 4, color);

        p1.draw(screen);
        p2.draw(screen);
        p3.draw(screen);
    }
}

class Line : TwoPoints {
    this(Point start, Point end) {
        p1 = start;
        p2 = end;
    }

    this(Point start, Point end, RenderQueue rq) {
        p1 = start;
        p2 = end;
        rq.add(cast(Renderable) this);
    }

    override void render(Screen screen) {
        double theta3 = atan2(p2.y - p1.y, p2.x - p1.x);
        Point p3 = Point(p1.x + 10 * cos(theta3), p1.y + 10 * sin(theta3));

        double theta4 = atan2(p1.y - p2.y, p1.x - p2.x);
        Point p4 = Point(p2.x + 10 * cos(theta4), p2.y + 10 * sin(theta4));

        DrawLineEx(p4.toScaledVector(screen), p3.toScaledVector(screen), 4, color);

        p1.draw(screen);
        p2.draw(screen);
        p3.draw(screen);
        p4.draw(screen);
    }
}

class Circle : RenderBase {
    double radius;
    Point center;
    Point renderPoint;
    Point[] constraints;

    this(Point c, double r) {
        radius = r;
        center = c;
        renderPoint = Point(-1000, -1000); // dead point
        constraints = [center];
    }

    this(Point c, Point side) {
        center = c;
        radius = TwoPoints.distance(c, side);
        renderPoint = side;
        constraints = [center, side];
    }

    // definitely weren't plagiarized from geeks4geeks
    private double cy(Point p1, Point p2, Point p3) {
        double f = (((p1.x * p1.x) - (p3.x * p3.x)) * (p1.x - p2.x) +
                    ((p1.y * p1.y) - (p3.y * p3.y)) * (p1.x - p2.x) +
                    ((p2.x * p2.x) - (p1.x * p1.x)) * (p1.x - p3.x) +
                    ((p2.y * p2.y) - (p1.y * p1.y)) * (p1.x - p3.x)) /
                    (2 * ((p3.y - p1.y) * (p1.x - p2.x) - (p2.y - p1.y) * (p1.x - p3.x)));
        return -f;
    }
    private double cx(Point p1, Point p2, Point p3) {
        double g = (((p1.x * p1.x) - (p3.x * p3.x)) * (p1.y - p2.y) +
                    ((p1.y * p1.y) - (p3.y * p3.y)) * (p1.y - p2.y) +
                    ((p2.x * p2.x) - (p1.x * p1.x)) * (p1.y - p3.y) +
                    ((p2.y * p2.y) - (p1.y * p1.y)) * (p1.y - p3.y)) /
                    (2 * ((p3.x - p1.x) * (p1.y - p2.y) - (p2.x - p1.x) * (p1.y - p3.y)));
        return -g;
    }

    this(Point p1, Point p2, Point p3) {
        // circle from three points...... don't think this was necessary
        // no it totally is!!
        center = Point(cx(p1, p2, p3), cy(p1, p2, p3));
        radius = TwoPoints.distance(center, p1);
        renderPoint = p1;
        constraints = [p1, p2, p3];
    }

    void updateConstraints() {
        if (constraints.length == 2) {
            // center and side
            radius = TwoPoints.distance(center, constraints[1]);
            renderPoint = constraints[1];
        } else if (constraints.length == 3) {
            center.x = cx(constraints[0], constraints[1], constraints[2]);
            center.y = cy(constraints[0], constraints[1], constraints[2]);
            radius = TwoPoints.distance(center, constraints[0]);
            renderPoint = constraints[0];
        }
    }

    Point circularInversion(Point p) {
        // get distance from center to p
        double dist = TwoPoints.distance(center, p);
        // r^2 / dist = dist from center to p'
        double dist_prime = (radius * radius) / dist;
        // project new point with same angle as CP but with distance dist_prime
        double angle = atan2(p.y - center.y, p.x - center.x);
        Point p_prime = Point(dist_prime * cos(angle), dist_prime * sin(angle));
        return p_prime;
    }

    override void render(Screen screen) {
        DrawRing(center.toScaledVector(screen), radius * screen.unit - 2, radius * screen.unit + 2, 0, 360, 0, color);

        renderPoint.draw(screen);
        center.draw(screen);
    }
}
