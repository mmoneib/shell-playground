# shell-playground
Games written in Shell Script for Unix-like command line. The games are solely tested on Bash and may not be portable to other Shell flavours without some tweaking.
## Engines
There are currently two game engines:
1. Turn-Based Engine
This is used for simulations of  board games, like XO, checkers, chess...etc. The structure is based on a sourced base script (inheritance) and functionality is spearated in sub-routines implemented by the sourcing script. There's a textual menu from which the user can initiate a game with a special configuration. A command indicating the next play is to be provided by the user with each turn.
2. Arcade Games
This is used for classic, score-based video games, like Snake, Tetris, Space Invaders...etc. The flow is continuos as the user interacts with the background without apparent interuptions. The structure is based on a template to be copied and filled with the games specifics, and the code is almost strictly procedural, with limited sub-routines used only in case of redundancies. The user faces a splash screen as an entry point, and the game starts smoothly afterwards.
