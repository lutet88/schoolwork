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
    Point p2 = Point(0.8, -0.3);

    // also works with HypLine
    HypLine hc = new HypLine(disk, p1, p2);
    hc.color = Colors.BLUE;
    rq.add(disk);
    rq.add(hc);

    double j = raylib.PI / 4;

    while (!WindowShouldClose()) {

        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) j += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) j -= 0.01f;

        writeln(j / raylib.PI * 180);

        HypLine hrot = hc.rotateAroundPoint(disk, p1, j, rq);
        hrot.color = Colors.RED;

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        rq.render();
        hrot.render(screen);
        EndDrawing();
    }
}
