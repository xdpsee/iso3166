//
//  ISO3166.swift
//  iso3166
//

#if os(iOS)
import UIKit
public typealias Image = UIImage
#elseif os(macOS)
import AppKit
public typealias Image = NSImage
#endif

public enum ISO3166 {

    private static let gbConstituentCodes = ["gb-eng", "gb-nir", "gb-sct", "gb-wls"]

    private static let knownCodes: Set<String> =
        Set(Country.all.map { $0.alpha2.lowercased() }).union(gbConstituentCodes)

    /// Localized country name for an alpha-2 code, or "Unknown" if the code is not recognized.
    /// Resolves against the system language (en / zh-Hans / zh-Hant catalogs).
    public static func countryName(alpha2: String) -> String {
        let code = alpha2.lowercased()
        guard knownCodes.contains(code) else {
            return "Unknown"
        }
        
        return Bundle.module.localizedString(forKey: code, value: "Unknown", table: nil)
    }

    /// Flag image for an alpha-2 code (or a `gb-*` constituent-country code), or nil if unknown.
    public static func flagImage(alpha2: String) -> Image? {
        let code = alpha2.lowercased()
        guard knownCodes.contains(code) else {
            return nil
        }
        
        #if os(iOS)
        return Image(named: code, in: Bundle.module, with: nil)
        #elseif os(macOS)
        guard let url = Bundle.module.url(forResource: code, withExtension: "png"),
              let image = Image(contentsOf: url) else {
            return nil
        }
        // PNGs are authored at 3x; AppKit treats loose files as 1x, so rescale
        // to points to match the asset-catalog sizing iOS renders.
        image.size = NSSize(width: image.size.width / 3, height: image.size.height / 3)
        return image
        #else
        return nil
        #endif
    }
}
