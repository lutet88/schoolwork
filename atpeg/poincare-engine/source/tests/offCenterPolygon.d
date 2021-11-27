import std.stdio;
import std.math;

import poincare.euclidean;
import poincare.rendering;
import poincare.poincare;
import poincare.tiling;

import raylib;


void ocptest()
{
    SetTargetFPS(60);
    InitWindow(1000, 1000, "Poincare Engine");
    scope(exit) CloseWindow();

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);

    Circle disk = new Circle(Point(0, 0), 1);

    Point p1 = Point(0.2, 0.4);
    Point p2 = Point(0.4, -0.1);
    HypSegment startingSegment = new HypSegment(disk, p1, p2);
    HypPolygon poly = new HypPolygon(disk, startingSegment, p1, 7);
    poly.setColor(Colors.ORANGE);

    rq.add(startingSegment);
    rq.add(disk);
    rq.add(poly);


    while (!WindowShouldClose()) {

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        rq.render();

        EndDrawing();
    }
}
