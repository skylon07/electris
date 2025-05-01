/// This is a file intended to test syntax recognition visually;
/// it contains various syntactic elements and stress-tests the definition's matcher expressions

/*
  Comments are used to explain sections;
  here, a test is made for checking that
  /* 
    nested comments are handled correctly
  */

  this should still be commented!
  "asdf" + 456 = export function()
*/


// keywords
import 'dart:async';
  import 'dart:async' as asynclib; // should look like a variable

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
  1_2_3,  !_1_2_3,
];

// string literals
str = "test";
str = 'test';
str = "$my_var_";
str = "$my_var$"; // second `$` should be an operator
str = "$my_var_$my_var_";
str = "${my_var_}$my_var_";
str = "$my_var_${my_var_}";
str = "$myVar$MyType$MY_CONST$myVar";
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



// contextual type highlighting: declarations and casts (after certain keywords)
class MyClass<ItemT> with someMixin implements someInterface {}
mixin class notAGoodClassName extends alsoNotAGoodClassName on reallyShouldDoBetterClassNames {}
test = myThing is something?;
test = myThing is   something;
test = myThing as something;
test = myThing as   something?;
typedef something = somethingElse?;
typedef   something =   somethingElse;
extension type myint(int val) {}
extension type myint.constructor(int val) {}
// test: the next line should be a keyword, not a type -- class
class

// contextual type highlighting: annotations
MyClass   myThing;
MyClass?  myThing;
MyClass<List<MyType>>   myThing;
MyClass<List<MyType>>?  myThing;
final mylib.MyThing myThing;
stillShouldBeAType? myThing;
final WithMultiline<
  Type,
  Params,
  Here,
> someVariable;
final notAType < someVariable;

// contextual type highlighting: type parameters
// (`void`s should be shaded as errors)
var myThing   = MyClass<dynamic>();
var myThing2  = MyClass<List<List<List<List<void>>>>>();
var myThing3  = <List<List<List<List<void>>>>>{};
var myThing4  = myFn<List<List<List<List<void>>>>>();



// punctuation edge-cases
var something = false ? 1 : 2; // `:` should be an operator
var thing = {asdf?.asdf : asdf}; // `:` should be punctuation
var mapThing = true ? 
  //  punct   punct   punct            punct           oper     oper
  //  v       v       v                v               v        v
  {"a": 1, "b": 2, "c": 3, "insideTest": true ? "true" : false} : 
  //punct   punct   punct              punct           oper
  //v       v       v                  v               v      
  {1: "a", 2: "b", 3: "c", "insideTest": true ? "true" : false};



// functions and records
void myFnAndRecords(
  abc def,
  abc ghi,
  abc jkl,
) {
  myLongFnName<
    really,
    long,
    dynamic,
    param,
    list
  >();
  if (something<1) {
    doAnotherFn!<intgrr>();
    fnCallButHaventTypedParensYet<int>
  }

  myType<test>? someFunction<T>(type1 id1, id2, type3 id3, [type4 id4, type5 id5]) {
    mytype mything;
    void lerp(Color? a, Color? b, List<int>? c);
  }
  var callback = (abc def, abc ghi, abc jkl, {abc xyz, required abc bbc,}) {};

  // `<asdf>` should be a type parameter list; `(max, value)` should not be recognized as a record
  var thing = [].reduce(<asdf>(max, value) => (max < value)? value : max);
  <something extends > // `>` should be an operator, not in the "unrecognized" style
  
  // shading should all be the same level
  something Function(abc, def) Function(abc, def) Function(abc, def) Function(abc, def) myFunction() {}
  myFunction as something Function(abc, def) Function(abc, def) Function(abc, def) Function(abc, def);

  // `void` should be shaded as an error
  hi Function(hi Function(hi Function(hi Function(hi Function(hi Function(void)))))) myFunction() {}
  myFunction as hi Function(hi Function(hi Function(hi Function(hi Function(hi Function(void))))));

  // `void` should be shaded as an error
  (asdf, (asdf, (asdf, (asdf, (asdf, (void,)))))) myThing;
  
  // everything should be at the same level in this parameter list
  <int Function(int)>[];

  // `(String, String)` should be the only thing shaded darker in this parameter list
  <(int, (String, String))>[];
  // the inside of this wrapper `(_,)` should match the above
  ((int, (String, String)),) something;

  (int aaa, List<int> bbb, (bool? ccc, List<int>? ddd, ({int eee}))) thing;

  takesCallback((event, emit) sync* {})
  takesCallback<Type>((event, emit) async {})

  // make sure the `=>` isn't screwing up type annotation recognition
  genericWithCallback<String>((item) => item);
  obj.genericWithCallback<String>((item) => item);
}

// hard keywords as functions (should look like keywords)
for(){}
for<type>() {}
for () {}
while(){}
while<type>() {}
while () {}
this(){}
this<type>() {}
this () {}

// soft keywords as functions (should look like functions)
extension(){}
extension<type>() {}
import(){}
import<type>() {}
part(){}
part<type>() {}
// soft keywords with spacing (should look like keywords)
extension () {}
import () {}
part () {}
// (should recognize `part` as a keyword, not a type)
part of(){}
part of<type>() {}
part  of () {}
// (should recognize `bool?` as a type)
boooolean required
boooolean required = false;
// (should *not* recognize `myVar` as a type, but other `type`s okay)
if (something case              myVar when myVar > 5)
if (something case final        myVar when myVar > 5)
if (something case        type  myVar when myVar > 5)
if (something case final  type  myVar when myVar > 5)
funkyfunc when = null;

// here lie some strange functions that tricked some typing rules...
class SomeWeirdClass {
  static myTypelessFunction              (List<int> someParam) {}
  static myTypelessFunction<WithGenerics>(List<int> someParam) {}
}



// records
typedef myLongType = (
  aaa,
  bbb,
  ccc,
  ddd,
);

typedef MyFn    = int  Function(num, int, String);
typedef MyFnFn  = int? Function(num, int, String)? Function(String);

void function({required int b}) {}
void Function({required int b}) xy;

Function()? asdf() {}
Function()? Function()? asdf() {}
Function()? Function()? Function()? asdf() {}

var mapMaker = () => {
  (0, false): "(match) yes",
  (0, true): "does not match",
  (1, false): "(the parens are important) and this",
  (1, true): null,
},



// many much records/functions testing

type       fn      ((rec, rec) id) {
type<type> fn      ((rec, rec) id) {
type       fn<type>((rec, rec) id) {
type<type> fn<type>((rec, rec) id) {

var fn = ((rec, rec) id) =>
var fn = ((rec, rec) id) {
var fn = (((rec, rec), rec) id) =>
var fn = (((rec, rec), rec) id) {
var fn = (type Function() id) =>
var fn = (type Function() id) {
var fn = (type Function() fn()) =>
var fn = (type Function() fn()) {
var fn = (type Function() fn(), id) =>
var fn = (type Function() fn(), id) {
   
(type Function() id) =>
(type Function() id) {
// no way to tell these aren't `(rec, rec) funcDef() {`, but seeing these without previous text would be unusual...
(type Function() fn()) =>
(type Function() fn()) {
(type Function() fn(), asdf) =>
(type Function() fn(), asdf) {
   
(rec, rec)  syn
(rec, rec)  asyn
(rec, rec)? syn
(rec, rec)? asyn
(id, id)    sync
(id, id)    async
(id, id)? sync
(id, id)? async
   
class MyClass {
         (type, type)      get something                      => (5, 5);
         (type, type)      set something((rec, rec) newThing) => (5, 5);
  type Function((int, int))       makeCb()                    => ((int, int) test) {};
  type Function((int, int))       makeCb()              { return ((int, int) test) {}; }
         type                   fn      (((rec, rec), rec) id) {}
         type<type>             fn      (((rec, rec), rec) id) {}
         type                   fn<type>(((rec, rec), rec) id) {}
         type<type>             fn<type>(((rec, rec), rec) id) {}
         (type, type)           fn      (((rec, rec), rec) id) {}
         (type, type)           fn<type>(((rec, rec), rec) id) {}
         ((type,), type)        fn      (((rec, rec), rec) id) {}
         (type, (type, type))   fn<type>(((rec, rec), rec) id) {}
  static (type, type)      get something                      => (5, 5);
  static (type, type)      set something((rec, rec) newThing) => (5, 5);
  static type                   fn      (((rec, rec), rec) id) {}
  static type<type>             fn      (((rec, rec), rec) id) {}
  static type                   fn<type>(((rec, rec), rec) id) {}
  static type<type>             fn<type>(((rec, rec), rec) id) {}
  static (type, type)           fn      (((rec, rec), rec) id) {}
  static (type, type)           fn<type>(((rec, rec), rec) id) {}
  static ((type,), type)        fn      (((rec, rec), rec) id) {}
  static (type, (type, type))   fn<type>(((rec, rec), rec) id) {}
}
   
fn      (((rec, rec), rec) id) {
fn      ((( id,  id),  id))
fn<type>(((rec, rec), rec) id) {
fn<type>((( id,  id),  id))
   
fn      (    (id, id), id)
fn<type>(    (id, id), id)
fn      (id, (id, id), id)
fn<type>(id, (id, id), id)

// TODO: `(id, id)` should not be showing as a type
fn      ( fn( (     id ,      id ) ), ((rec, rec) id) {return id} )
fn<type>( fn( (     id ,      id ) ), ((rec, rec) id) {return id} )
fn      ( fn( ((id, id), (id, id)) ), ((rec, rec) id) {return id} )
fn<type>( fn( ((id, id), (id, id)) ), ((rec, rec) id) {return id} )
   
fn       ( ((rec, rec) id) { return id },      id )
fn<type> ( ((rec, rec) id) { return id },      id )
fn       ( ((rec, rec) id) { return id }, (id, id))
fn<type> ( ((rec, rec) id) { return id }, (id, id))
fn!      ( ((rec, rec) id) { return id },      id )
fn!<type>( ((rec, rec) id) { return id },      id )
fn!      ( ((rec, rec) id) { return id }, (id, id))
fn!<type>( ((rec, rec) id) { return id }, (id, id))
fn       ( ((rec, rec) id) { return id },      id ).then(() {
fn<type> ( ((rec, rec) id) { return id },      id ).then(() {
fn!      ( ((rec, rec) id) { return id },      id ).then(() {
fn!<type>( ((rec, rec) id) { return id },      id ).then(() {
   
extension type id      .id((rec, rec) Function() id) {
class          id      .id((rec, rec) Function() id) {
extension type id<type>.id((rec, rec) Function() id) {
class          id<type>.id((rec, rec) Function() id) {
   
fn      (      id            , ((rec, rec) id) { return id } )
fn<type>(      id            , ((rec, rec) id) { return id } )
fn      ((     id ,      id ), ((rec, rec) id) { return id } )
fn<type>((     id ,      id ), ((rec, rec) id) { return id } )
fn      (((id, id), (id, id)), ((rec, rec) id) { return id } )
fn<type>(((id, id), (id, id)), ((rec, rec) id) { return id } )
   
fn      ( ((      rec ,       rec ) id) { return id }, ((rec, rec) id) { return id } )
fn<type>( ((      rec ,       rec ) id) { return id }, ((rec, rec) id) { return id } )
fn      ( (((rec, rec),       rec ) id) { return id }, ((rec, rec) id) { return id } )
fn<type>( (((rec, rec),       rec ) id) { return id }, ((rec, rec) id) { return id } )
fn      ( (((rec, rec), (rec, rec)) id) { return id }, ((rec, rec) id) { return id } )
fn<type>( (((rec, rec), (rec, rec)) id) { return id }, ((rec, rec) id) { return id } )
   
fn      ( ((      rec ,       rec ) id) { return id }( (     id ,      id ) ), ((rec, rec) id) { return id } )
fn<type>( ((      rec ,       rec ) id) { return id }( (     id ,      id ) ), ((rec, rec) id) { return id } )
fn      ( (((rec, rec),       rec ) id) { return id }( ((id, id),      id ) ), ((rec, rec) id) { return id } )
fn<type>( (((rec, rec),       rec ) id) { return id }( ((id, id),      id ) ), ((rec, rec) id) { return id } )
fn      ( (((rec, rec), (rec, rec)) id) { return id }( ((id, id), (id, id)) ), ((rec, rec) id) { return id } )
fn<type>( (((rec, rec), (rec, rec)) id) { return id }( ((id, id), (id, id)) ), ((rec, rec) id) { return id } )



// other edge-cases
for (var thing in mything) {}
item in myList;