module seranyl.rendering;

import std.conv;
import raylib;


struct Screen {
    Vector2 center = Vector2(540, 540);
    Vector2 size = Vector2(1080, 1080);
}

interface Renderable {
    void render(Screen screen);
}

class RenderBase : Renderable {
    bool toRender = true;
    Color color = Colors.GREEN;
    void render(Screen screen) {
        return;
    }
    RenderBase setColor(Color c) {
        color = c;
        return this;
    }
}

class RenderQueue {
    Renderable[] renderList;
    Screen screen;

    this(Screen scr) {
        renderList = new Renderable[0];
        screen = scr;
    }

    void add(Renderable r) {
        renderList ~= [r];
    }

    void clear() {
        renderList = new Renderable[0];
    }

    void render() {
        foreach (Renderable r; renderList) {
            r.render(screen);
        }
    }
}
