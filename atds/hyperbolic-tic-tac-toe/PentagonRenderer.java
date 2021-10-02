import javax.swing.*;
import java.awt.*;
import java.awt.geom.*;


public class PentagonRenderer {
    private JPanel panel;
    private Canvas canvas;

    private Pentagon origin;

    public PentagonRenderer(Pentagon origin) {
        canvas = new Canvas();
        panel = new JPanel();
        canvas.getContentPane().add(panel);
        canvas.setSize(1000, 1000);
        canvas.setVisible(true);
        this.origin = origin;
    }

    public static Line createLineByAngle(Vec2 origin, double angle, double length) {
        double endX = origin.x + Math.cos(angle) * length;
        double endY = origin.y + Math.sin(angle) * length;
        return new Line(origin, new Vec2(endX, endY));
    }

    public static Vec2 offsetByAngle(Vec2 origin, double angle, double length) {
        return new Vec2(origin.x + Math.cos(angle) * length,
                        origin.y + Math.sin(angle) * length);
    }


    public void render() {
        Line[] lines = new Line[15];
        for (int i = 0; i < 5; i++){
            double a = i * (Math.PI * 2 / 5);
            double a2 = a + 0.7 * Math.PI;
            double l2 = 200 * Math.sin(Math.PI * 2 / 10);
            Vec2 origin = offsetByAngle(new Vec2(500, 500), a, 100);
            lines[i] = createLineByAngle(origin, a2, l2);
            lines[i+5] = createLineByAngle(lines[i].p2, lines[i].getAngle(), 50);
        }
        for (int i = 0; i < 5; i++){
            lines[i+10] = createLineByAngle(lines[i].p2, Math.PI + lines[i+1].getAngle(), 50);
        }

        canvas.setLinesToPaint(lines);
    }
}

class Canvas extends JFrame {
    private Line[] linesToPaint;

    public Canvas() {
        super("Canvas");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
    }

    public void setLinesToPaint(Line[] linesToPaint) {
        this.linesToPaint = linesToPaint;
    }

    @Override
    public void paint(Graphics g) {
        super.paint(g);
        Graphics2D g2 = (Graphics2D) g;
        for (Line line : linesToPaint) {
            System.out.println(line);
            g2.draw(line.getLine2D());
        }
    }
}
