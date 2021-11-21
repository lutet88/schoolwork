import std.stdio;

import poincare.euclidean;
import poincare.rendering;
import poincare.poincare;

import raylib;


void main()
{
    SetTargetFPS(60);
    InitWindow(1000, 1000, "Poincare Engine");
    scope(exit) CloseWindow();

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);

    Circle disk = new Circle(Point(0, 0), 1);
    Point p1 = Point(0.5, 0.5);
    Point p2 = Point(0.8, 0.1);

    // also works with HypLine
    RenderBase hc = new HypCircle(disk, p2, p1);

    rq.add(disk);
    rq.add(hc);

    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        rq.render();
        EndDrawing();
    }
}
