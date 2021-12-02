module poincare.euclidean;

import std.math;
import std.stdio;
import std.conv;
import std.algorithm.comparison;
import std.string;

import poincare.rendering;

import raylib;


const double MAX_ERROR = 0.0005;

double error(double a, double b) {
    double err = min(abs((a / b) - 1), abs(b - a));
    return ((isNaN(a) && isNaN(b)) ? 0 : err);
}

double error(Point a, Point b) {
    // give the max of x and y error
    return max(error(a.x, b.x), error(a.y, b.y));
}

bool colinear(Point p1, Point p2, Point p3) {
    return error((p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)), 0) < MAX_ERROR / 10;
}


struct Point {
    double x;
    double y;

    Vector2 toScaledVector(Point center, double scale) {
        return Vector2(x*scale + center.x, y*scale + center.y);
    }

    Vector2 toScaledVector(Screen s) {
        return Vector2(x*s.unit + s.center.x, -y*s.unit + s.center.y);
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

    static Line perpendicularBisector(Point p1, Point p2) {
        // get slope of line between the TwoPoints
        double theta = atan2(p2.y - p1.y, p2.x - p1.x);
        // rotate by 90 degrees
        double theta_prime = theta + raylib.PI / 2;
        // get midpoint of p1 and p2
        Point midpoint = Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
        // get a point on the line
        Point otherpoint = Point(midpoint.x + cos(theta_prime), midpoint.y + sin(theta_prime));
        return new Line(midpoint, otherpoint);
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

    this(Point anchor, double m) {
        p1 = anchor;
        p2 = Point(p1.x + 1, p1.y + m); // faraway point
    }

    static Point intersect(Line l1, Line l2) {
        // handle if line is a point
        if (l1.p1 == l1.p2) return l1.p1;
        if (l2.p1 == l2.p2) return l2.p1;

        // generate linear form
        double m1 = (l1.p2.y - l1.p1.y) / (l1.p2.x - l1.p1.x);
        double m2 = (l2.p2.y - l2.p1.y) / (l2.p2.x - l2.p1.x);
        double b1 = l1.p1.y - (l1.p1.x * m1);
        double b2 = l2.p1.y - (l2.p1.x * m2);

        // if slope is infinity
        if ((m1 == double.infinity || m1 == -double.infinity || isNaN(m1)) && (m2 == double.infinity || m2 == -double.infinity || isNaN(m2))) {
            return Point(0, 0);
        } else if (m1 == double.infinity || m1 == -double.infinity || isNaN(m1)) {
            return Point(l1.p1.x, l1.p1.x * m2 + b2);
        } else if (m2 == double.infinity || m2 == -double.infinity || isNaN(m2)) {
            return Point(l2.p1.x, l2.p1.x * m1 + b1);
        }

        // find intersection
        double x = (b2 - b1) / (m1 - m2);
        double y = x * m1 + b1;
        double alty = x * m2 + b2;

        /*writeln(to!string(m1) ~ "x + " ~ to!string(b1));
        writeln(to!string(m2) ~ "x + " ~ to!string(b2));
        writeln(alty);
        writeln(y);*/

        assert (error(alty, y) < MAX_ERROR, "linear intersection failed!");

        return Point(x, y);
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

    double slope() {
        return (p2.y - p1.y) / (p2.x - p1.x);
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
        Point p_prime = Point(center.x + dist_prime * cos(angle), center.y + dist_prime * sin(angle));
        return p_prime;
    }

    override void render(Screen screen) {
        DrawRing(center.toScaledVector(screen), radius * screen.unit - 2, radius * screen.unit + 2, 0, 360, 0, color);

        renderPoint.draw(screen);
        center.draw(screen);
    }
}

class Text : RenderBase {
    Point anchor;
    string text;
    double fontSize;

    this(Point anchor, string text, double fontSize) {
        this.text = text;
        this.anchor = anchor;
        this.fontSize = fontSize;
    }

    override void render(Screen screen) {
        DrawTextEx(GetFontDefault(), cast(const(char)*) toStringz(text), anchor.toScaledVector(screen), fontSize * screen.unit, 2, color);
    }
}
