
class Main {
    public static void main(String[] args){
        System.out.println("bruh gaming");
        Pentagon origin = Pentagon.createPentaGrid(3);
        System.out.println(origin.toString(1));

        PentagonRenderer r = new PentagonRenderer(origin);
        r.render();
    }
}
