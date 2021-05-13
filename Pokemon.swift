import Foundation

struct PokemonListResults: Codable {
    let results: [PokemonListResult]
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonResult: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let sprites: PokemonSprites
    let species: Species
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct Species: Codable {
    let url: String
}

struct PokemonSprites: Codable {
    let front_default: String
}

struct PokemonDescription: Codable {
    let flavor_text_entries: [FlavorTextEntries]
}
struct FlavorTextEntries: Codable {
    let flavor_text: String
    let language: Language
}
struct Language: Codable {
    let name: String
}
