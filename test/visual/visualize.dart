import 'dart:async';
  import 'dart:async';

part 'something';
part of 'something';
  part of 'something';
  part    of 'something';
partof 'something';
of 'something';

void main() {
  var myVariable;
  var __$_myVariable_yay;
  
  var __$_MyType_yay;
  var __$_MY_TYPE_yay;
  var T;

  var __$_MY_CONST_YAY;
  var CN;
  
  var vars = Type? "str-literal" : int;
  vars = null;

  late final FIXED = 0xabcd;
  TESTextension type;
  List<int> someNumbers = [
    1.5,    !1.
    0x5afd, !0xfghj
    1e-567, !1.e+445,
    1.2E51, !.E215,

  ]

  var my_var$ = "test";
  var my_var_ = "test";
  STRING STRING1 = "$my_var_";
  STRING STRING2 = "$my_var$"; // second `$` should be an operator
  STRING STRING3 = "$my_var_$my_var_";
  STRING STRING4 = "${my_var_}$my_var_";
  STRING STRING5 = "$my_var_${my_var_}";
}

extension type MyInt(int n) {}
 extension type MyInt2(int n) {}
 extension   type MyInt3(int n) {}

@myAnnotation
  @myAnnotation.Yay2
class MyClass {
  // hard keywords
  for(){}
  for () {}
  while(){}
  while () {}
  this(){}
  this () {}

  // soft keywords
  extension(){}
  extension () {}
  import(){}
  import () {}
  part of(){}
  part  of () {}
  part(){}
  part () {}

  operator +() {}
  operator +=() {}

  operatorThingy() {
    this.operatorOperations = 8;
    performFunction(myDataType? something);
    performFunction(isRequired? requiredThing : notRequiredThing);
  }
}
