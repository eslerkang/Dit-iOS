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
    var managedObjectContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), contributions: [])
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        getTodoData { contributions in
            let date = Date()
            let timeline = Timeline(
                entries: [SimpleEntry(date: date, contributions: contributions)],
                policy: .after(Calendar.current.date(byAdding: .minute, value: 1, to: date)!)
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

        let count = 7*15
        
        let context = managedObjectContext

        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        
        var contributions = [ContributionEntity]()
        
        for i in 1...count {
            guard let startDate = calendar.date(byAdding: .day, value: -count+i, to: today),
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
                        if let data = entry.contributions {
                            ForEach(((data.count-7*7)..<data.count), id: \.self) { index in
                                switch data[index].commit {
                                case 0:
                                    Color.gray
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 1:
                                    Color(CustomColor.green1)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 2:
                                    Color(CustomColor.green2)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 3:
                                    Color(CustomColor.green3)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 4:
                                    Color(CustomColor.green4)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                default:
                                    Color(CustomColor.green5)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                }
                            }
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
                        if let data = entry.contributions {
                            ForEach(((data.count-7*15)..<data.count), id: \.self) { index in
                                switch data[index].commit {
                                case 0:
                                    Color.gray
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 1:
                                    Color(CustomColor.green1)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 2:
                                    Color(CustomColor.green2)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 3:
                                    Color(CustomColor.green3)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                case 4:
                                    Color(CustomColor.green4)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                default:
                                    Color(CustomColor.green5)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(3)
                                }
                            }
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

    var container = PersistenceController.shared.container
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider(context: container.viewContext))
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
        ContributionEntryView(
            entry: SimpleEntry(date: Date(), contributions: []))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ContributionEntryView(entry: SimpleEntry(date: Date(), contributions: []))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
