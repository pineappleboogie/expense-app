# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyFirstApp is an iOS application for Singapore credit card users to track spending against minimum/maximum thresholds for miles optimization. Built with SwiftUI and SwiftData for local persistence.

**Target**: iOS 17+, Swift 5.9+, Xcode 15+

## Build Commands

```bash
# Build
xcodebuild build -scheme MyFirstApp -project MyFirstApp/MyFirstApp.xcodeproj

# Run tests
xcodebuild test -scheme MyFirstApp -project MyFirstApp/MyFirstApp.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build
xcodebuild clean -scheme MyFirstApp -project MyFirstApp/MyFirstApp.xcodeproj
```

## Architecture

### Planned Structure
```
MyFirstApp/MyFirstApp/
├── Models/           # SwiftData models (CreditCard, Expense, CategoryCap)
├── Services/         # Business logic (SpendingCalculator, DateRangeCalculator)
├── ViewModels/       # State management
├── Views/            # SwiftUI views organized by feature
│   ├── Dashboard/
│   ├── Expenses/
│   ├── Cards/
│   └── Onboarding/
└── Extensions/       # Helper methods for Date, Decimal
```

### Key Design Decisions
- **Local-only storage**: SwiftData with no cloud sync
- **Pre-populated card library**: 30+ Singapore bank cards included
- **Category caps**: Some cards (UOB) have per-category spending limits with tiered rewards
- **Cycle types**: Calendar month vs statement date cycles require different calculations

## Specifications

- [specs/prd.md](specs/prd.md) - Product Requirements Document with data models and business logic
- [specs/task-v1.md](specs/task-v1.md) - Implementation task breakdown

## Task Workflow

Use the `/process-task-list` skill to work through tasks in specs/task-v1.md:
1. Complete one sub-task at a time
2. Request user confirmation before proceeding
3. Run tests and commit with conventional format (feat/fix/refactor) when parent task completes
4. Run `teach.md` after commiting to teach coding concepts
