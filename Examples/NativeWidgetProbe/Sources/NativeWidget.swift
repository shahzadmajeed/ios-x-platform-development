import SwiftUI
import WidgetKit

struct NativeWidgetEntry: TimelineEntry {
    let date: Date
}

struct NativeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NativeWidgetEntry {
        NativeWidgetEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (NativeWidgetEntry) -> Void) {
        completion(NativeWidgetEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NativeWidgetEntry>) -> Void) {
        completion(Timeline(entries: [NativeWidgetEntry(date: .now)], policy: .never))
    }
}

struct NativeWidget: Widget {
    let kind = "NativeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NativeWidgetProvider()) { _ in
            Text("Widget target built")
                .padding()
        }
        .configurationDisplayName("Native Widget Probe")
        .description("A minimal WidgetKit extension build probe.")
    }
}

@main
struct NativeWidgetBundle: WidgetBundle {
    var body: some Widget {
        NativeWidget()
    }
}
