# BizOps 360 — Smart Real Estate SaaS: Market Analysis & Build Roadmap

## 1. Why Real Estate, and Why Now (Bangladesh Market Context)

Bangladesh's real estate sector is large, fragmented, and structurally under-digitized — which is exactly the gap a BizOps 360-style vertical SaaS should exploit.

- The trade body REHAB has 930 registered members in 2026, up from just 11 at founding in 1991, and the sector now contributes close to 15% of national GDP.
- Formal registration is only the tip of the iceberg: REHAB's registered members are dwarfed by an estimated 82,000+ companies operating in the market once unregistered developers are included, meaning almost none of them run on real software.
- Growth isn't confined to Dhaka. Chittagong is the second most active market, and secondary cities like Gazipur, Narayanganj, Sylhet and Rajshahi are growing as infrastructure improves, while metro rail, the Padma Bridge and the Purbachal 300-ft road network are visibly repricing the corridors they touch — exactly the kind of location intelligence a "near metro / near landmark" search feature can monetize.
- Two regulators matter for trust and compliance logic: RAJUK (urban planning/approval authority) and REHAB (developer conduct). RAJUK approval is legally required for projects in Dhaka, and REHAB membership gives buyers a body they can escalate disputes to — this is why the spec's "Approval Status" and "Verification Status" fields aren't cosmetic, they're the product's core trust mechanism.
- The existing online layer is thin and mostly classifieds-style: Bproperty is the largest dedicated portal aggregating developer, agent and private listings; Bikroy has a free-to-list classifieds section with inconsistent verification; Pbazaar targets agents with developer integration tools.
- The market leader's own trajectory validates your roadmap direction: Bproperty started as an advertising-style listings business and deliberately transitioned toward transactional services, eventually running a commission-based model of roughly 5% tied to location, utilities and urbanization, and pairing listings with in-house legal vetting, mortgage assistance, valuation and interior design services. It has since consolidated hard — acquiring competitor Lamudi Bangladesh and merging into the Digital Classifieds Group, then in 2025 taking capital from a major local developer conglomerate. In short: **the "go from listings to transactions" bet already worked for the market leader; nobody has done it as a multi-tenant SaaS that developers/agencies run their own business on, with land-share and JV project types natively supported.**

**The white space:** none of the existing players (Bproperty, Bikroy, Pbazaar, Priyangon) are software vendors *to* developers — they're marketplaces that list *for* developers. Your BizOps 360 angle is different and defensible: sell the **operating system** (CRM + inventory + sales pipeline + finance + buyer portal) that a developer or brokerage runs their entire business on, with a public-facing marketplace as a byproduct, not the product.

---

## 2. Product Positioning

| | Bproperty / Bikroy / Pbazaar (classifieds/marketplace) | BizOps 360 Smart Real Estate (SaaS) |
|---|---|---|
| What's sold | Ad space / lead generation | Full business software (multi-tenant) |
| Who's the customer | Anyone who wants exposure | Developers, brokerages, land-share sponsors |
| Data structure | Free-text listing + photos | Structured project/unit/land-share schema |
| Sales process | Off-platform (WhatsApp, phone) | On-platform: lead → visit → negotiation → booking → installment |
| Financials | Not tracked | Native (reuses BizOps 360 Finance module) |
| Trust model | Self-reported | Verification workflow + document custody |
| Land-share / JV projects | Treated like generic listings | First-class project type with land records, share ledger, conditional-benefit clauses |

Position this as **"Salesforce + QuickBooks + a marketplace storefront, built specifically for Bangladeshi developers, land-share sponsors, and brokerages"** — not another Bikroy competitor.

---

## 3. Reused Foundation from BizOps 360 / Travel Agency Build

Since the travel-agency vertical is already shipped, the following stays identical and should **not** be rebuilt:

- **Backend:** Laravel modular monolith, `/api/v1` versioned REST, Actions/DTOs pattern, PostgreSQL, Redis (cache/queues/broadcasting), Filament for the internal admin panel.
- **Mobile:** Flutter + GetX, same navigation shell, same auth/session handling, same notification pipeline.
- **Cross-cutting:** multi-tenancy, RBAC, audit logging, file/document storage, notification service, reporting/dashboard shell, CI/CD pipeline.
- **Finance:** invoices, payments, receivables, partial payments, refunds — Real Estate installments plug into this rather than forking a second ledger.

New for this vertical: a `real_estate` module registered inside the same modular monolith, its own migrations/tables, its own Filament resources, and a new Flutter feature module — following the same pattern the travel-agency module already established. This is a **module addition**, not a new platform.

---

## 4. Multi-Tenancy Model (the SaaS-ification step)

The uploaded spec was written as a single operator's internal system. To turn it into a **sellable SaaS**, three tenancy decisions need to be locked before Phase 1 coding starts:

1. **Tenant = Developer/Agency organization.** Each signs up, gets isolated data (row-level `tenant_id` scoping, consistent with however the travel-agency module already isolates tenants), and manages their own projects, staff, leads, and finance.
2. **Public marketplace = shared layer.** Buyer-facing search/discovery reads across all *verified* tenants' published listings — this is what makes it a marketplace, not just per-tenant software. Buyer accounts, saved searches, and offers are platform-level, not tenant-scoped.
3. **Plan-gated modules.** Land-share/JV project type, broker network, installment automation, and AI search should be tiered (see §7 pricing) so the SaaS has natural upsell paths rather than one flat feature set.

---

## 5. Core Domain Model (carried over from the spec, tightened for build)

```
tenants (developers / agencies)
 └── real_estate_projects
        ├── project_locations         (division/district/area/sector/road/landmarks)
        ├── project_documents         (RAJUK approval, land docs — private by default)
        ├── land_records              (mouza, JL/khatian/dag no. — admin-only visibility)
        ├── land_shares               (share count, per-share value, ownership ledger)
        ├── buildings
        │      └── units
        │             ├── unit_media
        │             └── unit_prices
        ├── amenities
        ├── project_pricing           (land + construction + consultancy → estimated total)
        └── project_payment_plans     (installment templates)

buyers (platform-level)
 ├── property_requirements
 ├── property_matches
 ├── saved_projects
 ├── site_visits
 ├── offers                           (structured negotiation, not chat)
 ├── bookings
 ├── installment_plans / installments
 └── documents (agreements, receipts)

leads, customers, sales_activities     (CRM layer, tenant-scoped)
verification_reviews                   (admin: pending → verified/rejected, per project)
```

This matches the spec's §19 concept exactly, with `land_records` split out from `land_shares` since one is legal/private and the other is commercial/ledger data with different access rules.

---

## 6. Phased Roadmap

### Phase 0 — Foundation & Module Scaffolding (2–3 weeks)
- Register `real_estate` module in the modular monolith; wire tenant scoping.
- Migrate schema in §5 (projects → land → buildings/units → payment plans).
- Filament resources for Admin/Seller: create project wizard mirroring the spec's Steps 1–14 (project type → location → land info → building info → amenities → media → contact).
- Flutter: seller-side "Post Project" flow (reuse travel-agency's multi-step form pattern), buyer-side project detail screen.
- **Definition of done:** a seller can create a fully structured land-share project (like the Uttara Diabari example) and it renders correctly on a buyer detail screen — no search, no transactions yet.

### Phase 1 — MVP: One Working Commercial Loop (4–6 weeks)
Scope locked to the spec's core promise:
`Lead → Requirement → Property Match → Site Visit → Negotiation → Reservation → Booking → Installment → Completion`
- Leads/customers CRM, property requirement capture, basic rule-based matching (structured filters, not AI yet).
- Site visit scheduling + notifications.
- **Structured Offer & Negotiation workflow** (§ from the follow-up conversation: buyer offer → seller accept/reject/counter → offer history → final agreed price flows into booking, never re-typed).
- Reservation → Booking → Installment plan generation, wired into the existing Finance module (invoices/payments/receivables).
- Basic admin verification status (Pending / Verified / Rejected) with document checklist — no automated document OCR yet, just human review workflow.
- **Definition of done:** one tenant can run an entire sale end-to-end inside the platform, with a real installment schedule a buyer can see paid/due/remaining.

### Phase 2 — Buyer Journey & Trust Layer (4–5 weeks)
- Buyer account: "My Properties" dashboard (unit, agreed price, paid/remaining/next due — as specified).
- Compare feature (price/size/location/amenities/payment options side by side).
- Broker/channel-partner structure: broker referral tracking, commission rules feeding into Finance.
- Full verification workflow: seller-submitted vs platform-verified badge, document custody, RAJUK approval status with proof upload required before a project can show "RAJUK Approved" publicly (this directly answers the spec's own warning against unverified status claims).
- Bangladesh location structure + landmark-based search (division/district/area/sector + nearby landmarks), still keyword-based, not NLP yet.
- **Definition of done:** a buyer can browse only verified listings, compare three projects, and track their own purchase after booking.

### Phase 3 — Marketplace & Multi-Tenant Commercialization (4 weeks)
- Public marketplace surface aggregating all verified tenants (the shared layer from §4).
- Tenant onboarding/self-serve signup, plan selection, billing (subscription + listing limits).
- Reports & dashboards: per-tenant sales pipeline, collections, inventory status.
- Notification system fully wired (payment due, visit reminders, booking status, document uploads).
- **Definition of done:** a second, unrelated developer can sign up without your involvement, post a project, and appear in the public marketplace next to the first tenant's listings.

### Phase 4 — Smart Search & AI Layer (deliberately last, 3–5 weeks)
- Bangla/English NLP query parsing (e.g. "Uttara te metro station er kache 50 lakh er moddhe 3 bedroom") mapped to the structured filters already in place — this only works *because* Phases 0–3 forced sellers into structured fields instead of free text.
- Smart matching between buyer requirements and inventory (score-based, then optionally ML-ranked).
- **Definition of done:** natural-language Bangla/English search returns structurally correct results, provably better than a keyword search over free-text descriptions.

### Phase 5 — Scale Hardening
- Load/perf testing at multi-tenant scale, CI/CD maturity, security review of document storage (land ownership docs are sensitive), backup/DR for financial data.

---

## 7. Monetization Model for the SaaS

Reuse the market's proven pattern (Bproperty's own shift from ads to transactions) but sell it as software:

- **Tenant subscription tiers** (monthly, per developer/agency): Starter (single project, core CRM), Growth (multi-project, broker network, installment automation), Enterprise (API access, custom reports, dedicated verification queue).
- **Verification/trust fee**: one-time or annual fee per project for the "Platform Verified" badge — directly monetizes the trust gap that unregistered developers can't buy their way past.
- **Transaction-linked fee** (optional, later phase): small percentage or flat fee on completed bookings processed through the platform's installment engine — mirrors Bproperty's ~5% commission model but only on platform-processed transactions, not all listings.
- **Featured placement** on the public marketplace — classic marketplace upsell, low build cost, immediate revenue in Phase 3.
- **Broker network fee** — brokerages pay to plug into developer inventory rather than negotiating access manually.

---

## 8. Rough Team & Timeline

| Phase | Duration | Core roles needed |
|---|---|---|
| 0 – Foundation | 2–3 wks | 1 backend (Laravel), 1 Flutter dev |
| 1 – MVP loop | 4–6 wks | +1 backend, QA |
| 2 – Buyer/Trust | 4–5 wks | +1 Flutter (buyer app), designer for verification UX |
| 3 – Marketplace/Billing | 4 wks | +billing/payments integration dev |
| 4 – AI search | 3–5 wks | +NLP/ML contractor (Bangla language handling) |
| 5 – Hardening | 2–3 wks | DevOps/security review |

**Total to a commercially sellable multi-tenant SaaS: roughly 5–6 months** with a small team, assuming the travel-agency codebase's shared infrastructure (auth, tenancy, Finance, notifications, admin shell) is reused rather than rebuilt — which is the whole point of the BizOps 360 modular-monolith strategy.

---

## 9. Key Risks

1. **Trust/fraud risk is existential, not cosmetic** — land-share and JV projects are exactly the structure most associated with buyer disputes in Bangladesh. The verification workflow (Phase 2) cannot be cut for speed; it's the product's main differentiator vs. free-text classifieds.
2. **RAJUK/REHAB status claims carry legal weight** — never let a tenant self-declare "RAJUK Approved" without a document review gate, per the spec's own warning.
3. **Document custody = sensitive data** — land ownership and khatian/dag records need stricter access control than the rest of the app; treat this as a security-review item, not a generic file upload.
4. **NLP search (Phase 4) is the highest-uncertainty item** — sequencing it last is correct; don't let it block the commercial MVP.
5. **Marketplace network effects favor incumbents** — Bproperty already has hundreds of thousands of listings and brand recognition. Compete on being the system developers *run their business on*, not on listing volume, at least until Phase 3+.

---

## 10. Immediate Next Steps

1. Confirm tenancy boundary decisions in §4 before writing any migrations.
2. Turn Phase 0–1 of this roadmap into the Claude Code implementation plan (backend modules → tables → APIs → Flutter folders → prompts), the way you did for the travel agency build.
3. Decide Phase 1 payment gateway/integration scope now (bKash/Nagad/bank transfer reconciliation) since it gates the installment engine.
4. Lock the verification document checklist (RAJUK approval doc, land ownership doc, mutation doc) with legal/ops input before building the Filament review screen.

---

## Sources

- REHAB (Wikipedia): https://en.wikipedia.org/wiki/Real_Estate_and_Housing_Association_of_Bangladesh
- Dreamway Holdings, "Bangladesh Real Estate Company List": https://www.dreamwayhl.com/blogs/bangladesh-real-estate-company-list
- Dreamway Holdings, "Real Estate Company in Bangladesh": https://www.dreamwayhl.com/blogs/real-estate-company-bangladesh
- Dreamway Holdings, "Real Estate Agents in Bangladesh": https://www.dreamwayhl.com/blogs/real-estate-agents-in-bangladesh
- Ray White Ltd, "Top 10 Real Estate Companies in Bangladesh 2026": https://raywhiteltd.com/top-10-real-estate-companies-in-bangladesh/
- Dealroom, "B Property": https://app.dealroom.co/companies/bd_property
- The Daily Star, "bproperty.com buys Lamudi Bangladesh": https://www.thedailystar.net/node/1684549
- The Daily Star, "Bproperty gets $10m from parent company for expansion": https://www.thedailystar.net/node/1705633
- Dhaka Tribune, "Bproperty, Digital Classifieds Group come together": https://www.dhakatribune.com/business/281456/bproperty-digital-classifieds-group-come-together
