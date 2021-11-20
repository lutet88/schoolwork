module poincare.poincare;

import std.stdio;
import std.math;
import std.conv;

import raylib;

import poincare.euclidean;
import poincare.rendering;


const int SEGMENTS = 20;
const double RADIAN_TO_DEGREES = 0.01745329251;


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
        writeln(theta);

        // alpha: angle OCA (refer to notes)
        double alpha = atan(euC.radius / disk.radius);
        writeln(alpha);

        // beta: angle COA (refer to notes)
        double beta = atan(disk.radius / euC.radius);
        writeln(beta);

        writeln(alpha + beta);

        // start and end angle is just theta+-beta
        startAngle = theta - beta;
        endAngle = theta + beta;

        writeln(startAngle);
        writeln(endAngle);

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
