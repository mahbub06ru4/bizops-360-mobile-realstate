# Handoff — BizOps 360 Smart Real Estate mobile roadmap

State of the repo and the queued work. Read [`CLAUDE.md`](../CLAUDE.md) first for
architecture and conventions, and [`BizOps360_SmartRealEstate_SaaS_Roadmap.md`](BizOps360_SmartRealEstate_SaaS_Roadmap.md)
for the full product spec — this doc is the where-we-are / what-next.

**Product decision (2026): one multi-tenant Flutter app, Smart Real Estate
vertical, GetX.** Forked from `bizops360-mobile-travel` (same shell, same
shared platform code); only `lib/modules/` and the vertical-specific domain
differ. One login, one application — it adapts by
`tenant → industry → role → permissions → enabled features`.

---

## 1. What exists now (Phase 0 — done, 2026-09-14)

| Area | Status |
|---|---|
| Fork | Copied from `bizops360-mobile-travel`, then travel module (`bookings/travellers/visa/dashboard`) fully removed and replaced with `modules/real_estate/`. |
| Domain | `RealEstateProject`, `ProjectLocation`, `Building`, `Unit`, `UnitMedia`, `UnitPrice`, `Amenity`, `ProjectPricing`, `PaymentPlan` entities + `RealEstateProjectRepository` interface. |
| Data | `RealEstateRemoteDataSource` + mappers + real/fake repository pair. Fake repo seeded with 3 demo projects (Diabari/Uttara land-share, Khulshi/Chattogram apartment tower, Konabari/Gazipur commercial draft) — fully functional in-memory CRUD, no backend required. |
| Module | `modules/real_estate/projects/` — seller "Post Project" multi-step wizard (type → location → land → building → amenities → media → contact), project list screen, shared project detail screen (buyer/seller views differ by permission-gated actions, not separate screens). `modules/real_estate/dashboard/` — "My Projects" Home section. |
| Routing/nav | `/projects`, `/projects/post`, `/project` registered; bottom nav swapped Visa → **Projects** tab. |
| Permissions | `Perm.project{View,Create,Manage,Submit}`, `Feature.realEstateProjects`; `isTravel`/`travelOnly` renamed to `isRealEstate`/`industryOnly`. |
| i18n | ~50 new `proj.*` / `pp.*` keys, en + bn. Travel/visa/booking-only keys removed. |
| Tests | `flutter test` — 84 passing, 1 skipped (pre-existing `--tags integration`, needs a live API). `flutter analyze --fatal-infos` clean, `dart format` clean. |
| pubspec | Description updated to Smart Real Estate; added `image_picker` for the Post Project photo step. |

**Not built yet (by design — Phase 0 excludes it):** public browse/search,
leads/requirements/matching, site visits, offers/negotiation, bookings,
installments, buyer dashboard, verification badges, marketplace. See §3.

---

## 2. Running it on Windows

### One-time
1. Flutter 3.38.x already on PATH (`flutter --version` to confirm).
2. `flutter pub get`

### Day to day
```bash
flutter run                                                     # Android emulator → host localhost (http://10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://192.168.0.x        # physical Android device → PC LAN IP
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost
```
`API_BASE_URL` is **origin only** — `Env` appends `/api/v1`. The app runs
entirely on fake data by default (`USE_FAKE_DATA` defaults true until the API
is reachable) — no backend needed to click through the Post Project wizard and
project detail screen today.

### The backend
`bizops360-api` is a separate repo (Laravel + Sail, developed on the Mac via
Docker). Demo logins after `php artisan migrate:fresh --seed`:
`owner@skyline.test` / `manager@skyline.test` / `staff@skyline.test`, password
`password` (`skyline` = the real-estate demo tenant, "Skyline Properties").

---

## 3. Work queue — phased roadmap

Full detail in `BizOps360_SmartRealEstate_SaaS_Roadmap.md` §7. Mobile-relevant
summary:

| Phase | Scope | Status |
|---|---|---|
| **0 — Foundation** | Schema + seller Post Project flow + buyer detail screen. No search/transactions. | ✅ done (this handoff) |
| **1 — MVP sales pipeline** | Leads → Requirement → Property Match (rule-based filters) → Site Visit → structured Offer/Negotiation → Reservation → Booking → Installments (via existing Finance module). Basic admin verification (Pending/Verified/Rejected), manual doc review. | ⬜ next |
| **2 — Buyer journey & trust** | Buyer "My Properties" dashboard (paid/remaining/next due), compare feature, broker/commission, full verification workflow + RAJUK-approval proof-upload gate, BD location + landmark keyword search. | ⬜ |
| **3 — Marketplace & commercialization** | Public marketplace (verified listings only, cross-tenant), self-serve tenant onboarding/billing, per-tenant dashboards, full notification wiring. | ⬜ |
| **4 — Smart search & AI** | Bangla/English NLP query parsing, score-based matching. Deliberately last. | ⬜ |
| **5 — Scale hardening** | Load/perf, security review of document storage, backup/DR. | ⬜ |

### Phase 1 mobile work, concretely (next PR-sized chunks)
1. `modules/real_estate/leads/` — lead capture + requirement form (reuses the
   existing shared CRM lead entity/repository where possible; extend, don't
   duplicate).
2. `modules/real_estate/matching/` — property-match list against a buyer's
   requirement (structured filters only, no NLP).
3. `modules/real_estate/site_visits/` — scheduling UI, calendar-ish list.
4. `modules/real_estate/offers/` — structured offer/negotiation thread (offer →
   counter → accept/reject → history), not free-form chat.
5. Wire booking → installment screens into the existing `presentation/finance/`
   invoice/payment views rather than building a parallel ledger UI (Finance is
   reused as-is per the roadmap).
6. Extend `RealEstateProjectRepository`/`RealEstateRemoteDataSource` for the
   above as the corresponding backend endpoints land — check
   `app/Modules/Industry/RealEstate/Routes/api.php` in `bizops360-api` for the
   authoritative shape before adding a new datasource method.

---

## 4. Backend endpoints in play (Phase 0)

Matches `app/Modules/Industry/RealEstate/Routes/api.php` in `bizops360-api`
exactly (all under `/api/v1`, gated by `industry:real_estate`):

```
GET/POST   /projects
GET/PUT/DELETE /projects/{project}
POST       /projects/{project}/submit
POST       /projects/{project}/location
POST       /projects/{project}/pricing
POST       /projects/{project}/payment-plans
POST       /projects/{project}/land-shares
POST       /projects/{project}/land-records
GET/POST   /projects/{project}/documents
POST       /projects/{project}/buildings
GET/PUT/DELETE /buildings/{building}
POST       /buildings/{building}/units
GET/PUT/DELETE /units/{unit}
POST       /units/{unit}/media
POST       /units/{unit}/prices
POST       /projects/{project}/amenities
DELETE     /amenities/{amenity}
```

`land-records` and `project-documents` are legally/privately sensitive
(RAJUK approval, land deeds) — the mobile app must never surface them to a
role without the corresponding permission (see `CLAUDE.md` rule 8). Media
upload (`units/{unit}/media`) is currently JSON-body (`{url, caption,
is_primary}`), assuming the file is already hosted; a real multipart or
pre-signed-URL upload step ahead of this call is still open — see §5.

## 4a. Backend endpoints in play (Phase 1 — sales pipeline)

Matches `app/Modules/Industry/RealEstate/Routes/api.php` exactly, same
`/api/v1` + `industry:real_estate` gate as above. `lead` here is CRM's
existing `Lead` (route-bound `{lead}`), not a real-estate-only concept —
Phase 1 attaches to it rather than duplicating it.

```
GET        /site-visits                              tenant-wide list (?status=)
GET/POST   /leads/{lead}/site-visits
GET        /site-visits/{visit}
POST       /site-visits/{visit}/complete              body: {feedback}
POST       /site-visits/{visit}/cancel                no body

GET        /offers                                    tenant-wide list (?latest_per_thread=true|false)
GET/POST   /leads/{lead}/offers                        body: {unit_id, offered_price, offered_by?, notes?}
GET        /offers/{offer}                             embeds counter_offers (= the negotiation history)
POST       /offers/{offer}/counter                     body: {offered_price, offered_by?, notes?}
POST       /offers/{offer}/accept                      no body
POST       /offers/{offer}/reject                      no body

POST       /offers/{offer}/reserve                     creates the booking — no body
GET        /real-estate-bookings                       tenant-wide list (?status=)
GET        /real-estate-bookings/{booking}              embeds installment_plan (only on show)
POST       /real-estate-bookings/{booking}/confirm       reserved -> booked (not "confirmed")
POST       /real-estate-bookings/{booking}/cancel

POST       /real-estate-bookings/{booking}/installment-plan   body: {down_payment_amount, installment_count, frequency, start_date}
GET        /installment-plans/{installmentPlan}          embeds installments

GET/POST   /leads/{lead}/requirements                    body: {budget_min?, budget_max?, preferred_locations?, unit_type?, bedrooms_min?, purpose?, notes?}
GET        /requirements/{requirement}                    embeds matches (each with its unit)
POST       /requirements/{requirement}/match              runs rule-based matching, returns the match array directly

GET        /installments/{installment}
POST       /installments/{installment}/generate-invoice   raises a Finance invoice
POST       /installments/{installment}/mark-paid          manual settlement (no gateway reconciliation yet)
```

Key gotchas that caused a first-pass mismatch between the backend and mobile
builds (both were built in parallel without seeing each other):
- Site-visit/offer **create and per-lead list** are nested under `leads/{lead}/...`
  — the lead never goes in the request body.
- A booking is created only via `POST /offers/{offer}/reserve` (the offer must
  already be `accepted`) — there is no generic `POST /real-estate-bookings`.
- `RealEstateBooking.status` is `reserved | booked | cancelled | completed`
  — the `confirm` action's result is `booked`, not `confirmed`.
- `installment_plan` is only embedded on the booking's `show` response, never
  on list responses. An installment plan can only be created once the booking
  is `booked` (or `completed`).
- Offer/site-visit/requirement/booking responses embed a lightweight `lead`
  (`{id, name}`) and `unit`/`project` (`{id, unit_number|name, project_id?,
  project_name?}`) display object when the relation is loaded — the mobile
  app should read these instead of carrying its own synthesized
  `leadName`/`projectTitle`/`unitName` fields, which don't exist server-side.
- `down_payment_amount` is an absolute BDT amount, not a percent.

---

## 5. Open items / manual follow-ups

1. **Media upload flow** — decide multipart vs. pre-signed URL for
   `RealEstateRemoteDataSource.uploadMedia` and wire it once the backend's
   storage endpoint is confirmed.
2. **Backend verification** — the backend module was written without a local
   PHP 8.4 toolchain (Windows only has 7.4). Run on the Mac before merging:
   `sail artisan migrate`, `sail artisan db:seed --class=DemoSeeder`,
   `vendor/bin/pint`, `vendor/bin/phpstan analyse`, `php artisan test`.
3. **Unit pricing on create** — `addUnit` currently rides an optional first
   price line in its own payload; the dedicated `POST /units/{unit}/prices`
   endpoint exists server-side and is now also wired client-side
   (`addUnitPrice`) but not yet called from the Post Project wizard — hook it
   up if/when the wizard needs multiple price tiers per unit (e.g. per-share
   pricing for land-share units).
4. **Pest tests** — the backend agent flagged missing tenant-isolation +
   policy tests for `ProjectPolicy`/`LandRecordPolicy`; add these before the
   module is considered production-ready given land data's legal sensitivity.
