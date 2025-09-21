//
//  SettingsView.swift
//  Dynamic Sliding Puzzle Game
//
//  Created by Pranathi Immanni on 9/19/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameModel: PuzzleGameModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDifficulty: Difficulty
    @State private var showingInfo = false
    
    init(gameModel: PuzzleGameModel) {
        self.gameModel = gameModel
        self._selectedDifficulty = State(initialValue: gameModel.difficulty)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                headerView
                
                // Difficulty Selection
                difficultySection
                
                // Game Information
                infoSection
                
                // AI Solvability Info
                solvabilitySection
                
                Spacer()
                
                // Action Buttons
                actionButtonsView
            }
            .padding()
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoView()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "puzzlepiece.extension.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Dynamic Sliding Puzzle")
                .font(.title)
                .fontWeight(.bold)
            
            Text("AI-Enhanced Game Experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Difficulty Section
    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Difficulty Level")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(Difficulty.allCases) { difficulty in
                DifficultyRow(
                    difficulty: difficulty,
                    isSelected: selectedDifficulty == difficulty,
                    isCurrent: gameModel.difficulty == difficulty
                ) {
                    selectedDifficulty = difficulty
                }
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Game Features")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Learn More") {
                    showingInfo = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            FeatureRow(
                icon: "brain.head.profile",
                title: "AI Solvability Checker",
                description: "Ensures 100% solvable puzzles using inversion count algorithms"
            )
            
            FeatureRow(
                icon: "arrow.2.squarepath",
                title: "Smart Move Validation",
                description: "Real-time tile tracking and move validation"
            )
            
            FeatureRow(
                icon: "chart.bar.fill",
                title: "Progressive Difficulty",
                description: "Scales from 3×3 to 6×6 grids for all skill levels"
            )
            
            FeatureRow(
                icon: "timer",
                title: "Performance Tracking",
                description: "Move counter and timer for competitive play"
            )
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Solvability Section
    private var solvabilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                
                Text("Puzzle Integrity")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text("This puzzle is guaranteed to be solvable using advanced AI algorithms that check inversion counts and parity logic.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Image(systemName: gameModel.isSolvable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(gameModel.isSolvable ? .green : .red)
                
                Text(gameModel.isSolvable ? "Puzzle is solvable" : "Puzzle needs adjustment")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(gameModel.isSolvable ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(gameModel.isSolvable ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            Button(action: applySettings) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Apply Settings")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Actions
    private func applySettings() {
        if selectedDifficulty != gameModel.difficulty {
            gameModel.changeDifficulty(selectedDifficulty)
        }
        dismiss()
    }
}

// MARK: - Supporting Views
struct DifficultyRow: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let isCurrent: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(difficulty.rawValue)×\(difficulty.rawValue) grid")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isCurrent {
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

struct GameInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "puzzlepiece.extension.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Dynamic Sliding Puzzle Game")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("AI-Enhanced Puzzle Experience")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Features
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Key Features")
                            .font(.headline)
                        
                        InfoFeatureRow(
                            icon: "brain.head.profile",
                            title: "AI Solvability Checker",
                            description: "Uses inversion count algorithms and parity logic to ensure every puzzle is 100% solvable, preventing frustrating unwinnable states."
                        )
                        
                        InfoFeatureRow(
                            icon: "arrow.2.squarepath",
                            title: "Smart Game Mechanics",
                            description: "Real-time tile tracking, move validation, and solution detection using advanced matrix manipulation techniques."
                        )
                        
                        InfoFeatureRow(
                            icon: "chart.bar.fill",
                            title: "Progressive Difficulty",
                            description: "Scales from 3×3 to 6×6 grids, providing challenges for all skill levels from beginners to experts."
                        )
                        
                        InfoFeatureRow(
                            icon: "timer",
                            title: "Performance Analytics",
                            description: "Track your progress with move counters and timers, perfect for competitive play and skill development."
                        )
                        
                        InfoFeatureRow(
                            icon: "paintbrush.fill",
                            title: "Modern UI/UX",
                            description: "Beautiful, responsive interface designed with user-centered principles and smooth animations."
                        )
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Technical Details
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Technical Implementation")
                            .font(.headline)
                        
                        Text("Built with SwiftUI and RealityKit, this game demonstrates advanced software engineering principles including:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TechnicalPoint(text: "Matrix manipulation for efficient tile tracking")
                            TechnicalPoint(text: "AI-based solvability validation algorithms")
                            TechnicalPoint(text: "Real-time game state management")
                            TechnicalPoint(text: "Responsive UI with smooth animations")
                            TechnicalPoint(text: "Cross-platform compatibility")
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Future Extensions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Future Extensions")
                            .font(.headline)
                        
                        Text("This framework is designed to extend to various applications:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TechnicalPoint(text: "Educational tools for teaching algorithms")
                            TechnicalPoint(text: "Cognitive training applications")
                            TechnicalPoint(text: "AI solver research integration")
                            TechnicalPoint(text: "Mobile app deployment")
                            TechnicalPoint(text: "Multiplayer and gamification features")
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("About")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

struct InfoFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TechnicalPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SettingsView(gameModel: PuzzleGameModel())
}
