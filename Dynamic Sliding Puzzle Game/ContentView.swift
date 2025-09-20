//
//  ContentView.swift
//  Dynamic Sliding Puzzle Game
//
//  Created by Pranathi Immanni on 9/19/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var gameModel = PuzzleGameModel()
    @State private var showingSettings = false
    @State private var showingWinAlert = false

    var body: some View {
        GeometryReader { geometry in
        ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.pink.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Game Stats
                    statsView
                    
                    // Puzzle Grid
                    puzzleGridView(geometry: geometry)
                    
                    // Control Buttons
                    controlButtonsView
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert("🎉 Congratulations! 🎉", isPresented: $showingWinAlert) {
            Button("New Game") {
                gameModel.restart()
            }
            Button("Change Difficulty") {
                showingSettings = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You solved the puzzle in \(gameModel.moveCount) moves and \(gameModel.getFormattedTime())!")
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(gameModel: gameModel)
        }
        .onChange(of: gameModel.gameState) { _, newState in
            if newState == .won {
                showingWinAlert = true
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Dynamic Sliding Puzzle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("AI-Validated Fairness • Algorithmic Rigor")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Stats View
    private var statsView: some View {
        HStack(spacing: 30) {
            StatCard(
                title: "Moves",
                value: "\(gameModel.moveCount)",
                icon: "arrow.2.squarepath",
                color: .blue
            )
            
            StatCard(
                title: "Time",
                value: gameModel.getFormattedTime(),
                icon: "clock",
                color: .green
            )
            
            StatCard(
                title: "Difficulty",
                value: gameModel.difficulty.name,
                icon: "chart.bar.fill",
                color: .orange
            )
        }
    }
    
    // MARK: - Puzzle Grid View
    private func puzzleGridView(geometry: GeometryProxy) -> some View {
        let availableWidth = min(geometry.size.width - 40, 400)
        let tileSize = availableWidth / CGFloat(gameModel.size)
        
        return VStack(spacing: 2) {
            ForEach(0..<gameModel.size, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<gameModel.size, id: \.self) { col in
                        TileView(
                            tile: gameModel.grid[row][col],
                            size: tileSize,
                            isMovable: gameModel.canMoveTile(at: row, col: col)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                gameModel.moveTile(at: row, col: col)
                            }
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Control Buttons View
    private var controlButtonsView: some View {
        HStack(spacing: 20) {
            Button(action: { gameModel.restart() }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Restart")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Button(action: {
                if gameModel.gameState == .playing {
                    gameModel.pause()
                } else {
                    gameModel.resume()
                }
            }) {
                HStack {
                    Image(systemName: gameModel.gameState == .playing ? "pause.fill" : "play.fill")
                    Text(gameModel.gameState == .playing ? "Pause" : "Resume")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(gameModel.gameState == .playing ? Color.orange : Color.green)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TileView: View {
    let tile: Tile
    let size: CGFloat
    let isMovable: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if tile.isBlank {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.clear)
                        .frame(width: size, height: size)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isMovable ? Color.blue.opacity(0.8) : Color.blue.opacity(0.6),
                                    isMovable ? Color.purple.opacity(0.8) : Color.purple.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isMovable ? Color.white : Color.clear,
                                    lineWidth: isMovable ? 2 : 0
                                )
                        )
                        .shadow(
                            color: isMovable ? .blue.opacity(0.3) : .black.opacity(0.1),
                            radius: isMovable ? 8 : 4,
                            x: 0,
                            y: isMovable ? 4 : 2
                        )
                    
                    Text("\(tile.number)")
                        .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
            }
        }
        .disabled(!isMovable && !tile.isBlank)
        .scaleEffect(isMovable ? 1.05 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isMovable)
    }
}

#Preview {
    ContentView()
}
