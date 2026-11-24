# ChatGPT iOS Port (Native Swift / SwiftUI)

Production-grade, native iOS application ported from the official Android APK (`com.openai.chatgpt`, version `1.2026.300`).

## Highlights & Architecture
- **Language & Runtime:** Swift 5.9+ / Swift 6 Strict Concurrency (`@MainActor`, `actor`, `async/await`, `AsyncSequence`).
- **UI Framework:** SwiftUI (`@Observable`, `NavigationStack`, `TimelineView` + `Canvas` Metal shader).
- **Streaming Engine:** Real-time Server-Sent Events (SSE) `/backend-api/f/conversation` streaming parser via `URLSession.AsyncBytes`.
- **Advanced Voice Mode:** LiveKit WebRTC pipeline with real-time `AVAudioRecorder` metering powering the fluid Horizon audio orb visualizer.
- **Data Persistence:** SwiftData models (`DBConversationEntity`, `DBMessageEntity`, `DBMessageChunkEntity`, `DBCalpico*`) replicating Android Room SQLite schema.
- **Security:** Hardware-backed iOS Keychain Services for OAuth tokens (`kSecClassGenericPassword`).
- **Monetization:** StoreKit 2 in-app subscription flow for ChatGPT Plus ($19.99/month).

---

## Automated GitHub Actions CI (.ipa Builder)

This repository includes a preconfigured GitHub Actions workflow:
📁 `.github/workflows/build-ipa.yml`

### How to Build Your `.ipa`:
1. Push this repository to GitHub.
2. In your GitHub repository, navigate to the **Actions** tab.
3. Select the **Build iOS IPA** workflow on the left sidebar.
4. Click **Run workflow** -> choose the branch (e.g., `main`) -> click **Run workflow**.
5. Once the job finishes (~2 minutes on macOS-14 Apple Silicon runner):
   - **Option A (Workflow Artifact):** Download `ChatGPT-iOS-IPA` from the workflow summary page.
   - **Option B (GitHub Release):** If `create_release` was checked, the `.ipa` will be attached directly to a newly published GitHub Release!

### Sideloading the `.ipa` onto your iPhone / iPad:
- **AltStore / SideStore:** Open AltStore, tap `+`, and select `ChatGPT.ipa`.
- **Sideloadly:** Drag `ChatGPT.ipa` into Sideloadly and click Start.
- **TrollStore (iOS 14.0–17.0):** Open `ChatGPT.ipa` directly in TrollStore for permanent signing.
- **Apple Configurator / Xcode:** Connect iPhone via USB, open Xcode -> *Window* -> *Devices and Simulators*, and drag `ChatGPT.ipa` into Installed Apps.

---

## Local Development (Xcode)

To open and run the project locally on macOS:
```bash
open ChatGPT.xcodeproj
```
Select your target device or iOS Simulator (iOS 17.0+) and press `Cmd + R` to build and run.
