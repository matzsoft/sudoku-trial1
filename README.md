# Sudoku
Data entry and solver for sudoku puzzles. A MacOS app.

Still in early development.

## Currently Implemented
1. Can open a .txt file if in the correct format and display the contents.
1. Can create and display a new empty puzzle in 2 sizes.
1. Can select a cell with the mouse.
1. Can move the selection with the arrow keys.

## TODO List
For now, in no particular order, this is a list of things needed.

1. Figure out @Publisher, @State, and @Environment work and how to use them to control data sharing and View updates.
1. I would like Cell and Drawer to know what SudokuPuzzle they belong to without sacrificing immutability.
1. Allow editing of the puzzle cells.
1. Save an edited file to disk.
1. Allow graphics files as input, coverting them to puzzles.
1. Speech verification of puzzles.
1. A "show the solution" option.
1. An interactive "solve the puzzle" mode.
1. The drawer suffers from too much mixing of Int and CGFloat.
