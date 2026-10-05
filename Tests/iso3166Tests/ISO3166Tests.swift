import XCTest
@testable import iso3166

final class ISO3166LookupTests: XCTestCase {

    func testUnknownCodeReturnsUnknown() {
        XCTAssertEqual(ISO3166.countryName(alpha2: "zz"), "Unknown")
    }

    func testInvalidLengthReturnsUnknown() {
        XCTAssertEqual(ISO3166.countryName(alpha2: "china"), "Unknown")
    }

    func testUppercaseInputIsAccepted() {
        XCTAssertNotEqual(ISO3166.countryName(alpha2: "CN"), "Unknown")
    }

    func testKosovoIsKnown() {
        XCTAssertNotEqual(ISO3166.countryName(alpha2: "xk"), "Unknown")
    }

    func testGBConstituentCountriesAreKnown() {
        for code in ["gb-eng", "gb-nir", "gb-sct", "gb-wls"] {
            XCTAssertNotEqual(ISO3166.countryName(alpha2: code), "Unknown", code)
        }
    }

    func testFlagNilForUnknownCode() {
        XCTAssertNil(ISO3166.flagImage(alpha2: "zz"))
        XCTAssertNil(ISO3166.flagImage(alpha2: "abc"))
    }

    func testFlagNotNilForKnownCodes() {
        XCTAssertNotNil(ISO3166.flagImage(alpha2: "cn"))
        XCTAssertNotNil(ISO3166.flagImage(alpha2: "gb-sct"))
    }
}

final class CountryDataTests: XCTestCase {

    func testTableHasAllOfficialCodesPlusKosovo() {
        XCTAssertEqual(Country.all.count, 250)
    }

    func testChinaMatchesOfficialISOData() {
        let expected = Country(name: "China", alpha2: "CN", alpha3: "CHN", numeric: "156")
        XCTAssertEqual(Country.find(alpha2: "cn"), expected)
        XCTAssertEqual(Country.find(alpha2: "CN"), expected)
    }

    func testKosovoHasUserAssignedAlpha3AndEmptyNumeric() {
        let xk = Country.find(alpha2: "xk")
        XCTAssertEqual(xk?.name, "Kosovo")
        XCTAssertEqual(xk?.alpha2, "XK")
        XCTAssertEqual(xk?.alpha3, "XXK")
        XCTAssertEqual(xk?.numeric, "")
    }

    func testFindReturnsNilForUnknownCode() {
        XCTAssertNil(Country.find(alpha2: "zz"))
    }

    func testAlpha2CodesAreUniqueAndUppercase() {
        let codes = Country.all.map(\.alpha2)
        XCTAssertEqual(Set(codes).count, codes.count)
        XCTAssertTrue(codes.allSatisfy { $0.count == 2 && $0 == $0.uppercased() })
    }

    func testEveryCountryHasLocalizedName() {
        for country in Country.all {
            XCTAssertNotEqual(ISO3166.countryName(alpha2: country.alpha2), "Unknown", country.alpha2)
        }
    }
}

final class LocalizationCatalogTests: XCTestCase {

    private func table(_ language: String) throws -> [String: String] {
        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "Localizable",
                withExtension: "strings",
                subdirectory: "\(language).lproj"
            )
        )
        return try XCTUnwrap(NSDictionary(contentsOf: url) as? [String: String])
    }

    func testEnglishNames() throws {
        let en = try table("en")
        XCTAssertEqual(en["ad"], "Andorra")
        XCTAssertEqual(en["cn"], "China")
        XCTAssertEqual(en["gb-eng"], "England")
        XCTAssertEqual(en["gb-nir"], "Northern Ireland")
        XCTAssertEqual(en["gb-sct"], "Scotland")
        XCTAssertEqual(en["gb-wls"], "Wales")
        XCTAssertEqual(en["xk"], "Kosovo")
    }

    func testSimplifiedChineseNames() throws {
        let zhHans = try table("zh-Hans")
        XCTAssertEqual(zhHans["cn"], "中华人民共和国")
        XCTAssertEqual(zhHans["gb-eng"], "英格兰")
        XCTAssertEqual(zhHans["gb-nir"], "北爱尔兰")
        XCTAssertEqual(zhHans["gb-sct"], "苏格兰")
        XCTAssertEqual(zhHans["gb-wls"], "威尔士")
    }

    func testTraditionalChineseNames() throws {
        let zhHant = try table("zh-Hant")
        XCTAssertEqual(zhHant["cn"], "中華人民共和國")
        XCTAssertEqual(zhHant["gb-eng"], "英格蘭")
        XCTAssertEqual(zhHant["gb-nir"], "北愛爾蘭")
        XCTAssertEqual(zhHant["gb-sct"], "蘇格蘭")
        XCTAssertEqual(zhHant["gb-wls"], "威爾士")
    }

    func testEveryCodeExistsInAllThreeLanguages() throws {
        let codes = Set(Country.all.map { $0.alpha2.lowercased() })
            .union(["gb-eng", "gb-nir", "gb-sct", "gb-wls"])
        for language in ["en", "zh-Hans", "zh-Hant"] {
            let table = try table(language)
            for code in codes {
                XCTAssertNotNil(table[code], "\(language)/\(code)")
            }
        }
    }
}
