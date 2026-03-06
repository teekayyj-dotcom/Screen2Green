# Screen Time & Digital Wellness Application — Implementation Plan

## Executive Summary

This document outlines the architecture and implementation roadmap for a digital wellness application that combines **screen time tracking**, **AI-based addiction analysis**, **gamification**, and **real tree planting** rewards.

---

## 1. Current State vs. Target State

### What You Already Have ✓
- FastAPI backend skeleton
- MySQL database (Docker)
- User model structure (needs Base fix)
- Auth & user endpoints (partially stubbed)
- Docker Compose setup
- Requirements: TensorFlow, Firebase, SQLAlchemy, Alembic

### What Needs to Be Built
- Complete API (`app.api.v1.api` router — currently missing)
- Screen time models, schemas, and endpoints
- Points, badges, challenges, leaderboards
- AI pipeline (training + TFLite inference)
- NGO tree planting integration
- Flutter mobile app (new)
- Firebase auth & Firestore/Realtime DB integration

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER MOBILE APP                                 │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐│
│  │ Screen Time  │ │ Dashboard &  │ │ Gamification │ │ TFLite Inference     ││
│  │ Tracker      │ │ Charts       │ │ UI           │ │ (on-device AI)       ││
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └──────────┬───────────┘│
└─────────┼────────────────┼────────────────┼────────────────────┼────────────┘
          │                │                │                    │
          │  Usage Stats    │  Fetch Data    │  Points/Challenges │
          ▼                ▼                ▼                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FIREBASE                                             │
│  Auth │ Firestore (users, points, badges) │ Cloud Messaging (notifications)  │
└─────────────────────────────────────────────────────────────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PYTHON BACKEND (FastAPI)                             │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────────────────────┐│
│  │ Screen     │ │ AI Service │ │ Gamification│ │ NGO Integration           ││
│  │ Time API   │ │ (offline)  │ │ API         │ │ (tree planting API)       ││
│  └────────────┘ └────────────┘ └────────────┘ └────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────┐     ┌─────────────────────┐
│  MySQL              │     │  NGO Tree Planting  │
│  (usage logs,       │     │  API (e.g. One     │
│   transactions)     │     │  Tree Planted)     │
└─────────────────────┘     └─────────────────────┘
```

---

## 3. Data Models (Backend)

### Core Tables

| Table | Purpose |
|-------|---------|
| `users` | Extended from Firebase UID; store profile, membership_level |
| `screen_time_logs` | Daily per-app usage (app_name, duration_minutes, date, user_id) |
| `points` | Green points per user, history of earn/spend |
| `badges` | Badge definitions (id, name, icon, criteria) |
| `user_badges` | user_id, badge_id, earned_at |
| `challenges` | Challenge definitions (e.g. "No social media after 10PM") |
| `user_challenges` | user_id, challenge_id, status, completed_at |
| `tree_planting_transactions` | user_id, points_spent, tree_count, ngo_reference, created_at |
| `leaderboard_snapshots` | Optional: daily/weekly rankings |

---

## 4. API Endpoints Structure

### Auth (Firebase Integration)
- `POST /api/v1/auth/register` — Create user in DB after Firebase sign-up
- `POST /api/v1/auth/verify` — Verify Firebase token, return internal JWT/session
- `POST /api/v1/auth/refresh` — Refresh token

### Screen Time
- `POST /api/v1/screen-time/log` — Batch upload daily usage (from mobile)
- `GET /api/v1/screen-time/summary` — Daily/weekly totals, per-app breakdown
- `GET /api/v1/screen-time/history` — Historical data for charts

### Gamification
- `GET /api/v1/points` — Current points balance
- `GET /api/v1/badges` — Available badges
- `GET /api/v1/users/me/badges` — User's earned badges
- `GET /api/v1/challenges` — Active challenges
- `POST /api/v1/challenges/{id}/join` — Join challenge
- `POST /api/v1/challenges/{id}/complete` — Mark complete (with validation)
- `GET /api/v1/leaderboard` — Rankings (daily, weekly, all-time)

### Tree Planting
- `POST /api/v1/trees/plant` — Convert points to trees (calls NGO API)
- `GET /api/v1/trees/history` — User's tree planting history
- `GET /api/v1/trees/stats` — Total trees, CO₂ offset

### AI Recommendations
- `GET /api/v1/recommendations` — Personalized tips (can be server-side or TFLite-assisted)
- `POST /api/v1/ai/analyze` — Optional: server-side analysis for complex models

### Dashboard
- `GET /api/v1/dashboard` — Aggregated stats: screen time, points, trees, badges, rank

---

## 5. Mobile (Flutter) Structure

```
mobile_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── api/           # API client
│   │   ├── auth/          # Firebase Auth
│   │   └── storage/       # Local storage
│   ├── features/
│   │   ├── auth/
│   │   ├── screen_time/   # Usage tracking + charts
│   │   ├── dashboard/
│   │   ├── gamification/  # Points, badges, challenges, leaderboard
│   │   ├── trees/         # Tree planting UI
│   │   └── recommendations/
│   ├── models/
│   ├── providers/         # State management (Riverpod/Bloc)
│   └── assets/
│       └── ml/            # TFLite model
├── android/
│   └── (permission for UsageStats / App Usage)
├── ios/
│   └── (Screen Time API / FamilyControls if applicable)
└── pubspec.yaml
```

### Screen Time on Mobile

- **Android**: `UsageStatsManager` (API 21+) — requires `PACKAGE_USAGE_STATS` permission.
- **iOS**: `DeviceActivityReport` / `FamilyControls` (iOS 15+) — restricted to Family Sharing / Managed Devices, or use `Screen Time API` with MDM. For typical apps, consider **manual logging** or **Focus Mode** integrations as fallback.
- **Alternative**: Use `screen_time` / `app_usage` packages; be aware of platform limitations.

---

## 6. AI Pipeline

### Training (Python Backend / Notebook)
1. Collect labeled data: `(user_id, daily_usage_by_app, time_of_day, total_minutes)` → addiction risk level.
2. Build classifier (e.g. Random Forest, or simple NN) to predict:
   - Risk level (low / medium / high)
   - Behavior labels (e.g. "night_heavy", "social_media_dominant")
3. Export to TFLite: `tf.lite.TFLiteConverter.from_keras_model()`.
4. Host `.tflite` in backend and/or bundle in Flutter assets.

### Inference (Flutter)
- Use `tflite_flutter` package.
- Input: aggregated daily features (e.g. total mins, social media mins, night usage).
- Output: risk score + suggested actions.
- Optionally sync with backend for logging and model improvement.

---

## 7. NGO Tree Planting Integration

### Options
- **One Tree Planted** — [onetreeplanted.org](https://onetreeplanted.org) — check for partner/API programs.
- **Treedom** — [treedom.net](https://www.treedom.net) — API for planting trees.
- **Eden Reforestation** — [edenprojects.org](https://www.edenprojects.org) — partnership-based.
- **Custom NGO** — If you have a local partner, design a simple REST API: `POST /plant` with `{points, user_id}` → returns `{trees_planted, transaction_id}`.

### Flow
1. User spends Green Points in app.
2. Backend validates balance, calls NGO API.
3. Store transaction in `tree_planting_transactions`.
4. Deduct points, return confirmation to app.

---

## 8. Implementation Phases

### Phase 1: Foundation (2–3 weeks)
- [ ] Fix backend structure: create `app.api.v1.api`, wire routers
- [ ] Complete User model and base (SQLAlchemy Base)
- [ ] Firebase Auth integration (verify token in FastAPI)
- [ ] Screen time models, schemas, CRUD, `POST /log`, `GET /summary`
- [ ] Basic Flutter app: login, home screen, API client

### Phase 2: Screen Time & Dashboard (2 weeks)
- [ ] Flutter: UsageStats integration (Android) / manual logging fallback (iOS)
- [ ] Dashboard API: `GET /dashboard`
- [ ] Flutter: charts (e.g. `fl_chart`), daily/weekly views
- [ ] Background sync of usage to backend

### Phase 3: Gamification (2–3 weeks)
- [ ] Points system: earn rules (reduce screen time, complete challenges, quizzes)
- [ ] Badges model + API + Flutter UI
- [ ] Challenges model + join/complete logic + validation
- [ ] Leaderboard API + Flutter UI

### Phase 4: AI & Recommendations (2 weeks)
- [ ] Train simple model on sample data
- [ ] Export TFLite, integrate in Flutter
- [ ] Recommendation engine (rule-based + model output)
- [ ] Notification triggers (e.g. "3 hours used", "break reminder")

### Phase 5: Tree Planting & Polish (1–2 weeks)
- [ ] NGO API integration (or mock)
- [ ] Tree planting flow: spend points → API call → confirm
- [ ] Trees + CO₂ stats in dashboard
- [ ] Community/sharing features (optional)

### Phase 6: Testing & Deployment
- [ ] Unit + integration tests
- [ ] Security review (auth, rate limiting)
- [ ] Deploy backend (e.g. Cloud Run, AWS)
- [ ] App Store / Play Store submission

---

## 9. Technology Summary

| Component | Technology |
|-----------|------------|
| Mobile | Flutter |
| Backend | Python, FastAPI |
| Database | MySQL (primary), Firebase Firestore (optional for real-time) |
| Auth | Firebase Auth |
| ML | TensorFlow (training), TensorFlow Lite (mobile) |
| NGO | REST API (Treedom, One Tree Planted, or custom) |
| Notifications | Firebase Cloud Messaging |

---

## 10. Key Considerations

### Permissions & Privacy
- Clearly explain why usage data is collected.
- Store minimal data; consider on-device aggregation before upload.
- Comply with GDPR/CCPA if serving EU/California users.

### Platform Limitations
- **iOS**: Full per-app screen time requires FamilyControls (restricted). Many apps use manual logging or third-party integrations.
- **Android**: UsageStats works well; ensure `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` for background sync.

### Scalability
- Batch screen-time uploads (e.g. once per day) to reduce API load.
- Cache leaderboard; recompute periodically.
- Use Redis for rate limiting and session cache in production.

---

## Next Steps

1. **Choose implementation starting point**: Backend API fixes, Flutter scaffold, or database migrations.
2. **Pick NGO partner** and confirm API availability.
3. **Decide iOS strategy**: manual logging vs. exploring Screen Time APIs.
4. **Create `.env.example`** with placeholders for Firebase, DB, NGO API keys.

I can help you implement any phase in detail—tell me which part you want to build first (e.g. "Phase 1 backend", "Flutter screen time", "Gamification API").
