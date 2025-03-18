import UIKit

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    // Перечисление ключей для хранения данных в UserDefaults
    private enum Keys: String {
        case correct              // Общее количество правильных ответов
        case bestGameCorrect      // Лучший результат (количество правильных ответов)
        case bestGame             // Дата лучшего результата
        case gamesCount           // Количество сыгранных игр
    }
    
    // Количество сыгранных игр
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // Лучший результат среди всех игр
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let date = storage.object(forKey: Keys.bestGame.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: 10, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // Общая точность ответов в процентах
    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0.0 } // Защита от деления на 0
        return (Double(correctAnswers) / Double(gamesCount * 10)) * 100
    }
    
    // Общее количество правильных ответов во всех играх
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    // Метод для сохранения результата после игры
    func store(correct count: Int, total amount: Int) {
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        
        correctAnswers += count // Обновляем общее количество правильных ответов
        
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
        gamesCount += 1 // Увеличиваем счётчик сыгранных игр
    }
}
