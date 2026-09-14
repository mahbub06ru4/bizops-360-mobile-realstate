---
name: bizops-mobile
description: >-
  BizOps 360 Flutter app conventions — one multi-tenant, Travel-Agency-first app
  on GetX (state/routing/DI); the layered path
  (Screen/GetView → Controller → Use Case → Repository → DataSource → Dio);
  pure-Dart domain; Result<T>/sealed Failure error handling; permission-driven
  navigation and action visibility; the AppColors ThemeExtension + design tokens
  with Light/Dark/System; reusable App* common widgets; GetX en/bn translations;
  email+password Sanctum auth against bizops360-api /api/v1; and the
  dart format / flutter analyze --fatal-infos / flutter test gate. Use whenever
  writing, reviewing or debugging Dart/Flutter code in this repo.
---

# BizOps 360 — mobile engineering skill

Read `CLAUDE.md` first, then `docs/HANDOFF.md` for the milestone/PR queue. This is
the how-to behind the rules. The visual target is the approved design mockup
(hangar-green ink, terminal-grey ground, wayfinding amber; Bricolage Grotesque /
Public Sans / IBM Plex Mono / Hind Siliguri).

**One app, not many.** Multi-tenant, role- and permission-aware, Travel Agency
first. Never fork the app or duplicate features per role — adapt by
`tenant → industry → role → permissions → enabled features`.

## The layered path

```
Screen (GetView<Controller>)        ← no logic, no direct Dio / repo Get.find
  → Controller (GetxController)     ← owns Rx state, coordinates, calls use cases
  → UseCase (domain)               ← one business operation → Result<T>
  → Repository (interface, domain)  ← returns Result<T>
  → RepositoryImpl (data)           ← maps JSON↔entities, DioException→Failure
  → DataSource (data)               ← thin wrapper over ApiClient endpoints
  → ApiClient (core)               ← the one configured Dio
```

- **Domain is pure Dart.** `lib/domain/**` must not import `package:flutter`,
  `package:dio`, or `package:get`. Entities are `Equatable`. Mapping lives in
  `lib/data/mappers/`.
- **Controllers never see a `DioException`.** Repos catch and return
  `Result.err(Failure)`; controllers `fold(onOk, onErr)`. Status-code knowledge
  is confined to `core/network/dio_failure_mapper.dart`.
- A `ValidationFailure` carries `errors` (field → messages); surface with
  `forField('email')` into `InputDecoration.errorText`.
- **Travel rules stay in `lib/modules/travel/`.** The common platform
  (`lib/presentation/**`) must not import from `modules/travel/`.

## GetX

- Routing: named routes in `core/routing/`. Each `GetPage` has a `Binding`; a
  `RouteGuard` redirects to sign-in without a session.
- DI: an app-wide binding registers permanent services (stores, `ApiClient`,
  repositories, `AuthController`, `SettingsController`, `TenantContext`,
  `PermissionsController`). Feature bindings `lazyPut` their controller **and its
  use cases**. Never `Get.put`/`Get.find` inside a widget; never `Get.find` deep
  inside domain/data.
- Cross-cutting controllers live in `lib/application/{auth,session,tenant,permissions,navigation}/`.
- The auth interceptor's `onUnauthorized` resolves `AuthController` lazily to
  avoid a construction cycle; a 401 (outside `/auth/login`) ends the session
  once, centrally.
- Reactivity: `.obs` fields + `Obx(() => …)`. Don't `setState`.
- **UI-first**: every feature has a `FakeXRepository` (canned `Result.ok`, data
  shaped like the API envelope) next to the real impl. The feature binding picks
  one on `Env.useFakeData` (`--dart-define=USE_FAKE_DATA`, default on for
  non-prod). Controllers/screens/tests are identical either way.

## Permissions & navigation

- Gate nav items, screens, actions and buttons with the `Can(permission)` widget
  / `PermissionsController` — **never** scatter raw role-string checks.
- The backend is the security authority; always handle a 403 gracefully.
- Bottom nav is travel-focused and dynamic: baseline `Home | Customers | Visa |
  Tasks | More`, filtered by permissions + enabled features. Common capabilities
  (Profile, Attendance, Leave, Expenses, Documents, Team, Reports, Settings, …)
  live under **More / Workspace**. Don't put every module in the bar.
- Home is an operational travel dashboard composed from reusable
  `DashboardSection` widgets — not one giant `HomeScreen`.

## Theme, tokens & localization

- Colours: `context.colors.<token>` (the `AppColors` `ThemeExtension`). Metrics:
  `AppSpacing` / `AppRadius` / `AppElevation`. Never a literal `Color(0x…)` or
  magic padding in a widget. Define new tokens in **both** light and dark (and in
  `copyWith` / `lerp`).
- Support **Light / Dark / System** (`SettingsController.themeMode`).
- **Responsive**: `flutter_screenutil` against a 375 × 812 frame (`ScreenUtilInit`
  in `app/app.dart`). Use `.w` / `.h` / `.r` for sizing and `.sp` for raw font
  sizes; tokens are already in those units, so widgets mostly read tokens.
- Type: `Theme.of(context).textTheme` for prose; `AppTypography.mono(color)` for
  PNRs, flight numbers, references and money (`৳`, 2-2-3 grouping, lakh/crore).
- Every string is a `Tr.*` key with `en` **and** `bn` entries in
  `app_translations.dart` — including validation, errors, empty states,
  notifications. New feature → new key group. Layouts must tolerate EN/BN length
  differences.

## Common widgets & screen states

- Reuse `core/widgets/` `App*`: `AppButton`, `AppTextField`, `AppDropdown`,
  `AppSearchField`, `AppCard`, `AppDialog`, `AppBottomSheet`, `AppSnackbar`,
  `AppLoader`, `AppEmptyState`, `AppErrorState`, `AppNetworkError`,
  `AppPagination`, `AppAvatar`, `AppBadge`, `AppStatusChip`, `AppShimmer`.
- Every list/detail screen handles: loading, success, empty, error,
  pull-to-refresh, and pagination where the list can grow.

## Testing (flutter_test)

- Domain/data: pure unit tests (use cases, mappers, failure mapping, entity
  helpers, `PermissionResolver`).
- Widgets: pump inside `MaterialApp(theme: AppTheme.light()/dark())`.
  `test/flutter_test_config.dart` already disables google_fonts network fetch.
- Controllers: construct with fake repositories / use cases returning `Result`.
- Every bug fix adds a regression test.

## Verification gate (before "done")

```
dart format .
flutter analyze --fatal-infos
flutter test
```

All clean, strings bilingual, screens dark-safe with all states, permission-gated
where the backend gates it. Then summarise changed files + output.

## Do not

Put logic in widgets or controllers · import Flutter/Dio/GetX from `domain/` ·
expose `DioException` above the data layer · hard-code colours, metrics, English
strings, tenant IDs, roles or production URLs · scatter role checks in the UI ·
construct `Dio()` outside `ApiClient` · import `modules/travel/` from the common
platform · fork the app per role · add a package or a state-management framework
without a clear need · skip the `bn` translation · do unrelated refactoring.
