#!/usr/bin/env python3
# Regenerates Sources/iso3166/Models/CountryData.swift from the
# datasets/country-codes ISO 3166-1 CSV (plus Kosovo, a user-assigned
# code element). Usage: python3 Scripts/generate-country-data.py
import csv
import urllib.request

URL = "https://raw.githubusercontent.com/datasets/country-codes/master/data/country-codes.csv"
OUT = "Sources/iso3166/Models/Country+.swift"

def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')

rows = []
with urllib.request.urlopen(URL) as resp:
    for r in csv.DictReader(line.decode("utf-8") for line in resp):
        name = r["CLDR display name"].strip()
        alpha2 = r["ISO3166-1-Alpha-2"].strip().upper()
        alpha3 = r["ISO3166-1-Alpha-3"].strip().upper()
        numeric = r["ISO3166-1-numeric"].strip()
        assert name and len(alpha2) == 2 and len(alpha3) == 3, r
        rows.append((alpha2, name, alpha3, numeric))

rows.append(("XK", "Kosovo", "XXK", ""))
rows.sort(key=lambda x: x[0])

entries = "\n".join(
    f'        Country(name: "{esc(name)}", alpha2: "{a2}", alpha3: "{a3}", numeric: "{num}"),'
    for a2, name, a3, num in rows
)

header = """//
//  Country+.swift
//  iso3166
//
//  Generated from the datasets/country-codes project (ISO 3166-1), 2026-10-05.
//  Kosovo (XK / XXK) is a user-assigned code element, not official ISO 3166-1.
//  Regenerate: see Scripts/generate-country-data.py
//

import Foundation

public extension Country {

    /// All 249 officially assigned ISO 3166-1 alpha-2 entries, plus Kosovo (XK).
    static let all: [Country] = ["""

lookup = """
    ]

    private static let byAlpha2: [String: Country] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.alpha2, $0) }
    )

    /// Case-insensitive lookup by ISO 3166-1 alpha-2 code.
    static func find(alpha2: String) -> Country? {
        byAlpha2[alpha2.uppercased()]
    }
}
"""

with open(OUT, "w", encoding="utf-8") as f:
    f.write(header + "\n" + entries + lookup)

print(f"Wrote {OUT} with {len(rows)} entries")
