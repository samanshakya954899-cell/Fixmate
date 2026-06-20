# Mechanic Service App

Flutter + Supabase app for customers to book repair services and providers/mechanics to publish services.

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

5. Run the app with your Supabase values:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

If this folder does not have Android/iOS platform folders yet, run:

```bash
flutter create .
```

Then run the app again.

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
