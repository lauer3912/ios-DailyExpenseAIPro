# Daily Expense AI Pro -- Feature List

> **App:** Daily Expense AI Pro | **Bundle ID:** com.ggsheng.DailyExpenseAIPro
> **Version:** 1.0.0 | **Platform:** iOS 17.0+
> **Last Updated:** 2026-05-20

---

## Feature Summary

| Category | Count | Premium |
|----------|-------|---------|
| Core Tracking | 15 | 50/mo free, unlimited premium |
| Categories | 10 | All free |
| Accounts | 8 | 1 free, unlimited premium |
| Budgets | 10 | 2 free, unlimited premium |
| Goals | 8 | 2 free, unlimited premium |
| Analytics | 10 | Basic free, advanced premium |
| Settings | 4 | All free |
| **Total** | **65** | |

---

## 1. Core Tracking (15 features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 1 | Add Expense | Add transaction with amount, category, date, note, photo | P0 |
| 2 | Add Income | Add income with amount, category, date, note | P0 |
| 3 | Edit Transaction | Modify existing transaction | P0 |
| 4 | Delete Transaction | Remove transaction with confirmation | P0 |
| 5 | Search | Full-text search across all transactions | P1 |
| 6 | Filter by Date | Filter transactions by date range | P1 |
| 7 | Filter by Category | Filter by single or multiple categories | P1 |
| 8 | Filter by Account | Filter by specific account | P1 |
| 9 | Sort by Date | Sort asc/desc by date | P1 |
| 10 | Sort by Amount | Sort asc/desc by amount | P2 |
| 11 | Quick Add Widget | Home screen widget for quick entry | P2 |
| 12 | Repeat Transaction | Schedule recurring (daily/weekly/monthly) | P1 |
| 13 | Split Transaction | Split amount across multiple categories | P1 |
| 14 | Attach Photo | Attach receipt photo to transaction | P2 |
| 15 | Duplicate Transaction | Copy transaction with new date | P2 |

---

## 2. Categories (10 features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 16 | Default Expense Categories | Food, Transport, Shopping, Entertainment, Bills, Health, Other | P0 |
| 17 | Default Income Categories | Salary, Bonus, Gift, Investment, Other | P0 |
| 18 | Create Custom Category | Add custom expense category | P1 |
| 19 | Create Custom Income Category | Add custom income category | P1 |
| 20 | Edit Category | Modify name, icon, color | P1 |
| 21 | Delete Category | Remove and reassign transactions | P2 |
| 22 | Category Icons | SF Symbols icon picker | P1 |
| 23 | Category Colors | Custom color per category | P1 |
| 24 | Category Limits | Monthly spending limit per category | P2 |
| 25 | Category Comparison | Month-over-month category comparison | P2 |

---

## 3. Accounts (8 features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 26 | Bank Account | Track checking/savings accounts | P1 |
| 27 | Cash Account | Track cash on hand | P1 |
| 28 | Credit Card | Track credit card balance | P1 |
| 29 | Multiple Accounts | Manage unlimited accounts (premium) | P1 |
| 30 | Account Balance | Real-time balance per account | P0 |
| 31 | Transfer | Move money between accounts | P1 |
| 32 | Account History | Per-account transaction list | P1 |
| 33 | Net Worth | Total assets minus liabilities | P1 |

---

## 4. Budgets (10 features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 34 | Create Budget | Set monthly budget per category | P0 |
| 35 | Budget Amount | Specify budget limit | P0 |
| 36 | Progress Bar | Visual progress indicator | P0 |
| 37 | Budget Alerts | Notification at 80% and 100% | P1 |
| 38 | Rollover | Carry unused budget to next month | P2 |
| 39 | Copy Budget | Duplicate budget to next month | P2 |
| 40 | Budget vs Actual | Compare budgeted vs spent | P1 |
| 41 | Overall Budget | Total monthly spending limit | P1 |
| 42 | Category Breakdown | Per-category budget analysis | P1 |
| 43 | Completion % | Percentage of budget used | P0 |

---

## 5. Goals (8 features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 44 | Create Goal | Set savings goal with name | P0 |
| 45 | Target Amount | Specify goal target | P0 |
| 46 | Target Date | Set deadline for goal | P1 |
| 47 | Add Funds | Contribute to goal | P0 |
| 48 | Progress View | Visual progress indicator | P0 |
| 49 | Completion Celebration | Animation when goal reached | P2 |
| 50 | Edit Goal | Modify goal parameters | P1 |
| 51 | Delete Goal | Remove goal with confirmation | P1 |

---

## 6. Analytics (10 features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 52 | Pie Chart | Monthly spending by category | P0 |
| 53 | Bar Chart | Income vs expense comparison | P0 |
| 54 | Line Chart | Spending trend over time | P1 |
| 55 | Top Categories | Top 5 spending categories | P1 |
| 56 | Monthly Comparison | Compare current vs past months | P1 |
| 57 | Year Summary | Annual spending/income summary | P2 |
| 58 | Category Table | Detailed breakdown table | P1 |
| 59 | Daily Heatmap | Calendar heatmap of spending | P2 |
| 60 | CSV Export | Export data to CSV file | P1 |

---

## 7. Settings (4 features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 61 | Dark Mode | Toggle dark/light theme | P0 |
| 62 | Currency | Select from major currencies | P1 |
| 63 | Data Backup | Export all data to file | P2 |
| 64 | Delete All Data | Clear all app data | P1 |

---

## Technical Specifications

| Item | Value |
|------|-------|
| Platform | iOS 17.0+ |
| UI Framework | SwiftUI |
| Data Storage | UserDefaults + SQLite |
| Architecture | MVVM |
| Widget | WidgetKit |
| Subscriptions | StoreKit 2 |
| Charts | Swift Charts |
| Minimum Devices | iPhone XS, iPad Pro 3rd gen |

---

## Premium Subscription

**Product IDs:**
- Monthly: `com.ggsheng.DailyExpenseAIPro.premium_monthly`
- Yearly: `com.ggsheng.DailyExpenseAIPro.premium_yearly`

**Subscription Group:** `premium_group`

**Free Trial:** 3 days

**Premium Benefits:**
- Unlimited transactions (vs 50/month free)
- Unlimited accounts (vs 1 free)
- Unlimited budgets (vs 2 free)
- Unlimited goals (vs 2 free)
- Advanced analytics charts
- Cloud sync
- Ad-free experience
- Priority support
