# Singapore Credit Card Expense Tracker - Product Requirements Document

## Overview
An iOS app to help Singapore credit card users track spending against min/max thresholds for miles optimization.

## Key Decisions
- **Expense input**: Manual entry only (amount, card, date, optional category)
- **Storage**: Local only using SwiftData
- **Dashboard UI**: List with progress bars for each card
- **Monthly view**: Simple total spending for calendar month
- **Categories**: Preset categories (Dining, Transport, Shopping, Groceries, Online, Travel, Utilities, Others)
- **Reset cycles**: Pre-populated cards with default cycles + custom cards with user-defined cycles
- **Alerts**: None (visual indicators only)
- **Onboarding**: User must add at least one card before logging expenses

---

## Data Models

### CreditCard (SwiftData @Model)
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| bank | Bank enum | DBS, UOB, OCBC, Citibank, HSBC, StanChart, AMEX, Maybank, Other |
| network | CardNetwork enum | Visa, Mastercard, AMEX, Other |
| cardName | String | e.g., "Altitude Visa Signature" |
| minSpendingThreshold | Decimal? | Optional minimum for bonus miles (total spend) |
| maxSpendingThreshold | Decimal? | Optional maximum cap for bonus miles (total spend) |
| cycleType | CycleType enum | Calendar month or Statement month |
| statementDate | Int? | Day of month (1-31) for statement cycle |
| lastFourDigits | String? | Optional identifier |
| localEarnRate | Double? | Miles per dollar for local (SGD) spend |
| foreignEarnRate | Double? | Miles per dollar for foreign currency spend |
| baseMilesRate | Double? | Base miles rate (below min or above max threshold) |
| rewardNotes | String? | Additional reward info |
| hasCategoryCaps | Bool | If true, uses CategoryCap for tracking instead of simple min/max |
| categoryCaps | [CategoryCap] | Relationship - category-level spending caps |
| expenses | [Expense] | Relationship (cascade delete) |

### CategoryCap (SwiftData @Model)
For cards like UOB Visa Signature that have per-category spending caps.

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| category | BonusCategory enum | The category this cap applies to |
| minSpend | Decimal? | Minimum spend IN THIS CATEGORY to unlock bonus rate (e.g., $1k for UOB Visa Sig) |
| capAmount | Decimal | Maximum spend to earn bonus rate in this category |
| bonusRate | Double | Miles per dollar within cap (e.g., 4.0) |
| card | CreditCard | Parent card reference |

**Category Cap Logic:**
- If `minSpend` is set: User must spend at least `minSpend` in this category to earn `bonusRate`
- Spend below `minSpend` earns the card's `baseMilesRate`
- Spend between `minSpend` and `capAmount` earns `bonusRate`
- Spend above `capAmount` earns `baseMilesRate`

### BonusCategory (Enum)
Categories that credit cards use for bonus caps (different from expense categories):

| Value | Description |
|-------|-------------|
| online | Online/e-commerce purchases |
| contactless | Contactless/mobile wallet payments |
| foreignCurrency | Foreign currency transactions |
| dining | Dining & restaurants |
| travel | Travel bookings |
| groceries | Supermarket & groceries |
| transport | Transport (incl. SimplyGo) |
| shopping | Retail shopping |
| fuel | Petrol stations |
| general | All other spend |

### Expense (SwiftData @Model)
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| amount | Decimal | SGD amount |
| date | Date | Default today |
| category | ExpenseCategory? | User's expense category (optional) |
| bonusCategory | BonusCategory? | Which bonus cap this applies to (for cards with category caps) |
| card | CreditCard | Required reference |

---

## Pre-populated Card Library

### DBS
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| Altitude Visa Signature | 1.2 mpd | 2.0 mpd | 1.2 mpd | 3 mpd online hotels |
| Altitude AMEX | 1.2 mpd | 2.0 mpd | 1.2 mpd | 3 mpd online hotels |
| Woman's World Card | 4.0 mpd | 4.0 mpd | 0.4 mpd | Capped at $2k/month online |

### UOB
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| PRVI Miles Visa | 1.4 mpd | 2.4 mpd | 1.4 mpd | No cap |
| PRVI Miles Mastercard | 1.4 mpd | 2.4 mpd | 1.4 mpd | No cap |
| Visa Signature | 4.0 mpd | 4.0 mpd | 0.4 mpd | **HAS CATEGORY CAPS** - see below |
| Preferred Platinum Visa | 4.0 mpd | 4.0 mpd | 0.4 mpd | **HAS CATEGORY CAPS** - see below |
| Lady's Solitaire | 4.0 mpd | 4.0 mpd | 0.4 mpd | **HAS CATEGORY CAPS** - see below |

**UOB Visa Signature Category Caps** (each category has its own $1k min to unlock bonus):
- Foreign Currency: $1,000 min → $1,200 cap @ 4 mpd (below $1k = base rate)
- Contactless: $1,000 min → $1,200 cap @ 4 mpd (below $1k = base rate)
- *Each category is independent - must hit $1k in THAT category to unlock its bonus*

**UOB Preferred Platinum Visa Category Caps** (no minimum per category):
- Online: $600 cap @ 4 mpd
- Contactless: $600 cap @ 4 mpd

**UOB Lady's Solitaire Category Caps** (user selects 2 categories, no minimum):
- Category 1: $750 cap @ 4 mpd
- Category 2: $750 cap @ 4 mpd

### OCBC
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| 90°N Card | 1.3 mpd | 2.1 mpd | 1.3 mpd | No cap, no expiry |
| Rewards Card | 4.0 mpd | 4.0 mpd | 0.4 mpd | 6 mpd promo on e-commerce |

### Citibank
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| Rewards Card | 4.0 mpd | 4.0 mpd | 0.4 mpd | 10x on categories |
| PremierMiles Visa | 1.2 mpd | 2.0 mpd | 1.2 mpd | *Discontinuing Jan 2026* |

### HSBC
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| Revolution | 4.0 mpd | 4.0 mpd | 0.4 mpd | Online & contactless, $1.5k cap |
| TravelOne | 1.0 mpd | 2.5 mpd | 1.0 mpd | No FX fee |

### Standard Chartered
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| Visa Infinite | 1.4 mpd | 3.0 mpd | 1.4 mpd | $2k min spend |
| X Card | - | - | - | Cashback card, not miles |

### AMEX
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| KrisFlyer Card | 1.1 mpd | 2.0 mpd | 1.1 mpd | Direct KrisFlyer earn |
| Platinum Card | 1.6 mpd | 1.6 mpd | 1.6 mpd | With MR bonus |

### Maybank
| Card | Local | Foreign | Base | Notes |
|------|-------|---------|------|-------|
| Horizon Visa Signature | 1.6 mpd | 3.2 mpd | 1.6 mpd | Good overseas rate |

---

## File Structure

```
MyFirstApp/
├── MyFirstAppApp.swift              # SwiftData ModelContainer setup
├── ContentView.swift                # Root routing (onboarding vs main)
│
├── Models/
│   ├── CreditCard.swift             # @Model
│   ├── Expense.swift                # @Model
│   ├── CategoryCap.swift            # @Model - category-level spending caps
│   ├── Bank.swift                   # Enum
│   ├── CardNetwork.swift            # Enum
│   ├── ExpenseCategory.swift        # Enum with icons (user categories)
│   ├── BonusCategory.swift          # Enum - card bonus categories
│   ├── CycleType.swift              # Enum
│   └── CardTemplate.swift           # Pre-populated library with category caps
│
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── ExpenseViewModel.swift
│   └── CardManagementViewModel.swift
│
├── Views/
│   ├── MainTabView.swift            # Tab navigation
│   ├── Dashboard/
│   │   ├── DashboardView.swift      # Main dashboard
│   │   ├── CardProgressRow.swift    # Card with progress bars
│   │   └── MonthlyOverviewCard.swift
│   ├── Expenses/
│   │   └── AddExpenseView.swift     # Expense entry form
│   ├── Cards/
│   │   ├── CardManagementView.swift # List of user's cards
│   │   ├── CardLibraryView.swift    # Pre-populated card picker
│   │   ├── AddCustomCardView.swift  # Custom card form
│   │   └── EditCardView.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # First-time setup
│   └── Components/
│       ├── ProgressBarView.swift
│       └── StatusBadge.swift
│
├── Services/
│   ├── SpendingCalculator.swift     # Threshold & spending logic
│   └── DateRangeCalculator.swift    # Cycle date calculations
│
└── Extensions/
    ├── Date+Extensions.swift
    └── Decimal+Extensions.swift
```

---

## Key Screens

### 1. Onboarding (first launch)
- Welcome message
- Two options: "Choose from Library" or "Create Custom Card"
- Must add at least one card to proceed

### 2. Dashboard (main screen)
- **Top**: Monthly overview card showing total spend for calendar month (across ALL cards, regardless of individual card cycle type)
- **List**: Each card shows:
  - Bank + Card name (+ last 4 digits if set)
  - Current cycle date range
  - Current spending amount (total)
  - **For simple cards (no category caps)**:
    - Progress bar for min threshold (orange → green when met)
    - Progress bar for max threshold (blue → red when exceeded)
    - Status badge (Below minimum / Minimum met / In range / Over maximum)
  - **For cards WITH category caps**:
    - Mini progress bars for each category cap
    - **If category has minSpend requirement**:
      - Show two-stage progress: "Contactless: $800/$1,000 min" (orange) → "$1,150/$1,200 cap" (green)
      - Color: orange (below min, earning base rate), green (min met, earning bonus), blue (maxed out)
    - **If category has NO minSpend**:
      - Simple progress: "Online: $450/$600"
      - Color: blue (in progress), green (maxed out)
  - Earn rates: Local / Foreign / Base mpd (e.g., "1.4 / 2.4 / 1.4 mpd")
  - Additional reward notes if any

### 3. Add Expense
- Amount field (SGD, decimal keyboard)
- Card picker (from user's cards)
- **Bonus Category picker** (only shown if selected card has category caps):
  - Shows the card's bonus categories + "General" option
  - e.g., for UOB Preferred Platinum: "Online", "Contactless", or "General"
  - "General" = spend that doesn't qualify for any bonus cap (still tracked for total spend)
- Date picker (default today)
- Category picker (optional user category, with icons)
- Save button

### 4. Card Management
- List of user's cards (reorderable, deletable)
- Add button → choose from library or create custom
- Tap card → edit screen

---

## Spending Calculations

### Calendar Month Cycle
- Range: 1st of current month to last day of current month
- Example: Jan 1 - Jan 31

### Statement Month Cycle
- Range: Statement date of previous month to day before statement date of current month
- Example: If statement date is 15th, cycle is Dec 15 - Jan 14

### Progress Indicators
- **Min threshold progress** = current spend / min threshold
- **Max threshold progress** = current spend / max threshold
- Visual states:
  - Below min: Orange progress bar
  - Met min (no max): Green badge
  - Between min and max: Green badge, blue max progress bar
  - Exceeded max: Red badge and progress bar

---

## Implementation Steps

### Phase 1: Foundation
1. Create folder structure
2. Implement enums (Bank, CardNetwork, ExpenseCategory, CycleType)
3. Implement SwiftData models (CreditCard, Expense)
4. Set up ModelContainer in app entry point
5. Create CardTemplate with pre-populated cards

### Phase 2: Services
1. Implement DateRangeCalculator (cycle date logic)
2. Implement SpendingCalculator (threshold calculations)
3. Create Date and Decimal extensions

### Phase 3: ViewModels
1. CardManagementViewModel (CRUD for cards)
2. ExpenseViewModel (add/delete expenses)
3. DashboardViewModel (spending summaries)

### Phase 4: Onboarding
1. OnboardingView with welcome screen
2. CardLibraryView (grouped by bank)
3. AddCustomCardView (full form)

### Phase 5: Core Features
1. MainTabView (Dashboard, Add Expense, Cards tabs)
2. DashboardView with CardProgressRow components
3. AddExpenseView with form
4. CardManagementView with edit/delete

### Phase 6: Polish
1. Reusable components (ProgressBarView, StatusBadge)
2. MonthlyOverviewCard
3. Pull-to-refresh on dashboard

---

## Verification Plan

### Simple Cards (no category caps)
1. **Add card from library**: Select DBS Altitude, add last 4 digits → appears in dashboard
2. **Add custom card**: Create card with statement cycle (15th), set min $500 → verify cycle dates show correctly
3. **Add expense**: Enter $100, select card, save → dashboard updates spending
4. **Threshold progress**: Add expenses until crossing min threshold → badge changes to green
5. **Calendar month total**: Add expenses to different cards → monthly overview shows correct total
6. **Statement cycle**: Set card to statement date 15th → verify date range calculation

### Cards with Category Caps (no min requirement)
7. **Add UOB Preferred Platinum**: Select from library → should show 2 category caps (Online $600, Contactless $600)
8. **Add expense with bonus category**: Select UOB PP, enter $100, select "Online" as bonus category → Online cap shows $100/$600
9. **Category cap progress**: Add $600 to Online category → Online cap shows green (maxed), Contactless still empty
10. **Mixed categories**: Add $300 to Contactless → both categories show progress independently

### Cards with Category Caps (WITH min requirement)
11. **Add UOB Visa Signature**: Select from library → should show 2 category caps with $1k min each
12. **Below category minimum**: Add $500 to Contactless → shows "$500/$1,000 min" in orange (earning base rate)
13. **Meet category minimum**: Add another $600 to Contactless (total $1,100) → shows green progress toward $1,200 cap
14. **Independent categories**: Foreign Currency still shows $0/$1,000 min (orange) - unaffected by Contactless spend

### General
15. **Edit card**: Change thresholds → progress bars update
16. **Delete card**: Remove card → associated expenses deleted (cascade)
17. **App restart**: Close and reopen → all data persists
