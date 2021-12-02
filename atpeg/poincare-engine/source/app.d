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
    disk.setColor(Colors.WHITE);

    rq.add(disk);

    double x = 0.0001;
    double y = 0.0001;
    double a = 0.01;

    const int p = 7;
    const int q = 4;


    while (!WindowShouldClose()) {

        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) x += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) x -= 0.01f;

        if (IsKeyDown(KeyboardKey.KEY_DOWN)) y -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_UP)) y += 0.01f;

        if (IsKeyDown(KeyboardKey.KEY_A)) a -= 0.04f;
        if (IsKeyDown(KeyboardKey.KEY_D)) a += 0.04f;

        a = fmod(a + 210 * raylib.PI, 2 * raylib.PI / p);

        OffsetTiling tiling = new OffsetTiling(disk, Point(x, y), p, q, a, 3);
        tiling.setColor(Colors.PURPLE);

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        rq.render();
        tiling.render(screen);
        Point(x, y).draw(screen, Colors.ORANGE);

        EndDrawing();
    }
}


