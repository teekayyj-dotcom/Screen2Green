# Screen Time & Digital Wellness Application

A digital wellness app that tracks screen time, analyzes usage with AI, gamifies healthy habits, and converts reward points into real tree planting.

## Features

- **Screen Time Tracking** — Monitor daily usage per app
- **AI-Based Analysis** — Detect addiction patterns, generate recommendations (TensorFlow Lite)
- **Gamification** — Points, badges, challenges, leaderboard
- **Tree Planting** — Convert Green Points to real trees via NGO API
- **Dashboard** — Statistics, charts, CO₂ offset
- **Notifications** — Reminders and behavioral suggestions

## Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile | Flutter |
| Backend | Python, FastAPI |
| Database | MySQL |
| Auth | Firebase Auth |
| ML | TensorFlow, TensorFlow Lite |
| NGO | REST API integration |

## Project Structure

```
Application/
├── backend/          # FastAPI backend
├── mobile/           # Flutter app (to be created)
├── models/           # TFLite model files
├── PROJECT_PLAN.md   # Detailed implementation plan
├── docker-compose.yml
└── .env.example
```

## Quick Start

### Backend

```bash
# Copy environment
cp .env.example .env
# Edit .env with your values

# Run with Docker
docker-compose up -d
```

### Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

## Documentation

See **[PROJECT_PLAN.md](./PROJECT_PLAN.md)** for:

- System architecture
- Data models
- API endpoint design
- Phased implementation roadmap
- Platform-specific notes (Android/iOS)
- NGO integration options
