//
//  PuzzleGameModel.swift
//  Dynamic Sliding Puzzle Game
//
//  Created by Pranathi Immanni on 9/19/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State Management
enum GameState {
    case playing
    case won
    case paused
}

enum Difficulty: CaseIterable, Identifiable {
    case easy, medium, hard, expert
    
    var id: Int { rawValue }
    var rawValue: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        case .expert: return 6
        }
    }
    
    var name: String {
        switch self {
        case .easy: return "Easy (3×3)"
        case .medium: return "Medium (4×4)"
        case .hard: return "Hard (5×5)"
        case .expert: return "Expert (6×6)"
        }
    }
}

// MARK: - Tile Model
struct Tile: Identifiable, Equatable {
    let id: Int
    let number: Int
    let isBlank: Bool
    
    init(number: Int) {
        self.id = number
        self.number = number
        self.isBlank = (number == 0)
    }
}

// MARK: - Move Direction
enum MoveDirection {
    case up, down, left, right
    
    var offset: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        }
    }
}

// MARK: - Puzzle Game Model
@MainActor
class PuzzleGameModel: ObservableObject {
    @Published var grid: [[Tile]] = []
    @Published var gameState: GameState = .playing
    @Published var moveCount: Int = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var difficulty: Difficulty = .easy
    @Published var isSolvable: Bool = true
    
    private var timer: Timer?
    let size: Int
    
    init(difficulty: Difficulty = .easy) {
        self.difficulty = difficulty
        self.size = difficulty.rawValue
        generateSolvablePuzzle()
        startTimer()
    }
    
    // MARK: - Game Initialization
    func generateSolvablePuzzle() {
        var puzzle: [[Int]] = []
        
        // Generate a solved puzzle first
        for row in 0..<size {
            var rowArray: [Int] = []
            for col in 0..<size {
                let number = row * size + col + 1
                rowArray.append(number)
            }
            puzzle.append(rowArray)
        }
        
        // Set the last tile as blank (0)
        puzzle[size - 1][size - 1] = 0
        
        // Shuffle the puzzle while maintaining solvability
        puzzle = shufflePuzzle(puzzle)
        
        // Convert to Tile objects
        grid = puzzle.map { row in
            row.map { Tile(number: $0) }
        }
        
        // Verify solvability
        isSolvable = checkSolvability(puzzle)
        
        // If not solvable, make it solvable by swapping two non-blank tiles
        if !isSolvable {
            makeSolvable(&puzzle)
            grid = puzzle.map { row in
                row.map { Tile(number: $0) }
            }
            isSolvable = true
        }
        
        moveCount = 0
        gameState = .playing
    }
    
    // MARK: - Puzzle Shuffling with Solvability
    private func shufflePuzzle(_ puzzle: [[Int]]) -> [[Int]] {
        var shuffled = puzzle
        let blankRow = size - 1
        let blankCol = size - 1
        
        // Perform random valid moves to shuffle
        for _ in 0..<(size * size * 10) {
            let directions: [MoveDirection] = [.up, .down, .left, .right]
            let randomDirection = directions.randomElement()!
            
            if canMove(blankRow, blankCol, direction: randomDirection, in: shuffled) {
                let newRow = blankRow + randomDirection.offset.row
                let newCol = blankCol + randomDirection.offset.col
                
                // Swap blank with adjacent tile
                shuffled[blankRow][blankCol] = shuffled[newRow][newCol]
                shuffled[newRow][newCol] = 0
            }
        }
        
        return shuffled
    }
    
    // MARK: - Solvability Checker (AI-based)
    private func checkSolvability(_ puzzle: [[Int]]) -> Bool {
        // Flatten the puzzle (excluding blank tile)
        let flatPuzzle = puzzle.flatMap { $0 }.filter { $0 != 0 }
        
        // Count inversions
        var inversions = 0
        for i in 0..<flatPuzzle.count {
            for j in i+1..<flatPuzzle.count {
                if flatPuzzle[i] > flatPuzzle[j] {
                    inversions += 1
                }
            }
        }
        
        // For odd-sized puzzles, solvable if inversions are even
        if size % 2 == 1 {
            return inversions % 2 == 0
        }
        
        // For even-sized puzzles, need to consider blank tile position
        let blankRow = findBlankPosition(puzzle).row
        let blankFromBottom = size - blankRow
        
        return (inversions + blankFromBottom) % 2 == 1
    }
    
    private func findBlankPosition(_ puzzle: [[Int]]) -> (row: Int, col: Int) {
        for row in 0..<size {
            for col in 0..<size {
                if puzzle[row][col] == 0 {
                    return (row, col)
                }
            }
        }
        return (0, 0) // Should never happen
    }
    
    private func makeSolvable(_ puzzle: inout [[Int]]) {
        // Find two non-blank tiles and swap them
        var nonBlankTiles: [(row: Int, col: Int)] = []
        
        for row in 0..<size {
            for col in 0..<size {
                if puzzle[row][col] != 0 {
                    nonBlankTiles.append((row, col))
                }
            }
        }
        
        if nonBlankTiles.count >= 2 {
            let tile1 = nonBlankTiles[0]
            let tile2 = nonBlankTiles[1]
            
            // Swap the tiles
            let temp = puzzle[tile1.row][tile1.col]
            puzzle[tile1.row][tile1.col] = puzzle[tile2.row][tile2.col]
            puzzle[tile2.row][tile2.col] = temp
        }
    }
    
    // MARK: - Move Validation and Execution
    func canMoveTile(at row: Int, col: Int) -> Bool {
        guard row >= 0 && row < size && col >= 0 && col < size else { return false }
        guard !grid[row][col].isBlank else { return false }
        
        // Check if blank tile is adjacent
        let blankPos = findBlankPosition(grid.map { $0.map { $0.number } })
        let rowDiff = abs(row - blankPos.row)
        let colDiff = abs(col - blankPos.col)
        
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    func moveTile(at row: Int, col: Int) {
        guard canMoveTile(at: row, col: col) else { return }
        
        let blankPos = findBlankPosition(grid.map { $0.map { $0.number } })
        
        // Swap the tiles
        let temp = grid[row][col]
        grid[row][col] = grid[blankPos.row][blankPos.col]
        grid[blankPos.row][blankPos.col] = temp
        
        moveCount += 1
        
        // Check if puzzle is solved
        if isSolved() {
            gameState = .won
            stopTimer()
        }
    }
    
    private func canMove(_ row: Int, col: Int, direction: MoveDirection, in puzzle: [[Int]]) -> Bool {
        let newRow = row + direction.offset.row
        let newCol = col + direction.offset.col
        
        return newRow >= 0 && newRow < size && newCol >= 0 && newCol < size
    }
    
    // MARK: - Solution Detection
    private func isSolved() -> Bool {
        var expectedNumber = 1
        
        for row in 0..<size {
            for col in 0..<size {
                let currentNumber = grid[row][col].number
                
                // Last position should be blank (0)
                if row == size - 1 && col == size - 1 {
                    return currentNumber == 0
                }
                
                // All other positions should be in sequence
                if currentNumber != expectedNumber {
                    return false
                }
                
                expectedNumber += 1
            }
        }
        
        return true
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.gameState == .playing {
                self.elapsedTime += 0.1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Game Control
    func restart() {
        stopTimer()
        generateSolvablePuzzle()
        elapsedTime = 0
        startTimer()
    }
    
    func changeDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
        restart()
    }
    
    func pause() {
        gameState = .paused
        stopTimer()
    }
    
    func resume() {
        gameState = .playing
        startTimer()
    }
    
    // MARK: - Utility Functions
    func getFormattedTime() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
    }
    
    func getBlankPosition() -> (row: Int, col: Int) {
        return findBlankPosition(grid.map { $0.map { $0.number } })
    }
    
    deinit {
        stopTimer()
    }
}
