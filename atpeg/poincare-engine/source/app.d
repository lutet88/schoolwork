import std.stdio;
import std.math;
import std.conv;

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

    int p = 7;
    int q = 4;
    int depth = 2;

    Color[] colors = [Colors.WHITE, Colors.YELLOW, Colors.GREEN, Colors.SKYBLUE, Colors.BLUE, Colors.PURPLE, Colors.VIOLET, Colors.PINK, Colors.RED, Colors.ORANGE, Colors.GRAY];

    int color = 2;


    while (!WindowShouldClose()) {

        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) x += 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) x -= 0.01f;

        if (IsKeyDown(KeyboardKey.KEY_DOWN)) y -= 0.01f;
        if (IsKeyDown(KeyboardKey.KEY_UP)) y += 0.01f;

        if (IsKeyDown(KeyboardKey.KEY_A)) a -= 0.04f;
        if (IsKeyDown(KeyboardKey.KEY_D)) a += 0.04f;

        if (IsKeyPressed(KeyboardKey.KEY_F)) p --;
        if (IsKeyPressed(KeyboardKey.KEY_R)) p ++;

        if (IsKeyPressed(KeyboardKey.KEY_G)) q --;
        if (IsKeyPressed(KeyboardKey.KEY_T)) q ++;

        if (IsKeyPressed(KeyboardKey.KEY_H)) depth --;
        if (IsKeyPressed(KeyboardKey.KEY_Y)) depth ++;

        if (IsKeyPressed(KeyboardKey.KEY_C)) color ++;

        a = fmod(a + 2 * p * raylib.PI, 2 * raylib.PI / p);
        color %= colors.length;

        OffsetTiling tiling = new OffsetTiling(disk, Point(x, y), p, q, a, depth);
        tiling.setColor(colors[color]);

        Text segments = new Text(Point(-1.9, -1.14), "segments: " ~ to!string(tiling.tiles.length * p), 0.12);
        Text tiles = new Text(Point(-1.9, -1.27), "tiles: " ~ to!string(tiling.tiles.length), 0.12);
        Text coords = new Text(Point(-1.9, -1.4), "x: " ~ to!string(x) ~ ", y: " ~ to!string(y), 0.12);
        Text pq = new Text(Point(-1.9, -1.53), "p: " ~ to!string(p) ~ ", q: " ~ to!string(q), 0.12);
        Text ang = new Text(Point(-1.9, -1.66), "theta: " ~ to!string(a), 0.12);
        Text dpt = new Text(Point(-1.9, -1.79), "depth: " ~ to!string(depth), 0.12);

        coords.setColor(Colors.WHITE);
        pq.setColor(Colors.WHITE);
        ang.setColor(Colors.WHITE);
        dpt.setColor(Colors.WHITE);
        tiles.setColor(Colors.WHITE);
        segments.setColor(Colors.WHITE);

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        rq.render();
        tiling.render(screen);
        Point(x, y).draw(screen, Colors.ORANGE);

        coords.render(screen);
        pq.render(screen);
        ang.render(screen);
        dpt.render(screen);
        tiles.render(screen);
        segments.render(screen);

        EndDrawing();
    }
}


