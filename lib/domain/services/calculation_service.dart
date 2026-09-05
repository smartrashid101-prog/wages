// Simple Money Utils - inline to avoid import issues
class CalcMoneyUtils {
  static int calculatePay(int minutes, int rateCentsPerHour) {
    // pay = round(minutes × rate / 60)
    return ((minutes * rateCentsPerHour) / 60).round();
  }
}

// Simple App Constants - inline to avoid import issues
class CalcAppConstants {
  static const String overtimeAutomatic = 'automatic';
  static const String overtimeManual = 'manual';
  static const String overtimeNone = 'none';
  static const int defaultRegularThresholdMinutes = 480; // 8 hours
}

class CalculationResult {
  final int totalMinutes;
  final int regularMinutes;
  final int overtimeMinutes;
  final int regularPayCents;
  final int overtimePayCents;
  final int grossPayCents;
  final int netPayCents;
  final int bonusCents;
  final int deductionsCents;
  
  CalculationResult({
    required this.totalMinutes,
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.regularPayCents,
    required this.overtimePayCents,
    required this.grossPayCents,
    required this.netPayCents,
    required this.bonusCents,
    required this.deductionsCents,
  });
}

class CalculationService {
  /// Calculate work duration including overnight shifts
  int calculateDuration(int startMinutes, int endMinutes) {
    if (endMinutes <= startMinutes) {
      return endMinutes + 1440 - startMinutes;
    }
    return endMinutes - startMinutes;
  }
  
  /// Validate break against raw duration
  bool validateBreak(int breakMinutes, int rawDuration) {
    if (breakMinutes < 0) return false;
    if (breakMinutes > rawDuration) return false;
    return true;
  }
  
  /// Calculate total working minutes
  int calculateTotalMinutes(int rawDuration, int breakMinutes) {
    return rawDuration - breakMinutes;
  }
  
  /// Calculate pay from minutes and rate
  int calculatePay(int minutes, int rateCentsPerHour) {
    return CalcMoneyUtils.calculatePay(minutes, rateCentsPerHour);
  }
  
  /// Calculate automatic overtime
  (int regularMinutes, int overtimeMinutes) calculateAutomaticOvertime(
    int totalMinutes,
    int regularThresholdMinutes,
  ) {
    if (totalMinutes <= regularThresholdMinutes) {
      return (totalMinutes, 0);
    }
    return (regularThresholdMinutes, totalMinutes - regularThresholdMinutes);
  }
  
  /// Calculate manual overtime with validation
  (int regularMinutes, int overtimeMinutes, bool isValid) calculateManualOvertime(
    int totalMinutes,
    int regularMinutesInput,
    int overtimeMinutesInput,
  ) {
    final sum = regularMinutesInput + overtimeMinutesInput;
    if (sum <= totalMinutes && regularMinutesInput >= 0 && overtimeMinutesInput >= 0) {
      return (regularMinutesInput, overtimeMinutesInput, true);
    }
    return (0, 0, false);
  }
  
  /// Full calculation for a shift
  CalculationResult calculateShift({
    required int startMinutes,
    required int endMinutes,
    required int breakMinutes,
    required int hourlyRateCents,
    required int overtimeRateCents,
    required int bonusCents,
    required int deductionsCents,
    required String overtimeMode,
    int? regularThresholdMinutes,
    int? manualRegularMinutes,
    int? manualOvertimeMinutes,
  }) {
    // Calculate raw duration
    final rawDuration = calculateDuration(startMinutes, endMinutes);
    
    // Validate break
    if (!validateBreak(breakMinutes, rawDuration)) {
      throw Exception('Invalid break duration');
    }
    
    // Calculate total working minutes
    final totalMinutes = calculateTotalMinutes(rawDuration, breakMinutes);
    
    // Determine regular and overtime minutes
    int regularMinutes;
    int overtimeMinutes;
    
    switch (overtimeMode) {
      case CalcAppConstants.overtimeAutomatic:
        final threshold = regularThresholdMinutes ?? CalcAppConstants.defaultRegularThresholdMinutes;
        final result = calculateAutomaticOvertime(totalMinutes, threshold);
        regularMinutes = result.$1;
        overtimeMinutes = result.$2;
        break;
        
      case CalcAppConstants.overtimeManual:
        if (manualRegularMinutes == null || manualOvertimeMinutes == null) {
          throw Exception('Manual overtime requires regular and overtime minutes');
        }
        final result = calculateManualOvertime(
          totalMinutes,
          manualRegularMinutes,
          manualOvertimeMinutes,
        );
        if (!result.$3) {
          throw Exception('Invalid manual overtime distribution');
        }
        regularMinutes = result.$1;
        overtimeMinutes = result.$2;
        break;
        
      case CalcAppConstants.overtimeNone:
      default:
        regularMinutes = totalMinutes;
        overtimeMinutes = 0;
        break;
    }
    
    // Calculate pay
    final regularPay = calculatePay(regularMinutes, hourlyRateCents);
    final overtimePay = calculatePay(overtimeMinutes, overtimeRateCents);
    final grossPay = regularPay + overtimePay + bonusCents;
    final netPay = grossPay - deductionsCents;
    
    return CalculationResult(
      totalMinutes: totalMinutes,
      regularMinutes: regularMinutes,
      overtimeMinutes: overtimeMinutes,
      regularPayCents: regularPay,
      overtimePayCents: overtimePay,
      grossPayCents: grossPay,
      netPayCents: netPay,
      bonusCents: bonusCents,
      deductionsCents: deductionsCents,
    );
  }
}