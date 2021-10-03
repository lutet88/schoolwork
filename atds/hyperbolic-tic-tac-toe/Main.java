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

    static final int X = 3;
    static final int GRID_DEPTH = 3;

    public static void main(String[] args){
        System.out.println("Pentagonal Tic-Tac-Toe");

        // create graph of Pentagons
        Pentagon origin = Pentagon.createPentaGrid(GRID_DEPTH);

        // demonstrate cursed recursive toString() method
        System.out.println(origin);

        // renderer (doesn't work with depth > 2)
        /*
        ** PentagonRenderer r = new PentagonRenderer(origin);
        ** r.render();
        */

        // create CommandLineGame
        CommandLineGame clg = new CommandLineGame(origin, X);

        // run the game loop
        clg.gameLoop();
    }
}
