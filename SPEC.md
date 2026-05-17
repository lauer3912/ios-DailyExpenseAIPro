# DailyExpenseAIPro — Specification Document

## Basic Info
- **Name**: DailyExpenseAIPro
- **Bundle ID**: com.ggsheng.DailyExpenseAIPro
- **Platform**: iOS 17.0+
- **Language**: Swift 5.9
- **Frameworks**: SwiftUI, UserDefaults, WidgetKit, Swift Charts
- **Target Market**: Global (Western customers priority)
- **Revenue Model**: Freemium + Subscription
  - Free: Basic tracking (2 accounts, basic reports)
  - Premium: $4.99/month or $39.99/year (unlimited accounts, cloud sync, AI insights, advanced widgets, Apple Watch)

## 🎯 Core Features (70+)

### 1. Transaction Recording
1. Quick income recording
2. Quick expense recording
3. Category selection (custom icons)
4. Amount entry with numpad
5. Date/time picker
6. Multi-currency support
7. Notes/tags field
8. Location recording
9. Photo/receipt attachment
10. Voice input (Premium)

### 2. Account Management
11. Multi-account support (Cash/Bank/Credit/Investment)
12. Account balance tracking with history
13. Inter-account transfers
14. Liability accounts (credit cards/loans)
15. Investment accounts with portfolio value
16. Net worth calculation (assets minus liabilities)

### 3. Budget Management
17. Monthly budget setting per category
18. Budget allocation and limits
19. Budget progress visualization (ring/bar)
20. Overspending alerts (push notification)
21. Budget rollover (unused budget carries forward)
22. Weekly budget option
23. Custom period budget

### 4. Savings Goals
24. Savings goal creation with target amount and deadline
25. Automatic savings plan setup
26. Goal progress tracking (circular progress indicator)
27. Time-to-goal estimation
28. Emergency fund calculator
29. Debt payoff goal tracking
30. Goal priority ordering

### 5. Reports & Analytics
31. Daily report view
32. Weekly report view
33. Monthly report view
34. Annual report view
35. Category spending analysis (pie chart/bar chart)
36. Trend analysis (line chart)
37. Net cash flow analysis
38. Top spending categories ranking
39. Spending by merchant breakdown
40. Income structure analysis

### 6. Bills & Subscriptions
41. Recurring bill management
42. Bill due date reminders
43. Subscription tracking (auto-detect recurring charges)
44. Subscription renewal reminders
45. Bill payment history
46. Next bill date estimation

### 7. Debt Management
47. Debt inventory list
48. Payoff plan — Snowball method (smallest balance first)
49. Payoff plan — Avalanche method (highest interest first)
50. Interest calculator
51. Early repayment savings calculator

### 8. Advanced Features (Premium)
52. AI spending insights and analysis
53. Smart budget recommendations based on habits
54. Anomaly detection (unusual spending alerts)
55. Cloud sync (iCloud)
56. Family sharing (up to 6 members)
57. Receipt OCR scanning
58. Deep category statistics
59. Custom report export (CSV/PDF)
60. Advanced Widget (multiple sizes, lock screen)

### 9. Auxiliary Features
61. Home screen widget (small/medium/large)
62. Lock screen widget showing balance
63. Siri Shortcuts integration
64. Apple Watch companion app
65. Face ID / Touch ID app lock
66. Data export (CSV, PDF)
67. Data import (CSV)
68. Currency converter with live rates
69. Recurring transaction templates
70. Share reports with friends/family

## 🎨 UI Design

### Color Theme
#### Dark Mode
- Background: Deep charcoal (#0D1117)
- Card: Dark gray-blue (#161B22)
- Accent (Income): Mint green (#00D4AA)
- Accent (Expense): Coral red (#FF6B6B)
- Text: Light gray (#E6EDF3)
- Secondary text: Muted gray (#8B949E)

#### Light Mode
- Background: Warm white (#FAFBFC)
- Card: Pure white (#FFFFFF) + soft shadow
- Accent (Income): Deep teal (#006D77)
- Accent (Expense): Coral orange (#EF476F)
- Text: Dark gray (#1A1A1A)
- Secondary text: Medium gray (#6B7280)

### Typography
- Primary font: SF Pro Display (headings, 20pt+)
- Secondary font: SF Pro Text (body, 16-18pt)
- Numbers: SF Pro Rounded (bold, 24pt+)

## 📱 Screen Layout

### Dashboard (Home)
- Today's income/expense summary card
- Monthly budget progress ring
- Quick add button (FAB)
- Recent transactions list
- Net worth display
- Savings goals quick view

### Add Transaction
- Income/expense toggle
- Category grid (icon + name)
- Numpad for amount entry
- Date/currency picker
- Notes input field
- Save button

### Reports
- Chart type selector (pie/line/bar)
- Time range picker (week/month/year/custom)
- Category spending pie chart
- Trend line chart
- Detail transaction list

### Settings
- Account management
- Budget configuration
- Goal management
- Subscription management (Premium)
- Theme toggle (Dark/Light/System)
- Data export/import
- Privacy policy link
- Contact support

## 🔐 Privacy & Security
- Local encrypted storage (UserDefaults + Keychain for sensitive data)
- Face ID / Touch ID app lock
- No collection of personally identifiable information
- Optional data analytics opt-out
- GDPR compliant
- COPPA compliant for family sharing

## 📋 Submission Requirements
- English Privacy Policy (required)
- English App Store description (4000 char max)
- Screenshots: iPhone 6.9" (1320×2868) + iPad 13" (2048×2732)
- Optional: 60-second demo video
- No Chinese characters in any source files

## 🎬 Demo Video Script
0-5s: App launch + dashboard showcase
5-15s: Quick add transaction flow
15-25s: Budget progress ring animation
25-35s: Report charts transitions
35-45s: Widget demonstration
45-55s: Settings & theme switching
55-60s: Closing + app logo

## 🚀 AI Features (Premium Value)
- Smart spending analysis: budget recommendations based on habits
- Anomaly detection: flag unusual spending patterns
- Trend prediction: monthly income/expense forecasting
- Personalized suggestions: money-saving tips
- Natural language query: "How much did I spend on dining this month?"