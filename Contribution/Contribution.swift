//
//  Contribution.swift
//  Contribution
//
//  Created by 강태준 on 2022/09/09.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), contributions: [])
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        getTodoData { contributions in
            let date = Date()
            let timeline = Timeline(
                entries: [SimpleEntry(date: date, contributions: contributions)],
                policy: .atEnd
            )
            completion(timeline)
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        getTodoData { contributions in
            completion(SimpleEntry(date: Date(), contributions: contributions))
        }
    }
    
    func getTodoData(completion: @escaping ([ContributionEntity]) -> Void) {
        @Environment(\.widgetFamily) var family

        var count: Int {
            switch family {
            case .systemSmall:
                return 7*7
            case .systemMedium:
                return 7*15
            default:
                return 0
            }
        }
        
        let container = PersistenceController.shared.container
        let context = container.viewContext
        
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        
        var contributions = [ContributionEntity]()
        
        for i in 0..<count {
            guard let startDate = calendar.date(byAdding: .day, value: -count+1+i, to: today),
                  let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
            else {
                return
            }
            let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Todos")
            
            let isDonePredicate = NSPredicate(format: "isDone == YES")
            let startDatePredicate = NSPredicate(format: "updatedAt >= %@", startDate as CVarArg)
            let endDatePredicate = NSPredicate(format: "updatedAt < %@", endDate as CVarArg)
            
            readRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isDonePredicate, startDatePredicate, endDatePredicate])
            
            do {
                let data = try context.fetch(readRequest)
                contributions.append(ContributionEntity(date: startDate, commit: data.count))
            } catch {
                print("ERROR: \(error.localizedDescription)")
                return
            }
        }
        
        completion(contributions)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let contributions: [ContributionEntity]
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
                        ForEach((0..<entry.contributions.count), id: \.self) { index in
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
                        ForEach((0..<entry.contributions.count), id: \.self) { index in
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
        ContributionEntryView(entry: SimpleEntry(date: Date(), contributions: []))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ContributionEntryView(entry: SimpleEntry(date: Date(), contributions: []))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}