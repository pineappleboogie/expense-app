# Singapore Credit Card Expense Tracker - Task List

## Relevant Files

- `prd.md` - Product Requirements Document defining the app features and data models

### Models (to be created)
- `MyFirstApp/MyFirstApp/Models/Bank.swift` - Bank enum (DBS, UOB, OCBC, etc.)
- `MyFirstApp/MyFirstApp/Models/CardNetwork.swift` - Card network enum (Visa, Mastercard, AMEX, Other)
- `MyFirstApp/MyFirstApp/Models/ExpenseCategory.swift` - User expense categories with icons
- `MyFirstApp/MyFirstApp/Models/BonusCategory.swift` - Card bonus categories enum
- `MyFirstApp/MyFirstApp/Models/CycleType.swift` - Cycle type enum (Calendar/Statement month)
- `MyFirstApp/MyFirstApp/Models/CreditCard.swift` - SwiftData @Model for credit cards
- `MyFirstApp/MyFirstApp/Models/CategoryCap.swift` - SwiftData @Model for category-level spending caps
- `MyFirstApp/MyFirstApp/Models/Expense.swift` - SwiftData @Model for expenses
- `MyFirstApp/MyFirstApp/Models/CardTemplate.swift` - Pre-populated card library

### Services (to be created)
- `MyFirstApp/MyFirstApp/Services/DateRangeCalculator.swift` - Cycle date calculations
- `MyFirstApp/MyFirstApp/Services/SpendingCalculator.swift` - Threshold and spending logic

### ViewModels (to be created)
- `MyFirstApp/MyFirstApp/ViewModels/DashboardViewModel.swift` - Dashboard spending summaries
- `MyFirstApp/MyFirstApp/ViewModels/ExpenseViewModel.swift` - Add/delete expenses
- `MyFirstApp/MyFirstApp/ViewModels/CardManagementViewModel.swift` - CRUD for cards

### Views (to be created)
- `MyFirstApp/MyFirstApp/Views/MainTabView.swift` - Tab navigation
- `MyFirstApp/MyFirstApp/Views/Dashboard/DashboardView.swift` - Main dashboard
- `MyFirstApp/MyFirstApp/Views/Dashboard/CardProgressRow.swift` - Card with progress bars
- `MyFirstApp/MyFirstApp/Views/Dashboard/MonthlyOverviewCard.swift` - Monthly spending overview
- `MyFirstApp/MyFirstApp/Views/Expenses/AddExpenseView.swift` - Expense entry form
- `MyFirstApp/MyFirstApp/Views/Cards/CardManagementView.swift` - List of user's cards
- `MyFirstApp/MyFirstApp/Views/Cards/CardLibraryView.swift` - Pre-populated card picker
- `MyFirstApp/MyFirstApp/Views/Cards/AddCustomCardView.swift` - Custom card form
- `MyFirstApp/MyFirstApp/Views/Cards/EditCardView.swift` - Edit card form
- `MyFirstApp/MyFirstApp/Views/Onboarding/OnboardingView.swift` - First-time setup
- `MyFirstApp/MyFirstApp/Views/Components/ProgressBarView.swift` - Reusable progress bar
- `MyFirstApp/MyFirstApp/Views/Components/StatusBadge.swift` - Status badge component

### Extensions (to be created)
- `MyFirstApp/MyFirstApp/Extensions/Date+Extensions.swift` - Date helper methods
- `MyFirstApp/MyFirstApp/Extensions/Decimal+Extensions.swift` - Decimal formatting helpers

### Existing Files (to be modified)
- `MyFirstApp/MyFirstApp/MyFirstAppApp.swift` - Add SwiftData ModelContainer setup
- `MyFirstApp/MyFirstApp/ContentView.swift` - Root routing (onboarding vs main)


## Tasks

- [x] 1.0 Project Foundation & Data Models
  - [x] 1.1 Create folder structure (Models/, Services/, ViewModels/, Views/, Views/Dashboard/, Views/Expenses/, Views/Cards/, Views/Onboarding/, Views/Components/, Extensions/)
  - [x] 1.2 Implement `Bank` enum with cases: DBS, UOB, OCBC, Citibank, HSBC, StanChart, AMEX, Maybank, Other
  - [x] 1.3 Implement `CardNetwork` enum with cases: Visa, Mastercard, AMEX, Other
  - [x] 1.4 Implement `ExpenseCategory` enum with cases and SF Symbol icons: Dining, Transport, Shopping, Groceries, Online, Travel, Utilities, Others
  - [x] 1.5 Implement `BonusCategory` enum with cases: online, contactless, foreignCurrency, dining, travel, groceries, transport, shopping, fuel, general
  - [x] 1.6 Implement `CycleType` enum with cases: calendarMonth, statementMonth
  - [x] 1.7 Implement `CategoryCap` SwiftData @Model with fields: id, category (BonusCategory), minSpend (Decimal?), capAmount (Decimal), bonusRate (Double), card reference
  - [x] 1.8 Implement `CreditCard` SwiftData @Model with all fields from PRD including relationships to CategoryCap and Expense (cascade delete)
  - [x] 1.9 Implement `Expense` SwiftData @Model with fields: id, amount (Decimal), date, category (ExpenseCategory?), bonusCategory (BonusCategory?), card reference
  - [x] 1.10 Implement `CardTemplate` struct with static array of all pre-populated cards from PRD (DBS, UOB, OCBC, Citibank, HSBC, StanChart, AMEX, Maybank) including category caps for UOB cards
  - [x] 1.11 Update `MyFirstAppApp.swift` to configure SwiftData ModelContainer with CreditCard, Expense, and CategoryCap models

- [ ] 2.0 Services & Business Logic
  - [ ] 2.1 Implement `Date+Extensions.swift` with helpers: startOfMonth, endOfMonth, startOfDay, formatting methods
  - [ ] 2.2 Implement `Decimal+Extensions.swift` with currency formatting (SGD) and percentage calculation helpers
  - [ ] 2.3 Implement `DateRangeCalculator` service with method to calculate current cycle date range based on CycleType and optional statement date
  - [ ] 2.4 Implement `SpendingCalculator` service with methods to:
    - [ ] 2.4.1 Calculate total spending for a card within a date range
    - [ ] 2.4.2 Calculate spending per bonus category for cards with category caps
    - [ ] 2.4.3 Determine threshold status (below min, min met, in range, over max)
    - [ ] 2.4.4 Calculate progress percentages for min and max thresholds
    - [ ] 2.4.5 Calculate category cap progress including min spend unlock logic

- [ ] 3.0 ViewModels Layer
  - [ ] 3.1 Implement `CardManagementViewModel` with:
    - [ ] 3.1.1 Method to fetch all user cards from SwiftData
    - [ ] 3.1.2 Method to add a card from CardTemplate (pre-populated library)
    - [ ] 3.1.3 Method to add a custom card with user-defined fields
    - [ ] 3.1.4 Method to update an existing card
    - [ ] 3.1.5 Method to delete a card (with cascade delete of expenses)
    - [ ] 3.1.6 Method to reorder cards
  - [ ] 3.2 Implement `ExpenseViewModel` with:
    - [ ] 3.2.1 Method to add a new expense with amount, card, date, optional category, and optional bonus category
    - [ ] 3.2.2 Method to delete an expense
    - [ ] 3.2.3 Method to fetch expenses for a specific card within date range
  - [ ] 3.3 Implement `DashboardViewModel` with:
    - [ ] 3.3.1 Method to calculate monthly overview total (calendar month, all cards)
    - [ ] 3.3.2 Method to fetch all cards with their current cycle spending summaries
    - [ ] 3.3.3 Computed properties for each card's threshold status and progress
    - [ ] 3.3.4 Method to get category cap progress for cards with hasCategoryCaps = true

- [ ] 4.0 Onboarding Flow
  - [ ] 4.1 Implement `OnboardingView` with:
    - [ ] 4.1.1 Welcome message and app introduction
    - [ ] 4.1.2 Two action buttons: "Choose from Library" and "Create Custom Card"
    - [ ] 4.1.3 Logic to check if user has at least one card before allowing navigation to main app
  - [ ] 4.2 Implement `CardLibraryView` with:
    - [ ] 4.2.1 List of pre-populated cards grouped by bank (using CardTemplate data)
    - [ ] 4.2.2 Card detail showing: name, earn rates (local/foreign/base), reward notes
    - [ ] 4.2.3 Selection action that adds card to user's cards with optional last 4 digits input
    - [ ] 4.2.4 Visual indicator for cards with category caps
  - [ ] 4.3 Implement `AddCustomCardView` form with:
    - [ ] 4.3.1 Bank picker (enum selection)
    - [ ] 4.3.2 Card network picker (enum selection)
    - [ ] 4.3.3 Card name text field
    - [ ] 4.3.4 Last 4 digits optional text field
    - [ ] 4.3.5 Cycle type picker (calendar vs statement month)
    - [ ] 4.3.6 Statement date picker (1-31, shown only if statement month selected)
    - [ ] 4.3.7 Min/max threshold fields (optional Decimal inputs)
    - [ ] 4.3.8 Earn rate fields (local, foreign, base - optional)
    - [ ] 4.3.9 Reward notes optional text field
    - [ ] 4.3.10 Toggle for hasCategoryCaps with dynamic category cap entry form
    - [ ] 4.3.11 Save button with validation
  - [ ] 4.4 Update `ContentView.swift` to check for existing cards and route to OnboardingView or MainTabView

- [ ] 5.0 Core Features & Main Interface
  - [ ] 5.1 Implement `MainTabView` with three tabs:
    - [ ] 5.1.1 Dashboard tab with house icon
    - [ ] 5.1.2 Add Expense tab with plus.circle icon
    - [ ] 5.1.3 Cards tab with creditcard icon
  - [ ] 5.2 Implement `DashboardView` with:
    - [ ] 5.2.1 Monthly overview card at top showing calendar month total across all cards
    - [ ] 5.2.2 Scrollable list of CardProgressRow components for each user card
    - [ ] 5.2.3 Pull-to-refresh functionality to reload spending data
  - [ ] 5.3 Implement `CardProgressRow` component with:
    - [ ] 5.3.1 Header showing bank logo/icon, card name, and last 4 digits if available
    - [ ] 5.3.2 Current cycle date range display
    - [ ] 5.3.3 Current total spending amount
    - [ ] 5.3.4 For simple cards: min threshold progress bar (orange→green) and max threshold progress bar (blue→red)
    - [ ] 5.3.5 For cards with category caps: mini progress bars for each category showing min unlock and cap progress
    - [ ] 5.3.6 Status badge showing current threshold status
    - [ ] 5.3.7 Earn rates display (local/foreign/base mpd)
    - [ ] 5.3.8 Reward notes if available
  - [ ] 5.4 Implement `AddExpenseView` with:
    - [ ] 5.4.1 Amount field with decimal keyboard (SGD)
    - [ ] 5.4.2 Card picker showing user's cards
    - [ ] 5.4.3 Bonus category picker (only shown if selected card has category caps, includes "General" option)
    - [ ] 5.4.4 Date picker defaulting to today
    - [ ] 5.4.5 Optional expense category picker with icons
    - [ ] 5.4.6 Save button with validation (amount > 0, card selected)
    - [ ] 5.4.7 Success feedback and form reset after save
  - [ ] 5.5 Implement `CardManagementView` with:
    - [ ] 5.5.1 List of user's cards with reorder capability
    - [ ] 5.5.2 Swipe-to-delete with confirmation
    - [ ] 5.5.3 Tap to navigate to EditCardView
    - [ ] 5.5.4 Add button in navigation bar with options: "From Library" or "Custom Card"
  - [ ] 5.6 Implement `EditCardView` with:
    - [ ] 5.6.1 Pre-filled form matching AddCustomCardView fields
    - [ ] 5.6.2 Save changes button
    - [ ] 5.6.3 Delete card button with confirmation alert

- [ ] 6.0 Polish & Reusable Components
  - [ ] 6.1 Implement `ProgressBarView` reusable component with:
    - [ ] 6.1.1 Configurable progress value (0.0 to 1.0+)
    - [ ] 6.1.2 Configurable colors for different states (orange, green, blue, red)
    - [ ] 6.1.3 Optional label showing current/target values
    - [ ] 6.1.4 Smooth animation when progress changes
  - [ ] 6.2 Implement `StatusBadge` reusable component with:
    - [ ] 6.2.1 Four status types: belowMinimum, minimumMet, inRange, overMaximum
    - [ ] 6.2.2 Appropriate colors and icons for each status
    - [ ] 6.2.3 Compact pill-shaped design
  - [ ] 6.3 Implement `MonthlyOverviewCard` with:
    - [ ] 6.3.1 Calendar month label (e.g., "January 2025")
    - [ ] 6.3.2 Total spending amount prominently displayed
    - [ ] 6.3.3 Card count showing number of active cards
    - [ ] 6.3.4 Visual styling to stand out as header card
  - [ ] 6.4 Add visual polish:
    - [ ] 6.4.1 Consistent spacing and typography across all views
    - [ ] 6.4.2 Appropriate use of SF Symbols for icons
    - [ ] 6.4.3 Support for both light and dark mode
    - [ ] 6.4.4 Loading states where appropriate
  - [ ] 6.5 Final integration testing:
    - [ ] 6.5.1 Verify onboarding flow prevents access without at least one card
    - [ ] 6.5.2 Test adding expenses and seeing dashboard updates
    - [ ] 6.5.3 Test threshold progress visualization for simple cards
    - [ ] 6.5.4 Test category cap progress for UOB Visa Signature (with min requirement)
    - [ ] 6.5.5 Test category cap progress for UOB Preferred Platinum (no min requirement)
    - [ ] 6.5.6 Test statement cycle date range calculations
    - [ ] 6.5.7 Verify data persistence across app restarts
    - [ ] 6.5.8 Test cascade delete when removing a card
