# Chess App (prototype)

## Denaux

### Basic overview of current architecture

- The logic is handled in the controller, while the game initialization is handled in the controller-helper. The Piece objects
are also defined and initialized via the controller-helper file. The controller then passes down variables to be rendered in the html.erb
files. The user interfaces with the board via jquery/ajax functions in the asset pipeline, located in chess.js file. It is worth noting
that the erb templates assign a value that is passed down to the jquery, and which is used to select and manipulate logic contained in
the controllers.

### Known Bugs and Areas of Improvement

- Pawn logic needs work
- Code needs to be refactored
- AI needs improvement
- Will also in the future integrate user models capable of saving games and for improving AI through machine learning.

### Update for November
- Major refactor complete for maintaining data-consistency when developing models for the backend.
- Tentative design for the back-end is thus:
  - User models
  - Game instance model(State) :optionally belongs to Users
  - Board(array of object instances) : belongs to Game
- Probably use OAuth to help maintain data persistence throughout the game, or a
temporary Game instance that will expire if not associated with a User.

###Update for December
- Created models for database
   - Games: Store Player/ Cpu data
   - Turn: Stores board state, belongs to Games, games_id as foreign key    required reference
- Session stores Games id and count. Now the game maintains state throughout the session.
- Bugs:
  - king and pawn moves have some slight issues.
- AI is improved, but will still need work.
- Pawn impassant move not yet integrated.
- User model w/ OAuth to be implemented next.
