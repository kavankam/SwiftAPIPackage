import Foundation

public class WeatherAPIClient {
    // MARK: - Private Properties
    private let session: URLSession
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5"

    // MARK: - Public Initializer
    public init(apiKey: String) {
        self.apiKey = apiKey
        self.session = URLSession(configuration: .default)
    }

    // MARK: - Public Methods
    public func fetchCurrentWeather(
        forCity city: String,
        completion: @escaping @Sendable (Result<WeatherResponse, WeatherAPIError>) -> Void
    ) {
        let endpoint = "\(baseURL)/weather?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                
                if let cod = weatherResponse.cod, cod != 200 {
                               let message = weatherResponse.message ?? "Unknown error"
                               completion(.failure(.apiError(message)))
                               return
                           }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
}

// MARK: - Data Models

public struct WeatherResponse: Codable, Sendable {
    public let name: String?
    public let main: MainInfo?
    public let weather: [WeatherInfo]?
    public let cod: Int?
    public let message: String?
}

public struct MainInfo: Codable, Sendable {
    public let temp: Double
    public let feels_like: Double
    public let temp_min: Double
    public let temp_max: Double
    public let pressure: Int
    public let humidity: Int
}

public struct WeatherInfo: Codable, Sendable {
    public let id: Int
    public let main: String
    public let description: String
    public let icon: String
}

// MARK: - Custom Error Type

public enum WeatherAPIError: Error, Sendable {
    case invalidURL
    case noData
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
}
