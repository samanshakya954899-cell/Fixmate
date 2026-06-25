import json
from decimal import Decimal
from functools import wraps

from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.db.models import Q
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.utils.dateparse import parse_datetime
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

from .models import (
    BookingRequest,
    Chat,
    ChatMessage,
    Notification,
    Profile,
    ProviderProfile,
    ProviderService,
    Rating,
    ServiceCategory,
)
from .serializers import (
    booking_to_dict,
    category_to_dict,
    chat_to_dict,
    message_to_dict,
    notification_to_dict,
    profile_to_dict,
    provider_profile_to_dict,
    service_to_dict,
)


def read_json(request):
    if not request.body:
        return {}
    return json.loads(request.body.decode("utf-8"))


def error(message, status=400):
    return JsonResponse({"error": message}, status=status)


def require_login(view_func):
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return error("Authentication required.", status=401)
        return view_func(request, *args, **kwargs)

    return wrapper


def current_profile(request):
    return request.user.profile


def current_provider(request):
    return ProviderProfile.objects.filter(profile=current_profile(request)).first()


@require_http_methods(["GET"])
def health(request):
    return JsonResponse({"ok": True, "service": "fixmate-backend"})


@csrf_exempt
@require_http_methods(["POST"])
def signup(request):
    data = read_json(request)
    email = data.get("email", "").strip().lower()
    password = data.get("password", "")
    full_name = data.get("name", "").strip()
    account_type = data.get("account_type", Profile.CUSTOMER)

    if not email or not password:
        return error("Email and password are required.")
    if User.objects.filter(username=email).exists():
        return error("A user with this email already exists.", status=409)

    user = User.objects.create_user(
        username=email,
        email=email,
        password=password,
        first_name=full_name,
    )
    profile = user.profile
    profile.full_name = full_name
    roles = [Profile.CUSTOMER]
    if account_type == Profile.PROVIDER:
        roles.append(Profile.PROVIDER)
        ProviderProfile.objects.get_or_create(profile=profile)
    profile.roles = roles
    profile.save()
    login(request, user)
    return JsonResponse({"user": profile_to_dict(profile)}, status=201)


@csrf_exempt
@require_http_methods(["POST"])
def signin(request):
    data = read_json(request)
    email = data.get("email", "").strip().lower()
    password = data.get("password", "")
    user = authenticate(request, username=email, password=password)
    if user is None:
        return error("Invalid email or password.", status=401)
    login(request, user)
    return JsonResponse({"user": profile_to_dict(user.profile)})


@csrf_exempt
@require_http_methods(["POST"])
def signout(request):
    logout(request)
    return JsonResponse({"ok": True})


@require_http_methods(["GET"])
@require_login
def me(request):
    return JsonResponse({"user": profile_to_dict(current_profile(request))})


@require_http_methods(["GET"])
@require_login
def categories(request):
    queryset = ServiceCategory.objects.filter(is_active=True).order_by("name")
    return JsonResponse({"data": [category_to_dict(item) for item in queryset]})


@csrf_exempt
@require_http_methods(["GET", "POST"])
@require_login
def provider_services(request):
    if request.method == "GET":
        queryset = (
            ProviderService.objects.select_related("category", "provider")
            .filter(is_available=True)
            .order_by("created_at")
        )
        category_id = request.GET.get("category_id")
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        return JsonResponse({"data": [service_to_dict(item) for item in queryset]})

    provider = ProviderProfile.objects.filter(profile=current_profile(request)).first()
    if provider is None:
        provider = ProviderProfile.objects.create(profile=current_profile(request))
    data = read_json(request)
    service = ProviderService.objects.create(
        provider=provider,
        category=get_object_or_404(ServiceCategory, id=data.get("category_id")),
        title=data.get("title", ""),
        description=data.get("description", ""),
        base_charge=Decimal(str(data.get("charge", 0))),
        city=data.get("city", ""),
        service_area=data.get("service_area", ""),
    )
    profile = current_profile(request)
    if Profile.PROVIDER not in profile.roles:
        profile.roles = [*profile.roles, Profile.PROVIDER]
        profile.save(update_fields=["roles", "updated_at"])
    return JsonResponse({"data": service_to_dict(service)}, status=201)


@csrf_exempt
@require_http_methods(["POST", "PUT", "PATCH"])
@require_login
def save_profile(request):
    data = read_json(request)
    profile = current_profile(request)
    profile.full_name = data.get("full_name", profile.full_name)
    profile.phone = data.get("phone", profile.phone)
    profile.city = data.get("city", profile.city)
    profile.address = data.get("address", profile.address)
    profile.roles = data.get("roles", profile.roles or [Profile.CUSTOMER])
    profile.save()
    return JsonResponse({"data": profile_to_dict(profile)})


@csrf_exempt
@require_http_methods(["POST", "PUT", "PATCH"])
@require_login
def save_provider_profile(request):
    data = read_json(request)
    profile = current_profile(request)
    provider, _ = ProviderProfile.objects.get_or_create(profile=profile)
    provider.business_name = data.get("business_name", provider.business_name)
    provider.bio = data.get("bio", provider.bio)
    provider.service_area = data.get("service_area", provider.service_area)
    provider.experience_years = int(data.get("experience_years", 0))
    provider.is_available = bool(data.get("available", provider.is_available))
    provider.save()
    if Profile.PROVIDER not in profile.roles:
        profile.roles = [*profile.roles, Profile.PROVIDER]
        profile.save(update_fields=["roles", "updated_at"])
    return JsonResponse({"data": provider_profile_to_dict(provider)})


@csrf_exempt
@require_http_methods(["GET", "POST"])
@require_login
def bookings(request):
    profile = current_profile(request)

    if request.method == "GET":
        queryset = BookingRequest.objects.select_related("category").filter(
            Q(customer=profile) | Q(provider__profile=profile)
        )
        return JsonResponse({"data": [booking_to_dict(item) for item in queryset]})

    data = read_json(request)
    provider = None
    service = None
    if data.get("provider_id"):
        provider = get_object_or_404(ProviderProfile, profile_id=data["provider_id"])
    if data.get("service_id"):
        service = get_object_or_404(ProviderService, id=data["service_id"])
        provider = service.provider

    booking = BookingRequest.objects.create(
        customer=profile,
        provider=provider,
        category=get_object_or_404(ServiceCategory, id=data.get("category_id")),
        provider_service=service,
        booking_type=data.get("type", BookingRequest.OPEN),
        issue_description=data.get("issue", ""),
        address=data.get("address", ""),
        city=data.get("city", ""),
        preferred_at=parse_datetime(data["preferred_at"])
        if data.get("preferred_at")
        else None,
        quoted_charge=Decimal(str(data["quoted_charge"]))
        if data.get("quoted_charge") is not None
        else None,
    )
    Notification.objects.create(
        user=profile,
        title="Booking created",
        body="Your service request has been submitted.",
    )
    return JsonResponse({"data": booking_to_dict(booking)}, status=201)


@require_http_methods(["GET"])
@require_login
def provider_incoming_bookings(request):
    provider = current_provider(request)
    queryset = BookingRequest.objects.select_related("category").filter(
        Q(booking_type=BookingRequest.OPEN)
        | Q(provider=provider if provider else None)
    )
    return JsonResponse({"data": [booking_to_dict(item) for item in queryset]})


@csrf_exempt
@require_http_methods(["POST", "PATCH"])
@require_login
def update_booking_status(request, booking_id):
    data = read_json(request)
    status = data.get("status")
    valid_statuses = {choice[0] for choice in BookingRequest.STATUS_CHOICES}
    if status not in valid_statuses:
        return error("Invalid booking status.")
    booking = get_object_or_404(BookingRequest, id=booking_id)
    provider = current_provider(request)
    if status == BookingRequest.ACCEPTED and provider is not None:
        booking.provider = provider
    booking.status = status
    booking.save()
    return JsonResponse({"data": booking_to_dict(booking)})


@csrf_exempt
@require_http_methods(["POST"])
@require_login
def ensure_chat(request):
    data = read_json(request)
    booking = get_object_or_404(BookingRequest, id=data.get("booking_id"))
    if booking.provider_id is None:
        return error("Booking does not have a provider yet.")
    chat, _ = Chat.objects.get_or_create(
        booking=booking,
        defaults={
            "customer": booking.customer,
            "provider": booking.provider,
        },
    )
    return JsonResponse({"data": chat_to_dict(chat)})


@csrf_exempt
@require_http_methods(["GET", "POST"])
@require_login
def chat_messages(request, chat_id):
    chat = get_object_or_404(Chat, id=chat_id)
    profile = current_profile(request)
    is_participant = chat.customer_id == profile.id or chat.provider.profile_id == profile.id
    if not is_participant:
        return error("You are not a participant in this chat.", status=403)

    if request.method == "GET":
        queryset = ChatMessage.objects.filter(chat=chat).order_by("created_at")
        return JsonResponse({"data": [message_to_dict(item) for item in queryset]})

    data = read_json(request)
    message = ChatMessage.objects.create(
        chat=chat,
        sender=profile,
        body=data.get("body", ""),
    )
    return JsonResponse({"data": message_to_dict(message)}, status=201)


@csrf_exempt
@require_http_methods(["POST"])
@require_login
def rate_booking(request, booking_id):
    data = read_json(request)
    booking = get_object_or_404(BookingRequest, id=booking_id)
    if booking.provider_id is None:
        return error("Booking does not have a provider.")
    if booking.customer_id != current_profile(request).id:
        return error("Only the customer can rate this booking.", status=403)
    rating, _ = Rating.objects.update_or_create(
        booking=booking,
        defaults={
            "customer": booking.customer,
            "provider": booking.provider,
            "stars": int(data.get("stars", 1)),
            "review": data.get("review", ""),
        },
    )
    return JsonResponse({"data": {"id": str(rating.id)}}, status=201)


@require_http_methods(["GET"])
@require_login
def notifications(request):
    queryset = Notification.objects.filter(user=current_profile(request))
    return JsonResponse({"data": [notification_to_dict(item) for item in queryset]})
