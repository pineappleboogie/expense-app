//
//  FontRegistration.swift
//  MyFirstApp
//

import SwiftUI
import CoreText

enum FontRegistration {
    static func registerFonts() {
        let fontNames = [
            "FiraCode-Regular",
            "FiraCode-Medium",
            "FiraCode-SemiBold"
        ]

        for fontName in fontNames {
            registerFont(named: fontName)
        }
    }

    private static func registerFont(named fontName: String) {
        guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf"),
              let fontData = try? Data(contentsOf: fontURL) as CFData,
              let provider = CGDataProvider(data: fontData),
              let font = CGFont(provider) else {
            print("Failed to load font: \(fontName)")
            return
        }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            if let error = error?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(error) as String? ?? "Unknown error"
                // Font may already be registered, which is fine
                if !errorDescription.contains("already registered") {
                    print("Failed to register font \(fontName): \(errorDescription)")
                }
            }
        }
    }
}

// AppDelegate alternative for SwiftUI
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FontRegistration.registerFonts()
        return true
    }
}
