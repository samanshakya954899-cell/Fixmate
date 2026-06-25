# Mechanic Service App

Flutter app for customers to book repair services and providers/mechanics to publish services. The app currently has Supabase support in Flutter, and a Django backend now lives in `backend/`.

## Features

- Email/password login with Supabase Auth.
- Same user can act as customer and provider.
- Customer direct booking and open requests.
- Provider service publishing with charge, area, experience and availability.
- Booking statuses, chat, ratings and app notifications.
- Supabase SQL schema with Row Level Security policies.
- Demo fallback when Supabase keys are not configured.

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

The app includes these Supabase defaults for local development:

```text
SUPABASE_URL=https://iuglzyewnixqneqtktte.supabase.co
SUPABASE_ANON_KEY=sb_publishable_Xel6eKNmPXR3h41u9gy-WQ_kftNxL-k
```

You can still override them when needed:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

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

If signup or password reset shows an email rate limit message, Supabase has temporarily blocked more confirmation/reset emails for the project. Wait a few minutes before trying again. For local testing, you can also disable email confirmations in the Supabase dashboard under Authentication settings so signup does not need to send a confirmation email every time.
