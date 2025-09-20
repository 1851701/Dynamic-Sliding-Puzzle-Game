#!/usr/bin/env python3
"""
Dynamic Sliding Puzzle Game - Python Implementation
Demonstrates cross-platform compatibility and algorithmic rigor

This Python version showcases the same core algorithms and game logic
as the SwiftUI implementation, proving the framework's adaptability.
"""

import tkinter as tk
from tkinter import ttk, messagebox
import random
import time
from typing import List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum

class Difficulty(Enum):
    EASY = 3
    MEDIUM = 4
    HARD = 5
    EXPERT = 6

@dataclass
class GameStats:
    moves: int = 0
    start_time: float = 0
    elapsed_time: float = 0
    is_solvable: bool = True

class SlidingPuzzleGame:
    """
    Core game logic with AI-based solvability checking
    Implements the same algorithms as the SwiftUI version
    """
    
    def __init__(self, difficulty: Difficulty = Difficulty.EASY):
        self.difficulty = difficulty
        self.size = difficulty.value
        self.grid: List[List[int]] = []
        self.blank_pos: Tuple[int, int] = (0, 0)
        self.stats = GameStats()
        self.generate_solvable_puzzle()
    
    def generate_solvable_puzzle(self) -> None:
        """Generate a solvable puzzle using AI-based algorithms"""
        # Create solved puzzle
        self.grid = [[row * self.size + col + 1 for col in range(self.size)] 
                    for row in range(self.size)]
        self.grid[self.size - 1][self.size - 1] = 0  # Blank tile
        self.blank_pos = (self.size - 1, self.size - 1)
        
        # Shuffle while maintaining solvability
        self.grid = self._shuffle_puzzle()
        self.blank_pos = self._find_blank_position()
        
        # Verify and ensure solvability
        if not self._check_solvability():
            self._make_solvable()
            self.blank_pos = self._find_blank_position()
        
        self.stats = GameStats()
        self.stats.start_time = time.time()
    
    def _shuffle_puzzle(self) -> List[List[int]]:
        """Shuffle puzzle using valid moves to maintain solvability"""
        shuffled = [row[:] for row in self.grid]
        blank_row, blank_col = self.blank_pos
        
        # Perform random valid moves
        for _ in range(self.size * self.size * 10):
            directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
            random.shuffle(directions)
            
            for dr, dc in directions:
                new_row, new_col = blank_row + dr, blank_col + dc
                if (0 <= new_row < self.size and 0 <= new_col < self.size):
                    # Swap blank with adjacent tile
                    shuffled[blank_row][blank_col] = shuffled[new_row][new_col]
                    shuffled[new_row][new_col] = 0
                    blank_row, blank_col = new_row, new_col
                    break
        
        return shuffled
    
    def _check_solvability(self) -> bool:
        """
        AI-based solvability checker using inversion count algorithm
        Same logic as SwiftUI implementation
        """
        # Flatten puzzle (excluding blank)
        flat_puzzle = [num for row in self.grid for num in row if num != 0]
        
        # Count inversions
        inversions = 0
        for i in range(len(flat_puzzle)):
            for j in range(i + 1, len(flat_puzzle)):
                if flat_puzzle[i] > flat_puzzle[j]:
                    inversions += 1
        
        # For odd-sized puzzles: solvable if inversions are even
        if self.size % 2 == 1:
            return inversions % 2 == 0
        
        # For even-sized puzzles: consider blank position
        blank_row = self._find_blank_position()[0]
        blank_from_bottom = self.size - blank_row
        return (inversions + blank_from_bottom) % 2 == 1
    
    def _make_solvable(self) -> None:
        """Make unsolvable puzzle solvable by swapping two non-blank tiles"""
        non_blank_tiles = []
        for row in range(self.size):
            for col in range(self.size):
                if self.grid[row][col] != 0:
                    non_blank_tiles.append((row, col))
        
        if len(non_blank_tiles) >= 2:
            # Swap first two non-blank tiles
            r1, c1 = non_blank_tiles[0]
            r2, c2 = non_blank_tiles[1]
            self.grid[r1][c1], self.grid[r2][c2] = self.grid[r2][c2], self.grid[r1][c1]
    
    def _find_blank_position(self) -> Tuple[int, int]:
        """Find position of blank tile (0)"""
        for row in range(self.size):
            for col in range(self.size):
                if self.grid[row][col] == 0:
                    return (row, col)
        return (0, 0)
    
    def can_move_tile(self, row: int, col: int) -> bool:
        """Check if tile at (row, col) can be moved"""
        if not (0 <= row < self.size and 0 <= col < self.size):
            return False
        if self.grid[row][col] == 0:
            return False
        
        # Check if blank is adjacent
        blank_row, blank_col = self.blank_pos
        row_diff = abs(row - blank_row)
        col_diff = abs(col - blank_col)
        
        return (row_diff == 1 and col_diff == 0) or (row_diff == 0 and col_diff == 1)
    
    def move_tile(self, row: int, col: int) -> bool:
        """Move tile at (row, col) to blank position"""
        if not self.can_move_tile(row, col):
            return False
        
        # Swap tiles
        self.grid[self.blank_pos[0]][self.blank_pos[1]] = self.grid[row][col]
        self.grid[row][col] = 0
        self.blank_pos = (row, col)
        self.stats.moves += 1
        
        return True
    
    def is_solved(self) -> bool:
        """Check if puzzle is solved"""
        expected = 1
        for row in range(self.size):
            for col in range(self.size):
                if row == self.size - 1 and col == self.size - 1:
                    return self.grid[row][col] == 0
                if self.grid[row][col] != expected:
                    return False
                expected += 1
        return True
    
    def get_elapsed_time(self) -> float:
        """Get elapsed time in seconds"""
        return time.time() - self.stats.start_time

class SlidingPuzzleGUI:
    """
    Modern Tkinter GUI implementation
    Demonstrates cross-platform UI capabilities
    """
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Dynamic Sliding Puzzle Game - Python")
        self.root.geometry("600x700")
        self.root.configure(bg='#f0f0f0')
        
        # Game instance
        self.game = SlidingPuzzleGame()
        self.tile_buttons = []
        
        self.setup_ui()
        self.update_display()
        self.start_timer()
    
    def setup_ui(self):
        """Setup the user interface"""
        # Header
        header_frame = tk.Frame(self.root, bg='#f0f0f0')
        header_frame.pack(pady=10)
        
        title_label = tk.Label(
            header_frame, 
            text="Dynamic Sliding Puzzle Game", 
            font=('Arial', 20, 'bold'),
            bg='#f0f0f0',
            fg='#333333'
        )
        title_label.pack()
        
        subtitle_label = tk.Label(
            header_frame,
            text="AI-Validated Fairness • Algorithmic Rigor",
            font=('Arial', 10),
            bg='#f0f0f0',
            fg='#666666'
        )
        subtitle_label.pack()
        
        # Stats frame
        stats_frame = tk.Frame(self.root, bg='#f0f0f0')
        stats_frame.pack(pady=10)
        
        self.moves_label = tk.Label(
            stats_frame, 
            text="Moves: 0", 
            font=('Arial', 12, 'bold'),
            bg='#e3f2fd',
            fg='#1976d2',
            padx=10,
            pady=5
        )
        self.moves_label.pack(side=tk.LEFT, padx=5)
        
        self.time_label = tk.Label(
            stats_frame, 
            text="Time: 00:00", 
            font=('Arial', 12, 'bold'),
            bg='#e8f5e8',
            fg='#388e3c',
            padx=10,
            pady=5
        )
        self.time_label.pack(side=tk.LEFT, padx=5)
        
        self.difficulty_label = tk.Label(
            stats_frame, 
            text=f"Difficulty: {self.game.difficulty.name}", 
            font=('Arial', 12, 'bold'),
            bg='#fff3e0',
            fg='#f57c00',
            padx=10,
            pady=5
        )
        self.difficulty_label.pack(side=tk.LEFT, padx=5)
        
        # Game frame
        self.game_frame = tk.Frame(self.root, bg='#f0f0f0')
        self.game_frame.pack(pady=20)
        
        # Control buttons
        control_frame = tk.Frame(self.root, bg='#f0f0f0')
        control_frame.pack(pady=10)
        
        restart_btn = tk.Button(
            control_frame,
            text="Restart",
            command=self.restart_game,
            font=('Arial', 12, 'bold'),
            bg='#2196f3',
            fg='white',
            padx=20,
            pady=10
        )
        restart_btn.pack(side=tk.LEFT, padx=5)
        
        difficulty_btn = tk.Button(
            control_frame,
            text="Change Difficulty",
            command=self.change_difficulty,
            font=('Arial', 12, 'bold'),
            bg='#ff9800',
            fg='white',
            padx=20,
            pady=10
        )
        difficulty_btn.pack(side=tk.LEFT, padx=5)
        
        info_btn = tk.Button(
            control_frame,
            text="About",
            command=self.show_info,
            font=('Arial', 12, 'bold'),
            bg='#9c27b0',
            fg='white',
            padx=20,
            pady=10
        )
        info_btn.pack(side=tk.LEFT, padx=5)
    
    def create_tile_buttons(self):
        """Create tile buttons for the puzzle"""
        # Clear existing buttons
        for widget in self.game_frame.winfo_children():
            widget.destroy()
        self.tile_buttons = []
        
        # Calculate tile size
        tile_size = min(400 // self.game.size, 60)
        
        for row in range(self.game.size):
            button_row = []
            for col in range(self.game.size):
                btn = tk.Button(
                    self.game_frame,
                    text=str(self.game.grid[row][col]) if self.game.grid[row][col] != 0 else "",
                    font=('Arial', 16, 'bold'),
                    width=4,
                    height=2,
                    command=lambda r=row, c=col: self.on_tile_click(r, c),
                    bg='#bbdefb' if self.game.can_move_tile(row, col) else '#e0e0e0',
                    fg='white',
                    relief='raised',
                    bd=2
                )
                btn.grid(row=row, column=col, padx=2, pady=2)
                button_row.append(btn)
            self.tile_buttons.append(button_row)
    
    def on_tile_click(self, row: int, col: int):
        """Handle tile click"""
        if self.game.move_tile(row, col):
            self.update_display()
            if self.game.is_solved():
                self.show_win_message()
    
    def update_display(self):
        """Update the display"""
        self.create_tile_buttons()
        self.moves_label.config(text=f"Moves: {self.game.stats.moves}")
        
        # Update time
        elapsed = self.game.get_elapsed_time()
        minutes = int(elapsed // 60)
        seconds = int(elapsed % 60)
        self.time_label.config(text=f"Time: {minutes:02d}:{seconds:02d}")
    
    def start_timer(self):
        """Start the timer"""
        self.update_display()
        self.root.after(1000, self.start_timer)
    
    def restart_game(self):
        """Restart the game"""
        self.game.generate_solvable_puzzle()
        self.update_display()
    
    def change_difficulty(self):
        """Change game difficulty"""
        # Simple difficulty selection
        difficulties = list(Difficulty)
        current_index = difficulties.index(self.game.difficulty)
        next_index = (current_index + 1) % len(difficulties)
        
        self.game.difficulty = difficulties[next_index]
        self.game.size = self.game.difficulty.value
        self.game.generate_solvable_puzzle()
        self.difficulty_label.config(text=f"Difficulty: {self.game.difficulty.name}")
        self.update_display()
    
    def show_win_message(self):
        """Show win message"""
        elapsed = self.game.get_elapsed_time()
        minutes = int(elapsed // 60)
        seconds = int(elapsed % 60)
        
        message = f"🎉 Congratulations! 🎉\n\n"
        message += f"You solved the {self.game.difficulty.name} puzzle!\n"
        message += f"Moves: {self.game.stats.moves}\n"
        message += f"Time: {minutes:02d}:{seconds:02d}\n\n"
        message += f"Puzzle was guaranteed solvable by AI algorithms!"
        
        messagebox.showinfo("Puzzle Solved!", message)
    
    def show_info(self):
        """Show game information"""
        info = "Dynamic Sliding Puzzle Game - Python Implementation\n\n"
        info += "Key Features:\n"
        info += "• AI-based solvability checker using inversion counts\n"
        info += "• 100% solvable puzzles guaranteed\n"
        info += "• Progressive difficulty (3x3 to 6x6)\n"
        info += "• Real-time move validation\n"
        info += "• Cross-platform compatibility\n\n"
        info += "This demonstrates the same core algorithms\n"
        info += "as the SwiftUI implementation, proving\n"
        info += "framework adaptability across languages."
        
        messagebox.showinfo("About", info)
    
    def run(self):
        """Run the game"""
        self.root.mainloop()

def main():
    """Main function"""
    print("Starting Dynamic Sliding Puzzle Game - Python Implementation")
    print("Demonstrating cross-platform compatibility and algorithmic rigor")
    print("=" * 60)
    
    # Create and run the game
    game_gui = SlidingPuzzleGUI()
    game_gui.run()

if __name__ == "__main__":
    main()
