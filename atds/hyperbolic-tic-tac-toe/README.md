# Hyperbolic Tic-Tac-Toe

## Project goal
- Build a functional tic-tac-toe game on a {5, 4} hyperbolic tiling.
    - Data structures and game rules ✔️ 
    - Command-line interface ✔️
    - Graphical interface ⌛
        - [Poincare](https://en.wikipedia.org/wiki/Poincar%C3%A9_disk_model) or 
          [Beltrami-Klein](https://en.wikipedia.org/wiki/Beltrami%E2%80%93Klein_model) renderer
          
        - Using GUI toolkit (either `JavaFX` or `QtJambi`)
    
## Implementation
### Data Structures
- Each tile is represented as a `Pentagon`, a graph node with 10 connections (5 side, 5 corner) to 
other `Pentagon`s
  
### Algorithms
- Construction of `Pentagon` "grid": Depth-first recursive construction.
- Returning `toString()`: Depth-first recursive String building.
- Navigating the `Pentagon` "grid": Per-instruction recursive traversal.
- Detecting for X-in-a-row for a given player: Depth-first recursive search.

### UML Diagram
will be here when I'm actually done