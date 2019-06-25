#===============================================================================================
# HEIRUKICHI MATCH-3 - VX ACE
#===============================================================================================
# Version 1.0.0
# - Author: Heirukichi
# - Last update 06-25-2019 [MM-DD-YYYY]
#===============================================================================================
# TERMS OF USE
#-----------------------------------------------------------------------------------------------
# You are free to use this script in both commercial and non commercial games as long as proper
# credit is given to me (Heirukichi). Feen free to edit this script as much as you like as long
# as you do not pretend you wrote the whole script and you distribute it under the same license.
#
# Attribution-ShareAlike 4.0 International: https://creativecommons.org/licenses/by-sa/4.0/
#
# In addition to this I would like to be notified when this script is used in a commercial game.
# As the license says the usage of this script is free. The notification is only used to keep
# track of games where my script is being used.
# You can contact me using the appropriate form on my blog, or you can send me a private message
# on RPG Maker Forums @Heirukichi. While doing this is not mandatory please do not forget about
# it. It helps a lot. Of course feel free to notify me when you use it for non-commercial games
# as well (if you feel like doing it).
#===============================================================================================
# DESCRIPTION
#-----------------------------------------------------------------------------------------------
# This script allows you to create match-3 puzzles in your RPG Maker VX Ace games.
#===============================================================================================
# INSTRUCTIONS
#-----------------------------------------------------------------------------------------------
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
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# IMPORTANT: the script does not work with looping maps!
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Everything else should be configured in the CONFIG module below. Detailed instructions can be
# found there.
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
		HRK_MTT.check_adjacent_blocks(block.x, block.y)
		HRK_MTT.check_adjacent_blocks(x2, y2)
	end
	
end # end of Game_Interpreter
