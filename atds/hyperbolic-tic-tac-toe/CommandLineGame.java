/*
 ** Oct 2021
 ** https://github.com/lutet88
 */

import java.util.Scanner;


// command-line game class
// really hard to actually play, but allows a simple 2-player game
// please read the README.md for instructions on how to play this game
public class CommandLineGame {
    // game variables
    private Pentagon origin;
    private int x; // = x-in-a-row to win
    private Player currentPlayer = Player.ONE;

    // Scanner for input
    private Scanner scanner;

    // constructor
    // origin: origin Pentagon
    // x: number in a row to win
    public CommandLineGame(Pentagon origin, int x) {
        this.origin = origin;
        this.x = x;
        this.scanner = new Scanner(System.in);
    }

    public void gameLoop() {
        Player p = Player.NONE; // p is the winning player

        // infinite loop until someone has won
        // does not handle if all Pentagons are filled up!
        while (true) {
            // check if anyone has one, if they have, break
            p = origin.hasWon(x);
            if (p != Player.NONE) break;

            System.out.println();
            System.out.println("player "+currentPlayer+"'s turn");
            System.out.println("give command:\nnav a,b,c,...,z or 'this'\ngo a,b,c,...,z or 'this'");
            boolean turnComplete = false;

            // allow the player to keep sending commands while their turn is not yet complete
            while (!turnComplete) {
                // get two space-separated terms from Scanner
                String command = scanner.next();
                String instr = scanner.next();

                // store command-separated second param as temp
                String[] temp = instr.split(",");

                // parse the second parameter
                int[] vals;
                if (instr.equals("this")) { // if second term is "this" verbatim
                    // shorthand instructions for "go back to itself"
                    vals = new int[] {0, 5};
                } else {
                    vals = new int[temp.length];
                    // handle potential issues with human input
                    try {
                        for (int i = 0; i < temp.length; i++) {
                            vals[i] = Integer.parseInt(temp[i].strip()) % 10;
                            assert vals[i] > 0;
                        }
                    } catch (NumberFormatException e) {
                        // covered since parseInt throws NumberFormatException
                        System.out.println("invalid input, check your instruction values!");
                        continue;
                    } catch (AssertionError e) {
                        System.out.println("invalid input, no negative numbers please!");
                        continue;
                    } catch (Exception e) {
                        // handle any exception, since I don't trust the user here
                        // if they use some unicode trickery to cause an Exception I don't know of,
                        // vague Exception deals with that
                        System.out.println("invalid input!");
                        continue;
                    }
                }

                // switch by command
                switch (command) {
                    case "nav": // navigate and print that Pentagon.toString(1)
                        printNavigation(vals);
                        break;

                    case "go": // select and set owner for that Pentagon
                        try {
                            Pentagon f = origin.navigate(vals);

                            // if it's occupied, don't let the Player play
                            if (f.getOwner() != Player.NONE) {
                                System.out.println("occupied position!");
                                break;
                            }

                            // set the Pentagon's owner
                            f.setOwner(currentPlayer);
                        } catch (NullPointerException e) {
                            System.out.println("null Pentagon! check your instructions!");
                            break;
                        }

                        // finish the turn (while loop will exit)
                        turnComplete = true;
                        break;

                    default:
                        System.out.println("unrecognized command");
                        break;
                }
            }

            // at the end of this while loop, change between Player.ONE and Player.TWO
            changeTurns();
        }

        // game end message
        System.out.println("\n\n\n"+ p + " has won!");
    }

    // helper method for command 'nav'
    private void printNavigation(int[] instructions) {
        try {
            System.out.println(origin.navigate(instructions).toString(1));
        } catch (NullPointerException e) {
            System.out.println("null Pentagon! check your instructions!");
        }
    }

    // helper method as a shorthand to changing turns
    // simply switches between Player.ONE and Player.TWO
    private void changeTurns() {
        currentPlayer = (currentPlayer == Player.ONE) ? Player.TWO : Player.ONE;
    }

}
