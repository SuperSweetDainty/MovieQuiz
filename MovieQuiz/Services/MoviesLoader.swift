import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesURL: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string:  "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("не удалось получить URL")
        }
        return url
    }
    
    enum MoviesLoaderError: Error {
        case serverError(message: String)
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            switch result {
            case .success(let data):
                do {
                    // Декодируем JSON в модель MostPopularMovies
                    let movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if !movies.errorMessage.isEmpty {
                        // Обрабатываем ошибку от сервера в теле ответа
                        handler(.failure(MoviesLoaderError.serverError(message: movies.errorMessage)))
                    } else {
                        handler(.success(movies))
                    }
                } catch {
                    // Если произошла ошибка при декодировании, передаём её дальше
                    handler(.failure(error))
                }
            case .failure(let error):
                // Передаём ошибку дальше в handler
                handler(.failure(error))
            }
        }
    }
}
