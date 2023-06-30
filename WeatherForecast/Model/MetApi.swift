//
//  MetApi.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 07/12/2022.
//

import Foundation

/// This file was generated from JSON Schema using quicktype, do not modify it directly.
/// To parse the JSON, add this file to your project and do:
///
///   let metAPI = try? JSONDecoder().decode(MetAPI.self, from: jsonData)

// MARK: - MetAPI
struct MetApi: Codable {
    var location: Location?
    var meta: Meta?
}

// MARK: - Location
struct Location: Codable {
    let height, latitude, longitude: String?
    let time: [Time]?
}

// MARK: - Time
struct Time: Codable {
    let date: String?
    let highMoon, lowMoon: HighMoon?
    let moonphase: Moonphase?
    let moonposition: Moonposition?
    let moonrise: Moonrise?
    let moonset: Moonrise?
    let moonshadow: HighMoon?
    let solarmidnight: Solarmidnight?
    let solarnoon, sunrise, sunset: HighMoon?

    enum CodingKeys: String, CodingKey {
        case date
        case highMoon = "high_moon"
        case lowMoon = "low_moon"
        case moonphase, moonposition, moonrise, moonset, moonshadow, solarmidnight, solarnoon
        case sunrise, sunset
    }
}

// MARK: - HighMoon
struct HighMoon: Codable {
    let desc, elevation: String?
    let time: String?
    let azimuth: String?
}

// MARK: - Moonphase
struct Moonphase: Codable {
    let desc: String?
    let time: String?
    let value: String?
}

// MARK: - Moonposition
struct Moonposition: Codable {
    let azimuth, desc, elevation, phase: String?
    let range: String?
    let time: String?
}

// MARK: - Moonrise
struct Moonrise: Codable {
    let desc: String?
    let time: String?
}

// MARK: - Meta
struct Meta: Codable {
    let licenseurl: String?
}

enum Solarmidnight: Codable {
    case highMoon(HighMoon)
    case highMoonArray([HighMoon])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([HighMoon].self) {
            self = .highMoonArray(x)
            return
        }
        if let x = try? container.decode(HighMoon.self) {
            self = .highMoon(x)
            return
        }
        throw DecodingError.typeMismatch(Solarmidnight.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Solarmidnight"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .highMoon(let x):
            try container.encode(x)
        case .highMoonArray(let x):
            try container.encode(x)
        }
    }
}
