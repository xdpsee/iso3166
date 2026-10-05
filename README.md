# ISO3166

ISO 3166-1 国家/地区数据的 Swift Package：本地化名称（简体中文 / 繁体中文 / 英文）与国旗图片，零依赖。

## 特性

- **250 个代码**：官方 ISO 3166-1 alpha-2 全集（249 个），外加科索沃（`XK`，用户自定义代码元素）
- **三语名称**：`en` / `zh-Hans` / `zh-Hant`，按系统语言自动解析
- **国旗资源**：250 面 alpha-2 旗帜 + 英国四个构成国（`gb-eng` / `gb-nir` / `gb-sct` / `gb-wls`）
- **完整编码表**：alpha-2 / alpha-3 / numeric / 英文通用名
- **平台支持**：iOS 14+、macOS 11+

## 安装

### Xcode

File → Add Package Dependencies → 输入仓库 URL，或本地路径直接拖入。

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/xdpsee/iso3166.git", from: "1.0.0")
]
```

## 使用

```swift
import iso3166

// 本地化名称（跟随系统语言；未知代码返回 "Unknown"）
ISO3166.countryName(alpha2: "cn")       // en: "China" / zh-Hans: "中国"
ISO3166.countryName(alpha2: "GB")       // 大小写不敏感
ISO3166.countryName(alpha2: "gb-sct")   // "Scotland" / "苏格兰"
ISO3166.countryName(alpha2: "zz")       // "Unknown"

// 国旗图片（iOS 返回 UIImage，macOS 返回 NSImage；未知代码返回 nil）
if let flag = ISO3166.flagImage(alpha2: "de") {
    imageView.image = flag
}

// 完整编码数据
Country.find(alpha2: "us")
// Country(name: "US", alpha2: "US", alpha3: "USA", numeric: "840")

Country.all.count  // 250

// 遍历
for country in Country.all {
    print(country.alpha2, country.alpha3, ISO3166.countryName(alpha2: country.alpha2))
}
```

## 资源管线（贡献者必读）

SwiftPM 不会编译 `.xcstrings` 和 `.xcassets`，因此仓库同时保留**源文件**与**编译产物**（产物参与打包，源文件被 `Package.swift` exclude）。修改资源后必须重新生成：

```bash
./Scripts/build-resources.sh
```

该脚本会生成：

| 源 | 产物 |
|---|---|
| `Localizable.xcstrings` | `{en,zh-Hans,zh-Hant}.lproj/Localizable.strings` |
| `Assets.xcassets` | `Assets.car`（iOS 运行时使用） |
| `Assets.xcassets` | `Resources/Flags/*.png`（macOS 运行时使用，见下） |

国旗的 imageset 只填充 3x 槽位，macOS 平台无法读取 iOS 编译的 `Assets.car`，因此脚本额外导出散装 PNG；`flagImage` 在 iOS 走 asset catalog、在 macOS 按文件加载并还原 3x 逻辑尺寸。

国家编码表由数据集生成，更新时重新运行：

```bash
python3 Scripts/generate-country-data.py
```

## 数据来源

- 编码表：[datasets/country-codes](https://github.com/datasets/country-codes)（ISO 3166-1）
- 科索沃 `XK` 非官方 ISO 分配，`alpha3` 采用常用用户自定义代码 `XXK`，`numeric` 留空

## 测试

```bash
swift test
```

17 项测试覆盖：查询 API、编码表完整性、三语文案目录、国旗加载（macOS 宿主）。

## 目录结构

```
Sources/iso3166/
├── ISO3166.swift              # 公开 API（countryName / flagImage）
├── Models/
│   ├── Country.swift          # 数据模型
│   └── Country+.swift         # 生成的 250 条编码表
└── Resources/
    ├── Localizable.xcstrings  # 翻译源文件
    ├── Assets.xcassets        # 旗帜源文件
    ├── Flags/                 # 编译产物：macOS 用散装 PNG
    └── {en,zh-Hans,zh-Hant}.lproj/ + Assets.car  # 编译产物
Scripts/
├── build-resources.sh         # xcstrings / xcassets 编译管线
└── generate-country-data.py   # 编码表生成器
```
