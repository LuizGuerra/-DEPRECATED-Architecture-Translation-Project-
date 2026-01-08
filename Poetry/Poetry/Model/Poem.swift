import Foundation

// The structure of a single poem object from the API
struct Poem: Codable, Identifiable {
    let title: String
    let author: String
    let lines: [String]

    // Provide a simple ID for SwiftUI ForEach loops
    var id: String { title + author }
}

// The API response is often an array of poems
typealias PoemResponse = [Poem]
