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


HypLine hypPerpendicularBisector(Circle disk, Point p, Point q) {
    // draw two circles from p to q and q to p
    HypCircle hcp = new HypCircle(disk, p, q);
    HypCircle hcq = new HypCircle(disk, q, p);

    double pq = TwoPoints.distance(hcp.euC.center, hcq.euC.center);

    // find the distance to the midpoint
    double qm = ((hcq.euC.radius * hcq.euC.radius) - (hcp.euC.radius * hcp.euC.radius) + (pq * pq)) / (2 * pq);
    double pm = ((hcp.euC.radius * hcp.euC.radius) - (hcq.euC.radius * hcq.euC.radius) + (pq * pq)) / (2 * pq);

    assert (error(pm + qm, pq) < MAX_ERROR, "hypPerpendicularBisector failed, step 1");

    // use pythagorean theorem to find distance from midpoint to intersection point
    double ma = sqrt((hcq.euC.radius * hcq.euC.radius) - (qm * qm));
    double ma2 = sqrt((hcp.euC.radius * hcp.euC.radius) - (pm * pm));

    assert (error(ma, ma2) < MAX_ERROR, "hypPerpendicularBisector failed, step 2");

    // find angle from p to q
    double thetapq = atan2(hcq.euC.center.y - hcp.euC.center.y, hcq.euC.center.x - hcp.euC.center.x);
    // traverse it by pm
    Point m = Point(hcp.euC.center.x + pm * cos(thetapq), hcp.euC.center.y + pm * sin(thetapq));

    // traverse perpendicular to it by ma to obtain our two intersection points
    Point a = Point(m.x + ma * cos(thetapq + (std.math.PI / 2)), m.y + ma * sin(thetapq + (std.math.PI / 2)));
    Point b = Point(m.x + ma * cos(thetapq - (std.math.PI / 2)), m.y + ma * sin(thetapq - (std.math.PI / 2)));

    /* debug
    Segment ab = new Segment(a, b, rq);
    Segment cc = new Segment(hcp.euC.center, hcq.euC.center, rq);
    Segment cm = new Segment(hcp.euC.center, m, rq);
    rq.add(hcp);
    rq.add(hcq);
    */

    // return HypLine from intersection points
    return new HypLine(disk, a, b);
}


class HypLine : RenderBase {
    double startAngle;
    double endAngle;

    // pa and pb are intersection points with the Poincare Disk,
    // pa corresponds to startAngle and pb to endAngle
    Point pa;
    Point pb;

    Point c;
    Point d;

    Circle euC;

    this(Circle disk, Point c, Point d) {
        // define from two points
        Point c_prime = disk.circularInversion(c);
        euC = new Circle(c, d, c_prime);
        this.c = c;
        this.d = d;

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

    this(Circle disk, Circle newEuC) {
        // get angles
        // theta: offset angle from x-axis
        double theta2 = atan2(newEuC.center.y - disk.center.y, newEuC.center.x - disk.center.x);

        // beta: angle COA (refer to notes)
        double beta = atan(disk.radius / newEuC.radius);

        // find points a and b
        Point a = Point(newEuC.center.x + newEuC.radius * cos(raylib.PI + theta2 - beta), newEuC.center.y + newEuC.radius * sin(raylib.PI + theta2 - beta));
        Point b = Point(newEuC.center.x + newEuC.radius * cos(raylib.PI + theta2 + beta), newEuC.center.y + newEuC.radius * sin(raylib.PI + theta2 + beta));

        pa = a;
        pb = b;
        euC = newEuC;
        startAngle = raylib.PI + theta2 - beta;
        endAngle = raylib.PI + theta2 + beta;
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
        assert (error(TwoPoints.distance(euC.center, p), euC.radius) < MAX_ERROR, "invalid point for euclideanTangent");

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
        if (c.x != 0 && c.y != 0) c.draw(screen);
        if (d.x != 0 && d.y != 0) d.draw(screen);
    }

    HypLine rotateAroundPoint(Circle disk, Point p, double theta, RenderQueue rq) {
        // assert p is on the HypLine
        assert (error(euC.radius, TwoPoints.distance(p, euC.center)) < MAX_ERROR, "invalid point for rotateAroundPoint");

        // find angle between euC.center and p
        double alpha = atan2(euC.center.y - p.y, euC.center.x - p.x);
        double finalAngle = alpha + theta;
        // get line from p and that angle
        Line rl = new Line(p, Point(p.x + 2 * cos(finalAngle), p.y + 2 * sin(finalAngle)));

        // get perpendicular bisector between p and p inverted
        Point p_prime = disk.circularInversion(p);
        Line pb = TwoPoints.perpendicularBisector(p, p_prime);
        pb.color = Colors.BLUE;

        // find intersection point between the two, that's the new euC.center
        Point i = Line.intersect(pb, rl);

        Circle newEuC = new Circle(i, p);

        /*rq.add(new Line(euC.center, p));
        rq.add(rl);
        rq.add(pb);
        rq.add(newEuC);*/

        return new HypLine(disk, newEuC);
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
