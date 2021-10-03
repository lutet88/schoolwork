import java.awt.geom.*;

public class Line {
    public Vec2 p1;
    public Vec2 p2;

    public Line(Vec2 p1, Vec2 p2) {
        this.p1 = p1;
        this.p2 = p2;
    }

    public Line2D getLine2D() {
        return new Line2D.Double(p1.x, p1.y, p2.x, p2.y);
    }

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

    public double getMagnitude() {
        return Math.sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
    }

    public static Line createFromAngle(Vec2 origin, double angle, double length) {
        double endX = origin.x + Math.cos(angle) * length;
        double endY = origin.y + Math.sin(angle) * length;
        return new Line(origin, new Vec2(endX, endY));
    }

    @Override
    public String toString() {
        return this.p1+" -> "+this.p2+" (angle="+getAngle()+")";
    }
}