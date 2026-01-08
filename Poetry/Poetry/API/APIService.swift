import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    case apiError(String) // For specific API messages if any

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode API response: \(error.localizedDescription)"
        case .noData:
            return "No data received from the API."
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
}

class APIService {
    private let baseURL = "https://poetrydb.org"

    // Fetches a random poem from the API
    func fetchRandomPoem(completion: @escaping (Result<PoemResponse, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/random") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                // PoetryDB returns an array, even for a single random poem
                let decoder = JSONDecoder()
                let poems = try decoder.decode(PoemResponse.self, from: data)
                completion(.success(poems))
            } catch {
                print("Decoding Error: \(error)") // Log the underlying error
                completion(.failure(.decodingError(error)))
            }
        }.resume() // Start the network task
    }

    // Placeholder for fetching poems by author (will be needed later)
    func fetchPoems(by author: String, completion: @escaping (Result<PoemResponse, APIError>) -> Void) {
         guard let encodedAuthor = author.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
               let url = URL(string: "\(baseURL)/author/\(encodedAuthor)") else {
             completion(.failure(.invalidURL))
             return
         }

         URLSession.shared.dataTask(with: url) { data, response, error in
             // Similar decoding logic as fetchRandomPoem
             // ...
         }.resume()
     }

     // Placeholder for fetching a specific poem by title and author (will be needed later)
     func fetchPoem(title: String, author: String, completion: @escaping (Result<PoemResponse, APIError>) -> Void) {
          guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                let encodedAuthor = author.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                let url = URL(string: "\(baseURL)/author,title/\(encodedAuthor);\(encodedTitle)") else {
              completion(.failure(.invalidURL))
              return
          }

          URLSession.shared.dataTask(with: url) { data, response, error in
              // Similar decoding logic as fetchRandomPoem
              // ...
          }.resume()
      }

    // Add other fetching methods as needed for search/browse...
}
