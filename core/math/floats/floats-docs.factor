USING: help.markup help.syntax math math.private ;
IN: math.floats

ARTICLE: "floats" "Floats"
{ $subsection float }
"Rational numbers represent " { $emphasis "exact" } " quantities. On the other hand, a floating point number is an " { $emphasis "approximation" } ". While rationals can grow to any required precision, floating point numbers are fixed-width, and manipulating them is usually faster than manipulating ratios or bignums (but slower than manipulating fixnums). Floating point numbers are often used to represent irrational numbers, which have no exact representation as a ratio of two integers."
$nl
"Introducing a floating point number in a computation forces the result to be expressed in floating point."
{ $example "5/4 1/2 + ." "7/4" }
{ $example "5/4 0.5 + ." "1.75" }
"Integers and rationals can be converted to floats:"
{ $subsection >float }
"Two real numbers can be divided yielding a float result:"
{ $subsection /f }
"Floating point numbers are represented internally in IEEE 754 double-precision format. This internal representation can be accessed for advanced operations and input/output purposes."
{ $subsection float>bits }
{ $subsection double>bits }
{ $subsection bits>float }
{ $subsection bits>double }
{ $see-also "syntax-floats" } ;

ABOUT: "floats"

HELP: float
{ $class-description "The class of double-precision floating point numbers." } ;

HELP: >float ( x -- y )
{ $values { "x" real } { "y" float } }
{ $description "Converts a real to a float. This is the identity on floats, and performs a floating point division on rationals." } ;

HELP: bits>double ( n -- x )
{ $values { "n" "a 64-bit integer representing an 754 double-precision float" } { "x" float } }
{ $description "Creates a " { $link float } " object from a binary representation. This word is usually used to reconstruct floats read from streams." } ;

{ bits>double bits>float double>bits float>bits } related-words

HELP: bits>float ( n -- x )
{ $values { "n" "a 32-bit integer representing an 754 single-precision float" } { "x" float } }
{ $description "Creates a " { $link float } " object from a binary representation. This word is usually used to reconstruct floats read from streams." } ;

HELP: double>bits ( x -- n )
{ $values { "x" float } { "n" "a 64-bit integer representing an 754 double-precision float" } }
{ $description "Creates a " { $link float } " object from a binary representation. This word is usually used to reconstruct floats read from streams." } ;

HELP: float>bits ( x -- n )
{ $values { "x" float } { "n" "a 32-bit integer representing an 754 single-precision float" } }
{ $description "Creates a " { $link float } " object from a binary representation. This word is usually used to reconstruct floats read from streams." } ;

! Unsafe primitives
HELP: float+ ( x y -- z )
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link + } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link + } " instead." } ;

HELP: float- ( x y -- z )
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link - } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link - } " instead." } ;

HELP: float* ( x y -- z )
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link * } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link * } " instead." } ;

HELP: float-mod ( x y -- z )
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link mod } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link mod } " instead." } ;

HELP: float/f ( x y -- z )
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link /f } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link /f } " instead." } ;

HELP: float< ( x y -- ? )
{ $values { "x" float } { "y" float } { "?" "a boolean" } }
{ $description "Primitive version of " { $link < } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link < } " instead." } ;

HELP: float<= ( x y -- ? )
{ $values { "x" float } { "y" float } { "?" "a boolean" } }
{ $description "Primitive version of " { $link <= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link <= } " instead." } ;

HELP: float> ( x y -- ? )
{ $values { "x" float } { "y" float } { "?" "a boolean" } }
{ $description "Primitive version of " { $link > } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link > } " instead." } ;

HELP: float>= ( x y -- ? )
{ $values { "x" float } { "y" float } { "?" "a boolean" } }
{ $description "Primitive version of " { $link >= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link >= } " instead." } ;
