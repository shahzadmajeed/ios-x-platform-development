import SwiftUI
import UIKit

public enum GamingHubContent {
    public static let title = "Gaming Hub"
    public static let subtitle = "SwiftUI composed with a UIKit view"
    public static let playerName = "Player One"
}

public struct GamingScreen: View {
    public init() {}

    public var body: some View {
        TabView {
            NavigationStack {
                HomeTabView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                DiscoverTabView()
            }
            .tabItem {
                Label("Discover", systemImage: "sparkle.magnifyingglass")
            }

            NavigationStack {
                ActivityTabView()
            }
            .tabItem {
                Label("Activity", systemImage: "bolt.horizontal.circle")
            }

            NavigationStack {
                ProfileTabView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
        .tint(.indigo)
    }
}

private struct HomeTabView: View {
    private let featuredGame = GameItem.library[0]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(GamingHubContent.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                PlayerBadgeView(name: GamingHubContent.playerName)
                    .frame(height: 58)

                NavigationLink {
                    GameDetailView(game: featuredGame)
                } label: {
                    FeaturedGameCard(game: featuredGame)
                }
                .buttonStyle(.plain)

                HStack(spacing: 12) {
                    StatCard(value: "12", title: "Games played", icon: "gamecontroller.fill")
                    StatCard(value: "8.4k", title: "XP earned", icon: "bolt.fill")
                    StatCard(value: "4", title: "Day streak", icon: "flame.fill")
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeading(title: "Continue playing")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(GameItem.library.dropFirst())) { game in
                                NavigationLink {
                                    GameDetailView(game: game)
                                } label: {
                                    GameCard(game: game)
                                        .frame(width: 210)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                DailyChallengeCard()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .navigationTitle(GamingHubContent.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct DiscoverTabView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var favoriteIDs: Set<String> = []

    private let categories = ["All", "Action", "Puzzle"]
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var filteredGames: [GameItem] {
        GameItem.library.filter { game in
            let matchesCategory = selectedCategory == "All" || game.category == selectedCategory
            let matchesSearch = searchText.isEmpty
                || game.title.localizedCaseInsensitiveContains(searchText)
                || game.category.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.segmented)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredGames) { game in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink {
                                GameDetailView(game: game)
                            } label: {
                                GameCard(game: game)
                            }
                            .buttonStyle(.plain)

                            Button {
                                if favoriteIDs.contains(game.id) {
                                    favoriteIDs.remove(game.id)
                                } else {
                                    favoriteIDs.insert(game.id)
                                }
                            } label: {
                                Image(systemName: favoriteIDs.contains(game.id) ? "heart.fill" : "heart")
                                    .font(.headline)
                                    .foregroundStyle(favoriteIDs.contains(game.id) ? .pink : .white)
                                    .padding(9)
                                    .background(.black.opacity(0.25), in: Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(
                                favoriteIDs.contains(game.id)
                                    ? "Remove \(game.title) from favorites"
                                    : "Add \(game.title) to favorites"
                            )
                            .padding(10)
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Discover")
        .searchable(text: $searchText, prompt: "Search games")
    }
}

private struct ActivityTabView: View {
    @State private var selectedFeed = "All"

    private let feeds = ["All", "Friends"]
    private let events = [
        ActivityEvent(name: "Mia Chen", action: "reached a new high score", game: "Starlight Racers", icon: "trophy.fill", time: "2m ago"),
        ActivityEvent(name: "Jordan Lee", action: "started playing", game: "Puzzle Garden", icon: "leaf.fill", time: "18m ago"),
        ActivityEvent(name: "You", action: "completed a challenge in", game: "Neon Arena", icon: "checkmark.seal.fill", time: "1h ago"),
        ActivityEvent(name: "Sam Rivera", action: "earned an achievement in", game: "Starlight Racers", icon: "rosette", time: "3h ago")
    ]

    private var visibleEvents: [ActivityEvent] {
        selectedFeed == "Friends" ? events.filter { $0.name != "You" } : events
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Picker("Activity feed", selection: $selectedFeed) {
                    ForEach(feeds, id: \.self) { feed in
                        Text(feed).tag(feed)
                    }
                }
                .pickerStyle(.segmented)

                ForEach(visibleEvents) { event in
                    ActivityRow(event: event)
                }
            }
            .padding(20)
        }
        .navigationTitle("Activity")
    }
}

private struct ProfileTabView: View {
    @State private var notificationsEnabled = true
    @State private var hapticsEnabled = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PlayerBadgeView(name: GamingHubContent.playerName)
                    .frame(height: 58)

                HStack(spacing: 12) {
                    StatCard(value: "Level 12", title: "Player level", icon: "star.fill")
                    StatCard(value: "2,450", title: "Total score", icon: "number")
                }

                VStack(alignment: .leading, spacing: 4) {
                    SectionHeading(title: "Preferences")
                    Toggle("Game notifications", isOn: $notificationsEnabled)
                        .padding(.vertical, 6)
                    Toggle("Haptic feedback", isOn: $hapticsEnabled)
                        .padding(.vertical, 6)
                }

                NavigationLink {
                    AchievementsView()
                } label: {
                    Label("Achievements", systemImage: "rosette")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .navigationTitle("Profile")
    }
}

private struct GameDetailView: View {
    let game: GameItem
    @State private var isPlaying = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GameCard(game: game)
                    .frame(height: 210)

                HStack {
                    Label(game.category, systemImage: "square.grid.2x2")
                    Spacer()
                    Label(game.players, systemImage: "person.2.fill")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(game.description)
                    .font(.body)

                Button {
                    isPlaying.toggle()
                } label: {
                    Label(
                        isPlaying ? "Game launched" : "Play now",
                        systemImage: isPlaying ? "checkmark.circle.fill" : "play.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AchievementsView: View {
    private let achievements = [
        ("First Steps", "Play your first game", "figure.walk"),
        ("On a Roll", "Play three days in a row", "flame.fill"),
        ("Collector", "Try five different games", "square.grid.2x2.fill")
    ]

    var body: some View {
        List(achievements, id: \.0) { achievement in
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.0).font(.headline)
                    Text(achievement.1).font(.subheadline).foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: achievement.2)
                    .foregroundStyle(.indigo)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Achievements")
    }
}

private struct FeaturedGameCard: View {
    let game: GameItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("FEATURED THIS WEEK", systemImage: "sparkles")
                    .font(.caption.bold())
                Spacer()
                Image(systemName: game.icon)
                    .font(.largeTitle)
            }

            Spacer(minLength: 4)

            Text(game.title)
                .font(.title2.bold())
            Text("Jump back in and beat your best score.")
                .font(.subheadline)

            Label("View game", systemImage: "arrow.right")
                .font(.subheadline.bold())
                .padding(.top, 2)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 205, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.indigo, .purple, .pink.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24)
        )
    }
}

private struct GameCard: View {
    let game: GameItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: game.icon)
                    .font(.title2)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                Spacer(minLength: 4)
                Text(game.category.uppercased())
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.18), in: Capsule())
            }

            Spacer(minLength: 2)

            Text(game.title)
                .font(.headline)
                .lineLimit(1)
            Text("\(game.players) players  ·  ★ \(game.rating)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 154)
        .background(
            LinearGradient(
                colors: game.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

private struct StatCard: View {
    let value: String
    let title: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.indigo)
            Text(value)
                .font(.headline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.indigo.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct DailyChallengeCard: View {
    @State private var isClaimed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeading(title: "Daily challenge")
                Spacer()
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.orange)
            }

            Text("Play 5 rounds today")
                .font(.subheadline.weight(.medium))

            ProgressView(value: 2, total: 5)
                .tint(.indigo)

            HStack {
                Text("2 of 5 rounds")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(isClaimed ? "Claimed" : "Claim reward") {
                    isClaimed = true
                }
                .font(.caption.bold())
                .buttonStyle(.borderedProminent)
                .disabled(isClaimed)
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.indigo.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct SectionHeading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.bold())
    }
}

private struct ActivityEvent: Identifiable {
    let id = UUID()
    let name: String
    let action: String
    let game: String
    let icon: String
    let time: String
}

private struct ActivityRow: View {
    let event: ActivityEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: event.icon)
                .font(.headline)
                .foregroundStyle(.indigo)
                .frame(width: 42, height: 42)
                .background(.indigo.opacity(0.1), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                Text("\(event.action) \(event.game)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(event.time)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.indigo.opacity(0.1), lineWidth: 1)
        }
    }
}

private struct GameItem: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let icon: String
    let players: String
    let rating: String
    let description: String

    var gradient: [Color] {
        switch category {
        case "Puzzle":
            [.teal, .blue]
        case "Adventure":
            [.orange, .pink]
        default:
            [.indigo, .purple]
        }
    }

    static let library = [
        GameItem(
            id: "starlight",
            title: "Starlight Racers",
            category: "Action",
            icon: "moon.stars.fill",
            players: "2.1k",
            rating: "4.9",
            description: "Race through glowing space tracks, collect boosts, and challenge friends to beat your best lap."
        ),
        GameItem(
            id: "neon",
            title: "Neon Arena",
            category: "Action",
            icon: "bolt.fill",
            players: "840",
            rating: "4.7",
            description: "Dodge, dash, and outlast your rivals in a fast-paced neon battle arena."
        ),
        GameItem(
            id: "puzzle",
            title: "Puzzle Garden",
            category: "Puzzle",
            icon: "leaf.fill",
            players: "1.3k",
            rating: "4.8",
            description: "Grow a peaceful garden by solving colorful, satisfying tile puzzles."
        ),
        GameItem(
            id: "skybound",
            title: "Skybound Quest",
            category: "Adventure",
            icon: "mountain.2.fill",
            players: "620",
            rating: "4.6",
            description: "Explore floating islands, discover hidden paths, and help a tiny crew find its way home."
        )
    ]
}

private struct PlayerBadgeView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .headline)
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        label.accessibilityIdentifier = "player-badge"
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = "🎮  \(name)"
        uiView.accessibilityLabel = name
    }
}

#Preview("Gaming Hub") {
    GamingScreen()
}
