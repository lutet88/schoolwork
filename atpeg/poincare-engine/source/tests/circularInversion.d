import std.stdio;

import poincare.euclidean;
import poincare.rendering;
import poincare.poincare;

import raylib;


void testci()
{
    SetTargetFPS(60);
    InitWindow(1000, 1000, "Poincare Engine");
    scope(exit) CloseWindow();

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);


    Circle c = new Circle(Point(0, 0), 1);
    rq.add(c);
    Point p = Point(0.5, 0.3);
    Point p_prime;

    while (!WindowShouldClose()) {

        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) p.x += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) p.x -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_UP)) p.y -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_DOWN)) p.y += 0.01f;

        p_prime = c.circularInversion(p);

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        //DrawCircleLines(500, 500, 250, Colors.WHITE);
        rq.render();
        p.draw(screen);
        p_prime.draw(screen);

        EndDrawing();
    }
}
