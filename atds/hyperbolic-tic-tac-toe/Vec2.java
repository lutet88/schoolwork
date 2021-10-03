// sigh... Java doesn't have structs
// and Point2D is way too much of a pain

public class Vec2 {
    public double x;
    public double y;

    public Vec2(double x, double y) {
        this.x = x;
        this.y = y;
    }

    public Vec2 add(Vec2 other) {
        return new Vec2(this.x + other.x, this.y + other.y);
    }

    public Vec2 subtract(Vec2 other) {
        return this.add(this.invert());
    }

    public Vec2 invert() {
        return new Vec2(-this.x, -this.y);
    }

    public Vec2 average(Vec2 other) {
        return new Vec2((this.x + other.x) / 2, (this.y + other.y) / 2);
    }

    public Vec2 average(Vec2 other1, Vec2 other2) {
        return new Vec2((this.x + other1.x + other2.x) / 3, (this.y + other1.y + other2.y) / 3);
    }

    public double getAngle() {
        return Math.atan(this.y / this.x);
    }

    public static double mod2Pi(double angle) {
        while (angle < 0) angle += 2 * Math.PI;
        while (angle > 2 * Math.PI) angle -= 2 * Math.PI;
        return angle;
    }

    public double getMagnitude() {
        return Math.sqrt(this.x * this.x + this.y * this.y);
    }

    public Vec2 polarOffset(double angle, double length) {
        return new Vec2(x + Math.cos(angle) * length,
                y + Math.sin(angle) * length);
    }

    @Override
    public String toString() {
        return "<"+this.x+", "+this.y+">";
    }
}
