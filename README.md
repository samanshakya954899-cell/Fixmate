# Mechanic Service App

Flutter app for customers to book repair services and providers/mechanics to publish services. The app currently has Supabase support in Flutter, and a Django backend now lives in `backend/`.

## Features

- Email/password login with Supabase Auth.
- Same user can act as customer and provider.
- Customer direct booking and open requests.
- Provider service publishing with charge, area, experience and availability.
- Booking statuses, chat, ratings and app notifications.
- Supabase SQL schema with Row Level Security policies.
- Local fallback when Supabase keys are not configured.

## Setup

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the Supabase SQL editor.
3. Enable Email provider in Supabase Auth.
4. Install Flutter dependencies:

```bash
flutter pub get
```

5. Run the app:

```bash
flutter run
```

By default, the app connects to this Supabase project:

```text
SUPABASE_URL=https://qeguvopwnyyluynychtj.supabase.co
SUPABASE_ANON_KEY=sb_publishable_R6Zv_H3C8xozJ2EAbqIRRQ_jyUnsOJ6
```

You can override those values when needed:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

When Supabase is configured, signup uses Supabase Auth. The app sends the
email and password to Supabase Auth, and Supabase stores the account securely.
Do not store raw passwords in app tables such as `profiles`.

If this folder does not have Android/iOS platform folders yet, run:

```bash
flutter create .
```

Then run the app again.

## Django Backend

A Python/Django backend is available in `backend/`. It mirrors the app domain with models and JSON API endpoints for auth, profiles, categories, provider services, bookings, chats, ratings, and notifications.

```bash
cd backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

See `backend/README.md` for the full endpoint list.

## Supabase Tables

The schema creates:

- `profiles`
- `provider_profiles`
- `service_categories`
- `provider_services`
- `booking_requests`
- `booking_offers`
- `chats`
- `chat_messages`
- `ratings`
- `notifications`

Initial service categories are TV, Freezer, Cooler, AC and Other.

## Supabase Auth Troubleshooting

If signup or password reset shows an email rate limit message, Supabase has temporarily blocked more confirmation/reset emails for the project. Wait a few minutes before trying again. For production or repeated testing, configure a custom SMTP provider in the Supabase dashboard, or disable email confirmations in the Supabase dashboard while testing.
