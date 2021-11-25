import std.stdio;
import std.math;

import poincare.euclidean;
import poincare.rendering;
import poincare.poincare;
import poincare.tiling;

import raylib;


void main()
{
    SetTargetFPS(60);
    InitWindow(1000, 1000, "Poincare Engine");
    scope(exit) CloseWindow();

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);

    Circle disk = new Circle(Point(0, 0), 1);
    double d = tilingDistance(6, 4);
    Point p1 = Point(-d, 0);
    double k = 2 * raylib.PI / 3;
    double j = raylib.PI / 2;

    Point p2 = Point(d * cos(k), d * sin(k));


    // also works with HypLine
    HypSegment[] poly = new HypSegment[6];

    poly[0] = new HypSegment(disk, p1, p2);
    poly[0].setColor(Colors.BLUE);
    rq.add(poly[0]);

    for (int i = 1; i < 6; i++) {
        poly[i] = poly[i-1].rotateAroundPoint(disk, poly[i-1].d, j);
        poly[i].setColor(Colors.BLUE);
        rq.add(poly[i]);
    }

    rq.add(disk);


    while (!WindowShouldClose()) {

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        rq.render();

        EndDrawing();
    }
}
