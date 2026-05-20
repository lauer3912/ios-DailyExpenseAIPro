# AppStore Screenshots

This directory contains all required App Store screenshots for Daily Expense AI Pro.

## Screenshot Requirements

Apple requires screenshots for each device size. All screenshots must be:
- Actual app screenshots (not marketing mockups)
- Exactly the specified dimensions
- In PNG format
- Without device frame/bezel

## Directory Structure

```
Screenshots/
├── iPhone_69_1290x2796/    # iPhone 15 Pro Max, 6.9"
│   ├── 01_Dashboard.png
│   ├── 02_Transactions.png
│   ├── 03_AddTransaction.png
│   ├── 04_Analytics.png
│   ├── 05_Settings.png
│   └── 06_Subscription.png
├── iPhone_65_1284x2778/    # iPhone 14 Pro Max, 6.5"
│   └── [same 6 files]
├── iPhone_63_1206x2622/    # iPhone 14 Pro, 6.3"
│   └── [same 6 files]
├── iPad_13_2048x2732/      # iPad Pro 12.9"
│   └── [same 6 files]
├── iPad_11_1668x2388/      # iPad Pro 11", iPad Air
│   └── [same 6 files]
├── InAppPurchase/          # Apple REQUIRED for IAP review
│   ├── IAP_Monthly_订阅按钮.png
│   ├── IAP_Monthly_购买界面.png
│   └── IAP_Monthly_恢复购买.png
└── README.md               # This file
```

## Screenshot Specifications

| Device | Dimensions | Aspect Ratio |
|--------|-----------|--------------|
| iPhone 6.9" (15 Pro Max) | 1290×2796 | 19.5:9 |
| iPhone 6.5" (14 Pro Max) | 1284×2778 | 19.5:9 |
| iPhone 6.3" (14 Pro) | 1206×2622 | 19.5:9 |
| iPad Pro 12.9" | 2048×2732 | 4:3 |
| iPad Pro 11" / Air | 1668×2388 | 4:3 |

## Required Screenshots Per Device

| # | Screen | Description |
|---|--------|-------------|
| 1 | Dashboard | Main overview showing balance and recent transactions |
| 2 | Transactions | Full transaction list with search/filter |
| 3 | Add Transaction | Add new expense/income form |
| 4 | Analytics | Charts showing spending breakdown |
| 5 | Settings | App settings and preferences |
| 6 | Subscription | Premium subscription upsell screen |

## In-App Purchase Screenshots

Apple **REQUIRES** at least 1 screenshot per in-app purchase product:
- Must show the purchase interface
- Must be in English
- Size: Same as regular screenshots (1290×2796 for iPhone)

**Files:**
- `IAP_Monthly_订阅按钮.png` -- Shows subscription button
- `IAP_Monthly_购买界面.png` -- Shows purchase modal
- `IAP_Monthly_恢复购买.png` -- Shows restore purchase option

## Generation

Screenshots are generated via XCUITest:
```bash
cd ~/Desktop/ios-DailyExpenseAIPro
xcodebuild test -scheme DailyExpenseAIProUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max'
```

Screenshots are downloaded via SCP and placed in appropriate directories.

## Verification

After generation, verify:
1. MD5 hash of each screenshot is unique (no duplicates)
2. Dimensions match specification exactly
3. Human reviews each screenshot for correctness
