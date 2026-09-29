import json
import re

from django.contrib.auth.models import User
from django.core import mail
from django.test import TestCase, override_settings

from .models import Profile, ProviderProfile


@override_settings(
    EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend",
    OTP_RESEND_SECONDS=0,
)
class EmailOtpFlowTests(TestCase):
    def post_json(self, path, data):
        return self.client.post(
            path,
            data=json.dumps(data),
            content_type="application/json",
        )

    def latest_code(self):
        return re.search(r"\b(\d{6})\b", mail.outbox[-1].body).group(1)

    def test_signup_otp_creates_verified_provider_session(self):
        email = "new-provider@example.com"
        response = self.post_json(
            "/api/auth/signup/request-otp/",
            {
                "email": email,
                "name": "New Provider",
                "company_name": "Fix Team",
                "password": "StrongPass123!",
                "account_type": "provider",
            },
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(mail.outbox), 1)

        response = self.post_json(
            "/api/auth/signup/verify-otp/",
            {"email": email, "code": self.latest_code()},
        )
        self.assertEqual(response.status_code, 201)
        profile = Profile.objects.get(user__username=email)
        self.assertIn(Profile.PROVIDER, profile.roles)
        self.assertEqual(
            ProviderProfile.objects.get(profile=profile).business_name,
            "Fix Team",
        )
        self.assertEqual(self.client.get("/api/categories/").status_code, 200)

    def test_existing_user_can_sign_in_with_otp(self):
        user = User.objects.create_user(
            username="existing@example.com",
            email="existing@example.com",
            password="StrongPass123!",
        )
        response = self.post_json(
            "/api/auth/signin/request-otp/",
            {"email": user.email},
        )
        self.assertEqual(response.status_code, 200)

        response = self.post_json(
            "/api/auth/signin/verify-otp/",
            {"email": user.email, "code": self.latest_code()},
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(self.client.get("/api/categories/").status_code, 200)
