# Smart Expense Tracker

A Flutter-based expense tracking app with Hive local database, MVVM architecture, and rich features including categories, reports, budget tracking, CSV export, dark mode, and more.

![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FFCA28?logo=hive&logoColor=black)

## Features

- **Add, Edit & Delete Transactions**
  - Income & Expense types
  - Assign categories
  - Add optional notes

- **Categories Management**
  - Default categories: Food, Transport, Shopping, Bills, Health, Salary
  - Add/Delete custom categories

- **Dashboard**
  - Total balance, income, and expenses
  - Recent transactions overview

- **Reports & Analytics**
  - Pie chart of expenses by category
  - Total expenses summary

- **Search & Filter Transactions**
  - Search by title or note
  - Filter by All, Today, This Week, or This Month

- **Settings**
  - Dark/Light theme toggle
  - Set monthly budget
  - Export transactions to CSV
  - Add dummy data for testing

- **Persistence**
  - All data is stored locally using Hive
  - Categories, transactions, settings, and budget persisted

## Architecture

The app follows **MVVM (Model-View-ViewModel)** pattern:

- **Models**: `TransactionModel`, `CategoryModel`
- **Repositories**: Transactions, Categories, Settings, Budget
- **ViewModels**: TransactionViewModel, CategoryViewModel, SettingsViewModel
- **Screens**: Splash, Home (with bottom nav), Add/Edit Transaction, All Transactions, Reports, Settings
- **State Management**: Provider + ChangeNotifier
- **Local Database**: Hive Boxes (`transactionsBox`, `categoriesBox`, `settingsBox`, `budgetBox`)

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.4
  uuid: ^4.5.1
  intl: ^0.19.0
  fl_chart: ^0.70.0