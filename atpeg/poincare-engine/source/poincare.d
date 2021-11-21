module poincare.poincare;

import std.stdio;
import std.math;
import std.conv;

import raylib;

import poincare.euclidean;
import poincare.rendering;


const int SEGMENTS = 20;
const double RADIAN_TO_DEGREES = 0.01745329251;

alias ln = log;


double hypDistance(Circle disk, Point p, Point q) {
    HypLine temp = new HypLine(disk, p, q);
    return hypDistance(disk, p, q, temp);
}

double hypDistance(Circle disk, Point p, Point q, HypLine g) {
    double ap = TwoPoints.distance(g.pa, p);
    double aq = TwoPoints.distance(g.pa, q);
    double bp = TwoPoints.distance(g.pb, p);
    double bq = TwoPoints.distance(g.pb, q);

    return abs(ln((ap * bq) / (bp * aq)));
}


class HypLine : RenderBase {
    double startAngle;
    double endAngle;

    // pa and pb are intersection points with the Poincare Disk,
    // pa corresponds to startAngle and pb to endAngle
    Point pa;
    Point pb;

    Circle euC;

    this(Circle disk, Point c, Point d) {
        // define from two points
        Point c_prime = disk.circularInversion(c);
        euC = new Circle(c, d, c_prime);

        // get angles
        // theta: offset angle from x-axis
        double theta = atan2(disk.center.y - euC.center.y, disk.center.x - euC.center.x);

        // alpha: angle OCA (refer to notes)
        double alpha = atan(euC.radius / disk.radius);

        // beta: angle COA (refer to notes)
        double beta = atan(disk.radius / euC.radius);


        // start and end angle is just theta+-beta
        startAngle = theta - beta;
        endAngle = theta + beta;


        pa = Point(euC.center.x + euC.radius * cos(startAngle), euC.center.y + euC.radius * sin(startAngle));
        pb = Point(euC.center.x + euC.radius * cos(endAngle), euC.center.y + euC.radius * sin(endAngle));
    }

    Point circularInversion(Point p) {
        // get distance from center to p
        double dist = TwoPoints.distance(euC.center, p);
        // r^2 / dist = dist from center to p'
        double dist_prime = (euC.radius * euC.radius) / dist;
        // project new point with same angle as CP but with distance dist_prime
        double angle = atan2(p.y - euC.center.y, p.x - euC.center.x);
        Point p_prime = Point(dist_prime * cos(angle), dist_prime * sin(angle));
        return p_prime;
    }

    Line euclideanTangent(Point p) {
        assert (TwoPoints.distance(euC.center, p) == euC.radius, "invalid point for euclideanTangent");

        // make copy of p with shifted coordinates so euC.center is (0, 0)
        Point p_shift = Point(p.x - euC.center.x, p.y - euC.center.y);

        // take the tangent line for a centered circle
        // x and y don't matter, only the ratio between them,
        // since no matter what r is d/dx(r^2) = 0
        // use formula m = -x/y, let's hope y != 0
        double m = -(p_shift.x) / p_shift.y;
        Line tangent = new Line(p, m);
        return tangent;
    }

    override void render(Screen screen) {
        // TODO: FIX RAYLIB!!!!
        DrawRing(euC.center.toScaledVector(screen), euC.radius * screen.unit - 2, euC.radius * screen.unit + 2, startAngle / RADIAN_TO_DEGREES + 90, endAngle / RADIAN_TO_DEGREES + 90, SEGMENTS, color);

        pa.draw(screen);
        pb.draw(screen);
    }
}

class HypSegment : RenderBase {
    double startAngle;
    double endAngle;

    // pa and pb are intersection points with the Poincare Disk,
    // pa corresponds to startAngle and pb to endAngle
    Point pa;
    Point pb;

    // pc and pd are copies of the constructor
    Point pc;
    Point pd;

    Circle euC;

    this(Circle disk, Point c, Point d) {
        // define from two points
        Point c_prime = disk.circularInversion(c);
        euC = new Circle(c, d, c_prime);

        // get angles
        // theta: offset angle from x-axis
        double theta = atan2(disk.center.y - euC.center.y, disk.center.x - euC.center.x);

        startAngle = atan2(c.y - euC.center.y, c.x - euC.center.x);
        endAngle = atan2(d.y - euC.center.y, d.x - euC.center.x);

        pa = Point(euC.center.x + euC.radius * cos(startAngle), euC.center.y + euC.radius * sin(startAngle));
        pb = Point(euC.center.x + euC.radius * cos(endAngle), euC.center.y + euC.radius * sin(endAngle));
    }

    override void render(Screen screen) {
        // TODO: FIX RAYLIB!!!!
        DrawRing(euC.center.toScaledVector(screen), euC.radius * screen.unit - 2, euC.radius * screen.unit + 2, startAngle / RADIAN_TO_DEGREES + 90, endAngle / RADIAN_TO_DEGREES + 90, SEGMENTS, color);

        pa.draw(screen);
        pb.draw(screen);
    }
}

class HypCircle : RenderBase {

    Circle euC;
    Point center;
    Point anchor;

    double radius;

    this(Circle disk, Point ctr, Point b) {
        Point o = Point(0, 0);

        // draw hypLine between ctr and b
        HypLine cb = new HypLine(disk, b, ctr);

        // get euclidean tangent line at b on cb
        Line tangent = cb.euclideanTangent(b);

        // find its intersection with co
        Line co = new Line(o, ctr);
        Point d = Line.intersect(tangent, co);

        // radius is db
        euC = new Circle(d, TwoPoints.distance(d, b));

        anchor = b;
        center = ctr;

        // use hypDistance to find radius
        radius = hypDistance(disk, b, ctr, cb);
    }

    override void render(Screen screen) {
        DrawRing(euC.center.toScaledVector(screen), euC.radius * screen.unit - 2, euC.radius * screen.unit + 2, 0, 360, 0, color);

        center.draw(screen);
        anchor.draw(screen);
    }
}
