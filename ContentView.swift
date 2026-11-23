import SwiftUI

private enum ForceStyle {
    static let red = Color(red: 231/255, green: 53/255, blue: 60/255)
    static let bg = Color(red: 11/255, green: 11/255, blue: 13/255)
    static let card = Color(red: 27/255, green: 27/255, blue: 30/255)
    static let muted = Color(red: 175/255, green: 175/255, blue: 181/255)
}

private struct ForceCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 14) { content }
            .padding(18).frame(maxWidth: .infinity, alignment: .leading)
            .background(ForceStyle.card, in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct ExerciseArt: View {
    let exercise: Exercise
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14).fill(ForceStyle.red.opacity(0.13))
            if UIImage(named: exercise.id) != nil {
                Image(exercise.id).resizable().scaledToFill()
                    .frame(width: 92, height: 92).clipped().clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 32)).foregroundStyle(ForceStyle.red)
            }
        }
        .frame(width: 92, height: 92)
        .accessibilityLabel("Imagem do exercício \(exercise.name)")
    }
}

struct ContentView: View {
    @EnvironmentObject var store: FormaStore
    @StateObject private var health = HealthSteps()

    private var todaysWorkout: Workout? {
        let day = Calendar.current.component(.weekday, from: Date())
        let index = day - 2
        return (0..<Seed.workouts.count).contains(index) ? Seed.workouts[index] : nil
    }

    var body: some View {
        TabView {
            NavigationStack { dashboard }.tabItem { Label("Início", systemImage: "house.fill") }
            NavigationStack { workouts }.tabItem { Label("Treinos", systemImage: "dumbbell.fill") }
            NavigationStack { diet }.tabItem { Label("Dieta", systemImage: "fork.knife") }
            NavigationStack { water }.tabItem { Label("Água", systemImage: "drop.fill") }
            NavigationStack { music }.tabItem { Label("Música", systemImage: "music.note") }
        }
        .tint(ForceStyle.red)
        .preferredColorScheme(.dark)
    }

    private var dashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("FORMA / RED FORCE").font(.caption.bold()).tracking(2).foregroundStyle(ForceStyle.red)
                    Text("Bom dia! 💪").font(.largeTitle.bold())
                    Text("Sua evolução começa agora.").foregroundStyle(ForceStyle.muted)
                }
                ForceCard {
                    HStack {
                        Label("TREINO DE HOJE", systemImage: "flame.fill")
                            .font(.caption.bold()).foregroundStyle(ForceStyle.red)
                        Spacer()
                        Text("FOCO E FORÇA").font(.caption2).foregroundStyle(ForceStyle.muted)
                    }
                    if let workout = todaysWorkout {
                        Text(workout.title).font(.title2.bold())
                        Text("\(workout.exercises.count) exercícios · \(workout.day)")
                            .foregroundStyle(ForceStyle.muted)
                        NavigationLink {
                            WorkoutDetail(workout: workout)
                        } label: {
                            Label("Começar treino", systemImage: "play.fill")
                                .frame(maxWidth: .infinity).padding(14)
                                .background(ForceStyle.red, in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white).fontWeight(.bold)
                        }
                    } else {
                        Text("Hoje é dia de recuperar e voltar mais forte.").font(.title3.bold())
                        Text("Seu próximo treino está na aba Treinos.").foregroundStyle(ForceStyle.muted)
                    }
                }
                HStack(spacing: 10) {
                    metric("Água", value: "\(store.waterML) ml", symbol: "drop.fill")
                    metric("Passos", value: health.steps.map(String.init) ?? "—", symbol: "figure.walk")
                    metric("Meta", value: "2700 kcal", symbol: "flame.fill")
                }
                ForceCard {
                    Text("Apple Saúde").font(.headline)
                    Text(health.status).font(.subheadline).foregroundStyle(ForceStyle.muted)
                    Button("Conectar / atualizar passos") { Task { await health.connect() } }
                        .foregroundStyle(ForceStyle.red)
                }
                Text("Sua semana").font(.title2.bold())
                ForEach(Seed.workouts) { workout in
                    NavigationLink { WorkoutDetail(workout: workout) } label: {
                        workoutRow(workout)
                    }.buttonStyle(.plain)
                }
            }
            .padding(18)
        }
        .background(ForceStyle.bg)
        .onAppear { store.refreshDay() }
    }

    private func metric(_ title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol).foregroundStyle(ForceStyle.red)
            Text(value).font(.subheadline.bold()).lineLimit(1).minimumScaleFactor(0.75)
            Text(title).font(.caption2).foregroundStyle(ForceStyle.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ForceStyle.card, in: RoundedRectangle(cornerRadius: 15))
    }

    private func workoutRow(_ workout: Workout) -> some View {
        HStack(spacing: 12) {
            Text(workout.id).font(.title2.bold()).foregroundStyle(ForceStyle.red)
                .frame(width: 45, height: 54)
                .background(ForceStyle.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text("\(workout.day) · Treino \(workout.id)").font(.headline)
                Text(workout.title).font(.subheadline).foregroundStyle(ForceStyle.muted)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right").foregroundStyle(ForceStyle.red)
        }
        .padding(14)
        .background(ForceStyle.card, in: RoundedRectangle(cornerRadius: 18))
    }

    private var workouts: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Sua rotina de força").font(.title2.bold())
                Text("5 treinos por semana · evolua no seu ritmo")
                    .foregroundStyle(ForceStyle.muted)
                ForEach(Seed.workouts) { workout in
                    NavigationLink { WorkoutDetail(workout: workout) } label: {
                        workoutRow(workout)
                    }.buttonStyle(.plain)
                }
            }.padding(18)
        }
        .background(ForceStyle.bg)
        .navigationTitle("Treinos")
    }

    private var diet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForceCard {
                    Label("META DIÁRIA", systemImage: "flame.fill")
                        .font(.caption.bold()).foregroundStyle(ForceStyle.red)
                    Text("2.700 kcal").font(.largeTitle.bold())
                    Text("160 g proteína · 335 g carboidratos · 80 g gorduras")
                        .font(.subheadline).foregroundStyle(ForceStyle.muted)
                    Text("Metas provisórias; ajuste as porções conforme sua evolução.")
                        .font(.caption).foregroundStyle(ForceStyle.muted)
                }
                ForEach(Seed.meals) { meal in
                    ForceCard {
                        Text(meal.time).font(.caption.bold()).foregroundStyle(ForceStyle.red)
                        Text(meal.title).font(.headline)
                        Text(meal.detail).foregroundStyle(ForceStyle.muted)
                    }
                }
            }.padding(18)
        }
        .background(ForceStyle.bg)
        .navigationTitle("Minha dieta")
    }

    private var water: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ForceCard {
                    Image(systemName: "drop.fill").font(.largeTitle).foregroundStyle(ForceStyle.red)
                    Text("\(store.waterML) / \(store.waterGoal) ml").font(.title.bold())
                    ProgressView(value: Double(min(store.waterML, store.waterGoal)), total: Double(store.waterGoal))
                        .tint(ForceStyle.red)
                    Text("Registre cada copo ao longo do dia.")
                        .foregroundStyle(ForceStyle.muted)
                    HStack {
                        ForEach([200, 300, 500], id: \.self) { amount in
                            Button("+\(amount) ml") { store.addWater(amount) }
                                .buttonStyle(.bordered).tint(ForceStyle.red)
                        }
                    }
                    Button("Desfazer 200 ml") { store.addWater(-200) }
                        .font(.subheadline).foregroundStyle(ForceStyle.muted)
                }
            }.padding(18)
        }
        .background(ForceStyle.bg)
        .navigationTitle("Hidratação")
        .onAppear { store.refreshDay() }
    }

    private var music: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Som pesado para cada dia").font(.title2.bold())
                Text("Rock e funk submundo alternando na semana. Toque na faixa para encontrá-la no seu serviço favorito.")
                    .foregroundStyle(ForceStyle.muted)
                ForEach(ForcePlaylists.all) { playlist in
                    ForceCard {
                        HStack {
                            Image(systemName: playlist.isRock ? "music.mic" : "waveform")
                                .foregroundStyle(ForceStyle.red).font(.title)
                            VStack(alignment: .leading) {
                                Text(playlist.day.uppercased()).font(.caption.bold()).foregroundStyle(ForceStyle.red)
                                Text(playlist.title).font(.headline)
                                Text(playlist.genre).font(.caption).foregroundStyle(ForceStyle.muted)
                            }
                        }
                        ForEach(Array(playlist.tracks.enumerated()), id: \.offset) { index, track in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(index + 1). \(track.title)").font(.subheadline.bold())
                                Text(track.artist).font(.caption).foregroundStyle(ForceStyle.muted)
                                HStack(spacing: 16) {
                                    Link("Spotify", destination: track.spotifySearch).foregroundStyle(ForceStyle.red)
                                    Link("Apple Music", destination: track.appleSearch).foregroundStyle(ForceStyle.red)
                                }.font(.caption.bold())
                            }
                            if index < playlist.tracks.count - 1 { Divider().overlay(ForceStyle.red.opacity(0.2)) }
                        }
                    }
                }
                Text("Os links abrem a busca de cada música no serviço escolhido. Para criar playlists reais nas suas contas, será necessária autorização OAuth/MusicKit; esta versão não altera suas bibliotecas.")
                    .font(.footnote).foregroundStyle(ForceStyle.muted)
            }.padding(18)
        }.background(ForceStyle.bg).navigationTitle("Música")
    }

}

struct WorkoutDetail: View {
    @EnvironmentObject var store: FormaStore
    let workout: Workout
    @State private var entries: [String: String] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(workout.title).font(.title2.bold())
                Text("Mantenha 1–3 repetições em reserva. Priorize a técnica.")
                    .foregroundStyle(ForceStyle.muted)
                ForEach(workout.exercises) { exercise in
                    exerciseCard(exercise)
                }
            }.padding(18)
        }
        .background(ForceStyle.bg)
        .navigationTitle("Treino \(workout.id)")
        .onAppear { store.refreshDay() }
    }

    private func exerciseCard(_ exercise: Exercise) -> some View {
        let key = "\(workout.id)-\(exercise.id)"
        return ForceCard {
            NavigationLink {
                ExerciseDetailsView(exercise: exercise, workoutID: workout.id)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    ExerciseArt(exercise: exercise)
                    VStack(alignment: .leading, spacing: 5) {
                    Text(exercise.name).font(.headline)
                    Text("\(exercise.sets) séries · \(exercise.reps) repetições")
                        .font(.subheadline).foregroundStyle(ForceStyle.muted)
                    Label("\(exercise.rest)s descanso", systemImage: "timer")
                        .font(.caption).foregroundStyle(ForceStyle.red)
                }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").foregroundStyle(ForceStyle.red)
                }
            }
            .buttonStyle(.plain)
            Text("Toque na foto ou no nome para ampliar, ver músculos, técnica e registrar cada série.")
                .font(.caption2).foregroundStyle(ForceStyle.muted)
            TextField("Carga e repetições (ex.: 20kg, 10/10/9)", text: Binding(
                get: { entries[key] ?? store.logs[key] ?? "" },
                set: { entries[key] = $0 }
            ))
            .textInputAutocapitalization(.never)
            .padding(12)
            .background(ForceStyle.bg, in: RoundedRectangle(cornerRadius: 10))
            Button("Salvar registro") {
                store.saveLog(key, value: entries[key] ?? store.logs[key] ?? "")
            }
            .foregroundStyle(ForceStyle.red)
            Button {
                store.toggle(key)
            } label: {
                Label(store.completed.contains(key) ? "Concluído" : "Marcar concluído",
                      systemImage: store.completed.contains(key) ? "checkmark.circle.fill" : "circle")
                    .frame(maxWidth: .infinity).padding(12)
                    .background(store.completed.contains(key) ? ForceStyle.red.opacity(0.25) : ForceStyle.red,
                                in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white).fontWeight(.semibold)
            }
        }
    }
}
