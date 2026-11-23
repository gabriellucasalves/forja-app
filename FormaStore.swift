import Foundation
import Combine

final class FormaStore: ObservableObject {
    @Published private(set) var waterML: Int = 0
    @Published private(set) var completed: Set<String> = []
    @Published private(set) var logs: [String: String] = [:]
    let waterGoal = 3000
    private let defaults = UserDefaults.standard
    private var dayKey: String { Self.dayFormatter.string(from: Date()) }
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    init() { refreshDay() }
    func refreshDay() {
        waterML = defaults.integer(forKey: "water-\(dayKey)")
        completed = Set(defaults.stringArray(forKey: "completed-\(dayKey)") ?? [])
        logs = defaults.dictionary(forKey: "logs-\(dayKey)") as? [String:String] ?? [:]
    }
    func addWater(_ amount: Int) {
        refreshDay(); waterML = max(0, waterML + amount)
        defaults.set(waterML, forKey: "water-\(dayKey)")
    }
    func toggle(_ key: String) {
        refreshDay()
        if completed.contains(key) { completed.remove(key) } else { completed.insert(key) }
        defaults.set(Array(completed), forKey: "completed-\(dayKey)")
    }
    func saveLog(_ key: String, value: String) {
        refreshDay(); logs[key] = value
        defaults.set(logs, forKey: "logs-\(dayKey)")
    }
}
