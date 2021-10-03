/*
** Main.java
** contains the Java main method, which runs the rest of the app
**
** Oct 2021
** https://github.com/lutet88
**
** NOTE:    I really don't like header comments, since all the information
**          typically stored on them can be found through git and the README.md.
**          You won't find anything other than a signature on all the other files.
*/

class Main {
    public static void main(String[] args){
        System.out.println("Pentagonal Tic-Tac-Toe");

        // create graph of Pentagons
        Pentagon origin = Pentagon.createPentaGrid(4);

        // demonstrate cursed recursive toString() method
        System.out.println(origin);

        // renderer (doesn't work with depth > 2)
        /*
        ** PentagonRenderer r = new PentagonRenderer(origin);
        ** r.render();
        */
    }
}
