# Fixmate Django Backend

Python + Django backend for the Fixmate service booking app.

## What It Contains

- Django models for profiles, provider profiles, service categories, services, bookings, offers, chats, ratings, and notifications.
- JSON API routes under `/api/`.
- Email/password sign-up and sign-in using Django auth sessions.
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

## API Routes

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
set DJANGO_SECRET_KEY=change-me
set DJANGO_DEBUG=1
set DJANGO_ALLOWED_HOSTS=127.0.0.1,localhost
set SUPABASE_DB_PASSWORD=your-private-supabase-database-password
set SUPABASE_DB_HOST=db.YOUR_PROJECT.supabase.co
```
