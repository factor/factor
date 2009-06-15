USING: central destructors help.markup help.syntax ;

HELP: CENTRAL:
{ $description
    "This parsing word defines a pair of words useful for "
    "implementing the \"central\" pattern: " { $snippet "symbol" } " and "
    { $snippet "with-symbol" } ".  This is a middle ground between excessive "
    "stack manipulation and full-out locals, meant to solve the case where "
    "one object is operated on by several related words."
} ;

HELP: DISPOSABLE-CENTRAL:
{ $description
    "Like " { $link POSTPONE: CENTRAL: } ", but generates " { $snippet "with-" }
    " words that are wrapped in a " { $link with-disposal } "."
} ;