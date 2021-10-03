/*
 ** Oct 2021
 ** https://github.com/lutet88
 */

// Vec2 utility class.
// represents a vector in 2D with components <x, y>
// classes are so bloated why can't Java just have struct ughhhhhh
public class Vec2 {
    public double x;
    public double y;

    public Vec2(double x, double y) {
        this.x = x;
        this.y = y;
    }

    // vector addition
    public Vec2 add(Vec2 other) {
        return new Vec2(this.x + other.x, this.y + other.y);
    }

    // vector subtraction (literally calls add -other)
    public Vec2 subtract(Vec2 other) {
        return this.add(this.invert());
    }

    // inverts and returns the vector to <-x, -y>
    public Vec2 invert() {
        return new Vec2(-this.x, -this.y);
    }

    // returns the mean point between this vector and another (2 vector overload)
    public Vec2 average(Vec2 other) {
        return new Vec2((this.x + other.x) / 2, (this.y + other.y) / 2);
    }

    // returns the mean point between this vector and two other vectors (3 vector overload)
    public Vec2 average(Vec2 other1, Vec2 other2) {
        return new Vec2((this.x + other1.x + other2.x) / 3, (this.y + other1.y + other2.y) / 3);
    }

    // returns the mean point between an array of Vec2s.
    public static Vec2 average(Vec2[] vecs) {
        int xa = 0;
        int ya = 0;
        for (Vec2 vec: vecs) {
            xa += vec.x;
            ya += vec.y;
        }
        xa /= vecs.length;
        ya /= vecs.length;
        return new Vec2(xa, ya);
    }

    // returns the angle of this vector in radians
    public double getAngle() {
        return Math.atan(this.y / this.x);
    }

    // helper method to avoid discontinuities in atan()
    public static double mod2Pi(double angle) {
        while (angle < 0) angle += 2 * Math.PI;
        while (angle > 2 * Math.PI) angle -= 2 * Math.PI;
        return angle;
    }

    // returns the absolute magnitude of this vector
    public double getMagnitude() {
        return Math.sqrt(this.x * this.x + this.y * this.y);
    }

    // returns a vector offset from this vector by
    // - angle (radians)
    // - length
    public Vec2 polarOffset(double angle, double length) {
        return new Vec2(x + Math.cos(angle) * length,
                y + Math.sin(angle) * length);
    }

    // returns a simple string representation of this vector
    @Override
    public String toString() {
        return "<"+this.x+", "+this.y+">";
    }
}
