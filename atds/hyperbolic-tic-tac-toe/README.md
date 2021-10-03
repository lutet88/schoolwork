# Hyperbolic Tic-Tac-Toe

![httt logo](https://media.discordapp.net/attachments/885915977034924123/894267808450498631/httt.png?width=570&height=570)

## Inspiration
I wanted to write some minigame that can function nearly entirely recursively, for this recursion project. 
I remembered that Tic-Tac-Toe, or the (m, n, k) game, can be modeled as a graph and thus implemented recursively. 
I wondered if anyone had made a "Hyperbolic" version of the game, where the whole gaming is played on a uniform 
hyperbolic tiling. Turns out, no. That's why I chose this project.

## Project goal
- Build a functional tic-tac-toe game on a {5, 4} hyperbolic tiling.
    - Data structures and game rules ✔️ 
    - Command-line interface ✔️
    - Graphical interface ⌛
        - [Poincaré](https://en.wikipedia.org/wiki/Poincar%C3%A9_disk_model) or 
          [Beltrami-Klein](https://en.wikipedia.org/wiki/Beltrami%E2%80%93Klein_model) renderer
          
        - Using GUI toolkit (either `JavaFX` or `QtJambi`)

## Command-Line Game

The command-line interface `CommandLineGame` supports simple two-player tic-tac-toe gameplay.

1. Modify `Main.java` to change `X` (number in a row to win) and `GRID_DEPTH`,
   or the number of rings of additional `Pentagons` beyond the origin.

2. The game will prompt you will two commands, upon the start of the game:

`nav [instructions]`

`go [instructions]`

`[instructions]` are always in the form `v1,v2,v3,....vi`.
They represent your ability to select a `Pentagon`. The Pentagon selector, on each command, will traverse the Pentagrid
starting at the origin by moving to the neighbor at `v` index for each value `1,2,3...i` in your instructions.

`nav` will not skip your turn, and will display the `Pentagon` at those instructions, as well as its neighbors.

`go` will select a `Pentagon` at those instructions to place your mark. You will not lose your turn if you place on an
occupied or invalid tile. If the command succeeds, the turn is passed to the next player.

The game will end when there are X-in-a-row of consecutive same-player `Pentagon`s on the same axis `(i <-> (i+5) % 10)`
for each `Pentagon`.

![Order-4 Pentagonal Tiling](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/H2-5-4-dual.svg/720px-H2-5-4-dual.svg.png)

This is basically your playing field! Each vertex and edge of each `Pentagon` constitutes a connection!

## Implementation
### Data Structures
- Each tile is represented as a `Pentagon`, a graph node with 10 connections (5 side, 5 corner) to 
other `Pentagon`s
  
### Algorithms
- Construction of `Pentagon` "grid": Depth-first recursive construction. 
- Returning `toString()`: Depth-first recursive String building.
- Navigating the `Pentagon` "grid": Per-instruction recursive traversal.
- Detecting for X-in-a-row for a given player: Depth-first recursive search.
    - You could totally optimize this, but I don't have the time for that.

#### Doesn't really work:
- Rendering the `Pentagon` "grid": Depth-first recursive collection of `Line[]`.

![Rendering is really hard!](https://media.discordapp.net/attachments/561405222333841410/894197307589935134/unknown.png)

##### Rendering is really hard! I'm not very good at it, either.

#### Time complexity:
d = Depth 

n = Number of Pentagonal Nodes (`≈ 10 * 4^d`)

m = Number of instructions for navigation

- Construction: `O(n) ≈ O(4^d)`
- `toString()`: `O(n) ≈ O(4^d)`
- Navigation: `O(m)`
- Detecting `X`-in-a-row: `O(10^d * X)`

### UML Diagram
![UML Diagram](https://cdn.discordapp.com/attachments/885915977034924123/894254671517089862/unknown.png)

## Current Next Steps
- Properly figure out how to render a Poincaré disk using [this tutorial](http://www.malinc.se/noneuclidean/en/poincaretiling.php) I just discovered
- Make `Pentagon` universal for any Order-4 polygonal tiling
- Implement a graphical GUI
