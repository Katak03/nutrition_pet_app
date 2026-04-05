//
//  PetDecayCalculator.swift
//  Runner
//
//  Created by Irwan Shah on 04/04/2026.
//

import Foundation

/// Service for calculating pet stat decay over time
/// Mirrors the Dart logic from the main app to ensure consistent calculations
struct PetDecayCalculator {
    
    /// Calculates the decayed stats based on hours passed since last update
    /// - Parameters:
    ///   - hunger: Current hunger stat (0-100)
    ///   - happiness: Current happiness stat (0-100)
    ///   - health: Current health stat (0-100)
    ///   - hoursPassed: Number of hours elapsed
    /// - Returns: A tuple containing the new (hunger, happiness, health) values after decay
    static func calculateDecay(
        hunger: Int,
        happiness: Int,
        health: Int,
        hoursPassed: Int
    ) -> (hunger: Int, happiness: Int, health: Int) {
        let hourlyDecayRate = 2  // Stats decay by 2 points per hour
        
        // Calculate new hunger and happiness
        let newHunger = max(0, min(100, hunger - (hoursPassed * hourlyDecayRate)))
        let newHappiness = max(0, min(100, happiness - (hoursPassed * hourlyDecayRate)))
        
        // Health decays only if hunger is critically low (< 30)
        let newHealth: Int
        if newHunger < 30 {
            newHealth = max(0, min(100, health - hoursPassed))
        } else {
            newHealth = health
        }
        
        return (hunger: newHunger, happiness: newHappiness, health: newHealth)
    }
    
    /// Calculates the number of hours elapsed since a given timestamp
    /// - Parameter timestamp: Unix timestamp in milliseconds
    /// - Returns: Number of hours elapsed (returns 0 if less than 1 hour has passed)
    static func hoursSince(timestamp: Int) -> Int {
        let now = Int(Date().timeIntervalSince1970 * 1000)  // Current time in milliseconds
        let elapsed = now - timestamp
        
        if elapsed < 0 {
            return 0  // Handle future timestamps gracefully
        }
        
        let hours = elapsed / (60 * 60 * 1000)  // Convert milliseconds to hours
        return max(0, hours)  // Ensure non-negative
    }
}
