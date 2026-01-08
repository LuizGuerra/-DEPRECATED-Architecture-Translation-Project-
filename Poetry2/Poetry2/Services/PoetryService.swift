//
//  PoetryService.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// Service remains the same, used by ViewModels
class PoetryService {
    func fetchRandomPoem(completion: @escaping (Poem?) -> Void) {
        guard let url = URL(string: "https://poetrydb.org/random") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  error == nil,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data),
                  let poem = poems.first
            else {
                completion(nil)
                return
            }
            completion(poem)
        }.resume()
    }

    func searchPoems(byTitle title: String, completion: @escaping ([Poem]) -> Void) {
        let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://poetrydb.org/title/\(encoded)") else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data)
            else {
                completion([])
                return
            }
            completion(poems)
        }.resume()
    }

    func searchPoems(byAuthor author: String, completion: @escaping ([Poem]) -> Void) {
        let encoded = author.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://poetrydb.org/author/\(encoded)") else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data)
            else {
                completion([])
                return
            }
            completion(poems)
        }.resume()
    }

    func searchPoems(byLineCount count: Int, completion: @escaping ([Poem]) -> Void) {
        guard let url = URL(string: "https://poetrydb.org/lines/\(count)") else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data)
            else {
                completion([])
                return
            }
            completion(poems)
        }.resume()
    }
}

