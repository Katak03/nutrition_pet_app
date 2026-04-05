import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct PetWidgetEntry: TimelineEntry {
    let date: Date
    let petSnapshot: PetSnapshot?
    let decayedStats: (hunger: Int, happiness: Int, health: Int)?
    let currentAssetId: String?
    let error: String?
    
    init(
        date: Date,
        petSnapshot: PetSnapshot?,
        decayedStats: (hunger: Int, happiness: Int, health: Int)? = nil,
        currentAssetId: String? = nil,
        error: String? = nil
    ) {
        self.date = date
        self.petSnapshot = petSnapshot
        self.decayedStats = decayedStats
        self.currentAssetId = currentAssetId
        self.error = error
    }
}

// MARK: - Timeline Provider
struct PetWidgetProvider: TimelineProvider {
    
    // 🛠 FIX 1: Ensure this matches your actual App Group in Xcode Capabilities
    private static let appGroupIdentifier = "group.com.example.nutritionGame"
    private static let petSnapshotKey = "petSnapshot"
    
    func placeholder(in context: Context) -> PetWidgetEntry {
        PetWidgetEntry(date: Date(), petSnapshot: nil, error: "Loading...")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PetWidgetEntry) -> ()) {
        completion(loadPetEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PetWidgetEntry>) -> ()) {
        let currentEntry = loadPetEntry()
        let nextRefreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextRefreshDate))
        completion(timeline)
    }
    
    private func loadPetEntry() -> PetWidgetEntry {
        guard let sharedDefaults = UserDefaults(suiteName: Self.appGroupIdentifier) else {
            return PetWidgetEntry(date: Date(), petSnapshot: nil, error: "App Group Access Denied")
        }
        
        guard let snapshotData = sharedDefaults.data(forKey: Self.petSnapshotKey) else {
            return PetWidgetEntry(date: Date(), petSnapshot: nil, error: "No Pet Data Found")
        }
        
        let decoder = JSONDecoder()
        guard let petSnapshot = try? decoder.decode(PetSnapshot.self, from: snapshotData) else {
            return PetWidgetEntry(date: Date(), petSnapshot: nil, error: "Data Format Error")
        }
        
        let hoursPassed = PetDecayCalculator.hoursSince(timestamp: petSnapshot.lastUpdate)
        let decayedStats = PetDecayCalculator.calculateDecay(
            hunger: petSnapshot.stats.hunger,
            happiness: petSnapshot.stats.happiness,
            health: petSnapshot.stats.health,
            hoursPassed: hoursPassed
        )
        
        let currentAssetId = AssetResolver.resolveAsset(
            hunger: decayedStats.hunger,
            happiness: decayedStats.happiness,
            health: decayedStats.health
        )
        
        return PetWidgetEntry(
            date: Date(),
            petSnapshot: petSnapshot,
            decayedStats: decayedStats,
            currentAssetId: currentAssetId,
            error: nil
        )
    }
}

// MARK: - Main View Logic
struct NutritionPetWidgetEntryView: View {
    var entry: PetWidgetProvider.Entry
    
    var body: some View {
        if let error = entry.error {
            ErrorStateView(message: error)
        } else if let petSnapshot = entry.petSnapshot,
                  let decayedStats = entry.decayedStats,
                  let assetId = entry.currentAssetId {
            PetWidgetContentView(
                petSnapshot: petSnapshot,
                decayedStats: decayedStats,
                assetId: assetId
            )
        } else {
            PlaceholderView()
        }
    }
}

// MARK: - UI Components
struct PetWidgetContentView: View {
    let petSnapshot: PetSnapshot
    let decayedStats: (hunger: Int, happiness: Int, health: Int)
    let assetId: String
    
    var body: some View {
        VStack(spacing: 8) {
            PetSpriteView(assetId: assetId)
                .frame(maxHeight: .infinity)
            
            Text(petSnapshot.name)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
            
            VStack(spacing: 4) {
                StatBarView(label: "Hunger", value: decayedStats.hunger, color: .orange)
                StatBarView(label: "Happy", value: decayedStats.happiness, color: .pink)
                StatBarView(label: "Health", value: decayedStats.health, color: .green)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct PetSpriteView: View {
    let assetId: String
    var body: some View {
        Image(assetId)
            .resizable()
            .scaledToFit()
            .padding(.bottom, 4)
    }
}

struct StatBarView: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(color.opacity(0.2))
                    RoundedRectangle(cornerRadius: 3).fill(color)
                        .frame(width: geo.size.width * CGFloat(min(max(value, 0), 100)) / 100)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - State Views
struct ErrorStateView: View {
    let message: String
    var body: some View {
        Text(message).font(.caption).padding()
            .containerBackground(for: .widget) { Color.red.opacity(0.1) }
    }
}

struct PlaceholderView: View {
    var body: some View {
        ProgressView()
            .containerBackground(for: .widget) { Color(UIColor.systemBackground) }
    }
}

// MARK: - Widget Entry Point

// 🛠 FIX 2: Added @main here since we removed the Bundle file
struct NutritionPetWidget: Widget {
    let kind: String = "NutritionPetWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetWidgetProvider()) { entry in
            NutritionPetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Nutrition Pet")
        .description("Keep an eye on your pet's vitals.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    NutritionPetWidget()
} timeline: {
    let stats = PetSnapshot.Stats(hunger: 80, happiness: 60, health: 90)
    let snapshot = PetSnapshot(
        petId: "preview", name: "Fluffy", assetId: "pet_happy",
        level: 5, xp: 100, stats: stats,
        lastUpdate: Int(Date().timeIntervalSince1970 * 1000),
        lastFedAt: Int(Date().timeIntervalSince1970 * 1000)
    )
    PetWidgetEntry(
        date: .now,
        petSnapshot: snapshot,
        decayedStats: (80, 60, 90),
        currentAssetId: "pet_happy",
        error: nil
    )
}
