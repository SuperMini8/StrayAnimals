# App Store 審查資訊（App Review Information）

這份文件是**每次送審都要用的常備資料**，不是一次性的補件稿。

App Store Connect 的「App 審查資訊 → 備註（Notes）」與「解決中心（Resolution Center）」
兩個欄位都是 **4,000 字元上限**，兩處貼同一份，就是下方的〈正式版 Notes〉。

---

## 送審速查

| # | 事項 | 貼／放哪裡 |
|---|---|---|
| 1 | 〈正式版 Notes〉全文 | App 審查資訊 → 備註（Notes） |
| 2 | 同上全文 + 影片說明開頭句 | 解決中心（僅在被退件、需要回覆時） |
| 3 | 實機錄影 | App 審查資訊 → 附件（Attachment）；被退件時另外附在解決中心訊息裡 |
| 4 | 登入資訊 | 免填，本 App 無帳號系統 |
| 5 | 聯絡資訊 | PIN-YU YEH / superminieight@gmail.com |

送審前先跑一次〈送審前檢查清單〉，並確認〈事實對照表〉裡有沒有因為改 code 而失效的句子。

---

## 正式版 Notes

**3,483 字元**（上限 4,000）。修改後務必重新計算：

```bash
python3 -c "import re;t=open('docs/app-review-notes.md',encoding='utf-8').read();print(len(re.search(r'BEGIN NOTES -->\n(.*?)\n<!-- END NOTES',t,re.S).group(1)),'字元')"
```

<!-- BEGIN NOTES -->
1. DEMO ACCOUNT
Not applicable. No account system: no registration, no login, no account deletion. All features work immediately after launch.

2. TESTED DEVICES
Physical devices: iPhone 15 (iOS 26.5) and iPhone SE 2nd generation (iOS 18.6.2). The full user flow was verified on both, covering the latest OS and the smallest supported screen. Minimum OS iOS 15.0; iPhone only; portrait only.

3. PURPOSE AND AUDIENCE
"浪浪想找家" (Stray Animals) helps people in Taiwan find adoptable shelter animals. It presents the Taiwan Ministry of Agriculture's public animal-adoption Open Data as a fast, filterable mobile list, solving the fact that the government portal is hard to browse on a phone, cannot be filtered, and serves oversized images. Audience: the general public in Taiwan considering adopting a dog or cat, and rescue volunteers. No user-generated content, advertising, in-app purchase or subscription.

4. SETUP AND MAIN FEATURES
No setup, login or sample files needed; just launch with a network connection.
- The adoption list loads automatically; scrolling down loads the next page.
- Category chips filter the list: All / Dog / Cat / Other / Young / Adult.
- Tapping a card opens the detail page: photo, adoption status, sterilization and rabies-vaccination status, location found, adoption opening date, shelter name, address and phone, and remarks.
- Detail page actions: "Open map" passes the shelter's public address to Apple Maps (no navigation is started); "Call shelter" opens its public phone number in the Phone app; "Share" renders the page as an image into the standard iOS share sheet.
PERMISSIONS: none are requested. There is no location, contacts, camera, photo library, microphone, notification or App Tracking Transparency prompt anywhere. Core Location and Contacts are not linked, Info.plist has no usage-description keys, and the privacy manifest declares no collected data and no tracking.

5. EXTERNAL SERVICES
- Taiwan Ministry of Agriculture Open Data API (data.moa.gov.tw): public, unauthenticated shelter-animal dataset. No API key; no user data sent.
- ImageKit.io: image optimisation and CDN proxy only, resizing photos already published publicly in that dataset. Only the public image filename is sent; not used for accounts, user content, analytics, advertising or personal data.
- Apple Maps and the system Phone app, opened via standard URLs.
- Only third-party library: SnapKit (Auto Layout).
No authentication service, payment processor, advertising SDK, analytics SDK, AI service, or backend server of our own is used.

6. REGIONAL DIFFERENCES
None. No geo-fencing and no region-based feature or content gating; the app behaves identically in every storefront. The dataset is Taiwan government shelter data, so listed animals are in Taiwan. The interface is Traditional Chinese because the source data is published in Traditional Chinese only.

7. REGULATED INDUSTRY / PROTECTED MATERIAL
Not applicable. All data and images come from the Taiwan Ministry of Agriculture Open Data Platform, released under the Open Government Data License Version 1.0, which permits reuse with attribution. The attribution and licence link are published on our support page and privacy policy. No protected third-party copyrighted material is included. Icons are from Lucide, Bootstrap Icons and Phosphor Icons (ISC / MIT).

Privacy policy: https://supermini8.github.io/StrayAnimals/privacy.html
Support: https://supermini8.github.io/StrayAnimals/support.html
<!-- END NOTES -->

---

## 事實對照表

**這是這份文件最重要的部分。**

- **左欄**＝Notes 目前的宣稱，也就是**專案現況**。
- **中欄**＝這句話在專案裡的依據，要驗證就去看這個檔案。
- **右欄**＝**假設性的**未來改動。一旦做了，左欄那句就失效，必須回來改 Notes。
  右欄寫的都**還沒發生**。

Notes 與送審 binary 不符的話，審查員一比對就會退件，所以每次送審前逐列掃一遍。

| Notes 的宣稱（現況） | 依據 | 日後若做了這件事 → 左欄失效 |
|---|---|---|
| 無帳號系統、無登入 | 專案無任何認證相關程式 | 加入登入、會員、收藏同步 |
| 不要求任何權限 | `StrayAnimals/Info.plist` 無任何 `NS*UsageDescription`；`PrivacyInfo.xcprivacy` 三個陣列皆空 | 新增任何權限描述鍵 |
| 未連結 Core Location / Contacts | 全專案無 `import MapKit` / `import Contacts` / `CLLocationManager` | 改用內嵌地圖或取得定位 |
| 地圖以標準 URL 開啟、不啟動導航 | `PetInformationViewModel.makeMapURL()` 產生 `https://maps.apple.com/?q=` | 改回 `MKMapItem.openInMaps()`（build 1 的作法） |
| 撥號交給系統電話 App | `PetInformationViewModel.makeCallURL()` 產生 `tel://` | 改成 App 內撥號 |
| 分享是本機截圖、不上傳 | `PetInformationViewController.makeShareImage()` + `UIActivityViewController` | 改成上傳伺服器再分享 |
| 資料來自 data.moa.gov.tw、無金鑰 | `WebService/NetWork/ServiceHost.swift`、`APIEndpoint.swift` | 換資料源或加上認證 |
| ImageKit 僅做圖片壓縮代理 | `WebService/ImageLoader.swift`（`ik.imagekit.io/mini8`） | 換 CDN、或改用 ImageKit 儲存 |
| 唯一第三方套件是 SnapKit | `StrayAnimals.xcodeproj/project.pbxproj` 的 SPM 相依 | 新增任何套件／SDK |
| 六種分類 All/Dog/Cat/Other/Young/Adult | `Main/ListView/CategoryItemViewModel.swift` 的 `ListCategory` | 增減分類項目 |
| iPhone only、僅直向 | `TARGETED_DEVICE_FAMILY = 1`、`INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = Portrait` | 支援 iPad 或橫向 |
| 最低支援 iOS 15.0 | `IPHONEOS_DEPLOYMENT_TARGET = 15.0` | 調整部署目標 |
| 介面為繁體中文 | 字串硬編於程式中，`en.lproj/Localizable.strings` 為空 | 真的做英文在地化後要改寫第 6 點 |
| 授權標示在支援頁與隱私權頁 | `docs/support.html`、`docs/privacy.html` | 網頁改版時別把授權段落刪掉 |

---

## 什麼情況要更新這份文件

- **換測試機或換 iOS 版本** → 第 2 點。實機型號與版本必須是真的跑過的。
- **新增／移除任何第三方服務、SDK、套件** → 第 5 點。
- **新增任何權限請求** → 第 4 點的 PERMISSIONS 整段要重寫，且 `PrivacyInfo.xcprivacy` 要同步。
- **新增功能或改變主要流程** → 第 4 點，並重錄影片。
- **支援 iPad 或橫向** → 第 2 點。
- **加入付費、訂閱、帳號、UGC** → 第 1、3 點會整段改寫，且 Apple 會用完全不同的審查標準。
- **網站網址變更** → 第 7 點結尾兩行。
- 每次改完，**重新計算字元數**並確認未超過 4,000。

---

## 追問備援段落

正式版為了壓字數寫得精簡。審查員若針對某一項追問，可直接貼下面對應的完整說明。

**若追問 ImageKit（對應第 5 點）**

> ImageKit.io is used solely as an image optimisation and CDN delivery proxy. It resizes and compresses the animal photos that the government dataset already publishes publicly (originals are 768x768 and load too slowly on mobile networks). ImageKit is used only for real-time image optimisation and delivery; it does not modify the original data and does not provide any of the app's content. Only the public image filename is sent to ImageKit. It is not used for user accounts, user-generated content, analytics, advertising, or storage of any personal data. ImageKit is infrastructure, not a content provider — copyright in the images remains with the Ministry of Agriculture Open Data Platform.

**若追問權限或隱私（對應第 4 點）**

> The app requests no sensitive data and no device capabilities. There is no location, contacts, camera, photo library, microphone, notification, or App Tracking Transparency prompt anywhere in the app. The app does not link against Core Location or the Contacts framework, and never calls requestWhenInUseAuthorization() or any equivalent API. The Info.plist contains no usage-description keys, and the app's privacy manifest declares no collected data types and no tracking. The app operates no backend server of its own and stores no user data.

**若追問資料授權（對應第 7 點）**

> The app displays publicly available stray-animal information and images provided by the Taiwan Ministry of Agriculture Open Data Platform. That dataset is published under the Taiwan Government Open Data License, Version 1 (政府資料開放授權條款 第1版), which permits both commercial and non-commercial reuse in accordance with its terms, including redistribution, provided the source is attributed. Attribution to the Ministry of Agriculture Open Data Platform, together with a link to the licence, is published on our support page and in our privacy policy. The app does not include protected third-party copyrighted material that would require additional authorisation.

**若追問 App 價值或目標客群（對應第 3 點）**

> Problem it solves: the government Open Data portal and individual shelter web pages are difficult to browse on a phone, offer no convenient filtering, and serve very large images that load slowly over mobile networks. This app turns that raw public dataset into a fast, readable list with photos, adoption status, and one-tap contact to the shelter. Value provided: it lowers the barrier to adopting a shelter animal by making public adoption information easy to browse, easy to understand, easy to share, and directly actionable.

---

## 實機錄影腳本

Apple 要求 **physical device + latest OS**，所以用 **iPhone 15**（目前搭載最新 iOS 的那台）錄，
**不能用模擬器**，也不要用 Mac 的螢幕錄影去錄模擬器或 QuickTime 鏡像畫面。

用 iOS 內建螢幕錄製（控制中心的紅色錄影鈕），錄完直接存在相簿，AirDrop 傳到 Mac。
檔名會長這樣：`ScreenRecording_MM-DD-YYYY HH-MM-SS_1.MP4`。

一鏡到底、不要剪接。約 60–90 秒：

1. 從 iPhone **主畫面點 App 圖示啟動**（一定要從這裡開始，Apple 明文要求）
2. 等列表載入，往下捲幾頁 → 展示自動載入下一頁
3. 點任一張卡片進入詳細頁
4. 詳細頁往下捲，展示動物資訊、收容資訊、補充說明各區塊
5. 點「分享」→ 錄到 iOS 分享選單跳出（選一個 App 進去也可以，能證明圖片真的產出）
6. 回到詳細頁，點「聯絡收容所」→ 錄到系統撥號對話框 → 取消
7. 點「查看地圖」→ 錄到 Apple Maps 開啟並顯示**正確地址** → 切回 App
8. 返回列表，依序點「狗」→「貓」→「幼年」→「其他」展示篩選
9. 結束

錄完自我檢查：有沒有從主畫面開始？三個動作（分享／電話／地圖）都錄到了嗎？
地圖顯示的是正確地址而不是 (0,0) 外海嗎？

檔案 25MB 以內可直接上傳。過大時壓縮：

```bash
ffmpeg -i input.MP4 -vf "scale=-2:1280" -c:v libx264 -crf 26 -preset slow -c:a aac -b:a 96k -movflags +faststart review-demo.mp4
```

---

## 送審前檢查清單

兩台實機都要跑過：

- [ ] 冷啟動不閃退
- [ ] 農業部 API 正常回傳、列表與圖片正常載入
- [ ] 六種分類切換都正常
- [ ] 捲到底自動載入下一頁正常
- [ ] 詳細頁各區塊正常顯示
- [ ] 查看地圖 → Apple Maps 顯示正確地址（不是 (0,0) 外海）
- [ ] 聯絡收容所 → 系統撥號畫面正常
- [ ] 分享 → 截圖內容正確、分享選單正常
- [ ] 飛航模式下 API 失敗不會崩潰
- [ ] 背景切回前景後仍可操作
- [ ] **SE2 專屬**：4.7 吋窄螢幕下卡片、分類列、詳細頁底部按鈕沒有截斷或重疊
- [ ] **SE2 專屬**：舊系統上分享截圖產出正常（不是空白圖）

文件面：

- [ ] 〈事實對照表〉逐列確認，這版有沒有讓哪句話失效
- [ ] Notes 字元數 ≤ 4,000
- [ ] 支援頁與隱私權頁已 push，且線上版本是最新的（開無痕確認）
- [ ] 影片是實機錄的、涵蓋所有核心功能

---

## 常見錯誤

1. **不要寫 "navigate to the shelter"** — 目前只是開啟地址頁面，不是啟動導航。
2. **不要寫 "No third-party cloud services are used"** — ImageKit 在核心圖片路徑上，必須誠實列出。
3. **不要把模擬器寫成 device models** — Apple 要 physical device，寧可誠實寫一台，也不要虛構多台。
4. **不要為了 ImageKit 去準備授權文件** — 它是基礎設施，不主張內容所有權，第 7 點只談 Open Data 授權即可。
5. **不要宣稱有英文介面** — `en.lproj/Localizable.strings` 目前是空的，介面實際只有繁中。

---

## 已知待辦

- **App 內未標示資料來源。** 政府資料開放授權條款第 1 版要求利用時註明提供機關，
  目前僅在支援頁與隱私權頁標示，App 介面內沒有。建議下個版本在列表頁底部或詳細頁
  加一行「資料來源：農業部資料開放平台」。第 7 點屆時可改寫成 attribution 也顯示在 App 內。
- **導覽列標題「流浪動物」與 App 名稱「浪浪想找家」不一致。** 這次未被指出，
  但建議統一，避免審查員認為畫面與 metadata 對不上。

---

## 變更紀錄

| 日期 | 版本 | 事由 |
|---|---|---|
| 2026-07-28 | 1.0.0 (2) | 首次送審遭 Guideline 2.1 Information Needed 退件，建立本文件回覆七項提問。同時補強 `docs/support.html`、`docs/privacy.html`：加上聯絡信箱與開發者資訊、具名列出第三方服務、標示開放資料授權、改為中英對照。地圖實作已於 commit `7e24745` 由 `MKPlacemark` + `openInMaps()` 改為 `https://maps.apple.com/?q=` URL，MapKit 與 Contacts 已移除。 |
