//
//  Poem.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// Model remains the same
struct Poem: Codable, Equatable {
    let title: String
    let author: String
    let lines: [String]

    static func == (lhs: Poem, rhs: Poem) -> Bool {
        // Simple equality check based on content
        return lhs.title == rhs.title && lhs.author == rhs.author && lhs.lines == rhs.lines
    }
}

