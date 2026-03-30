# iOS Home Widget Setup Instructions

## Bundle Information
- **Main App Bundle ID**: `com.example.nutritionGame`
- **App Group ID**: `group.com.example.nutritionGame`
- **Widget Extension Bundle ID**: `com.example.nutritionGame.NutritionPetWidget`

---

## Step 1: Configure App Groups for Main App

1. Open `ios/Runner.xcworkspace` in Xcode (NOT the .xcodeproj file)
2. Select the **Runner** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability** and search for **App Groups**
5. Add capability: App Groups
6. In the App Groups section, enter: **group.com.example.nutritionGame**

---

## Step 2: Create Widget Extension Target

1. In Xcode, go to **File → New → Target**
2. Choose **Widget Extension** (NOT App Clip or Watch Kit App)
3. Configure:
   - Product Name: `NutritionPetWidget`
   - Team ID: (your team)
   - Bundle Identifier: `com.example.nutritionGame.NutritionPetWidget`
   - **Deselect** "Include Configuration Intent"
4. Click **Finish**
5. When prompted to activate the scheme, click **Activate**

---

## Step 3: Configure App Groups for Widget Extension

1. In Xcode, select the **NutritionPetWidget** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and search for **App Groups**
4. Add capability: App Groups
5. Enter the same App Group ID: **group.com.example.nutritionGame**

---

## Step 4: Update Widget Extension Files

The widget extension comes with boilerplate code. Replace the contents:

### File: `ios/NutritionPetWidget/NutritionPetWidget.swift`

```swift
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), hunger: 75, happiness: 75, health: 75, mood: "neutral", petAsset: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), hunger: 75, happiness: 75, health: 75, mood: "neutral", petAsset: "placeholder")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Refresh every 15 minutes to check for updates from Firestore
        let nextRefresh = Date().addingTimeInterval(15 * 60)
        let timeline = Timeline(entries: [SimpleEntry(date: Date(), hunger: 75, happiness: 75, health: 75, mood: "neutral", petAsset: "placeholder")], policy: .after(nextRefresh))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let hunger: Int
    let happiness: Int
    let health: Int
    let mood: String
    let petAsset: String
}

struct NutritionPetWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Soft background color (light blue-gray)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.93, green: 0.96, blue: 0.98),
                    Color(red: 0.88, green: 0.94, blue: 0.98)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Pet image placeholder
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                    .frame(height: 100)
                
                // Stats for larger widgets
                HStack(spacing: 16) {
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "fork.knife")
                            .font(.caption)
                        Text("\(entry.hunger)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                        Text("\(entry.happiness)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                        Text("\(entry.health)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    NutritionPetWidgetEntryView(entry: SimpleEntry(date: Date(), hunger: 75, happiness: 75, health: 75, mood: "neutral", petAsset: "placeholder"))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
}

@main
struct NutritionPetWidget: Widget {
    let kind: String = "NutritionPetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NutritionPetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Nutrition Pet")
        .description("See your pet's current status and projections.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

### File: `ios/NutritionPetWidget/NutritionPetWidgetBundle.swift`

```swift
import WidgetKit
import SwiftUI

@main
struct NutritionPetWidgetBundle: WidgetBundle {
    var body: some Widget {
        NutritionPetWidget()
    }
}
```

---

## Step 5: Verify Configuration

1. In Xcode, select the **NutritionPetWidget** scheme from the top dropdown
2. Select a Simulator or Device
3. Build and run: **Cmd + R**
4. The widget should appear in the widget gallery on the lock screen or home screen

---

## Step 6: Test on Device

1. Switch to the **Runner** scheme
2. Build and run the main app
3. Background the app (press home or gesture up)
4. Go to home screen and add widget:
   - Long-press empty space
   - Tap **+** button
   - Search for "Nutrition Pet" widget
   - Add it to your home screen

---

## Troubleshooting

- **Widget doesn't appear**: Check that both targets have the same App Group ID
- **Data not updating**: Verify `HomeWidget.updateWidget(iOSName: 'NutritionPetWidget')` is being called in Dart
- **Build errors**: Ensure Podfile has iOS 15.0 minimum deployment target (already set)

---

## Next Steps

Once the widget is working:
1. Replace the placeholder pawprint with your actual pet image asset
2. Implement data reading from the shared app group user defaults
3. Add dynamic timeline updates based on the snapshot data from Dart
4. Test stat decay and mood transitions in widget preview
