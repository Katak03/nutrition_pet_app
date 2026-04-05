//
//  PetSnapshot.swift
//  Runner
//
//  Created by Irwan Shah on 04/04/2026.
//

import Foundation

/// Represents a snapshot of the pet's state, decoded from the Flutter app's JSON structure
/// This struct is used to share data between the main app and the widget via App Groups
struct PetSnapshot: Codable {
    let petId: String
    let name: String
    let assetId: String
    let level: Int
    let xp: Int
    let stats: Stats
    let lastUpdate: Int  // Unix timestamp in milliseconds
    let lastFedAt: Int   // Unix timestamp in milliseconds

    init(petId: String, name: String, assetId: String, level: Int, xp: Int, stats: Stats, lastUpdate: Int, lastFedAt: Int) {
        self.petId = petId
        self.name = name
        self.assetId = assetId
        self.level = level
        self.xp = xp
        self.stats = stats
        self.lastUpdate = lastUpdate
        self.lastFedAt = lastFedAt
    }
    
    /// Nested stats structure for hunger, happiness, and health
    struct Stats: Codable {
        let hunger: Int      // 0-100
        let happiness: Int   // 0-100
        let health: Int      // 0-100
    }
    
    // MARK: - Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case petId
        case name
        case assetId
        case level
        case xp
        case stats
        case lastUpdate
        case lastFedAt
    }
    
    /// Custom decoder to handle the JSON structure from Flutter
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.petId = try container.decode(String.self, forKey: .petId)
        self.name = try container.decode(String.self, forKey: .name)
        self.assetId = try container.decode(String.self, forKey: .assetId)
        self.level = try container.decode(Int.self, forKey: .level)
        self.xp = try container.decode(Int.self, forKey: .xp)
        self.stats = try container.decode(Stats.self, forKey: .stats)
        self.lastUpdate = try container.decode(Int.self, forKey: .lastUpdate)
        self.lastFedAt = try container.decode(Int.self, forKey: .lastFedAt)
    }
    
    /// Custom encoder to maintain the JSON structure for Flutter compatibility
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(petId, forKey: .petId)
        try container.encode(name, forKey: .name)
        try container.encode(assetId, forKey: .assetId)
        try container.encode(level, forKey: .level)
        try container.encode(xp, forKey: .xp)
        try container.encode(stats, forKey: .stats)
        try container.encode(lastUpdate, forKey: .lastUpdate)
        try container.encode(lastFedAt, forKey: .lastFedAt)
    }
}
