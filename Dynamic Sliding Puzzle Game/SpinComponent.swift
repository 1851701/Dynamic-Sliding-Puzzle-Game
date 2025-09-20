//
//  SpinComponent.swift
//  Dynamic Sliding Puzzle Game
//
//  Created by Pranathi Immanni on 9/19/25.
//

import RealityKit

/// A component that spins the entity around a given axis.
struct SpinComponent: Component {
    let spinAxis: SIMD3<Float> = [0, 1, 0]
}
