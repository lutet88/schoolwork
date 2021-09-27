

class Pentagon {

    private int layer;

    public static Pentagon createPentaGrid(int maxDepth){
        return new Pentagon(maxDepth);
    }

    private Pentagon[] neighbors = new Pentagon[10];

    public Pentagon(Pentagon parent, int parentSide, int maxDepth) {
        neighbors[parentSide] = parent;

        layer = maxDepth;
        if (maxDepth == 0) return;
        for (int i = 0; i < 10; i++){
            if (i == parentSide) continue;
            neighbors[i] = new Pentagon(this, (i+5) % 10, maxDepth-1);
        }
    }
    public Pentagon(int maxDepth){
        layer = maxDepth;
        if (maxDepth == 0) return;
        for (int i = 0; i < 10; i++){
            neighbors[i] = new Pentagon(this, (i+5) % 10, maxDepth-1);
            neighbors[i].setNeighbor((i+4) % 10, neighbors[(i+9) % 10]);
        }
    }

    public Pentagon getNeighbor(int side){
        return neighbors[side];
    }

    public void setNeighbor(int side, Pentagon p){
        neighbors[side] = p;
    }

    @Override
    public String toString(){
        StringBuilder sb = new StringBuilder();
        sb.append("Pentagon on layer "+layer+"\n");
        for(int i = 0; i < 10; i++){
            if (neighbors[i] == null) continue;
            sb.append("\t"+i+": "+neighbors[i].toString(i, 2)+"\n");
        }
        return sb.toString();
    }

    public String toString(int side, int tabs){
        StringBuilder sb = new StringBuilder();
        sb.append("Pentagon on layer "+layer);
        for (int i = side+8; i <= side+11; i++){
            if (neighbors[i % 10] == null) continue;
            sb.append("\n");
            for (int j = 0; j < tabs; j++) sb.append("\t");
            sb.append(i%10+": "+neighbors[i % 10].toString(i % 10, tabs+1));
        }
        return sb.toString();
    }
}
