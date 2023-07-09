import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void recursivePrint(List<int> list) {
  if (list.isEmpty) {
    return;
  }
  print("${list.first} ");
  recursivePrint(list.slice(1));
}

void recPrint2(ListSlice<int> list) {
  if (list.isEmpty) {
    return;
  }
  print("${list.first} ");
  recPrint2(list.slice(1));
}

void main() {
  // test('Slice recursion', () {
  //   recursivePrint([0, 1, 2, 3]);
  // });

  test('Slice recursion 2', () {
    recPrint2([0, 1, 2, 3].slice(0));
  });
}
