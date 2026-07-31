# 專案快速說明 / Project Brief

這份文件是給未來的 AI 或新協作者快速了解專案用的。  
如果你開新對話，可以先叫 AI：「請先讀 `AGENTS.md`」。

This file helps future AI sessions or new collaborators quickly understand the project.  
When starting a new chat, ask the AI to read `AGENTS.md` first.

## 這是什麼專案 / What This Is

StrayAnimals 是一個 iOS App，用來瀏覽台灣農業部 Open Data 裡的流浪動物認養資料。

StrayAnimals is an iOS app for browsing Taiwan stray animal adoption data from the Ministry of Agriculture Open Data API.

這個 App 使用 Swift 開發，畫面是 UIKit + 程式化 UI，架構主要是 MVVM + Combine。目前主要支援 iPhone 直向畫面。

The app is written in Swift with UIKit, programmatic UI, MVVM, and Combine. It currently focuses on iPhone portrait layouts.

## 產品畫面 / Product Surface

- 主畫面：顯示動物列表、分類篩選、「今日更新」橫向區塊，以及可以往下載入更多資料的主要列表。
- Main screen: animal list, category filters, a horizontal "today updated" section, and a paged main list.

- 詳細頁：顯示動物照片、簡介、目前狀態、基本資料、收容所資訊、備註、打開地圖、撥打電話，以及分享圖片。
- Detail screen: animal photo, summary, status, attributes, shelter information, notes, map/call actions, and share image generation.

- 公開文件：`docs/` 裡有支援頁、隱私權頁、App Review 備註等靜態網頁。
- Public docs: static support, privacy, and App Review note pages live in `docs/`.

## 架構 / Architecture

- App 入口：`StrayAnimals/SceneDelegate.swift` 建立 `UINavigationController`，第一個畫面是 `ListViewController`。
- Entry point: `StrayAnimals/SceneDelegate.swift` creates a `UINavigationController` with `ListViewController`.

- UI 層：畫面使用 UIKit，用 Swift 程式碼建立，不主要依賴 storyboard。Auto Layout 使用 SnapKit。
- UI layer: UIKit views and view controllers are built programmatically. SnapKit is used for Auto Layout.

- 狀態流：ViewModel 使用 Combine 提供 input/output。ViewController 把使用者事件送進 input，並監聽 output 更新畫面、loading、錯誤提示和導航。
- State flow: ViewModels expose Combine inputs/outputs. ViewControllers send user events into inputs and observe outputs for UI updates, loading states, alerts, and navigation.

- 網路流程：`WebService` 接收一個 `EndpointType`，建立 `URLRequest`，檢查 HTTP/JSON 回應，用 `JSONDecoder.apiDefault` 解碼，並把錯誤轉成 `WebServiceError`。
- Network flow: `WebService` accepts an `EndpointType`, builds a `URLRequest`, validates HTTP/JSON responses, decodes with `JSONDecoder.apiDefault`, and maps failures to `WebServiceError`.

- 資料來源：`StrayAnimalList` 呼叫 `https://data.moa.gov.tw/Service/OpenData/TransService.aspx`，並帶上 `UnitId=QcbUEzN6E6DL`。
- Data source: `StrayAnimalList` calls `https://data.moa.gov.tw/Service/OpenData/TransService.aspx` with `UnitId=QcbUEzN6E6DL`.

- 圖片：`ImageLoader` 會把原始圖片網址轉成 ImageKit 的縮圖網址，並用 `NSCache` 做記憶體快取。也有保留載入原圖並自己 downsample 的方法。
- Images: `ImageLoader` converts original image URLs into ImageKit resized URLs and keeps an in-memory `NSCache`. Original image loading/downsampling also exists.

- Mock：網路 client 可以透過 `APIClientProtocol` 注入，所以可以用 `MockLoader` 讀本地 mock JSON。
- Mocking: network clients can be injected through `APIClientProtocol`, so `MockLoader` can read local mock JSON.

## 重要檔案 / Key Files

- `README.md`：給人看的專案簡介。
- `README.md`: human-facing project overview.

- `StrayAnimals/SceneDelegate.swift`：App 啟動後建立第一個畫面。
- `StrayAnimals/SceneDelegate.swift`: app root setup.

- `StrayAnimals/Model/PetData.swift`：API 回傳的動物資料 model。
- `StrayAnimals/Model/PetData.swift`: API response model for animal records.

- `StrayAnimals/Model/AnimalEnum.swift`：動物種類、性別、年齡、地區、收容所、狀態等 enum 和顯示文字 helper。
- `StrayAnimals/Model/AnimalEnum.swift`: domain enums and display helpers for animal fields, shelters, areas, categories, and status.

- `StrayAnimals/Main/ListView/ListViewController.swift`：主列表畫面，包含 collection view、diffable data source，以及點選後前往詳細頁。
- `StrayAnimals/Main/ListView/ListViewController.swift`: compositional collection view, diffable data source, and navigation to detail.

- `StrayAnimals/Main/ListView/ListViewModel.swift`：主列表資料邏輯，包含分類、分頁、重新載入、載入更多、今日更新，以及把 `PetData` 轉成 cell view model。
- `StrayAnimals/Main/ListView/ListViewModel.swift`: category setup, paging, reload/load-more flow, today-updated request, and mapping `PetData` to list item view models.

- `StrayAnimals/Main/PetInformationView/PetInformationViewController.swift`：詳細頁 UI，包含收容所按鈕、分享圖片等互動。
- `StrayAnimals/Main/PetInformationView/PetInformationViewController.swift`: detail UI, shelter actions, and share image creation.

- `StrayAnimals/Main/PetInformationView/PetInformationViewModel.swift`：把 `PetData` 整理成詳細頁要顯示的資料，並載入詳細圖片。
- `StrayAnimals/Main/PetInformationView/PetInformationViewModel.swift`: maps `PetData` into detail view data and loads detail images.

- `StrayAnimals/WebService/WebService.swift`：使用 Combine 實作的 API client。
- `StrayAnimals/WebService/WebService.swift`: Combine-based API client.

- `StrayAnimals/WebService/NetWork/APIEndpoint.swift`：API endpoint protocol 和各 endpoint 定義。
- `StrayAnimals/WebService/NetWork/APIEndpoint.swift`: endpoint protocol and endpoint definitions.

- `StrayAnimals/WebService/NetWork/Query/StrayAnimalListQuery.swift`：Open Data 查詢參數、分頁、分類篩選。
- `StrayAnimals/WebService/NetWork/Query/StrayAnimalListQuery.swift`: Open Data query parameters, paging, and category filtering.

- `StrayAnimals/WebService/ImageLoader.swift`：ImageKit URL 轉換、圖片下載、downsample、快取、共用下載中的 request。
- `StrayAnimals/WebService/ImageLoader.swift`: ImageKit URL conversion, image downloading, downsampling, caching, and in-flight request sharing.

- `StrayAnimals/Mock/PetDataMockJSON.json`：本地假資料。
- `StrayAnimals/Mock/PetDataMockJSON.json`: mock API response data.

- `StrayAnimals/Extensions/`：UIKit 和 Foundation 的 extension helper。
- `StrayAnimals/Extensions/`: UIKit and Foundation helpers.

- `StrayAnimals/Utilities/`：共用 UI 工具，例如字體、badge、loading、reusable view 等。
- `StrayAnimals/Utilities/`: reusable UI utilities such as fonts, badges, loading, and reusable view support.

## 如何執行 / How To Run

- 用 Xcode 打開專案：
- Open the project in Xcode:

```sh
open StrayAnimals.xcodeproj
```

- 查看 Xcode 專案資訊：
- List project metadata:

```sh
xcodebuild -list -project StrayAnimals.xcodeproj
```

- 用 command line build：
- Build from CLI:

```sh
xcodebuild -project StrayAnimals.xcodeproj -scheme StrayAnimals -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

目前只有一個 app target，名稱是 `StrayAnimals`。設定有 `Debug` 和 `Release`。Scheme 也是 `StrayAnimals`。

There is currently one app target, `StrayAnimals`, with Debug and Release configurations. The shared scheme is `StrayAnimals`.

## 依賴 / Dependencies

- Swift Package Manager:
  - SnapKit 5.7.1

- 外部服務 / External services:
  - 農業部 Open Data API / Ministry of Agriculture Open Data API
  - ImageKit.io 圖片代理 / ImageKit.io image proxy: `https://ik.imagekit.io/mini8`

## 目前限制與注意事項 / Current Constraints

- `README.md` 說目前只支援 iPhone 直向畫面。
- `README.md` says only iPhone portrait is supported for now.

- 初次掃描專案時，沒有看到 test target。
- No test target was visible during the initial project scan.

- 政府 API 的日期格式有混用；如果要改日期解碼，應該先看 `JSONDecoder.apiDefault`。
- Government API date fields use mixed formats; check `JSONDecoder.apiDefault` before changing date decoding.

- `StrayAnimalListQuery.setCategory` 會先清掉所有查詢條件，再套用新的分類。改分類或查詢時，要注意分頁設定不要被弄壞。
- `StrayAnimalListQuery.setCategory` clears all query fields, then applies the chosen category. Preserve paging setup after changing filters.

- List 畫面同時保存完整的 `PetData` 和較輕量的 cell view model，因為進詳細頁時需要完整資料。
- List view keeps both full `PetData` arrays and lightweight cell view models because detail navigation needs the original record.

- 點進詳細頁時，會同時從 `todayPets` 和主要列表 `pets` 裡找資料。
- `todayPets` and main `pets` are both searched when opening detail.

- ImageKit URL 的轉換假設「只靠原始圖片檔名」就能找到代理後的圖片。
- ImageKit URL building assumes source image filenames are enough to locate transformed images.

## 寫程式時的習慣 / Coding Conventions

- 優先沿用目前的 MVVM + Combine input/output pattern。
- Prefer the existing MVVM + Combine input/output pattern.

- 新增需要測試或替換的邏輯時，優先用 protocol 做 dependency injection。
- Prefer dependency injection through protocols for network/image behavior when adding testable code.

- UI 維持 UIKit + SnapKit + 程式化 UI 的風格。
- Keep UI programmatic and consistent with the existing UIKit/SnapKit style.

- 新增顏色、圖片、字體或 UI helper 前，先看現有 asset、`FontGroup`、UIKit extensions 是否已經有可用的東西。
- Use existing color assets, image assets, `FontGroup`, and UIKit extensions before adding new styling helpers.

- 註解保持短而有用。專案裡很多註解是中文，可以延續這個風格。
- Keep comments useful and short. Many files already use Chinese comments, so continuing that style is fine.

## 未來 AI 對話的建議閱讀順序 / Useful Starting Points For Future AI Sessions

1. 先讀這份 `AGENTS.md`。
2. 再讀 `README.md`，確認產品方向。
3. 如果問題跟主列表有關，讀 `ListViewModel.swift`，再讀 `ListViewController.swift`。
4. 如果問題跟詳細頁有關，讀 `PetInformationViewModel.swift`，再讀 `PetInformationViewController.swift`。
5. 如果問題跟 API 或 decode 有關，讀 `APIEndpoint.swift`、`StrayAnimalListQuery.swift`、`RequestBuilder.swift`、`URLFactory.swift`、`JSONDecoder.swift`、`WebService.swift`。
6. 如果問題跟圖片有關，讀 `ImageLoader.swift` 和會呼叫它的 item/card view model。

1. Read this `AGENTS.md` file first.
2. Read `README.md` for the product summary.
3. For list behavior, inspect `ListViewModel.swift` then `ListViewController.swift`.
4. For detail behavior, inspect `PetInformationViewModel.swift` then `PetInformationViewController.swift`.
5. For API or decoding issues, inspect `APIEndpoint.swift`, `StrayAnimalListQuery.swift`, `RequestBuilder.swift`, `URLFactory.swift`, `JSONDecoder.swift`, and `WebService.swift`.
6. For image issues, inspect `ImageLoader.swift` and the item/card view models that call it.

## 你可以之後自己補的內容 / Things You Can Add Later

如果你之後想讓 AI 更快進入狀況，可以補這些：

- 最近正在做什麼功能。
- 哪些檔案先不要動。
- 哪些 bug 還沒修。
- App Store / TestFlight / release 相關流程。
- 你希望 AI 寫 code 時遵守的個人偏好。
- 常用 simulator、iOS 版本、Xcode 版本。
- 重要決策：為什麼用這個架構、為什麼某些地方先不重構。

You can add these later to help future AI sessions:

- Current feature work.
- Files that should not be changed yet.
- Known bugs.
- App Store, TestFlight, or release process notes.
- Your personal coding preferences for AI.
- Common simulator, iOS version, or Xcode version.
- Important decisions: why the current architecture exists, or why some areas should not be refactored yet.
