library fixmate_app;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'core/constants/app_config_and_theme.dart';
part 'app/fixseva_app.dart';
part 'app/authentication_gate.dart';
part 'app/viewmodels/authentication_gate_view_model.dart';
part 'domain/repositories/service_repository.dart';
part 'data/repositories/service_booking_repository.dart';
part 'features/auth/presentation/views/auth_view.dart';
part 'features/auth/presentation/viewmodels/auth_view_model.dart';
part 'features/home/presentation/views/role_based_home_shell.dart';
part 'features/home/presentation/viewmodels/role_based_home_view_model.dart';
part 'features/customer/presentation/views/customer_services_view.dart';
part 'features/customer/presentation/viewmodels/customer_services_view_model.dart';
part 'features/services/presentation/widgets/service_listing_card.dart';
part 'features/provider/presentation/views/provider_workspace_view.dart';
part 'features/provider/presentation/viewmodels/provider_workspace_view_model.dart';
part 'features/bookings/presentation/views/bookings_view.dart';
part 'features/bookings/presentation/viewmodels/bookings_view_model.dart';
part 'features/bookings/presentation/widgets/booking_request_card.dart';
part 'features/bookings/presentation/viewmodels/booking_request_card_view_model.dart';
part 'features/chat/presentation/views/booking_chat_view.dart';
part 'features/chat/presentation/viewmodels/booking_chat_view_model.dart';
part 'features/profile/presentation/views/user_profile_view.dart';
part 'features/profile/presentation/viewmodels/user_profile_view_model.dart';
part 'features/notifications/presentation/views/notifications_view.dart';
part 'features/notifications/presentation/viewmodels/notifications_view_model.dart';
part 'shared/widgets/app_hero.dart';
part 'shared/widgets/section_title.dart';
part 'shared/widgets/info_chip.dart';
part 'shared/widgets/icon_line.dart';
part 'shared/widgets/status_badge.dart';
part 'shared/widgets/info_banner.dart';
part 'shared/widgets/form_panel.dart';
part 'shared/widgets/empty_state.dart';
part 'shared/dialogs/booking_request_form_sheet.dart';
part 'shared/dialogs/viewmodels/booking_request_form_view_model.dart';
part 'shared/dialogs/service_listing_form_sheet.dart';
part 'shared/dialogs/viewmodels/service_listing_form_view_model.dart';
part 'shared/dialogs/booking_rating_sheet.dart';
part 'shared/dialogs/viewmodels/booking_rating_view_model.dart';
part 'core/utils/formatting_and_ui_helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configured = _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
  if (configured) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
  }
  runApp(ServiceBookingApp(configured: configured));
}
