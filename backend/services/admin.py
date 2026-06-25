from django.contrib import admin

from .models import (
    BookingOffer,
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


admin.site.register(Profile)
admin.site.register(ProviderProfile)
admin.site.register(ServiceCategory)
admin.site.register(ProviderService)
admin.site.register(BookingRequest)
admin.site.register(BookingOffer)
admin.site.register(Chat)
admin.site.register(ChatMessage)
admin.site.register(Rating)
admin.site.register(Notification)
