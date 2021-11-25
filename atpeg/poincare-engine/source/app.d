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
    Point p2 = Point(0.5, 0.0);

    // also works with HypLine
    HypSegment hc = new HypSegment(disk, p1, p2);
    hc.color = Colors.BLUE;
    rq.add(disk);
    rq.add(hc);

    double j = 0.2;

    while (!WindowShouldClose()) {

        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) j += 0.04f;
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) j -= 0.04f;

        //writeln(j / raylib.PI * 180);

        HypSegment hrot = hc.rotateAroundPoint(disk, p1, j, rq);
        hrot.color = Colors.RED;

        HypCircle sc = new HypCircle(disk, p1, p2);
        sc.color = Colors.PURPLE;
        BeginDrawing();
        ClearBackground(Colors.BLACK);

        rq.render();
        hrot.render(screen);
        //sc.render(screen);
        EndDrawing();
    }
}
