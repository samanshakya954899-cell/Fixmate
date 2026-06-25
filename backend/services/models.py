import uuid

from django.contrib.auth.models import User
from django.db import models


class Profile(models.Model):
    CUSTOMER = "customer"
    PROVIDER = "provider"
    ADMIN = "admin"

    ROLE_CHOICES = (
        (CUSTOMER, "Customer"),
        (PROVIDER, "Provider"),
        (ADMIN, "Admin"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    full_name = models.CharField(max_length=255, blank=True)
    phone = models.CharField(max_length=40, blank=True)
    city = models.CharField(max_length=120, blank=True)
    address = models.TextField(blank=True)
    avatar_url = models.URLField(blank=True)
    roles = models.JSONField(default=list)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        if not self.roles:
            self.roles = [self.CUSTOMER]
        super().save(*args, **kwargs)

    def __str__(self):
        return self.full_name or self.user.email or self.user.username


class ProviderProfile(models.Model):
    profile = models.OneToOneField(
        Profile,
        primary_key=True,
        on_delete=models.CASCADE,
        related_name="provider_profile",
    )
    business_name = models.CharField(max_length=255, blank=True)
    bio = models.TextField(blank=True)
    experience_years = models.PositiveIntegerField(default=0)
    service_area = models.CharField(max_length=255, blank=True)
    is_available = models.BooleanField(default=True)
    verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.business_name or str(self.profile)


class ServiceCategory(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=120, unique=True)
    description = models.TextField(blank=True)
    icon_name = models.CharField(max_length=80, default="build")
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name


class ProviderService(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    provider = models.ForeignKey(
        ProviderProfile,
        on_delete=models.CASCADE,
        related_name="services",
    )
    category = models.ForeignKey(ServiceCategory, on_delete=models.PROTECT)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    base_charge = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    city = models.CharField(max_length=120, blank=True)
    service_area = models.CharField(max_length=255, blank=True)
    is_available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["created_at"]

    def __str__(self):
        return self.title


class BookingRequest(models.Model):
    DIRECT = "direct"
    OPEN = "open"
    BOOKING_TYPE_CHOICES = ((DIRECT, "Direct"), (OPEN, "Open"))

    PENDING = "pending"
    ACCEPTED = "accepted"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    REJECTED = "rejected"
    STATUS_CHOICES = (
        (PENDING, "Pending"),
        (ACCEPTED, "Accepted"),
        (IN_PROGRESS, "In progress"),
        (COMPLETED, "Completed"),
        (CANCELLED, "Cancelled"),
        (REJECTED, "Rejected"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    customer = models.ForeignKey(
        Profile,
        on_delete=models.CASCADE,
        related_name="customer_bookings",
    )
    provider = models.ForeignKey(
        ProviderProfile,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="provider_bookings",
    )
    category = models.ForeignKey(ServiceCategory, on_delete=models.PROTECT)
    provider_service = models.ForeignKey(
        ProviderService,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
    )
    booking_type = models.CharField(
        max_length=20,
        choices=BOOKING_TYPE_CHOICES,
        default=OPEN,
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=PENDING)
    issue_description = models.TextField()
    address = models.TextField()
    city = models.CharField(max_length=120, blank=True)
    preferred_at = models.DateTimeField(null=True, blank=True)
    quoted_charge = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
    )
    image_url = models.URLField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.category} booking for {self.customer}"


class BookingOffer(models.Model):
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    STATUS_CHOICES = (
        (PENDING, "Pending"),
        (ACCEPTED, "Accepted"),
        (REJECTED, "Rejected"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking = models.ForeignKey(
        BookingRequest,
        on_delete=models.CASCADE,
        related_name="offers",
    )
    provider = models.ForeignKey(ProviderProfile, on_delete=models.CASCADE)
    message = models.TextField(blank=True)
    charge = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=PENDING)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["booking", "provider"],
                name="unique_booking_provider_offer",
            )
        ]


class Chat(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking = models.OneToOneField(
        BookingRequest,
        on_delete=models.CASCADE,
        related_name="chat",
    )
    customer = models.ForeignKey(Profile, on_delete=models.CASCADE)
    provider = models.ForeignKey(ProviderProfile, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)


class ChatMessage(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    chat = models.ForeignKey(Chat, on_delete=models.CASCADE, related_name="messages")
    sender = models.ForeignKey(Profile, on_delete=models.CASCADE)
    body = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]


class Rating(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking = models.OneToOneField(
        BookingRequest,
        on_delete=models.CASCADE,
        related_name="rating",
    )
    customer = models.ForeignKey(
        Profile,
        on_delete=models.CASCADE,
        related_name="given_ratings",
    )
    provider = models.ForeignKey(
        ProviderProfile,
        on_delete=models.CASCADE,
        related_name="ratings",
    )
    stars = models.PositiveSmallIntegerField()
    review = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class Notification(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Profile, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    body = models.TextField()
    read_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
