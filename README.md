# Forja

> ⚠️ **Projeto em desenvolvimento** — funcionalidades incompletas e sujeitas a mudanças.

Aplicativo iOS para treino, alimentação, hidratação e passos. O código ainda usa o nome **FORMA** no target e nos arquivos (`FORMAApp.swift`).

## Stack

- Swift
- SwiftUI
- HealthKit
- iOS 17 ou superior

## Instalação

1. No Xcode, crie um projeto iOS App chamado FORMA, interface SwiftUI, linguagem Swift.
2. Adicione os arquivos `.swift` desta pasta ao target (substitua o App gerado pelo `FORMAApp.swift`).
3. Em Signing & Capabilities, adicione HealthKit; em Info, configure `NSHealthShareUsageDescription` com: `O FORMA le seus passos para mostrar sua atividade diaria.`
4. Use iOS 17 ou superior e execute em um iPhone físico para testar o HealthKit.

O armazenamento usa `UserDefaults` para registros simples e dados iniciais estáticos. Não há backend.

> A meta nutricional é provisória e **não substitui orientação profissional**.
