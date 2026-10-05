//
//  File.swift
//  iso3166
//
//  Created by 陈振辉 on 2026/10/5.
//

import Foundation

public struct Country: Codable, Equatable, Sendable {
    public let name: String
    public let alpha2: String
    public let alpha3: String
    public let numeric: String
}
