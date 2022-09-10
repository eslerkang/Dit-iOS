//
//  Contribution.swift
//  Contribution
//
//  Created by 강태준 on 2022/09/09.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let date = Date()
        let entry = SimpleEntry(date: date)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date()))

    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct ContributionEntryView : View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry
    
    var rows: [GridItem] = Array(
        repeating:
            GridItem(.adaptive(
                minimum: 10,
                maximum: 500)
            ),
        count: 7
    )

    var body: some View {
        switch family {
        case .systemSmall:
            GeometryReader { g in
                HStack(alignment: .center, spacing: 0) {
                    LazyHGrid(rows: rows) {
                        ForEach((0..<7*7)) { _ in
                            Color.green
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(3)
                        }
                    }
                    .frame(
                        width: g.size.width - 20,
                        height: g.size.height - 20,
                        alignment: .center
                    )
                }
                .frame(
                    width: g.size.width,
                    height: g.size.height,
                    alignment: .center
                )
            }
        case .systemMedium:
            GeometryReader { g in
                HStack(alignment: .center, spacing: 0) {
                    LazyHGrid(rows: rows) {
                        ForEach((0..<7*15)) { _ in
                            Color.green
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(3)
                        }
                    }
                    .frame(
                        width: g.size.width - 20,
                        height: g.size.height - 20,
                        alignment: .center
                    )
                }
                .frame(
                    width: g.size.width,
                    height: g.size.height,
                    alignment: .center
                )
            }
        default:
            Text("지원하지 않는 위젯입니다.")
        }

    }
}

@main
struct Contribution: Widget {
    let kind: String = "widget.com.eslerkang.Dit"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider())
        { entry in
            ContributionEntryView(entry: entry)
        }
        .configurationDisplayName("Dit Contributions")
        .description("내 잔디를 볼 수 있는 위젯입니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Contribution_Previews: PreviewProvider {
    static var previews: some View {
        ContributionEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ContributionEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
