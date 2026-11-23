import Foundation

struct Exercise: Identifiable, Hashable {
    let id: String
    let name: String
    let sets: Int
    let reps: String
    let rest: Int
}
struct Workout: Identifiable {
    let id: String
    let title: String
    let day: String
    let exercises: [Exercise]
}
struct Meal: Identifiable {
    let id: String
    let time: String
    let title: String
    let detail: String
}

enum Seed {
    static func ex(_ name: String, _ sets: Int, _ reps: String, _ rest: Int = 90) -> Exercise {
        Exercise(id: name.lowercased().replacingOccurrences(of: " ", with: "-"), name: name, sets: sets, reps: reps, rest: rest)
    }
    static let workouts: [Workout] = [
        Workout(id:"A",title:"Push - peito, ombros e triceps",day:"Segunda",exercises:[ex("Supino inclinado",3,"6-10",150),ex("Supino maquina",3,"8-12",120),ex("Crucifixo maquina",2,"12-15"),ex("Desenvolvimento de ombros",3,"8-12",120),ex("Elevacao lateral",3,"12-20"),ex("Triceps polia corda",3,"10-15")]),
        Workout(id:"B",title:"Pull - costas e biceps",day:"Terca",exercises:[ex("Remada maquina neutra",3,"8-12",150),ex("Puxada frontal",3,"8-12",120),ex("Remada polia triangulo",3,"10-12",120),ex("Crucifixo inverso",3,"12-15"),ex("Rosca simultanea",3,"8-12"),ex("Rosca maquina",2,"10-15")]),
        Workout(id:"C",title:"Pernas I - quadriceps",day:"Quarta",exercises:[ex("Leg press",4,"8-12",180),ex("Cadeira extensora",3,"10-15"),ex("Cadeira flexora",3,"10-15"),ex("Cadeira adutora",2,"12-15"),ex("Gemeos sentado",4,"12-20"),ex("Abdominal maquina",3,"12-15")]),
        Workout(id:"D",title:"Superior completo",day:"Quinta",exercises:[ex("Supino maquina",3,"8-12",120),ex("Remada maquina neutra",3,"8-12",120),ex("Puxada frontal",2,"10-12",120),ex("Elevacao lateral",3,"12-20"),ex("Triceps maquina",2,"10-15"),ex("Rosca com halteres",2,"10-15")]),
        Workout(id:"E",title:"Pernas II - posterior e gluteos",day:"Sexta",exercises:[ex("Cadeira flexora",4,"8-12",120),ex("Leg press",3,"10-12",150),ex("Gluteo maquina",3,"10-15"),ex("Cadeira abdutora",3,"12-20"),ex("Gemeos sentado",3,"12-20"),ex("Lombar maquina",2,"12-15"),ex("Abdominal remador",3,"12-15")])
    ]
    static let meals: [Meal] = [
        Meal(id:"1",time:"07:15",title:"Pre-treino",detail:"Banana, pao e cafe se tolerado"),
        Meal(id:"2",time:"09:30",title:"Pos-treino",detail:"Ovos, pao, leite e fruta"),
        Meal(id:"3",time:"12:30",title:"Almoco",detail:"Arroz, feijao, frango e legumes"),
        Meal(id:"4",time:"15:30",title:"Lanche",detail:"Iogurte, aveia e banana"),
        Meal(id:"5",time:"18:30",title:"Lanche",detail:"Sanduiche de frango ou atum"),
        Meal(id:"6",time:"21:30",title:"Jantar",detail:"Arroz, feijao, carne moida e salada"),
        Meal(id:"7",time:"23:30",title:"Ceia opcional",detail:"Leite ou iogurte com aveia")
    ]
}
