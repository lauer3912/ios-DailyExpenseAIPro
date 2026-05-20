# Daily Expense AI Pro -- Developer Guide

> **App:** Daily Expense AI Pro | **Bundle ID:** com.ggsheng.DailyExpenseAIPro
> **Last Updated:** 2026-05-20

---

## Project Structure

```
ios-DailyExpenseAIPro/
├── Sources/                    # Main app Swift source files
├── Widgets/                    # Widget extension
├── Assets.xcassets/            # App assets (icons, colors)
├── AppStore/
│   ├── Assets/
│   │   ├── Icon/              # 1024x1024 icon + 19 sizes
│   │   └── UI/                # UI mockups + README.md
│   ├── Docs/
│   │   └── FeatureList.md     # 65 features
│   ├── Screenshots/
│   │   ├── iPhone_69_1290x2796/    # 6 screenshots
│   │   ├── iPhone_65_1284x2778/    # 6 screenshots
│   │   ├── iPhone_63_1206x2622/    # 6 screenshots
│   │   ├── iPad_13_2048x2732/       # 6 screenshots
│   │   ├── iPad_11_1668x2388/       # 6 screenshots
│   │   ├── InAppPurchase/           # 3 IAP screenshots
│   │   └── README.md
│   ├── Listing.md              # App Store metadata
│   ├── Description.txt         # Full description (~4000 chars)
│   ├── PrivacyPolicy.html      # Hosted privacy policy
│   ├── HOW-TO.md               # This file
│   └── HOW-TO-AppStoreConnect.md  # Step-by-step submission guide
├── project.yml                 # XcodeGen configuration
└── DailyExpenseAIPro.xcodeproj/
```

---

## Build Commands

### Generate Project (after code changes)
```bash
cd ~/Desktop/ios-DailyExpenseAIPro
~/xcodegen/bin/xcodegen generate
```

### Debug Build (no signing)
```bash
xcodebuild -project DailyExpenseAIPro.xcodeproj -scheme DailyExpenseAIPro \
  -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

### Clean + Rebuild
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/DailyExpenseAIPro-*
~/xcodegen/bin/xcodegen generate
xcodebuild clean
xcodebuild -project DailyExpenseAIPro.xcodeproj -scheme DailyExpenseAIPro \
  -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

### Archive (VNC Human Only)
```
Product → Archive → Distribute App → App Store Connect → Upload
```

---

## Git Workflow

1. Agent makes code changes locally
2. Agent commits + pushes to GitHub
3. Agent SSH to MacinCloud: `git pull origin main`
4. Agent runs xcodegen + build verification
5. Human VNC archive + upload

---

## In-App Purchases

| Product ID | Type | Price |
|------------|------|-------|
| com.ggsheng.DailyExpenseAIPro.premium_monthly | Auto-Renewable | $4.99/mo |
| com.ggsheng.DailyExpenseAIPro.premium_yearly | Auto-Renewable | $39.99/yr |

**Subscription Group:** premium_group
**Free Trial:** 3 days

---

## Features (65 Total)

### Core Tracking (15)
1. Add expense with amount, category, date, note
2. Add income with amount, category, date, note
3. Edit existing transactions
4. Delete transactions (with confirmation)
5. Search transactions
6. Filter by date range
7. Filter by category
8. Filter by account
9. Sort by date (asc/desc)
10. Sort by amount (asc/desc)
11. Quick add from home screen
12. Repeat transaction (daily/weekly/monthly)
13. Split transaction across categories
14. Attach photo to transaction
15. Duplicate transaction

### Categories (10)
16. Default expense categories (Food, Transport, Shopping, etc.)
17. Default income categories (Salary, Bonus, Gift, etc.)
18. Create custom expense category
19. Create custom income category
20. Edit category name/icon/color
21. Delete category (reassign transactions)
22. Category icons (SF Symbols)
23. Category color coding
24. Category spending limits
25. Category monthly comparison

### Accounts (8)
26. Add bank account
27. Add cash account
28. Add credit card account
29. Add multiple accounts
30. Account balance tracking
31. Transfer between accounts
32. Account-specific transaction history
33. Net worth summary

### Budgets (10)
34. Create monthly budget per category
35. Set budget amount
36. Budget progress bar
37. Budget alerts (80%, 100%)
38. Rollover unused budget
39. Copy budget to next month
40. Budget vs actual comparison
41. Overall monthly budget
42. Budget category breakdown
43. Budget completion percentage

### Goals (8)
44. Create savings goal
45. Set goal target amount
46. Set goal target date
47. Add funds to goal
48. Goal progress visualization
49. Goal completion celebration
50. Edit goal
51. Delete goal

### Analytics (10)
52. Monthly spending pie chart
53. Monthly income vs expense bar chart
54. Spending trend line chart
55. Top 5 spending categories
56. Monthly comparison
57. Year-to-date summary
58. Category breakdown table
59. Daily spending heatmap
60. Export to CSV

### Settings (4)
61. Dark mode toggle
62. Currency selection
63. Language (English only for now)
64. Data backup/restore
65. Delete all data

---

## Review Notes

- Contact Email: lauer3912@qq.com
- Demo Account: test@example.com / Test123456
- Privacy Policy: https://lauer3912.github.io/ios-DailyExpenseAIPro/docs/PrivacyPolicy.html
