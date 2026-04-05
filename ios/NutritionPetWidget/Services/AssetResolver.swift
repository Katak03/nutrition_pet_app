//
//  AssetResolver.swift
//  Runner
//
//  Created by Irwan Shah on 04/04/2026.
//

import Foundation

/// Service for resolving the appropriate pet asset based on current stats
/// Uses a priority-based system to determine which state the pet should be displayed in
struct AssetResolver {
    
    /// Resolves the asset ID based on the pet's current stat values
    /// Priority order:
    /// 1. If health < 30 → "pet_sick"
    /// 2. Else if happiness < 30 → "pet_sad"
    /// 3. Else if hunger < 30 → "pet_hungry"
    /// 4. Else → "pet_happy"
    /// - Parameters:
    ///   - hunger: Current hunger stat (0-100)
    ///   - happiness: Current happiness stat (0-100)
    ///   - health: Current health stat (0-100)
    /// - Returns: Asset ID string for the appropriate pet sprite
    static func resolveAsset(hunger: Int, happiness: Int, health: Int) -> String {
        // Critical health check - highest priority
        if health < 30 {
            return "pet_sick"
        }
        
        // Low happiness check
        if happiness < 30 {
            return "pet_sad"
        }
        
        // Low hunger check
        if hunger < 30 {
            return "pet_hungry"
        }
        
        // Default happy state
        return "pet_happy"
    }
}
