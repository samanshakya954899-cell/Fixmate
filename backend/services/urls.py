from django.urls import path

from . import views


urlpatterns = [
    path("health/", views.health, name="health"),
    path("auth/account-status/", views.account_status, name="account-status"),
    path("auth/signup/request-otp/", views.request_signup_otp, name="request-signup-otp"),
    path("auth/signup/verify-otp/", views.verify_signup_otp, name="verify-signup-otp"),
    path("auth/signin/request-otp/", views.request_signin_otp, name="request-signin-otp"),
    path("auth/signin/verify-otp/", views.verify_signin_otp, name="verify-signin-otp"),
    path("auth/signup/", views.signup, name="signup"),
    path("auth/signin/", views.signin, name="signin"),
    path("auth/signout/", views.signout, name="signout"),
    path("auth/me/", views.me, name="me"),
    path("categories/", views.categories, name="categories"),
    path("provider-services/", views.provider_services, name="provider-services"),
    path("profile/", views.save_profile, name="profile"),
    path("provider-profile/", views.save_provider_profile, name="provider-profile"),
    path("bookings/", views.bookings, name="bookings"),
    path(
        "provider-bookings/",
        views.provider_incoming_bookings,
        name="provider-bookings",
    ),
    path(
        "bookings/<uuid:booking_id>/status/",
        views.update_booking_status,
        name="booking-status",
    ),
    path("chats/ensure/", views.ensure_chat, name="ensure-chat"),
    path("chats/<uuid:chat_id>/messages/", views.chat_messages, name="chat-messages"),
    path("bookings/<uuid:booking_id>/rating/", views.rate_booking, name="rating"),
    path("notifications/", views.notifications, name="notifications"),
]
