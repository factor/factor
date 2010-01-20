USING: help.markup help.syntax math math.private ;
IN: math.integers

ARTICLE: "integers" "Integers"
{ $subsections integer }
"Integers come in two varieties -- fixnums and bignums. Fixnums fit in a machine word and are faster to manipulate; if the result of a fixnum operation is too large to fit in a fixnum, the result is upgraded to a bignum. Here is an example where two fixnums are multiplied yielding a bignum:"
{ $example "USE: classes" "67108864 class ." "fixnum" }
{ $example "USE: classes" "128 class ." "fixnum" }
{ $example "134217728 128 * ." "17179869184" }
{ $example "USE: classes" "1 128 shift class ." "bignum" }
"Integers can be entered using a different base; see " { $link "syntax-numbers" } "."
$nl
"Integers can be tested for, and real numbers can be converted to integers:"
{ $subsections
    fixnum?
    bignum?
    >fixnum
    >integer
    >bignum
}
{ $see-also "prettyprint-numbers" "modular-arithmetic" "bitwise-arithmetic" "integer-functions" "syntax-integers" } ;

ABOUT: "integers"

HELP: fixnum
{ $class-description "The class of fixnums, which are fixed-width integers small enough to fit in a machine cell. Because they are not heap-allocated, fixnums do not have object identity. Equality of tagged pointer bit patterns is actually " { $emphasis "value" } " equality for fixnums." } ;

HELP: >fixnum
{ $values { "x" real } { "n" fixnum } }
{ $description "Converts a real number to a fixnum, with a possible loss of precision and overflow." } ;

HELP: bignum
{ $class-description "The class of bignums, which are heap-allocated arbitrary-precision integers." } ;

HELP: >bignum
{ $values { "x" real } { "n" bignum } }
{ $description "Converts a real number to a bignum, with a possible loss of precision." } ;

HELP: >integer
{ $values { "x" real } { "n" bignum } }
{ $description "Converts a real number to an integer, with a possible loss of precision." } ;

HELP: integer
{ $class-description "The class of integers, which is a disjoint union of fixnums and bignums." } ;

HELP: even?
{ $values { "n" integer } { "?" "a boolean" } }
{ $description "Tests if an integer is even." } ;

HELP: odd?
{ $values { "n" integer } { "?" "a boolean" } }
{ $description "Tests if an integer is odd." } ;

! Unsafe primitives
HELP: fixnum+ ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" integer } }
{ $description "Primitive version of " { $link + } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link + } " instead." } ;

HELP: fixnum- ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" integer } }
{ $description "Primitive version of " { $link - } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link - } " instead." } ;

HELP: fixnum* ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" integer } }
{ $description "Primitive version of " { $link * } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link * } " instead." } ;

HELP: fixnum/i ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" integer } }
{ $description "Primitive version of " { $link /i } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link /i } " instead." } ;

HELP: fixnum-mod ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link mod } ". The result always fits in a fixnum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link mod } " instead." } ;

HELP: fixnum/mod ( x y -- z w )
{ $values { "x" fixnum } { "y" fixnum } { "z" integer } { "w" fixnum } }
{ $description "Primitive version of " { $link /mod } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link /mod } " instead." } ;

HELP: fixnum< ( x y -- ? )
{ $values { "x" fixnum } { "y" fixnum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link < } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link < } " instead." } ;

HELP: fixnum<= ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" integer } }
{ $description "Primitive version of " { $link <= } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link <= } " instead." } ;

HELP: fixnum> ( x y -- ? )
{ $values { "x" fixnum } { "y" fixnum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link > } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link > } " instead." } ;

HELP: fixnum>= ( x y -- ? )
{ $values { "x" fixnum } { "y" fixnum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link >= } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link >= } " instead." } ;

HELP: fixnum-bitand ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link bitand } ". The result always fits in a fixnum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitand } " instead." } ;

HELP: fixnum-bitor ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link bitor } ". The result always fits in a fixnum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitor } " instead." } ;

HELP: fixnum-bitxor ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link bitxor } ". The result always fits in a fixnum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitxor } " instead." } ;

HELP: fixnum-bitnot ( x -- y )
{ $values { "x" fixnum } { "y" fixnum } }
{ $description "Primitive version of " { $link bitnot } ". The result always fits in a fixnum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitnot } " instead." } ;

HELP: fixnum-shift ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link shift } ". The result may overflow to a bignum." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link shift } " instead." } ;

HELP: fixnum-shift-fast ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link shift } ". Unlike " { $link fixnum-shift } ", does not perform an overflow check, so the result may be incorrect." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link shift } " instead." } ;

HELP: fixnum+fast ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link + } ". Unlike " { $link fixnum+ } ", does not perform an overflow check, so the result may be incorrect." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link + } " instead." } ;

HELP: fixnum-fast ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link - } ". Unlike " { $link fixnum- } ", does not perform an overflow check, so the result may be incorrect." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link - } " instead." } ;

HELP: fixnum*fast ( x y -- z )
{ $values { "x" fixnum } { "y" fixnum } { "z" fixnum } }
{ $description "Primitive version of " { $link * } ". Unlike " { $link fixnum* } ", does not perform an overflow check, so the result may be incorrect." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link * } " instead." } ;

HELP: bignum+ ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link + } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link + } " instead." } ;

HELP: bignum- ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link - } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link - } " instead." } ;

HELP: bignum* ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link * } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link * } " instead." } ;

HELP: bignum/i ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link /i } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link /i } " instead." } ;

HELP: bignum-mod ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link mod } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link mod } " instead." } ;

HELP: bignum/mod ( x y -- z w )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } { "w" bignum } }
{ $description "Primitive version of " { $link /mod } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link /mod } " instead." } ;

HELP: bignum< ( x y -- ? )
{ $values { "x" bignum } { "y" bignum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link < } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link < } " instead." } ;

HELP: bignum<= ( x y -- ? )
{ $values { "x" bignum } { "y" bignum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link <= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link <= } " instead." } ;

HELP: bignum> ( x y -- ? )
{ $values { "x" bignum } { "y" bignum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link > } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link > } " instead." } ;

HELP: bignum>= ( x y -- ? )
{ $values { "x" bignum } { "y" bignum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link >= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link >= } " instead." } ;

HELP: bignum= ( x y -- ? )
{ $values { "x" bignum } { "y" bignum } { "?" "a boolean" } }
{ $description "Primitive version of " { $link number= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link number= } " instead." } ;

HELP: bignum-bitand ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link bitand } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitand } " instead." } ;

HELP: bignum-bitor ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link bitor } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitor } " instead." } ;

HELP: bignum-bitxor ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link bitxor } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitxor } " instead." } ;

HELP: bignum-bitnot ( x -- y )
{ $values { "x" bignum } { "y" bignum } }
{ $description "Primitive version of " { $link bitnot } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link bitnot } " instead." } ;

HELP: bignum-shift ( x y -- z )
{ $values { "x" bignum } { "y" bignum } { "z" bignum } }
{ $description "Primitive version of " { $link shift } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link shift } " instead." } ;
