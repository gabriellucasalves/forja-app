// xcode: set sdk=iOS


import SwiftUI
import Combine
import HealthKit

@MainActor
final class HealthSteps: ObservableObject {
    @Published var steps: Int? = nil
    @Published var status = "Conecte o Apple Saúde"

    private let healthStore = HKHealthStore()

    func connect() async {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKObjectType.quantityType(
                forIdentifier: .stepCount
              ) else {
            status = "HealthKit indisponível"
            return
        }

        do {
            try await healthStore.requestAuthorization(
                toShare: [],
                read: [type]
            )

            await loadSteps(type)
        } catch {
            status = "Erro: \(error.localizedDescription)"
        }
    }

    private func loadSteps(_ type: HKQuantityType) async {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: Date(),
            options: .strictStartDate
        )

        await withCheckedContinuation {
            (continuation: CheckedContinuation<Void, Never>) in

            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in

                let count = result?
                    .sumQuantity()?
                    .doubleValue(for: .count())

                Task { @MainActor in
                    if let error {
                        self.status = error.localizedDescription
                    } else {
                        self.steps = count.map { Int($0) }
                        self.status = count == nil
                            ? "Sem dados de passos disponíveis"
                            : "Passos de hoje"
                    }
                    continuation.resume()
                }
            }

            healthStore.execute(query)
        }
    }
}
