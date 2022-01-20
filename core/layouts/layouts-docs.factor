USING: help.markup help.syntax math kernel.private classes
classes.builtin ;
IN: layouts

HELP: tag-bits
{ $var-description "Number of least significant bits reserved for a type tag in a tagged pointer." }
{ $see-also tag } ;

HELP: tag-mask
{ $var-description "Taking the bitwise and of a tagged pointer with this mask leaves the tag." } ;

HELP: num-types
{ $var-description "Number of distinct built-in types. This is one more than the maximum value from the " { $link tag } " primitive." } ;

HELP: type-number
{ $values { "class" class } { "n" { $maybe integer } } }
{ $description "Outputs the built-in type number instances of " { $link class } ". Will output " { $link f } " if this is not a built-in class." }
{ $see-also builtin-class } ;

HELP: tag-fixnum
{ $values { "n" integer } { "tagged" integer } }
{ $description "Outputs a tagged fixnum." } ;

HELP: fixnum-bits
{ $values { "n" "number of bits in a fixnum" } } ;

HELP: first-bignum
{ $values { "n" "smallest positive integer not representable by a fixnum" } } ;

HELP: most-positive-fixnum
{ $values { "n" "largest positive integer representable by a fixnum" } } ;

HELP: most-negative-fixnum
{ $values { "n" "smallest negative integer representable by a fixnum" } } ;

HELP: bootstrap-first-bignum
{ $values { "n" "smallest positive integer not representable by a fixnum" } }
{ $description "Outputs the value for the target architecture when bootstrapping." } ;

HELP: bootstrap-most-positive-fixnum
{ $values { "n" "largest positive integer representable by a fixnum" } }
{ $description "Outputs the value for the target architecture when bootstrapping." } ;

HELP: bootstrap-most-negative-fixnum
{ $values { "n" "smallest negative integer representable by a fixnum" } }
{ $description "Outputs the value for the target architecture when bootstrapping." } ;

HELP: cell
{ $values { "n" "a positive integer" } }
{ $description "Outputs the pointer size in bytes of the current CPU architecture." } ;

HELP: cells
{ $values { "m" integer } { "n" integer } }
{ $description "Computes the number of bytes used by " { $snippet "m" } " CPU operand-sized cells." } ;

HELP: cell-bits
{ $values { "n" integer } }
{ $description "Outputs the number of bits in one CPU operand-sized cell." } ;

HELP: bootstrap-cell
{ $values { "n" "a positive integer" } }
{ $description "Outputs the pointer size in bytes for the target image (if bootstrapping) or the current CPU architecture (otherwise)." } ;

HELP: bootstrap-cells
{ $values { "m" integer } { "n" integer } }
{ $description "Computes the number of bytes used by " { $snippet "m" } " cells in the target image (if bootstrapping) or the current CPU architecture (otherwise)." } ;

HELP: bootstrap-cell-bits
{ $values { "n" integer } }
{ $description "Outputs the number of bits in one cell in the target image (if bootstrapping) or the current CPU architecture (otherwise)." } ;

HELP: immediate
{ $class-description "Union class of all values that the Factor VM can store immediately, all others are stored as references (pointer) to them." } ;

ARTICLE: "layouts-types" "Type numbers"
"Corresponding to every built-in class is a built-in type number. An object can be asked for its built-in type number:"
{ $subsections tag }
"Built-in type numbers can be converted to classes, and vice versa:"
{ $subsections
    type>class
    type-number
    num-types
}
{ $see-also "builtin-classes" } ;

ARTICLE: "layouts-tags" "Tagged pointers"
"Every pointer stored on the stack or in the heap has a " { $emphasis "tag" } ", which is a small integer identifying the type of the pointer. If the tag is not equal to one of the two special tags, the remaining bits contain the memory address of a heap-allocated object. The two special tags are the " { $link fixnum } " tag and the " { $link f } " tag."
$nl
"Words for working with tagged pointers:"
{ $subsections
    tag-bits
    tag-mask
}
"The Factor VM does not actually expose any words for working with tagged pointers directly. The above words operate on integers; they are used in the bootstrap image generator and the optimizing compiler." ;

ARTICLE: "layouts-limits" "Sizes and limits"
"Processor cell size:"
{ $subsections
    cell
    cells
    cell-bits
}
"Range of integers representable by " { $link fixnum } "s:"
{ $subsections
    most-negative-fixnum
    most-positive-fixnum
}
"Maximum array size:"
{ $subsections max-array-capacity } ;

ARTICLE: "layouts-bootstrap" "Bootstrap support"
"Processor cell size for the target architecture:"
{ $subsections
    bootstrap-cell
    bootstrap-cells
    bootstrap-cell-bits
}
"Range of integers representable by " { $link fixnum } "s of the target architecture:"
{ $subsections
    bootstrap-most-negative-fixnum
    bootstrap-most-positive-fixnum
}
"Maximum array size for the target architecture:"
{ $subsections bootstrap-max-array-capacity } ;

ARTICLE: "layouts" "VM memory layouts"
"The words documented in this section do not ever need to be called by user code. They are documented for the benefit of those wishing to explore the internals of Factor's implementation."
{ $subsections
    "layouts-types"
    "layouts-tags"
    "layouts-limits"
    "layouts-bootstrap"
} ;

ABOUT: "layouts"
