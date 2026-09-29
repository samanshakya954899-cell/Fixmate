# Fixmate Django Backend

Python + Django backend for the Fixmate service booking app.

## What It Contains

- Django models for profiles, provider profiles, service categories, services, bookings, offers, chats, ratings, and notifications.
- JSON API routes under `/api/`.
- Email/password sign-up and sign-in using Django auth sessions.
- Six-digit email OTP verification for sign-up and passwordless sign-in.
- Seed data for the five default categories: TV, Freezer, Cooler, AC, and Other.
- Supabase PostgreSQL when `SUPABASE_DB_PASSWORD` is set, with SQLite fallback for local testing.

## Setup

From this `backend` folder:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver 127.0.0.1:8000
```

## Use Supabase As The Backend Database

Use your Supabase project URL:

```text
https://YOUR_PROJECT.supabase.co
```

Django cannot connect to Supabase PostgreSQL with only the project URL. It also needs your private database password from:

```text
Supabase Dashboard -> Project Settings -> Database -> Database password
```

Then run:

```bash
set SUPABASE_DB_PASSWORD=YOUR_DATABASE_PASSWORD
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

When `SUPABASE_DB_PASSWORD` is set, backend data is saved in your Supabase PostgreSQL database, not in `db.sqlite3`.

Health check:

```bash
curl http://127.0.0.1:8000/api/health/
```

Admin:

```text
http://127.0.0.1:8000/admin/
```

## Free Email OTP Setup (Gmail)

Local development uses Django's console email backend by default, so OTP emails
are printed in the backend terminal. To deliver OTPs to real inboxes using a
free Gmail account:

1. Enable 2-Step Verification on the Google account.
2. Create a Google App Password for Mail.
3. Copy `.env.example` to `.env` in this folder.
4. Set `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD`, and `DEFAULT_FROM_EMAIL`.
5. Keep the App Password private. Never put it in Flutter or commit `.env`.

```text
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=1
EMAIL_HOST_USER=your-address@gmail.com
EMAIL_HOST_PASSWORD=your-16-character-app-password
DEFAULT_FROM_EMAIL=FixMate <your-address@gmail.com>
```

Gmail SMTP is suitable for development and small-volume use. Move to a
dedicated transactional email provider if the app's email volume grows.

## API Routes

- `POST /api/auth/account-status/`
- `POST /api/auth/signup/request-otp/`
- `POST /api/auth/signup/verify-otp/`
- `POST /api/auth/signin/request-otp/`
- `POST /api/auth/signin/verify-otp/`
- `POST /api/auth/signup/`
- `POST /api/auth/signin/`
- `POST /api/auth/signout/`
- `GET /api/auth/me/`
- `GET /api/categories/`
- `GET /api/provider-services/`
- `POST /api/provider-services/`
- `POST|PUT|PATCH /api/profile/`
- `POST|PUT|PATCH /api/provider-profile/`
- `GET|POST /api/bookings/`
- `GET /api/provider-bookings/`
- `POST|PATCH /api/bookings/<booking_id>/status/`
- `POST /api/chats/ensure/`
- `GET|POST /api/chats/<chat_id>/messages/`
- `POST /api/bookings/<booking_id>/rating/`
- `GET /api/notifications/`

## Environment

Optional settings:

```bash
set SUPABASE_URL=https://YOUR_PROJECT.supabase.co
set SUPABASE_SECRET_KEY=your-server-only-supabase-secret-key
set DJANGO_SECRET_KEY=change-me
set DJANGO_DEBUG=1
set DJANGO_ALLOWED_HOSTS=127.0.0.1,localhost
set SUPABASE_DB_PASSWORD=your-private-supabase-database-password
set SUPABASE_DB_HOST=db.YOUR_PROJECT.supabase.co
```

For local development, copy `.env.example` to `.env` inside this folder and fill in your private values. `.env` is ignored by Git.

`SUPABASE_SECRET_KEY` is a server-only API key. The Flutter app should use `BACKEND_URL` to talk to Django, not the secret key directly.
