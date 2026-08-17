import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/calendar/services/calendar_reminder_service.dart';
import 'package:prayer_assistant/src/services/imsakiyem_api.dart';
import 'package:prayer_assistant/src/services/local_database.dart';
import 'package:prayer_assistant/src/services/location_resolver.dart';
import 'package:prayer_assistant/src/services/notification_service.dart';
import 'package:prayer_assistant/src/services/widget_bridge_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/haptic_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/item_reminder_service.dart';

class MockImsakiyemApi extends Mock implements ImsakiyemApi {}

class MockLocalDatabase extends Mock implements LocalDatabase {}

class MockLocationResolver extends Mock implements LocationResolver {}

class MockNotificationService extends Mock implements NotificationService {}

class MockWidgetBridgeService extends Mock implements WidgetBridgeService {}

class MockCalendarReminderService extends Mock
    implements CalendarReminderService {}

class MockItemReminderService extends Mock implements ItemReminderService {}

class MockHapticService extends Mock implements HapticService {}