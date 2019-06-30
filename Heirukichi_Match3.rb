#===============================================================================================
# HEIRUKICHI MATCH-3 - VX ACE
#===============================================================================================
# Version 1.1.0
# - Author: Heirukichi
# - Last update 06-30-2019 [MM-DD-YYYY]
#===============================================================================================
# TERMS OF USE
#-----------------------------------------------------------------------------------------------
# This script is under the GNU General Public License v3.0. This means that:
# - You are free to use this script in both commercial and non-commercial games as long as you
#   give proper credits to me (Heirukichi) and provide a link to my website;
# - You are free to modify this script as long as you do not pretend you wrote this and you
#   distribute it under the same license as the original.
#
# You can review the full license here: https://www.gnu.org/licenses/gpl-3.0.html
#
# In addition I'd like to keep track of games where my scripts are used so, even if this is not
# mandatory, I'd like you to inform me and send me a link when a game including my script is
# published. As I said, this is not mandatory but it really helps me and it is much appreciated.
#
# IMPORTANT NOTICE:
# If you want to distribute this code, feel free to do it, but provide a link to my website
# instead of pasting my script somewhere else.
#===============================================================================================
# DESCRIPTION
#-----------------------------------------------------------------------------------------------
# This script allows you to create match-3 puzzles in your RPG Maker VX Ace games.
#===============================================================================================
# INSTRUCTIONS
#-----------------------------------------------------------------------------------------------
# Copy/paste this script in your project BELOW Materials and above main. The script aliases a
# few methods of the Game_Map class and Graphics module. Be sure to place it BELOW any script
# that overwrites those methods.
#
# When using this script you can mark puzzle maps using the following notetad: [hrkm3p].
# In any map marked as a puzzle map, you can mark events that have to act as blocks for your
# puzzle. Those events should contain a comment with the following syntax: "Block: color_here".
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Example:
# @> Comment: Block: blue
# - The comment above marks an event as a blue block.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# NOTE: blocks color is just a way to check if they are part of the same set and can be deleted
#		when matched together. You can have a red event acting as a yellow block.
#
# Additionially, you can allocate a self switch to determine if blocks have already been deleted
# or not. Follow the instructions in the CONFIG module below if you want to customize the said
# switch.
#
# Every block event has to be moved using one of the two following script calls:
# - hrk_mtt_push_block (push the block in the direction the player is facing)
# - hrk_mtt_swap_blocks (swap blocks according to the configuration of the script)
#
# NOTE: before swaping blocks the engine checks if the swap is a valid move. If it is not, the
#		movement is skipped and nothing happens.
#
# AUTHOR NOTE: I recommend using block swapping with Below Characters events.
#
# If you want to reset the puzzle you can use the following script call in one of your events:
# - hrk_mtt_reset_puzzle
#
# The script call will automatically reset your map. However, to do so, you have to designate a
# dummy map. That dummy map is used to temporary transfer the player to automatically reset the
# map where the puzzle takes place. The reset happens while the screen is frozen so you can use
# any map you want. Even so, I recommend using a small empty map to speed up the process.
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# IMPORTANT: the script does not work with looping maps!
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Everything else should be configured in the CONFIG module below. Detailed instructions can be
# found there.
#===============================================================================================
# UPDATE LOG
#-----------------------------------------------------------------------------------------------
# 06-30-2019 [MM-DD-YYYY] Version 1.1.0
# * Added a method to automatically reset your puzzle.
# * Aliased fadein and fadeout methods in Graphics module.
#
# 06-26-2019 [MM-DD-YYYY] Version 1.0.2
# * Fixed a bug that caused hrk_mtt_swap_blocks to check the selected block twice instead of
#   checking both blocks when eliminating matching blocks.
#
# 06-26-2019 [MM-DD-YYYY] Version 1.0.1
# * Updated Terms of Use. There is no substantial change in what you can do with the script, the
#   only thing that changed is how credit must be given (you have to provide a link to my blog
#   instead of posting this script somewhere and when giving credits). For more details you can
#   review the complete license in the Terms of Use paragraph above.
#===============================================================================================

$imported = {} if $imported.nil?
$imported["Heirukichi_MTT"] = true

module HRK_MTT
	
	#===========================================================================================
	# ** CONFIG module. Edit this one to customize the script.
	#===========================================================================================
	module CONFIG
	
		#=======================================================================================
		# Set this value to be the self switch you want to trigger to delete blocks. Do not
		# forget to use either ' ' or " ". Default is 'A'.
		# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# Example:
		# 'A' -> OK
		# "A" -> OK
		# A -> WRONG
		#=======================================================================================
		DISAPPEAR_SWITCH = 'A'
		
		#=======================================================================================
		# Set this to be the minimum number of aligned blocks to trigger blocks destruction.
		# Default is 2 (as in any other match-3 game).
		#=======================================================================================
		ALIGNED_BLOCKS = 3
		
		#=======================================================================================
		# When CUSTOM_VARIABLE is true, you can store the number of aligned blocks necessary to
		# trigger the blocks destruction in a variable and use that one instead of the default
		# value used in this configuration module. This allows you to dinamically create puzzles
		# with different clearing conditions. Default is false.
		# CUSTOM_VARIABLE_ID is the ID of the said variable. Default is 10.
		#=======================================================================================
		CUSTOM_VARIABLE = false
		CUSTOM_VARIABLE_ID = 10
		
		#=======================================================================================
		# This value is only used when you try to swap blocks. Set it to false if you want to
		# swap the selected block with the one in the direction the player is facing, set it to
		# true otherwise. Default is false.
		#=======================================================================================
		REVERSE_DIR = false
		
		#=======================================================================================
		# This is a dummy map id. The player is temporary transferred to this map when resetting
		# puzzle maps. Default is 1.
		#=======================================================================================
		DUMMY_MAP = 1
		
	end # end of CONFIG module
	
	#===========================================================================================
	# - - - - - - - - - - - - - - - - - - - ! WARNING ! - - - - - - - - - - - - - - - - - - - -
	# DO NOT MODIFY THE SCRIPT AFTER THIS POINT UNLESS YOU KNOW EXACTLY WHAT YOU ARE DOING. ANY
	# MODIFICATION AFTER THIS POINT MIGHT PREVENT THE SCIPT FROM WORKING PROPERLY AND CAUSE YOUR
	# GAME TO CRASH.
	#===========================================================================================
	
	#===========================================================================================
	# ** HRK_MTT::Block class
	#===========================================================================================
	class Block
	
		attr_reader :id
		attr_reader :color
		
		#---------------------------------------------------------------------------------------
		# * Initialize
		#---------------------------------------------------------------------------------------
		def initialize
			@id = 0
			@block = false
			@color = 0
		end
		
		#---------------------------------------------------------------------------------------
		# * Return true if the current block space contains a block
		#---------------------------------------------------------------------------------------
		def block?
			@block
		end
		
		#---------------------------------------------------------------------------------------
		# * Setup block
		#---------------------------------------------------------------------------------------
		def set_block(key, e_id)
			@block = true
			@color = key
			@id = e_id
		end
		
		#---------------------------------------------------------------------------------------
		# * Return true if the current block space contains a destroyed block
		#---------------------------------------------------------------------------------------
		def disappeared?
			return false unless block?
			$game_self_switches[[$game_map.map_id, id, HRK_MTT.destroy]]
		end
		
		#---------------------------------------------------------------------------------------
		# * Destroy block in this space
		#---------------------------------------------------------------------------------------
		def destroy_block
			return unless block?
			$game_self_switches[[$game_map.map_id, id, HRK_MTT.destroy]] = true
		end
		
		#---------------------------------------------------------------------------------------
		# * Reset block
		#---------------------------------------------------------------------------------------
		def reset_block
			return unless block?
			$game_self_switches[[$game_map.map_id, id, HRK_MTT.destroy]] = false
		end
		
		#---------------------------------------------------------------------------------------
		# * Returns true if the current block space contains an active block
		#---------------------------------------------------------------------------------------
		def active?
			return false unless block?
			!disappeared?
		end
		
		#---------------------------------------------------------------------------------------
		# * Returns true if the current block space contains a block of a given color
		#---------------------------------------------------------------------------------------
		def same_color?(c)
			return false unless active?
			@color == c
		end
		
	end # end of Block class
	
	#-------------------------------------------------------------------------------------------
	# * Destroy switch id
	#-------------------------------------------------------------------------------------------
	def self.destroy
		CONFIG::DISAPPEAR_SWITCH
	end
	
	#-------------------------------------------------------------------------------------------
	# * Dummy map id
	#-------------------------------------------------------------------------------------------
	def self.dummy_map
		CONFIG::DUMMY_MAP
	end
	
	#-------------------------------------------------------------------------------------------
	# * Custom chain length
	#-------------------------------------------------------------------------------------------
	def self.custom_chain
		$game_variables[CONFIG::CUSTOM_VARIABLE_ID]
	end
	
	#-------------------------------------------------------------------------------------------
	# * Chain length
	#-------------------------------------------------------------------------------------------
	def self.chain_length
		CONFIG::CUSTOM_VARIABLE ? custom_chain : CONFIG::ALIGNED_BLOCKS
	end
	
	#-------------------------------------------------------------------------------------------
	# * Check horizontal matches
	#-------------------------------------------------------------------------------------------
	def self.check_horizontally(x, y, d)
		marked = 0
		block = $game_map.puzzle_grid[x][y]
		for i in (x - d)..(x + d)
			next unless $game_map.valid?(i, y)
			b2 = $game_map.puzzle_grid[i][y]
			block.same_color?(b2.color) ? marked += 1 : marked = 0
			return true if (marked > d)
		end
		false
	end
	
	#-------------------------------------------------------------------------------------------
	# * Check vertical matches
	#-------------------------------------------------------------------------------------------
	def self.check_vertically(x, y, d)
		marked = 0
		block = $game_map.puzzle_grid[x][y]
		for i in (y - d)..(y + d)
			next unless $game_map.valid?(x, i)
			b2 = $game_map.puzzle_grid[x][i]
			block.same_color?(b2.color) ? marked += 1 : marked = 0
			return true if (marked > d)
		end
		false
	end
	
	#-------------------------------------------------------------------------------------------
	# * Clear horizontal blocks
	#-------------------------------------------------------------------------------------------
	def self.clear_horz(x, y, d)
		block = $game_map.puzzle_grid[x][y]
		i = 1
		while (i <= d)
			x2 = x + i
			break unless $game_map.valid?(x2, y)
			b2 = $game_map.puzzle_grid[x2][y]
			break unless b2.same_color?(block.color)
			b2.destroy_block
			i += 1
		end
		i = 1
		while (i <= d)
			x2 = x - i
			break unless $game_map.valid?(x2, y)
			b2 = $game_map.puzzle_grid[x2][y]
			break unless b2.same_color?(block.color)
			b2.destroy_block
			i += 1
		end
	end
	
	#-------------------------------------------------------------------------------------------
	# * Clear vertical blocks
	#-------------------------------------------------------------------------------------------
	def self.clear_vert(x, y, d)
		block = $game_map.puzzle_grid[x][y]
		i = 1
		while (i <= d)
			y2 = y + i
			break unless $game_map.valid?(x, y2)
			b2 = $game_map.puzzle_grid[x][y2]
			break unless b2.same_color?(block.color)
			b2.destroy_block
			i += 1
		end
		i = 1
		while (i <= d)
			y2 = y - i
			break unless $game_map.valid?(x, y2)
			b2 = $game_map.puzzle_grid[x][y2]
			break unless b2.same_color?(block.color)
			b2.destroy_block
			i += 1
		end
	end
	
	#-------------------------------------------------------------------------------------------
	# * Clear single block
	#-------------------------------------------------------------------------------------------
	def self.clear_block(x, y)
		$game_map.puzzle_grid[x][y].destroy_block
	end
	
	#-------------------------------------------------------------------------------------------
	# * Check adjacent blocks for matches and delete them from the grid
	#-------------------------------------------------------------------------------------------
	def self.check_adjacent_blocks(x, y)
		distance = chain_length - 1
		mark_horz = check_horizontally(x, y, distance)
		mark_vert = check_vertically(x, y, distance)
		clear_horz(x, y, distance) if mark_horz
		clear_vert(x, y, distance) if mark_vert
		clear_block(x, y) if (mark_horz || mark_vert)
	end
	
	#-------------------------------------------------------------------------------------------
	# * Check if block swap is possible
	#-------------------------------------------------------------------------------------------
	def self.swap_possible?(x1, y1, x2, y2)
		distance = chain_length - 1
		b1 = $game_map.puzzle_grid[x1][y1].clone
		b2 = $game_map.puzzle_grid[x2][y2].clone
		$game_map.puzzle_grid[x1][y1].set_block(b2.color, b2.id)
		$game_map.puzzle_grid[x2][y2].set_block(b1.color, b1.id)
		return true if check_horizontally(x1, y1, distance)
		return true if check_horizontally(x2, y2, distance)
		return true if check_vertically(x1, y1, distance)
		return true if check_vertically(x2, y2, distance)
		$game_map.puzzle_grid[x1][y1].set_block(b1.color, b1.id)
		$game_map.puzzle_grid[x2][y2].set_block(b2.color, b2.id)
		false
	end
	
	#-------------------------------------------------------------------------------------------
	# * Swap direction
	#-------------------------------------------------------------------------------------------
	def self.dir
		d = $game_player.direction
		CONFIG::REVERSE_DIR ? $game_player.reverse_dir(d) : d
	end
	
	#-------------------------------------------------------------------------------------------
	# * Resetting?
	#-------------------------------------------------------------------------------------------
	def self.resetting?
		@resetting
	end
	
	#-------------------------------------------------------------------------------------------
	# * Set Player Position
	#-------------------------------------------------------------------------------------------
	def self.set_player_position(map, x, y)
		@player_position = [] if @player_position.nil?
		@player_position.replace([map, x, y])
	end
	
	#-------------------------------------------------------------------------------------------
	# * Player Position
	#-------------------------------------------------------------------------------------------
	def self.player_position
		return [1, 0, 0] if @player_position.nil?
		@player_position
	end
	
	#-------------------------------------------------------------------------------------------
	# * Start Map Reset
	#-------------------------------------------------------------------------------------------
	def self.start_reset
		@resetting = true
		Graphics.freeze
		set_player_position($game_map.map_id, $game_player.x, $game_player.y)
	end
	
	#-------------------------------------------------------------------------------------------
	# * Clear Map Reset
	#-------------------------------------------------------------------------------------------
	def self.clear_reset
		@resetting = false
		set_player_position(dummy_map, 0, 0)
		Graphics.transition(30)
	end
	
end # end of HRK_MTT module

#===============================================================================================
# ** Game_Map class
#===============================================================================================
class Game_Map

	attr_reader :puzzle
	attr_reader :puzzle_grid
	
	#-------------------------------------------------------------------------------------------
	# * Aliased method: initialize
	#-------------------------------------------------------------------------------------------
	alias hrk_mtt_initialize_old initialize
	def initialize
		hrk_mtt_initialize_old
		@puzzle_grid = []
	end
	
	#-------------------------------------------------------------------------------------------
	# * Aliased method: setup
	#-------------------------------------------------------------------------------------------
	alias hrk_mtt_setup_old	setup
	def setup(map_id)
		hrk_mtt_setup_old(map_id)
		@puzzle = @map.note.include?("[hrkm3p]")
		hrk_mtt_setup_puzzle if puzzle
	end
	
	#-------------------------------------------------------------------------------------------
	# + New method: hrk_mtt_setup_puzzle
	#-------------------------------------------------------------------------------------------
	def hrk_mtt_setup_puzzle
		new_grid = Array.new(width) do
			Array.new(height) { HRK_MTT::Block.new }
		end
		@puzzle_grid.replace(new_grid)
		hrk_mtt_setup_blocks
	end
	
	#-------------------------------------------------------------------------------------------
	# + New method: hrk_mtt_setup_blocks
	#-------------------------------------------------------------------------------------------
	def hrk_mtt_setup_blocks
		events.each_key do |k|
			e = events[k]
			comments = e.list.select { |cmd| cmd.code == 108 }
			comments.each do |c|
				if c.parameters[0][/Block: (\w+)/]
					puzzle_grid[e.x][e.y].set_block($1, k)
					break
				end
			end
		end
	end
	
	#-------------------------------------------------------------------------------------------
	# + New method: hrk_mtt_reset_blocks
	#-------------------------------------------------------------------------------------------
	def hrk_mtt_reset_blocks
		events.each_key do |k|
			e = events[k]
			puzzle_grid[e.x][e.y].reset_block
		end
	end
	
end #end of Game_Map

#===============================================================================================
# ** Game_Interpreter class
#===============================================================================================
class Game_Interpreter
	
	#-------------------------------------------------------------------------------------------
	# + New method: hrk_mtt_push_block
	#-------------------------------------------------------------------------------------------
	def hrk_mtt_push_block
		return unless $game_map.puzzle
		block = $game_map.events[@event_id]
		return unless $game_map.puzzle_grid[block.x][block.y].block?
		blclr = $game_map.puzzle_grid[block.x][block.y].color
		$game_map.puzzle_grid[block.x][block.y].set_block(0, 0)
		block.move_straight($game_player.direction)
		Fiber.yield while block.moving?
		$game_map.puzzle_grid[block.x][block.y].set_block(blclr, @event_id)
		HRK_MTT.check_adjacent_blocks(block.x, block.y)
	end
	
	#-------------------------------------------------------------------------------------------
	# + New method: hrk_mtt_swap_blocks
	#-------------------------------------------------------------------------------------------
	def hrk_mtt_swap_blocks
		return unless $game_map.puzzle
		block = $game_map.events[@event_id]
		return unless $game_map.puzzle_grid[block.x][block.y].block?
		blclr = $game_map.puzzle_grid[block.x][block.y].color
		x2 = $game_map.round_x_with_direction(block.x, HRK_MTT.dir)
		y2 = $game_map.round_y_with_direction(block.y, HRK_MTT.dir)
		oldx = block.x
		oldy = block.y
		block2 = $game_map.events[$game_map.puzzle_grid[x2][y2].id]
		return unless $game_map.puzzle_grid[x2][y2].block?
		blclr2 = $game_map.puzzle_grid[x2][y2].color
		return if blclr == blclr2
		move_possible = HRK_MTT.swap_possible?(block.x, block.y, x2, y2)
		return unless move_possible
		block.instance_variable_set(:@through, true)
		block2.instance_variable_set(:@through, true)
		block.move_straight(HRK_MTT.dir)
		block2.move_straight(10 - HRK_MTT.dir)
		Fiber.yield while block2.moving?
		block.instance_variable_set(:@through, false)
		block2.instance_variable_set(:@through, false)
		HRK_MTT.check_adjacent_blocks(oldx, oldy)
		HRK_MTT.check_adjacent_blocks(x2, y2)
	end
	
	#-------------------------------------------------------------------------------------------
	# + New method: hrk_mtt_reset_puzzle
	#-------------------------------------------------------------------------------------------
	def hrk_mtt_reset_puzzle
		return unless $game_map.puzzle
		HRK_MTT.start_reset
		$game_map.hrk_mtt_reset_blocks
		$game_player.reserve_transfer(HRK_MTT.dummy_map, 0, 0)
		Fiber.yield while $game_player.transfer?
		pos = HRK_MTT.player_position
		$game_player.reserve_transfer(*pos)
		Fiber.yield while $game_player.transfer?
		HRK_MTT.clear_reset
	end
	
end # end of Game_Interpreter

#===============================================================================================
# ** Graphics module
#===============================================================================================
module Graphics
	
	#-------------------------------------------------------------------------------------------
	# * Graphics class (used to alias methods)
	#-------------------------------------------------------------------------------------------
	class << Graphics
		
		#---------------------------------------------------------------------------------------
		# * Aliased method: fadein
		#---------------------------------------------------------------------------------------
		alias hrk_mtt_fadein_old	fadein
		def fadein(d)
			return if HRK_MTT.resetting?
			hrk_mtt_fadein_old(d)
		end
		
		#---------------------------------------------------------------------------------------
		# * Aliased method: fadeout
		#---------------------------------------------------------------------------------------
		alias hrk_mtt_fadeout_old	fadeout
		def fadeout(d)
			return if HRK_MTT.resetting?
			hrk_mtt_fadeout_old(d)
		end
		
	end #end of Graphics class
	
end # end of Graphics module
