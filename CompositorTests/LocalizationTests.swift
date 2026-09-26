import AppKit
import Testing
@testable import Compositor

@MainActor
struct LocalizationTests {
    private func chineseStrings() throws -> [String: String] {
        let path = try #require(Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "zh-Hans.lproj"))
        return try #require(PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: path)), format: nil) as? [String: String])
    }

    @Test func professionalTermsAndNewFiltersAreInTheBuiltApp() throws {
        let strings = try chineseStrings()
        for (key, value) in ["Type": "文字", "Folder": "图层组", "Dither": "仿色", "Multiply": "正片叠底",
                             "Set Black Point": "设置黑场", "Set Gray Point": "设置灰场", "Set White Point": "设置白场",
                             "Point Sample": "点取样", "Color Picker (Dither Light Color)": "拾色器（仿色亮色）"] {
            #expect(strings[key] == value, "\(key) in the compiled resource")
        }
        // Color names must keep their color meaning outside the Levels eyedroppers.
        #expect(strings["Black"] == "黑色")
        #expect(strings["White"] == "白色")
    }

    @Test func runtimeChoicesAndShortcutTitlesHaveChineseResources() throws {
        let strings = try chineseStrings()
        let groups: [[String]] = [
            LayerBlendMode.allCases.map(\.rawValue), LayerEffectKind.allCases.map(\.rawValue),
            FilterKind.allCases.map(\.rawValue), AdjustmentKind.allCases.map(\.rawValue),
            DitherStyle.allCases.map(\.rawValue), DitherPixelShape.allCases.map(\.rawValue),
            DitherColors.allCases.map { $0 == .original ? "Original Colors" : $0.rawValue },
            ShapeKind.allCases.map(\.rawValue), LayerSampling.allCases.map(\.rawValue),
            WandMode.allCases.map(\.rawValue), LassoKind.allCases.map(\.rawValue),
            SelectionMode.allCases.map(\.rawValue), GradientStyle.allCases.map(\.rawValue),
            GradientShape.allCases.map(\.rawValue), TextAlignment.allCases.map(\.rawValue),
            BackgroundQuality.allCases.map(\.rawValue), ColorRange.allCases.map(\.rawValue),
            HueSampleMode.allCases.map(\.rawValue), HueSampleMode.allCases.map(\.help),
            LevelsAuto.allCases.map(\.rawValue), LevelsChannel.allCases.map(\.rawValue),
            CameraRawWhiteBalance.allCases.map(\.rawValue), CameraRawGlowStyle.allCases.map(\.rawValue),
            CameraRawVignetteStyle.allCases.map(\.rawValue), CameraRawUprightMode.allCases.map(\.rawValue),
            CameraRawProjection.allCases.map(\.rawValue), CameraRawProcessVersion.allCases.map(\.rawValue),
            CameraRawProcessVersion.allCases.map(\.summary), CameraRawCurvePage.allCases.map(\.rawValue),
            CameraRawPointChannel.allCases.map(\.rawValue), CameraRawMixerPage.allCases.map(\.rawValue),
            CameraRawMixerTab.allCases.map(\.rawValue), CameraRawGradePage.allCases.map(\.rawValue),
            ShortcutDefinition.all.flatMap { [$0.title, $0.group] },
            ["Point Sample", "3 by 3 Average", "5 by 5 Average"]
        ]
        for key in Set(groups.flatMap { $0 }) {
            #expect(strings[key]?.isEmpty == false, "Missing runtime translation: \(key)")
        }
        // Names assembled for the undo menu and effect picker also need complete keys.
        for kind in LayerEffectKind.allCases {
            for action in ["Add", "Cancel", "Edit", "Copy", "Hide", "Show", "Remove"] {
                #expect(strings["\(action) \(kind.rawValue)"]?.isEmpty == false)
            }
            #expect(strings["Color Picker (\(kind.rawValue) Color)"]?.isEmpty == false)
        }
    }

    @Test func languagePreferenceIsIsolatedAndRejectsUnsupportedValues() throws {
        let suite = "io.github.lento52.compositor-cn.test.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let original = UserDefaults.standard.persistentDomain(forName: Bundle.main.bundleIdentifier!)
        #expect(LanguagePreference.save("zh-Hans", defaults: defaults))
        #expect(defaults.persistentDomain(forName: suite)?["AppleLanguages"] as? [String] == ["zh-Hans"])
        #expect(!LanguagePreference.save("unsupported", defaults: defaults))
        #expect(defaults.persistentDomain(forName: suite)?["AppleLanguages"] as? [String] == ["zh-Hans"])
        #expect(LanguagePreference.save("en", defaults: defaults))
        #expect(LanguagePreference.save(nil, defaults: defaults))
        #expect(defaults.persistentDomain(forName: suite)?["AppleLanguages"] == nil)
        #expect(NSDictionary(dictionary: UserDefaults.standard.persistentDomain(forName: Bundle.main.bundleIdentifier!) ?? [:])
                == NSDictionary(dictionary: original ?? [:]))
    }

    @Test func chineseLabelsDoNotChangeStoredIdentifiersOrUserText() throws {
        let strings = try chineseStrings()
        #expect(strings[LayerBlendMode.multiply.rawValue] == "正片叠底")
        let encoded = try JSONEncoder().encode(LayerBlendMode.multiply)
        #expect(String(data: encoded, encoding: .utf8) == "\"Multiply\"")
        #expect(try JSONDecoder().decode(LayerBlendMode.self, from: encoded) == .multiply)
        #expect(DitherColors.original.rawValue == "Original")
        #expect(LevelsSample.black.rawValue == "Black")
        let session = EditorSession()
        session.createDocument(width: 64, height: 64, emptyLayer: true)
        let id = try #require(session.activeLayerID)
        session.renameLayer(id, to: "中文与 English 自定义图层")
        #expect(session.activeLayer?.name == "中文与 English 自定义图层")
        session.duplicateLayers([id])
        #expect(session.activeLayer?.name == String(localized: "\("中文与 English 自定义图层") copy"))
        session.undo()
        #expect(session.activeLayer?.name == "中文与 English 自定义图层")
    }

    @Test func translatedMaskMenuValidationDoesNotDependOnItsTitle() throws {
        let session = EditorSession()
        session.createDocument(width: 32, height: 32, emptyLayer: true)
        let coordinator = NativeLayerList.Coordinator(session: session)
        let item = NSMenuItem(title: "添加蒙版", action: nil, keyEquivalent: "")
        item.identifier = NSUserInterfaceItemIdentifier("addMask")
        item.submenu = NSMenu(title: "添加蒙版")
        #expect(coordinator.validateMenuItem(item))
        session.addMask(revealing: true)
        #expect(!coordinator.validateMenuItem(item))
        session.undo()
        #expect(coordinator.validateMenuItem(item))
    }

    @Test func forkHasAnIndependentIdentityAndNoUpstreamUpdater() {
        #expect(Bundle.main.bundleIdentifier == "io.github.lento52.compositor-cn")
        for key in ["SUFeedURL", "SUPublicEDKey", "SUEnableAutomaticChecks"] {
            #expect(Bundle.main.object(forInfoDictionaryKey: key) == nil)
        }
    }
}
