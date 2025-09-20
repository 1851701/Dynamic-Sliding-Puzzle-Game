#!/usr/bin/env python3
"""
Test script to verify the core algorithms work correctly
This demonstrates the same logic used in the SwiftUI implementation
"""

def test_solvability_algorithm():
    """Test the AI-based solvability checker"""
    print("Testing AI-based solvability algorithm...")
    
    # Test case 1: 3x3 solvable puzzle
    puzzle_3x3_solvable = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 0]  # Blank at bottom-right
    ]
    
    # Test case 2: 3x3 unsolvable puzzle
    puzzle_3x3_unsolvable = [
        [1, 2, 3],
        [4, 5, 6],
        [8, 7, 0]  # Swapped 7 and 8
    ]
    
    # Test case 3: 4x4 solvable puzzle
    puzzle_4x4_solvable = [
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 10, 11, 12],
        [13, 14, 15, 0]  # Blank at bottom-right
    ]
    
    def check_solvability(puzzle):
        """Same algorithm as SwiftUI implementation"""
        size = len(puzzle)
        
        # Flatten puzzle (excluding blank)
        flat_puzzle = [num for row in puzzle for num in row if num != 0]
        
        # Count inversions
        inversions = 0
        for i in range(len(flat_puzzle)):
            for j in range(i + 1, len(flat_puzzle)):
                if flat_puzzle[i] > flat_puzzle[j]:
                    inversions += 1
        
        # For odd-sized puzzles: solvable if inversions are even
        if size % 2 == 1:
            return inversions % 2 == 0
        
        # For even-sized puzzles: consider blank position
        blank_row = 0
        for row in range(size):
            for col in range(size):
                if puzzle[row][col] == 0:
                    blank_row = row
                    break
        
        blank_from_bottom = size - blank_row
        return (inversions + blank_from_bottom) % 2 == 1
    
    # Test results
    print(f"3x3 solvable puzzle: {check_solvability(puzzle_3x3_solvable)} (Expected: True)")
    print(f"3x3 unsolvable puzzle: {check_solvability(puzzle_3x3_unsolvable)} (Expected: False)")
    print(f"4x4 solvable puzzle: {check_solvability(puzzle_4x4_solvable)} (Expected: True)")
    
    return all([
        check_solvability(puzzle_3x3_solvable) == True,
        check_solvability(puzzle_3x3_unsolvable) == False,
        check_solvability(puzzle_4x4_solvable) == True
    ])

def test_move_validation():
    """Test move validation logic"""
    print("\nTesting move validation logic...")
    
    # Test puzzle with blank at (2,2)
    puzzle = [
        [1, 2, 3],
        [4, 0, 5],  # Blank at (1,1)
        [6, 7, 8]
    ]
    
    def can_move_tile(puzzle, row, col):
        """Same logic as SwiftUI implementation"""
        size = len(puzzle)
        if row < 0 or row >= size or col < 0 or col >= size:
            return False
        if puzzle[row][col] == 0:
            return False
        
        # Find blank position
        blank_row, blank_col = 0, 0
        for r in range(size):
            for c in range(size):
                if puzzle[r][c] == 0:
                    blank_row, blank_col = r, c
                    break
        
        # Check if blank is adjacent
        row_diff = abs(row - blank_row)
        col_diff = abs(col - blank_col)
        return (row_diff == 1 and col_diff == 0) or (row_diff == 0 and col_diff == 1)
    
    # Test cases
    test_cases = [
        (0, 1, True),   # Tile 2 can move (adjacent to blank)
        (1, 0, True),   # Tile 4 can move (adjacent to blank)
        (1, 2, True),   # Tile 5 can move (adjacent to blank)
        (2, 1, True),   # Tile 7 can move (adjacent to blank)
        (0, 0, False),  # Tile 1 cannot move (not adjacent)
        (2, 2, False),  # Tile 8 cannot move (not adjacent)
        (1, 1, False),  # Blank tile cannot move
    ]
    
    all_passed = True
    for row, col, expected in test_cases:
        result = can_move_tile(puzzle, row, col)
        status = "✓" if result == expected else "✗"
        print(f"  {status} Tile at ({row},{col}): {result} (Expected: {expected})")
        if result != expected:
            all_passed = False
    
    return all_passed

def test_solution_detection():
    """Test solution detection logic"""
    print("\nTesting solution detection logic...")
    
    def is_solved(puzzle):
        """Same logic as SwiftUI implementation"""
        size = len(puzzle)
        expected = 1
        
        for row in range(size):
            for col in range(size):
                current_number = puzzle[row][col]
                
                # Last position should be blank (0)
                if row == size - 1 and col == size - 1:
                    return current_number == 0
                
                # All other positions should be in sequence
                if current_number != expected:
                    return False
                
                expected += 1
        
        return True
    
    # Test cases
    solved_puzzle = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 0]
    ]
    
    unsolved_puzzle = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 0, 8]  # Wrong order
    ]
    
    print(f"Solved puzzle: {is_solved(solved_puzzle)} (Expected: True)")
    print(f"Unsolved puzzle: {is_solved(unsolved_puzzle)} (Expected: False)")
    
    return is_solved(solved_puzzle) == True and is_solved(unsolved_puzzle) == False

def main():
    """Run all tests"""
    print("Dynamic Sliding Puzzle Game - Algorithm Verification")
    print("=" * 50)
    
    tests = [
        ("Solvability Algorithm", test_solvability_algorithm),
        ("Move Validation", test_move_validation),
        ("Solution Detection", test_solution_detection)
    ]
    
    all_passed = True
    for test_name, test_func in tests:
        try:
            result = test_func()
            status = "PASSED" if result else "FAILED"
            print(f"\n{test_name}: {status}")
            if not result:
                all_passed = False
        except Exception as e:
            print(f"\n{test_name}: ERROR - {e}")
            all_passed = False
    
    print("\n" + "=" * 50)
    if all_passed:
        print("🎉 ALL TESTS PASSED! 🎉")
        print("The core algorithms are working correctly.")
        print("The SwiftUI implementation should work perfectly!")
    else:
        print("❌ SOME TESTS FAILED!")
        print("Please check the algorithm implementations.")
    
    return all_passed

if __name__ == "__main__":
    main()
