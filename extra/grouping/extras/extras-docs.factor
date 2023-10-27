USING: arrays grouping help.markup help.syntax kernel math
quotations sequences ;
IN: grouping.extras

HELP: group-by
{ $values { "seq" sequence } { "quot" { $quotation ( elt -- key ) } } { "groups" "a new assoc" } }
{ $description "Groups the elements by the key received by applying quot to each element in the sequence." }
{ $examples
  { $example
    "USING: grouping.extras unicode.data prettyprint sequences strings ;"
    "\"THis String Has  CasE!\" [ category ] group-by [ last >string ] { } map-as ."
    "{ \"TH\" \"is\" \" \" \"S\" \"tring\" \" \" \"H\" \"as\" \"  \" \"C\" \"as\" \"E\" \"!\" }"
  }
} ;

HELP: <n-groups>
{ $values
    { "seq" sequence } { "n" integer }
    { "groups" object }
}
{ $description "Separates a sequence into " { $snippet "n" } " groups of roughly equal size, any remainder is distributed to the first groups. Groups are represented by slices." } ;

HELP: <prefixes>
{ $values
    { "seq" sequence }
    { "prefixes" object }
}
{ $description "All slices of a sequence that start at index 0, ordered by length in ascending order. The empty sequence is not included." } ;


HELP: <suffixes>
{ $values
    { "seq" sequence }
    { "suffixes" object }
}
{ $description "All slices of a sequence that end at its last element, ordered by length in descending order. The empty sequence is not included." } ;

HELP: clump-as
{ $values
    { "seq" sequence } { "n" integer } { "exemplar" object }
    { "array" array }
}
{ $description "A version of " { $link clump } " that returns a sequence of the same class as " { $snippet "exemplar" } "." } ;

HELP: clump-map
{ $values
    { "seq" sequence } { "quot" quotation } { "n" integer }
    { "result" object }
}
{ $description "Map each clump of " { $snippet "seq" } " of size " { $snippet "n" } " using " { $snippet "quot" } "." } ;

HELP: clump-map-as
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" object } { "n" integer }
    { "result" object }
}
{ $description "A version of " { $link clump-map } " that returns a sequence of the same class as " { $snippet "exemplar" } "." } ;

HELP: group-as
{ $values
    { "seq" sequence } { "n" integer } { "exemplar" object }
    { "array" array }
}
{ $description "A version of " { $link group } " that returns a sequence of the same class as " { $snippet "exemplar" } "." } ;

HELP: group-map
{ $values
    { "seq" sequence } { "quot" quotation } { "n" integer }
    { "result" object }
}
{ $description "Map each group of " { $snippet "seq" } " of size " { $snippet "n" } " using " { $snippet "quot" } "." } ;

HELP: group-map-as
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" object } { "n" integer }
    { "result" object }
}
{ $description "A version of " { $link group-map } " that returns a sequence of the same class as " { $snippet "exemplar" } "." } ;

HELP: n-group
{ $values
    { "seq" sequence } { "n" integer }
    { "groups" object }
}
{ $description "A strict version of " { $link <n-groups> } " that returns a list of sequences instead of slices." }
{ $examples
  { $example
    "USING: grouping.extras prettyprint ;"
    "\"abcdefgh\" 4 n-group ."
    "{ \"ab\" \"cd\" \"ef\" \"gh\" }"
  }
  { $example
    "USING: grouping.extras prettyprint ;"
    "\"abcdefgh\" 3 n-group ."
    "{ \"abc\" \"def\" \"gh\" }"
  }
} ;

HELP: pad-groups
{ $values
    { "seq" sequence } { "n" integer } { "elt" object }
    { "padded" object }
}
{ $description "Pads " { $snippet "seq" } " at the end with element " { $snippet "elt" } 
    " such that its length is divisible by " { $snippet "n" } "." } ;

HELP: short-groups
{ $values
    { "seq" sequence } { "n" integer }
    { "seq'" sequence }
}
{ $description "If the length of " { $snippet "seq" } " is divisible by " { $snippet "n" } 
    ", return the sequence as is. Otherwise, trim it at the end to fit that requirement."
    $nl
    "Returns a virtual sequence." } ;

HELP: all-prefixes
{ $values
    { "seq" sequence }
    { "array" array }
}
{ $description "A strict version of " { $link <prefixes> } " that returns a list of sequences"
    " instead of slices." } ;

HELP: prefixes
{ $class-description "Class that represents the prefixes of a sequence." } ;

HELP: all-suffixes
{ $values
    { "seq" sequence }
    { "array" array }
}
{ $description "A strict version of " { $link <suffixes> } " that returns a list of sequences instead of slices." } ;

HELP: suffixes
{ $class-description "Class that represents the suffixes of a sequence." } ;
