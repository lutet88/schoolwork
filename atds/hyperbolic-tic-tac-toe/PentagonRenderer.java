/*
 ** Oct 2021
 ** https://github.com/lutet88
 */

import javax.swing.*;
import java.awt.*;
import java.awt.geom.*;
import java.sql.Array;
import java.util.HashSet;
import java.util.Arrays;


// Render handler class for Pentagons.
// Uses the Java awt/swing framework.
public class PentagonRenderer {
    private JPanel panel;
    private Canvas canvas;

    private Pentagon origin;

    // constructor
    // PentagonRenders should be created with the origin Pentagon of Pentagon.createPentaGrid(maxDepth)
    public PentagonRenderer(Pentagon origin) {
        canvas = new Canvas();
        panel = new JPanel();
        canvas.getContentPane().add(panel);
        canvas.setSize(1000, 1000); // never ended up implementing variable display sizes
        canvas.setVisible(true);
        this.origin = origin;
    }

    // 
    public void render() {
        canvas.clearLinesToPaint();
        System.out.println(Arrays.toString(origin.getNeighbor(0).getGeometry()));
        canvas.setLinesToPaint(origin.getGeometries(3));
    }
}

class Canvas extends JFrame {
    private HashSet<Line[]> linesToPaint = new HashSet<Line[]>();

    public Canvas() {
        super("Canvas");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
    }

    public void setLinesToPaint(HashSet<Line[]> linesToPaint) {
        this.linesToPaint = linesToPaint;
    }

    public void addLinesToPaint(Line[] lines) {
        linesToPaint.add(lines);
    }

    public void clearLinesToPaint() {
        linesToPaint = new HashSet<Line[]>();
    }

    @Override
    public void paint(Graphics g) {
        super.paint(g);
        Graphics2D g2 = (Graphics2D) g;
        for (Line[] lineGroup : linesToPaint) {
            for (Line line : lineGroup) {
                // System.out.println(line);
                if (line != null) {
                    g2.draw(line.getLine2D());
                }
            }
        }
    }
}
