# Match-3 - VXAce
_Author: Heirukichi_

## DESCRIPTION
This script allows you to create match-3 puzzles in your VXAce games. It allows you to move elements of your puzzle by either pushing them or swapping them with other elements.


## INSTALLATION
Copy/paste this script in your project BELOW Materials and above main. The script aliases a few methods of the `Game_Map` class and `Graphics` module. Be sure to place it BELOW any script that overwrites those methods.
When using this script you can mark puzzle maps using the following notetad: `[hrkm3p]`.
In any map marked as a puzzle map, you can mark events that have to act as blocks for your puzzle. Those events should contain a comment with the following syntax: "Block: color_here".
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Example:
@> Comment: Block: blue
- The comment above marks an event as a blue block.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### NOTICE
> Blocks color is just a way to check if they are part of the same set and can be deleted	when matched together. You can have a red event acting as a yellow block.

Additionially, you can allocate a self switch to determine if blocks have already been deleted or not. Follow the instructions in the CONFIG module below if you want to customize the said switch.

Every block event has to be moved using one of the two following script calls:
- `hrk_mtt_push_block` (push the block in the direction the player is facing)
- `hrk_mtt_swap_blocks` (swap blocks according to the configuration of the script)

#### NOTICE
> Before swaping blocks the engine checks if the swap is a valid move. If it is not, the movement is skipped and nothing happens.

#### AUTHOR NOTE
> I recommend using block swapping with Below Characters events.

If you want to reset the puzzle you can use the following script call in one of your events:
- `hrk_mtt_reset_puzzle`

The script call will automatically reset your map. However, to do so, you have to designate a dummy map. That dummy map is used to temporary transfer the player to automatically reset the map where the puzzle takes place. The reset happens while the screen is frozen so you can use any map you want. Even so, I recommend using a small empty map to speed up the process.


#### **IMPORTANT NOTICE**
> The script does not work with looping maps!


Everything else should be configured in the `CONFIG` module. Detailed instructions can be found there.
