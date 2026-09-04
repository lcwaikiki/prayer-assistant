import 'dart:math' as math;
import 'hijri_utils.dart';

/// Represents details of the Moon's phase for a given date.
class MoonPhaseInfo {
  const MoonPhaseInfo({
    required this.date,
    required this.phaseValue,
    required this.illumination,
    required this.phaseNameKey,
    required this.ageInDays,
    required this.isWhiteDay,
    this.whiteDayNumber,
  });

  /// The target date.
  final DateTime date;

  /// Phase value from 0.0 to 1.0.
  /// 0.0 = New Moon, 0.25 = First Quarter, 0.5 = Full Moon, 0.75 = Last Quarter.
  final double phaseValue;

  /// Illumination percentage from 0.0 to 100.0.
  final double illumination;

  /// Localization key for the phase stage.
  final String phaseNameKey;

  /// Approximate age of the moon in days within the synodic month cycle (0 to 29.53).
  final double ageInDays;

  /// Whether this date is one of the White Days (13, 14, 15 Hijri).
  final bool isWhiteDay;

  /// The White Day number (13, 14, 15), or null if not a White Day.
  final int? whiteDayNumber;
}

const double synodicMonthDays = 29.53058867;

/// Returns astronomical [MoonPhaseInfo] for [date], considering optional [hijriOffset].
MoonPhaseInfo getMoonPhase(DateTime date, {int hijriOffset = 0}) {
  final utc = date.toUtc();
  // Julian Date calculation
  final julianDate = utc.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
  // Known reference New Moon: Jan 6, 2000, 18:14 UTC (JD 2451550.25972)
  const referenceNewMoonJd = 2451550.25972;

  final daysSinceNewMoon = julianDate - referenceNewMoonJd;
  final cyclePosition = daysSinceNewMoon % synodicMonthDays;
  final ageInDays = cyclePosition < 0 ? cyclePosition + synodicMonthDays : cyclePosition;
  final phaseValue = ageInDays / synodicMonthDays;

  // Illumination calculation: 0% at New Moon (phaseValue = 0 or 1), 100% at Full Moon (phaseValue = 0.5)
  final angle = phaseValue * 2.0 * math.pi;
  final illumination = (1.0 - math.cos(angle)) / 2.0 * 100.0;

  final phaseNameKey = _getPhaseNameKey(phaseValue);

  final hijri = hijriCalendarWithOffset(date, hijriOffset);
  final hDay = hijri.hDay;
  final isWhiteDay = hDay >= 13 && hDay <= 15;
  final whiteDayNumber = isWhiteDay ? hDay : null;

  return MoonPhaseInfo(
    date: date,
    phaseValue: phaseValue,
    illumination: illumination,
    phaseNameKey: phaseNameKey,
    ageInDays: ageInDays,
    isWhiteDay: isWhiteDay,
    whiteDayNumber: whiteDayNumber,
  );
}

String _getPhaseNameKey(double phase) {
  if (phase < 0.03 || phase >= 0.97) {
    return 'moonPhaseNewMoon';
  } else if (phase >= 0.03 && phase < 0.22) {
    return 'moonPhaseWaxingCrescent';
  } else if (phase >= 0.22 && phase < 0.28) {
    return 'moonPhaseFirstQuarter';
  } else if (phase >= 0.28 && phase < 0.47) {
    return 'moonPhaseWaxingGibbous';
  } else if (phase >= 0.47 && phase < 0.53) {
    return 'moonPhaseFullMoon';
  } else if (phase >= 0.53 && phase < 0.72) {
    return 'moonPhaseWaningGibbous';
  } else if (phase >= 0.72 && phase < 0.78) {
    return 'moonPhaseLastQuarter';
  } else {
    return 'moonPhaseWaningCrescent';
  }
}
