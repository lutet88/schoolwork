import std.stdio;

import poincare.euclidean;
import poincare.rendering;

import raylib;


void main()
{
    SetTargetFPS(60);
    InitWindow(1000, 1000, "Poincare Engine");
    scope(exit) CloseWindow();

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);

    Circle tp = new Circle(Point(-0.4, 0.7), Point(0.1, 0.2));
    rq.add(tp);

    while (!WindowShouldClose()) {

        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) tp.center.x += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) tp.center.x -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_UP)) tp.center.y -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_DOWN)) tp.center.y += 0.01f;

        if (IsKeyDown(KeyboardKey.KEY_D)) tp.radius += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_A)) tp.radius -= 0.01f;
        //if (IsKeyDown(KeyboardKey.KEY_W)) tp.p2.y -= 0.01f;
        //if (IsKeyDown(KeyboardKey.KEY_S)) tp.p2.y += 0.01f;

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        DrawCircleLines(500, 500, 250, Colors.WHITE);
        rq.render();

        EndDrawing();
    }
}
