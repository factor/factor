USING: layouts generic help.markup help.syntax kernel math
memory namespaces sequences kernel.private classes ;

HELP: tag-bits
{ $var-description "Number of least significant bits reserved for a type tag in a tagged pointer." }
{ $see-also tag } ;

HELP: num-tags
{ $var-description "Number of distinct pointer tags. This is one more than the maximum value from the " { $link tag } " primitive." } ;

HELP: tag-mask
{ $var-description "Taking the bitwise and of a tagged pointer with this mask leaves the tag." } ;

HELP: num-types
{ $var-description "Number of distinct built-in types. This is one more than the maximum value from the " { $link type } " primitive." } ;

HELP: tag-number
{ $values { "class" class } { "n" "an integer or " { $link f } } }
{ $description "Outputs the pointer tag for pointers to instances of " { $link class } ". Will output " { $link f } " if instances of this class are not identified by a distinct pointer tag." } ;

HELP: type-number
{ $values { "class" class } { "n" "an integer or " { $link f } } }
{ $description "Outputs the built-in type number instances of " { $link class } ". Will output " { $link f } " if this is not a built-in class." }
{ $see-also builtin-class } ;

HELP: tag-header
{ $values { "n" "a built-in type number" } { "tagged" integer } }
{ $description "Outputs the header for objects of type " { $snippet "n" } "." } ;

HELP: first-bignum
{ $values { "n" "smallest positive integer not representable by a fixnum" } } ;

HELP: most-positive-fixnum
{ $values { "n" "largest positive integer representable by a fixnum" } } ;

HELP: most-negative-fixnum
{ $values { "n" "smallest negative integer representable by a fixnum" } } ;
