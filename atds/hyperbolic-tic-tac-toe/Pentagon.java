import java.util.*;

class Pentagon {
    public int layer;

    public static Pentagon createPentaGrid(int maxDepth) {
        return new Pentagon(maxDepth-1, 0);
    }

    private Pentagon[] neighbors = new Pentagon[10];
    private Vec2[] vertices = new Vec2[5];
    private Vec2 center;

    public Pentagon(Pentagon parent, int parentSide, int layer) {
        neighbors[parentSide] = parent;
        this.layer = layer;
    }

    public void populate(int maxLayers) {
        if (layer >= maxLayers) return;
        for (int i = 0; i < 10; i++){
            if (neighbors[i] == null) neighbors[i] = new Pentagon(this, (i+5) % 10, layer+1);
        }
        for (int i = 0; i < 10; i++){
            if (neighbors[i].layer <= layer) continue;
            setStartingNeighbors(i, neighbors);
            neighbors[i].populate(maxLayers);
        }
    }
    public Pentagon(int maxLayers, int layer) {
        this.populate(maxLayers);
        layer = layer;
    }

    private void setStartingNeighbors(int i, Pentagon[] nbs) {
        if (i % 2 == layer % 2) {
            // side
            nbs[i].setNeighbor((i+4) % 10, nbs[(i+2) % 10]);
            nbs[i].setNeighbor((i+6) % 10, nbs[(i+8) % 10]);
            nbs[i].setNeighbor((i+3) % 10, nbs[(i+1) % 10]);
            nbs[i].setNeighbor((i+7) % 10, nbs[(i+9) % 10]);
        } else {
            // corner
            nbs[i].setNeighbor((i+4) % 10, nbs[(i+1) % 10]);
            nbs[i].setNeighbor((i+6) % 10, nbs[(i+9) % 10]);
        }
    }

    public Pentagon getNeighbor(int side){
        return neighbors[side];
    }

    public void setNeighbor(int side, Pentagon p){
        neighbors[side] = p;
    }

    @Override
    public String toString() {
        // simple redirect to toString(3) (default)
        return this.toString(3);
    }

    public String toString(int maxDepth) {
        StringBuilder sb = new StringBuilder();
        sb.append("Pentagon on layer ")
                .append(layer)
                .append("\n");
        for(int i = 0; i < 10; i++){
            if (neighbors[i] == null) continue;
            sb.append("\t"+i+": "+neighbors[i].toString(i, 2, maxDepth)+"\n");
        }
        return sb.toString();
    }

    public String toString(int side, int tabs, int maxDepth) {
        if (tabs > maxDepth) return "["+this.hashCode()+"]";
        StringBuilder sb = new StringBuilder();

        sb.append("Pentagon ")
                .append(this.hashCode())
                .append(" on layer ")
                .append(layer);

        for (int i = 0; i < 10; i++){
            if (neighbors[i % 10] == null) continue;

            sb.append("\n");
            for (int j = 0; j < tabs; j++) sb.append("\t");

            if ((i + 5) % 10 == side) {
                sb.append(i % 10)
                        .append(": Parent");
                continue;
            }

            sb.append(i % 10)
                    .append(": ")
                    .append(neighbors[i % 10].toString(i % 10, tabs + 1, maxDepth));
        }
        return sb.toString();
    }
}
