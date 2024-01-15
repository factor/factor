! Copyright (C) 2024 Aleksander Sabak.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.markup help.syntax kernel math quotations sequences
sequences.parser ;
IN: sequences.parser

HELP: <safe-slice>
{ $values
    { "from" integer } { "to" integer } { "seq" sequence }
    { "slice/f" { $maybe slice } }
}
{ $description "" } ;

HELP: <sequence-parser>
{ $values
    { "sequence" sequence }
    { "sequence-parser" sequence-parser }
}
{ $description
  "Creates a new sequence-parser parsing " { $snippet "sequence" } "."
}
{ $see-also advance current offset }
;

{ advance current consume next offset } related-words

HELP: advance
{ $values
    { "sequence-parser" sequence-parser }
}
{ $description "Advances the parser by one element." } ;

HELP: consume
{ $values
    { "sequence-parser" sequence-parser }
    { "obj/f" { $maybe object } }
}
{ $description "Returns the current element and advances the parser." } ;

HELP: current
{ $values
    { "sequence-parser" sequence-parser }
    { "obj/f" { $maybe object } }
}
{ $description "Returns the current element." } ;

HELP: next
{ $values
    { "sequence-parser" sequence-parser }
    { "obj/f" { $maybe object } }
}
{ $description "Advances the parser and returns the new current element." } ;

HELP: offset
{ $values
    { "sequence-parser" sequence-parser } { "offset" object }
    { "obj/f" { $maybe object } }
}
{ $description "Return the element of the parsed sequence offset from the current position of the parser. Negative offsets will yield already parsed elements." } ;

{ parse-sequence with-sequence-parser } related-words

HELP: parse-sequence
{ $values
    { "sequence" sequence } { "quot" { $quotation ( ..a parser -- ..b ) } }
}
{ $description "Runs the quotation on a sequence-parser parsing the " { $snippet "sequence" } "." } ;

HELP: peek-next
{ $values
    { "sequence-parser" sequence-parser }
    { "obj/f" { $maybe object } }
}
{ $description "Return the element of the sequence after the current position of the parser." } ;

HELP: previous
{ $values
    { "sequence-parser" sequence-parser }
    { "obj/f" { $maybe object } }
}
{ $description "Return the element of the sequence before the current position of the parser." } ;

HELP: sequence-parse-end?
{ $values
    { "sequence-parser" sequence-parser }
    { "?" boolean }
}
{ $description "Retruns " { $link POSTPONE: t } " if the parser has exhausted the sequence, otherwise " { $link POSTPONE: f } "." } ;

HELP: sequence-parser
{ $class-description "" } ;

HELP: skip-until
{ $values
    { "sequence-parser" sequence-parser } { "quot" quotation }
}
{ $description "" } ;

HELP: skip-whitespace
{ $values
    { "sequence-parser" sequence-parser }
}
{ $description "" } ;

HELP: skip-whitespace-eol
{ $values
    { "sequence-parser" sequence-parser }
}
{ $description "" } ;

HELP: sort-tokens
{ $values
    { "seq" sequence }
    { "seq'" sequence }
}
{ $description "" } ;

HELP: take-first-matching
{ $values
    { "sequence-parser" sequence-parser } { "seq" sequence }
}
{ $description "" } ;

HELP: take-integer
{ $values
    { "sequence-parser" sequence-parser }
    { "n/f" { $maybe integer } }
}
{ $description "" } ;

HELP: take-longest
{ $values
    { "sequence-parser" sequence-parser } { "seq" sequence }
}
{ $description "" } ;

HELP: take-n
{ $values
    { "sequence-parser" sequence-parser } { "n" integer }
    { "seq/f" { $maybe sequence } }
}
{ $description "" } ;

HELP: take-rest
{ $values
    { "sequence-parser" sequence-parser }
    { "sequence" sequence }
}
{ $description "" } ;

HELP: take-rest-slice
{ $values
    { "sequence-parser" sequence-parser }
    { "sequence/f" { $maybe sequence } }
}
{ $description "" } ;

HELP: take-sequence
{ $values
    { "sequence-parser" sequence-parser } { "sequence" sequence }
    { "obj/f" { $maybe object } }
}
{ $description "" } ;

HELP: take-sequence*
{ $values
    { "sequence-parser" sequence-parser } { "sequence" sequence }
}
{ $description "" } ;

HELP: take-until
{ $values
    { "sequence-parser" sequence-parser } { "quot" quotation }
    { "sequence/f" { $maybe sequence } }
}
{ $description "" } ;

HELP: take-until-object
{ $values
    { "sequence-parser" sequence-parser } { "obj" object }
    { "sequence" sequence }
}
{ $description "" } ;

HELP: take-until-sequence
{ $values
    { "sequence-parser" sequence-parser } { "sequence" sequence }
    { "sequence'/f" { $maybe sequence } }
}
{ $description "" } ;

HELP: take-until-sequence*
{ $values
    { "sequence-parser" sequence-parser } { "sequence" sequence }
    { "sequence'/f" { $maybe sequence } }
}
{ $description "" } ;

HELP: take-while
{ $values
    { "sequence-parser" sequence-parser } { "quot" quotation }
    { "sequence/f" { $maybe sequence } }
}
{ $description "" } ;

HELP: with-sequence-parser
{ $values
    { "sequence-parser" sequence-parser } { "quot" { $quotation ( ..a parser -- ..b obj/f ) } }
    { "obj/f" { $maybe object } }
}
{ $description "Saves the position of the parser and calls the quotation on it. If the quotation returns " { $link POSTPONE: f } " the parser is rewound to the saved position." } ;

HELP: write-full
{ $values
    { "sequence-parser" sequence-parser }
}
{ $description "" } ;

HELP: write-rest
{ $values
    { "sequence-parser" sequence-parser }
}
{ $description "" } ;

ARTICLE: "sequences.parser" "sequences.parser"
{ $vocab-link "sequences.parser" }
;

ABOUT: "sequences.parser"
