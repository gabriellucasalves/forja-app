import SwiftUI

private enum DetailTheme {
    static let red = Color(red: 231/255, green: 53/255, blue: 60/255)
    static let bg = Color(red: 11/255, green: 11/255, blue: 13/255)
    static let card = Color(red: 27/255, green: 27/255, blue: 30/255)
}

private struct ExerciseGuide {
    let muscles: [String]
    let steps: [String]
    let tip: String
    static func forExercise(_ id: String) -> ExerciseGuide {
        switch id {
        case "leg-press":
            return .init(muscles: ["Quadríceps", "Glúteos", "Adutores"], steps: ["Ajuste o banco e apoie toda a região das costas.", "Mantenha os pés estáveis na plataforma, aproximadamente na largura dos ombros.", "Flexione os joelhos com controle, sem deixar a lombar arredondar.", "Empurre a plataforma sem travar bruscamente os joelhos."], tip: "Use uma amplitude confortável e controlada. Não deixe o quadril sair do banco.")
        case "supino-inclinado", "supino-maquina":
            return .init(muscles: ["Peitoral", "Tríceps", "Deltoide anterior"], steps: ["Ajuste o banco e mantenha os pés apoiados.", "Posicione os ombros de maneira estável.", "Desça a carga com controle.", "Empurre sem perder a estabilidade do tronco."], tip: "Evite tirar os ombros do encosto ou usar impulso.")
        case "cadeira-extensora":
            return .init(muscles: ["Quadríceps"], steps: ["Ajuste o banco e o apoio das pernas.", "Mantenha o quadril apoiado.", "Estenda os joelhos de forma controlada.", "Retorne lentamente à posição inicial."], tip: "Não use balanço do tronco para mover a carga.")
        case "cadeira-flexora":
            return .init(muscles: ["Posteriores de coxa"], steps: ["Ajuste o equipamento ao comprimento das pernas.", "Estabilize o quadril no banco.", "Flexione os joelhos sem impulso.", "Retorne de maneira lenta e controlada."], tip: "Evite levantar o quadril para compensar o peso.")
        case "puxada-frontal", "remada-maquina-neutra", "remada-polia-triangulo":
            return .init(muscles: ["Dorsais", "Romboides", "Bíceps"], steps: ["Ajuste o equipamento e mantenha o tronco estável.", "Inicie o movimento de forma controlada.", "Puxe sem jogar o corpo para trás.", "Retorne lentamente à posição inicial."], tip: "Priorize o controle das escápulas em vez de aumentar a carga.")
        case "elevacao-lateral", "desenvolvimento-de-ombros", "crucifixo-inverso":
            return .init(muscles: ["Deltoides", "Estabilizadores dos ombros"], steps: ["Escolha uma carga que permita controle.", "Mantenha o tronco estável.", "Execute o movimento sem balanço.", "Retorne de forma lenta."], tip: "Evite compensar com o pescoço ou a lombar.")
        default:
            return .init(muscles: ["Consulte a orientação do seu treinador"], steps: ["Ajuste o equipamento à sua altura.", "Use uma carga que permita executar as repetições com controle.", "Mantenha a postura estável durante o movimento.", "Interrompa se sentir dor ou desconforto incomum."], tip: "As instruções são gerais. Confirme a técnica específica com um profissional de educação física.")
        }
    }
}

struct ExerciseDetailsView: View {
    let exercise: Exercise
    let workoutID: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: FormaStore
    @State private var checked: Set<Int> = []
    @State private var loads: [Int: String] = [:]
    @State private var repetitions: [Int: String] = [:]
    @State private var restEnd: Date?
    @State private var showPhoto = false

    private var guide: ExerciseGuide { .forExercise(exercise.id) }
    private var exerciseKey: String { "\(workoutID)-\(exercise.id)" }
    private var storageKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "forma-series-\(formatter.string(from: Date()))-\(exerciseKey)"
    }
    private var seriesDone: Int { checked.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Button { showPhoto = true } label: {
                    ZStack(alignment: .bottomTrailing) {
                        if UIImage(named: exercise.id) != nil {
                            Image(exercise.id).resizable().scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 220)
                                .background(DetailTheme.card)
                        } else {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 75)).foregroundStyle(DetailTheme.red)
                                .frame(maxWidth: .infinity, minHeight: 220)
                                .background(DetailTheme.card)
                        }
                        Label("Ampliar foto", systemImage: "arrow.up.left.and.arrow.down.right")
                            .font(.caption.bold()).padding(10)
                            .background(.black.opacity(0.75), in: Capsule()).padding(12)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }.buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 5) {
                    Text("TREINO \(workoutID) · EXERCÍCIO").font(.caption.bold()).foregroundStyle(DetailTheme.red)
                    Text(exercise.name).font(.largeTitle.bold())
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Músculos trabalhados").font(.headline)
                    ForEach(guide.muscles, id: \.self) { muscle in
                        Label(muscle, systemImage: "circle.fill")
                            .font(.subheadline).foregroundStyle(.white)
                            .labelStyle(.titleAndIcon)
                    }
                }.detailPanel()

                HStack(spacing: 8) {
                    metric("\(exercise.sets)", "Séries", "square.stack")
                    metric(exercise.reps, "Repetições", "repeat")
                    metric("\(exercise.rest)s", "Descanso", "timer")
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Suas séries").font(.headline)
                        Spacer()
                        Text("\(seriesDone)/\(exercise.sets)").foregroundStyle(DetailTheme.red).bold()
                    }
                    ProgressView(value: Double(seriesDone), total: Double(max(1, exercise.sets)))
                        .tint(DetailTheme.red)
                    ForEach(1...max(1, exercise.sets), id: \.self) { number in
                        HStack(spacing: 8) {
                            Text("\(number)ª").font(.subheadline.bold()).frame(width: 28)
                            TextField("kg", text: Binding(get: { loads[number] ?? "" }, set: { loads[number] = $0; persist() }))
                                .keyboardType(.decimalPad).textFieldStyle(.roundedBorder)
                            TextField("reps", text: Binding(get: { repetitions[number] ?? "" }, set: { repetitions[number] = $0; persist() }))
                                .keyboardType(.numberPad).textFieldStyle(.roundedBorder)
                            Button {
                                if checked.contains(number) { checked.remove(number) }
                                else { checked.insert(number); restEnd = Date().addingTimeInterval(TimeInterval(exercise.rest)) }
                                persist()
                            } label: {
                                Image(systemName: checked.contains(number) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2).foregroundStyle(checked.contains(number) ? .green : DetailTheme.red)
                            }.accessibilityLabel("Marcar série \(number)")
                        }
                    }
                    Text("Carga (kg) e repetições são salvas automaticamente neste aparelho.")
                        .font(.caption).foregroundStyle(.secondary)
                    if checked.count == exercise.sets {
                        Label("Todas as séries concluídas!", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }.detailPanel()

                if let restEnd {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let seconds = max(0, Int(ceil(restEnd.timeIntervalSince(context.date))))
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Descanso").font(.headline)
                            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(DetailTheme.red)
                                .monospacedDigit()
                            if seconds == 0 { Text("Descanso concluído. Pronto para a próxima série!").font(.subheadline) }
                            Button("Encerrar descanso") { self.restEnd = nil }.foregroundStyle(DetailTheme.red)
                        }.detailPanel()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Como executar").font(.headline)
                    ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1).").bold().foregroundStyle(DetailTheme.red)
                            Text(step).font(.subheadline)
                        }
                    }
                }.detailPanel()
                VStack(alignment: .leading, spacing: 8) {
                    Label("Dica de execução", systemImage: "lightbulb.fill").foregroundStyle(DetailTheme.red).bold()
                    Text(guide.tip).font(.subheadline)
                }.detailPanel()
                Text("Fotografia: consulte os créditos e a licença do arquivo incluído no Assets. As orientações não substituem avaliação profissional.")
                    .font(.caption2).foregroundStyle(.secondary)
            }.padding(18)
        }
        .background(DetailTheme.bg)
        .navigationTitle("Detalhes do exercício")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear(perform: restore)
        .sheet(isPresented: $showPhoto) {
            NavigationStack {
                ZStack {
                    DetailTheme.bg.ignoresSafeArea()
                    if UIImage(named: exercise.id) != nil {
                        Image(exercise.id).resizable().scaledToFit().padding()
                    } else {
                        Text("Foto não disponível").foregroundStyle(.secondary)
                    }
                }
                .navigationTitle(exercise.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fechar") { showPhoto = false } } }
            }.preferredColorScheme(.dark)
        }
    }

    private func metric(_ value: String, _ title: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(DetailTheme.red)
            Text(value).font(.headline).minimumScaleFactor(0.7).lineLimit(1)
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(12)
        .background(DetailTheme.card, in: RoundedRectangle(cornerRadius: 14))
    }

    private func persist() {
        let data = SeriesData(checked: Array(checked), loads: loads, repetitions: repetitions)
        if let encoded = try? JSONEncoder().encode(data) { UserDefaults.standard.set(encoded, forKey: storageKey) }
        if checked.count == exercise.sets && !store.completed.contains(exerciseKey) { store.toggle(exerciseKey) }
        if checked.count != exercise.sets && store.completed.contains(exerciseKey) { store.toggle(exerciseKey) }
    }
    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode(SeriesData.self, from: data) else { return }
        checked = Set(saved.checked)
        loads = saved.loads
        repetitions = saved.repetitions
    }
}

private struct SeriesData: Codable {
    var checked: [Int]
    var loads: [Int: String]
    var repetitions: [Int: String]
}

private extension View {
    func detailPanel() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(DetailTheme.card, in: RoundedRectangle(cornerRadius: 18))
    }
}
