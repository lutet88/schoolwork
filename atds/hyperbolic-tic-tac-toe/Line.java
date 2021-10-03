/*
 ** Oct 2021
 ** https://github.com/lutet88
 */

import java.awt.geom.*;


// Line utility class.
// represents the line connecting two Vec2 points.
public class Line {
    public Vec2 p1;
    public Vec2 p2;

    public Line(Vec2 p1, Vec2 p2) {
        this.p1 = p1;
        this.p2 = p2;
    }

    // returns the java.awt.geom.Line2D version of this Line object
    public Line2D getLine2D() {
        return new Line2D.Double(p1.x, p1.y, p2.x, p2.y);
    }

    // returns the angle of this line from p1 to p2 in radians.
    public double getAngle() {
        double yPart = (p2.y - p1.y);
        double xPart = (p2.x - p1.x);
        if (xPart < 0) {
            return Math.PI + Math.atan(yPart / xPart);
        } else if (xPart == 0) {
            if (yPart > 0) {
                return Math.PI / 2;
            }
            return -Math.PI / 2;
        }
        return Math.atan(yPart / xPart);
    }

    // returns the length of this line.
    public double getLength() {
        return Math.sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
    }

    // creates a line by offsetting from a Vec2 origin by
    // - angle (radians)
    // - length
    public static Line createFromAngle(Vec2 origin, double angle, double length) {
        double endX = origin.x + Math.cos(angle) * length;
        double endY = origin.y + Math.sin(angle) * length;
        return new Line(origin, new Vec2(endX, endY));
    }

    // returns a simple string representation as a literal Line between two Vec2s.
    @Override
    public String toString() {
        return this.p1+" *------> "+this.p2+" (angle="+getAngle()+")";
    }
}
