import std.stdio;

import poincare.euclidean;
import poincare.rendering;

import raylib;


void tpctest()
{
    SetTargetFPS(60);
    InitWindow(1000, 1000, "Poincare Engine");
    scope(exit) CloseWindow();

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);


    Circle tp = new Circle(Point(0, 0.6), Point(-0.5, 0.1), Point(0.5, 0.1));
    rq.add(tp);

    while (!WindowShouldClose()) {

        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) tp.constraints[1].x += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) tp.constraints[1].x -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_UP)) tp.constraints[1].y -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_DOWN)) tp.constraints[1].y += 0.01f;

        if (IsKeyDown(KeyboardKey.KEY_D)) tp.constraints[0].x += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_A)) tp.constraints[0].x -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_W)) tp.constraints[0].y -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_S)) tp.constraints[0].y += 0.01f;

        tp.updateConstraints();

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        DrawCircleLines(500, 500, 250, Colors.WHITE);
        rq.render();

        EndDrawing();
    }
}
