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

    @Override
    public String toString() {
        return "<"+this.x+", "+this.y+">";
    }
}
