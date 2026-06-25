from django.db import migrations


def seed_categories(apps, schema_editor):
    ServiceCategory = apps.get_model("services", "ServiceCategory")
    categories = [
        ("TV", "TV repair and installation", "tv"),
        ("Freezer", "Freezer repair and cooling issues", "kitchen"),
        ("Cooler", "Air cooler repair and servicing", "air"),
        ("AC", "AC repair, gas refill and servicing", "ac_unit"),
        ("Other", "Other home appliance repair services", "build"),
    ]
    for name, description, icon_name in categories:
        ServiceCategory.objects.get_or_create(
            name=name,
            defaults={
                "description": description,
                "icon_name": icon_name,
                "is_active": True,
            },
        )


def remove_seed_categories(apps, schema_editor):
    ServiceCategory = apps.get_model("services", "ServiceCategory")
    ServiceCategory.objects.filter(
        name__in=["TV", "Freezer", "Cooler", "AC", "Other"]
    ).delete()


class Migration(migrations.Migration):
    dependencies = [
        ("services", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(seed_categories, remove_seed_categories),
    ]
