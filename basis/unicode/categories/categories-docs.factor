! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: unicode.categories

ABOUT: "unicode.categories"

ARTICLE: "unicode.categories" "Unicode category syntax"
"There is special syntax sugar for making predicate classes which are unions of Unicode general categories, plus some other code."
{ $subsections
    POSTPONE: CATEGORY:
    POSTPONE: CATEGORY-NOT:
} ;

HELP: CATEGORY:
{ $syntax "CATEGORY: foo Nl Pd Lu | \"Diacritic\" property? ;" }
{ $description "This defines a predicate class which is a subset of code points. In this example, " { $snippet "foo" } " is the class of characters which are in the general category Nl or Pd or Lu, or which have the Diacritic property." } ;

HELP: CATEGORY-NOT:
{ $syntax "CATEGORY-NOT: foo Nl Pd Lu | \"Diacritic\" property? ;" }
{ $description "This defines a predicate class which is a subset of code points, the complement of what " { $link POSTPONE: CATEGORY: } " would define. In this example, " { $snippet "foo" } " is the class of characters which are neither in the general category Nl or Pd or Lu, nor have the Diacritic property." } ;
