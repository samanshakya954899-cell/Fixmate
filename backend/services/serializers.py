def iso(value):
    return value.isoformat() if value else None


def profile_to_dict(profile):
    return {
        "id": str(profile.id),
        "email": profile.user.email,
        "full_name": profile.full_name,
        "phone": profile.phone,
        "city": profile.city,
        "address": profile.address,
        "avatar_url": profile.avatar_url,
        "roles": profile.roles,
        "created_at": iso(profile.created_at),
        "updated_at": iso(profile.updated_at),
    }


def category_to_dict(category):
    return {
        "id": str(category.id),
        "name": category.name,
        "description": category.description,
        "icon_name": category.icon_name,
        "is_active": category.is_active,
        "created_at": iso(category.created_at),
    }


def provider_profile_to_dict(provider_profile):
    return {
        "id": str(provider_profile.profile_id),
        "business_name": provider_profile.business_name,
        "bio": provider_profile.bio,
        "experience_years": provider_profile.experience_years,
        "service_area": provider_profile.service_area,
        "is_available": provider_profile.is_available,
        "verified": provider_profile.verified,
        "created_at": iso(provider_profile.created_at),
        "updated_at": iso(provider_profile.updated_at),
    }


def service_to_dict(service):
    return {
        "id": str(service.id),
        "provider_id": str(service.provider_id),
        "category_id": str(service.category_id),
        "title": service.title,
        "description": service.description,
        "base_charge": float(service.base_charge),
        "city": service.city,
        "service_area": service.service_area,
        "is_available": service.is_available,
        "created_at": iso(service.created_at),
        "updated_at": iso(service.updated_at),
        "service_categories": {
            "name": service.category.name,
        },
        "provider_profiles": provider_profile_to_dict(service.provider),
    }


def booking_to_dict(booking):
    return {
        "id": str(booking.id),
        "customer_id": str(booking.customer_id),
        "provider_id": str(booking.provider_id) if booking.provider_id else None,
        "category_id": str(booking.category_id),
        "provider_service_id": (
            str(booking.provider_service_id) if booking.provider_service_id else None
        ),
        "booking_type": booking.booking_type,
        "status": booking.status,
        "issue_description": booking.issue_description,
        "address": booking.address,
        "city": booking.city,
        "preferred_at": iso(booking.preferred_at),
        "quoted_charge": (
            float(booking.quoted_charge) if booking.quoted_charge is not None else None
        ),
        "image_url": booking.image_url,
        "created_at": iso(booking.created_at),
        "updated_at": iso(booking.updated_at),
        "service_categories": {
            "name": booking.category.name,
        },
    }


def chat_to_dict(chat):
    return {
        "id": str(chat.id),
        "booking_id": str(chat.booking_id),
        "customer_id": str(chat.customer_id),
        "provider_id": str(chat.provider_id),
        "created_at": iso(chat.created_at),
    }


def message_to_dict(message):
    return {
        "id": str(message.id),
        "chat_id": str(message.chat_id),
        "sender_id": str(message.sender_id),
        "body": message.body,
        "created_at": iso(message.created_at),
    }


def notification_to_dict(notification):
    return {
        "id": str(notification.id),
        "user_id": str(notification.user_id),
        "title": notification.title,
        "body": notification.body,
        "read_at": iso(notification.read_at),
        "created_at": iso(notification.created_at),
    }
