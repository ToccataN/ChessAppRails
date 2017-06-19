# Chess App (prototype)

## Denaux

### Basic overview of current architecture

- The logic is handled in the controller, while the game initialization is handled in the controller-helper. The Piece objects
are also defined and initialized via the controller-helper file. The controller then passes down variables to be rendered in the html.erb 
files. The user interfaces with the board via jquery/ajax functions in the asset pipeline, located in chess.js file. It is worth noting
that the erb templates assign a vlaue that is passed down to the jquery, and which is used to select and manipulate logic contained in
the controllers.

### Known Bugs and Areas of Improvement 

- Pawn logic needs work
- Castling functionality needs to be integrated in
- Player select color in root directory
- Code needs to be refactored
- AI needs improvement
- Will also in the future integrate user models capable of saving games and for improving AI through machine learning.

