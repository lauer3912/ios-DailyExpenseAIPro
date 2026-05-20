# How to Submit to App Store Connect -- Daily Expense AI Pro

> **App:** Daily Expense AI Pro | **Bundle ID:** com.ggsheng.DailyExpenseAIPro | **Version:** 1.0.0
> **Last Updated:** 2026-05-20

---

## Step 1: Prepare Build

1. Ensure latest code is on MacinCloud:
   ```bash
   cd ~/Desktop/ios-DailyExpenseAIPro && git pull origin main
   ~/xcodegen/bin/xcodegen generate
   ```

2. Build verification (Agent via SSH):
   ```bash
   xcodebuild -project DailyExpenseAIPro.xcodeproj -scheme DailyExpenseAIPro \
     -configuration Debug -destination 'generic/platform=iOS Simulator' build
   ```

3. **Archive via VNC** (Human only):
   - Open Xcode → Product → Archive → Distribute App → App Store Connect → Upload
   - Human tells Agent result

---

## Step 2: App Store Connect Configuration

Navigate to: https://appstoreconnect.apple.com → Apps → Daily Expense AI Pro

### 2.1 App Information

| Field | Value |
|-------|-------|
| Default Language | English |
| Name | Daily Expense AI Pro |
| Subtitle | Smart Expense Tracker |
| Category | Finance |
| Primary Category | Finance |
| Secondary Category | (None) |
| Age Rating | 4+ |

### 2.2 Pricing and Availability

| Field | Value |
|-------|-------|
| Price Schedule | Free (with In-App Purchase) |
| Availability | All territories |

### 2.3 App Privacy

| Field | Value |
|-------|-------|
| Privacy Policy | Required - URL to hosted PrivacyPolicy.html |
| Data Collection | No data collection - all local |

**Privacy Details:**
- **Health & Fitness:** No
- **Location:** No
- **Contact Info:** No
- **Identified Users:** No
- **Browsing History:** No
- **Purchases:** Yes (In-App Purchase subscription)
- **Crash Data:** No
- **Performance Data:** No
- **Advertising Data:** No

---

## Step 3: App Store Listing

### 3.1 Localized Info (English)

**Promotional Text** (optional):
```
Smart AI-powered expense tracking. See where your money goes.
```

**Description** -- Copy from `AppStore/Description.txt`:
```
[Full description in Description.txt -- approximately 4000 characters]
```

**Keywords:**
```
expense,tracker,budget,money,finance,accounting,income,ai,smart,categories
```

**Support URL:** https://github.com/lauer3912/ios-DailyExpenseAIPro

### 3.2 Screenshots

Upload from `AppStore/Screenshots/` directory:

| Device | Size | Count | Files |
|--------|------|-------|-------|
| iPhone 6.9" | 1290×2796 | 6 | 01_Dashboard.png, 02_Transactions.png, 03_AddTransaction.png, 04_Analytics.png, 05_Settings.png, 06_Subscription.png |
| iPhone 6.5" | 1284×2778 | 6 | Same as above |
| iPhone 6.3" | 1206×2622 | 6 | Same as above |
| iPad 13" | 2048×2732 | 6 | Same as above |
| iPad 11" | 1668×2388 | 6 | Same as above |

**In-App Purchase Screenshots** (REQUIRED by Apple):
| Device | Size | Files |
|--------|------|-------|
| iPhone 6.9" | 1290×2796 | IAP_Monthly_订阅按钮.png, IAP_Monthly_购买界面.png, IAP_Monthly_恢复购买.png |

### 3.3 App Icon

1024×1024 App Store Icon from `AppStore/Assets/Icon/Icon-1024@1x.png`

---

## Step 4: Build Selection

After upload, select the build:
- Build **version 1.0.0** with status "Ready to Submit"

---

## Step 5: Certification

| Field | Value |
|-------|-------|
| Export Compliance | No |
| Ads Identifier | No |

---

## Step 6: Submit for Review

1. Click **Add for Review**
2. Confirm all information
3. Submit

---

## Quick Reference -- Daily Expense AI Pro App Store Content

All detailed content is in `AppStore/Listing.md`:
- Full description text
- Keywords list
- Screenshot specifications
- Version history

**Privacy Policy:** `AppStore/PrivacyPolicy.html` -- host and provide URL

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build not appearing | Wait 5-10 minutes after upload |
| Screenshots wrong size | Must match exact dimensions per device |
| Missing screenshots | Run UITests to capture: `xcodebuild test -scheme DailyExpenseAIProUITests` |
| Privacy policy required | Host AppStore/PrivacyPolicy.html and enter URL |
| IAP screenshots missing | Apple requires at least 1 screenshot per in-app purchase product |
