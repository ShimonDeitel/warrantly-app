import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 31

    @Published var items: [Warranty] = []
    @Published var enabledCategories: Set<String> = ["All"]

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("warrantly", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Warranty].self, from: data) else {
            items = Self.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }

    func canAddMore(isPro: Bool) -> Bool {
        isPro || items.count < Self.freeLimit
    }

    @discardableResult
    func add(_ item: Warranty, isPro: Bool) -> Bool {
        guard canAddMore(isPro: isPro) else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: Warranty) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    static func seedData() -> [Warranty] {
        [
            Warranty(title: "Water Heater", customer: "Jane Cole", expiration: ISO8601DateFormatter().date(from: "2027-03-01T00:00:00Z") ?? Date()),
            Warranty(title: "HVAC Compressor", customer: "Mike Reyes", expiration: ISO8601DateFormatter().date(from: "2026-11-15T00:00:00Z") ?? Date()),
            Warranty(title: "Sump Pump", customer: "Dana Ortiz", expiration: ISO8601DateFormatter().date(from: "2026-09-20T00:00:00Z") ?? Date()),
            Warranty(title: "Furnace Motor", customer: "Lee Park", expiration: ISO8601DateFormatter().date(from: "2028-01-10T00:00:00Z") ?? Date())
        ]
    }
}
