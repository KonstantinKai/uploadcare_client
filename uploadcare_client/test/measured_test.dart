import 'package:test/test.dart';
import 'package:uploadcare_client/src/measures.dart';

void main() {
  group('Dimensions', () {
    test('toString', () {
      expect(Dimensions.zero.toString(), equals('0x0'));
      expect(Dimensions(0, 0, units: MeasureUnits.Percent).toString(),
          equals('0px0p'));
    });

    test('constructors', () {
      final zero = Dimensions.zero;
      final square = Dimensions.square(10);
      final fromWidth = Dimensions.fromWidth(10);
      final fromHeight = Dimensions.fromHeight(10);
      expect(zero.toString(), equals('0x0'));
      expect(square.toString(), equals('10x10'));
      expect(fromWidth.toString(), equals('10x'));
      expect(fromHeight.toString(), equals('x10'));
    });
  });

  group('Offsets', () {
    test('toString', () {
      expect(Offsets.zero.toString(), equals('0,0'));
      expect(Offsets(0, 0, units: MeasureUnits.Percent).toString(),
          equals('0p,0p'));
    });
  });
}
