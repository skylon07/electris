// keywords
import 'dart:async';
  import 'dart:async';

// keywords with spaces
part 'something';
part of 'something';
  part of 'something';
  part    of 'something';

// not actually keywords
partof 'something';
of 'something';

// operators (valid)
operator <() {}
operator >() {}
operator ==() {}
operator []() {}
operator []=() {}

// operators (invalid)
operator []==() {}
operator asdf() {}



// variables
var myVariable;
var __$_myVariable_yay;

// type variables
var __$_MyType_yay;
var __$_MY_TYPE_yay;
var T;

// const variables
var __$_MY_CONST_YAY;
var CN;



// number literals (good, !bad)
var someNumbers = [
  1.5,    !1.
  0x5afd, !0xfghj
  1e-567, !1.e+445,
  1.2E51, !.E215,
];

// string literals
str = "test";
str = 'test';
str = "$my_var_";
str = "$my_var$"; // second `$` should be an operator
str = "$my_var_$my_var_";
str = "${my_var_}$my_var_";
str = "$my_var_${my_var_}";
str = "strstr\n\"; // this comment is actually part of the string!
str = "strstr\n\""; // this comment is not a part of the string either
str = "strstr\n\\"; // this comment is not a part of the string
str = "strstr\n\\\"; // ...but this one is again!
str = "strstr\n\\\\"; // this comment is not a part of the string
str = "strstr\n\\\\\"; // ...but this one is again!
str = "strstr\n\\\\\\"; // this comment is not a part of the string
str = "strstr\n\\\\\\\"; // ...but this one is again!
str = "something\xab";
str = "something\u{abcd}";
str = r"rawstrstr\n\";
str = r"rawstrstr\n\\";
str = r"rawstrstr\n\\\";
str = r"rawstrstr\n\\\\";
str = r"rawstrstr\n\\\\\";
str = r"rawstrstr\n\\\\\\";
str = r"rawstrstr\n\\\\\\\";
str = r"somethingraw\xab";
str = r"somethingraw\u{abcd}";

// keyword literals
true == false == null




// functions
...

// hard keywords as functions (should look like keywords)
for(){}
for <type> () {}
for () {}
while(){}
while <type> () {}
while () {}
this(){}
this <type> () {}
this () {}

// soft keywords as functions (should look like functions)
extension(){}
extension <type> () {}
extension () {}
import(){}
import <type> () {}
import () {}
part(){}
part <type> () {}
part () {}
// (should recognize `part` as a keyword, not a type)
part of(){}
part of <type> () {}
part  of () {}







void main() {
  // make sure `thing2` is light green
  (String thing, String? thing2) someRecord;
  
  var vars = Type? "str-literal" : int;
  vars = null;

  late final FIXED = 0xabcd;
  TESTextension type; "asdf"
  asdf123456the_end

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
    performFunction(isRequired ? requiredThing : notRequiredThing);
  }
}
