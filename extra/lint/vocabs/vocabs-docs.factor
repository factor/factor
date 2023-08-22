! Copyright (C) 2022 CapitalEx
! See https://factorcode.org/license.txt for BSD license.
USING: assocs hashtables help.markup help.syntax io kernel
sequences strings ;
IN: lint.vocabs

HELP: find-unused
{ $values
    { "name" "a vocab name string" }
    { "seq" sequence }
}
{ $description 
    "Finds unusued imports in the given vocab name. Returing the result as a " { $link sequence } "." 
} 
{ $examples
    { $example "USING: lint.vocabs prettyprint ;"
        "\"lint.vocabs\" find-unused ."
        "{ }"
    }
} ;

HELP: find-unused-in-file
{ $values
    { "path" "a pathname string" }
    { "seq" sequence }
}
{ $description 
    "Finds unused imports in the given file. Returing the result as a " { $link sequence } "." 
} 
{ $examples
    { $example "USING: lint.vocabs prettyprint ;"
        "\"vocab:lint/vocabs/vocabs.factor\" find-unused-in-file ."
        "{ }"
    }
} ;

HELP: find-unused-in-string
{ $values
    { "string" string }
    { "seq" sequence }
}
{ $description 
    "Finds unused imports in the given " { $link string } ". Returing the result as a " { $link sequence } "."
} ;

HELP: find-unused.
{ $values
    { "name" "a vocab name string" }
}
{ $description 
    "Finds unused imports in given vocab and outputs it to the current " { $link output-stream } "." 
}
{ $examples
    { $example "USING: lint.vocabs ;"
        "\"lint.vocabs\" find-unused."
        "No unused vocabs found in lint.vocabs."
    }
} ;


ARTICLE: "lint.vocabs" "The Unused Vocabulary Linter"
"The " { $vocab-link "lint.vocabs" } " vocabulary implements a set of words designed to find unused imports. "
"It attempts to ignore USE: and USING: that are a part of a string, postponed with either POSTPONE: or \\, and "
"contained inside a " { $link "regexp" } "."
$nl
"It can sometimes be easy to lose track of what vocabularies you've imported while iterating over ideas. So to "
"find any vocabularies you feel are unused, you can run:"
$nl
{ $example 
    "USING: lint.vocabs ;"
    "\"lint.vocabs\" find-unused."
    "No unused vocabs found in lint.vocabs."
}
;

ABOUT: "lint.vocabs"
