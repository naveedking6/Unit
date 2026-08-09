/// A single meter-reading record.
class UnitRecord {
  final int? id;
  final String name;
  final DateTime date;
  final int startUnit;
  final int endUnit;
  final String? meterImagePath;
  final DateTime createdAt;

  UnitRecord({
    this.id,
    required this.name,
    required this.date,
    required this.startUnit,
    required this.endUnit,
    this.meterImagePath,
    required this.createdAt,
  });

  /// کل یونٹ = آخری یونٹ − شروع کا یونٹ
  /// Never negative — validated before a record is ever constructed/saved.
  int get totalUnit => endUnit - startUnit;

  int get year => date.year;
  int get month => date.month;
  int get day => date.day;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'start_unit': startUnit,
      'end_unit': endUnit,
      'total_unit': totalUnit,
      'meter_image_path': meterImagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UnitRecord.fromMap(Map<String, dynamic> map) {
    return UnitRecord(
      id: map['id'] as int?,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
      startUnit: map['start_unit'] as int,
      endUnit: map['end_unit'] as int,
      meterImagePath: map['meter_image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// Thrown when a record would be invalid — e.g. end < start.
/// The Urdu message is what gets shown directly to the user.
class InvalidUnitException implements Exception {
  final String urduMessage;
  InvalidUnitException(this.urduMessage);
}

/// Central validation + calculation logic. Kept pure/testable — no UI, no DB.
class UnitCalculator {
  static const String errStartRequired = 'شروع کا یونٹ درج کریں';
  static const String errEndRequired = 'آخری یونٹ درج کریں';
  static const String errEndLessThanStart =
      'آخری یونٹ شروع کے یونٹ سے کم نہیں ہو سکتا';

  /// Validates and returns the total. Throws [InvalidUnitException] on error.
  static int calculateTotal({required int? startUnit, required int? endUnit}) {
    if (startUnit == null) {
      throw InvalidUnitException(errStartRequired);
    }
    if (endUnit == null) {
      throw InvalidUnitException(errEndRequired);
    }
    if (endUnit < startUnit) {
      throw InvalidUnitException(errEndLessThanStart);
    }
    return endUnit - startUnit;
  }
}
