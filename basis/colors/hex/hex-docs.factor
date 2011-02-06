! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: colors help.markup help.syntax strings ;

IN: colors.hex

HELP: hex>rgba
{ $values { "hex" string } { "rgba" color } }
{ $description "Converts a hexadecimal string value into a " { $link color } "." }
;

HELP: rgba>hex
{ $values { "rgba" color } { "hex" string } }
{ $description "Converts a " { $link color } " into a hexadecimal string value." }
;

HELP: HEXCOLOR:
{ $syntax "HEXCOLOR: value" }
{ $description "Parses as a " { $link color } " object with the given hexadecimal value." }
{ $examples
  { $code
    "USING: colors.hex io.styles ;"
    "\"Hello!\" { { foreground HEXCOLOR: 336699 } } format nl"
  }
} ;

ARTICLE: "colors.hex" "HEX colors"
"The " { $vocab-link "colors.hex" } " vocabulary implements colors specified "
"by their hexadecimal value."
{ $subsections
    hex>rgba
    rgba>hex
    POSTPONE: HEXCOLOR:
}
{ $see-also "colors" } ;

ABOUT: "colors.hex"
