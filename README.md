# Match-3 - VXAce
_Author: Heirukichi_

## DESCRIPTION
This script allows you to create match-3 puzzles in your VXAce games. It allows you to move elements of your puzzle by either pushing them or swapping them with other elements.

## TABLE OF CONTENTS
* [Installation](#installation)
* [Usage](#usage)
* [License](#license)

## INSTALLATION
Copy/paste this script in your project _BELOW_ Materials and above main. The script aliases a few methods of the `Game_Map` class and `Graphics` module. Be sure to place it _BELOW_ any script that overwrites those methods.
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

## USAGE
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

## LICENSE
All the images in this project are under the CC BY-SA 4.0 International license. You can review the full license [here](https://creativecommons.org/licenses/by-sa/4.0/legalcode).

The code is under the GNU General Public License v3.0. You can review the complete GNU General Public License v3.0 in the LICENSE file or at this [link](https://www.gnu.org/licenses/gpl-3.0.html).

To sum up things you are free to use this material in any commercial and non commercial project as long as _ALL_ the following conditions are satisfied:
- proper credit is given to me (Heirukichi);
- a link to my website is provided (I recommend adding it to a credits.txt file in your project, but any other mean is fine);
- if you modify anything, you still provide credit and properly mark the parts you have modified.

In addition, I would like to be notified if you use this in any project.
You can send me a message containing a link to the finished product using the contact form on my website (check my profile for the link).
The link is not supposed to contain a free copy of the finished product.
The sole purpose of the link is to help me keeping track of where my work is being used.

More information can be found in the script itself.
At the same time, the script contains detailed instructions on how to use it. Read them carefully.
