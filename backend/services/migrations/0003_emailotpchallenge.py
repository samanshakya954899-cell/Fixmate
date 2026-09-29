from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("services", "0002_seed_categories"),
    ]

    operations = [
        migrations.CreateModel(
            name="EmailOtpChallenge",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("email", models.EmailField(max_length=254)),
                ("purpose", models.CharField(choices=[("signup", "Sign up"), ("signin", "Sign in")], max_length=20)),
                ("code_hash", models.CharField(max_length=255)),
                ("password_hash", models.CharField(blank=True, max_length=255)),
                ("full_name", models.CharField(blank=True, max_length=255)),
                ("company_name", models.CharField(blank=True, max_length=255)),
                ("account_type", models.CharField(default="customer", max_length=20)),
                ("attempts", models.PositiveSmallIntegerField(default=0)),
                ("expires_at", models.DateTimeField()),
                ("last_sent_at", models.DateTimeField(auto_now=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.AddConstraint(
            model_name="emailotpchallenge",
            constraint=models.UniqueConstraint(fields=("email", "purpose"), name="unique_email_otp_purpose"),
        ),
    ]
