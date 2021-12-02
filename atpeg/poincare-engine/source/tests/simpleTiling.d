import std.stdio;
import std.math;

import poincare.euclidean;
import poincare.rendering;
import poincare.poincare;
import poincare.tiling;

import raylib;


void stiletest()
{

    SetTargetFPS(60);
    InitWindow(1000, 1000, "Poincare Engine");
    scope(exit) CloseWindow();

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);

    Circle disk = new Circle(Point(0, 0), 1);
    disk.setColor(Colors.WHITE);

    CenteredTiling tiling = new CenteredTiling(disk, 6, 4, 2);
    tiling.setColor(Colors.PURPLE);

    rq.add(tiling);
    rq.add(disk);


    while (!WindowShouldClose()) {

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        rq.render();

        EndDrawing();
    }
}


