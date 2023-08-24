USING: help.markup help.syntax io kernel math
prettyprint.backend prettyprint.config prettyprint.custom
prettyprint.private prettyprint.sections sequences ;
IN: prettyprint

ARTICLE: "prettyprint-numbers" "Prettyprinting numbers"
"The " { $link . } " word prints numbers in decimal. A set of words in the " { $vocab-link "prettyprint" } " vocabulary is provided to print integers using another base."
{ $subsections
    .b
    .o
    .h
} ;

ARTICLE: "prettyprint-stacks" "Prettyprinting stacks"
"Prettyprinting the current data, retain, call stacks:"
{ $subsections
    .s
    .r
    .c
}
"Prettyprinting any stack:"
{ $subsections stack. }
"Prettyprinting any call stack:"
{ $subsections callstack. }
"Note that calls to " { $link .s } " can also be included inside words as a debugging aid, however a more convenient way to achieve this is to use the annotation facility. See " { $link "tools.annotations" } "." ;

ARTICLE: "prettyprint-variables" "Prettyprint control variables"
"The following variables affect the " { $link . } " and " { $link pprint } " words if set in the current dynamic scope:"
{ $subsections
    tab-size
    margin
    nesting-limit
    length-limit
    line-limit
    number-base
    string-limit?
    boa-tuples?
    c-object-pointers?
}
"The default limits are meant to strike a balance between readability, and not producing too much output when large structures are given. There are two combinators that override the defaults:"
{ $subsections with-short-limits without-limits }
"That the " { $link short. } " and " { $link pprint-short } " words wrap calls to " { $link . } " and " { $link pprint } " in " { $link with-short-limits } ". Code that uses the prettyprinter for serialization should use " { $link without-limits } " to avoid producing unreadable output." ;

ARTICLE: "prettyprint-limitations" "Prettyprinter limitations"
"When using the prettyprinter as a serialization mechanism, keep the following points in mind:"
{ $list
    { "When printing words, " { $link POSTPONE: USING: } " declarations are only output if the " { $link pprint-use } " or " { $link unparse-use } " words are used." }
    { "Long output will be truncated if certain " { $link "prettyprint-variables" } " are set." }
    "Shared structure is not reflected in the printed output; if the output is parsed back in, fresh objects are created for all literal denotations."
    { "Circular structure is not printed in a readable way. For example, try this:"
        { $code "{ f } dup dup set-first ." }
    }
    "Floating point numbers might not equal themselves after being printed and read, since a decimal representation of a float is inexact."
}
"On a final note, the " { $link short. } " and " { $link pprint-short } " words restrict the length and nesting of printed sequences, their output will very likely not be valid syntax. They are only intended for interactive use." ;

ARTICLE: "prettyprint-section-protocol" "Prettyprinter section protocol"
"Prettyprinter sections must subclass " { $link section } ", and they must also obey a protocol."
$nl
"Layout queries:"
{ $subsections
    section-fits?
    indent-section?
    unindent-first-line?
    newline-after?
    short-section?
}
"Printing sections:"
{ $subsections
    short-section
    long-section
}
"Utilities to use when implementing sections:"
{ $subsections
    new-section
    new-block
    add-section
} ;

ARTICLE: "prettyprint-sections" "Prettyprinter sections"
"The prettyprinter's formatting engine can be used directly:"
{ $subsections with-pprint }
"Code in a " { $link with-pprint } " block or a method on " { $link pprint* } " can build up a tree of " { $emphasis "sections" } ". A section is either a text node or a " { $emphasis "block" } " which itself consists of sections."
$nl
"Once the output sections have been generated, the tree of sections is traversed and intelligent decisions are made about indentation and line breaks. Finally, text is output."
{ $subsections section }
"Adding leaf sections:"
{ $subsections
    line-break
    text
    styled-text
}
"Nesting and denesting sections:"
{ $subsections
    <object
    <block
    <inset
    <flow
    <colon
    block>
}
"New types of sections can be defined."
{ $subsections "prettyprint-section-protocol" } ;

ARTICLE: "prettyprint-literal" "Literal prettyprinting protocol"
"Most custom data types have a literal syntax which resembles a sequence. An easy way to define such a syntax is to add a method to the " { $link pprint* } " generic word which calls " { $link pprint-object } ", and then to provide methods on two other generic words:"
{ $subsections
    pprint-delims
    >pprint-sequence
}
"For example, consider the following data type, together with a parsing word for creating literals:"
{ $code
    "TUPLE: rect w h ;"
    ""
    "SYNTAX: RECT["
    "    scan-number"
    "    scan-token \"*\" assert="
    "    scan-number"
    "    scan-token \"]\" assert="
    "    <rect> suffix! ;"
}
"An example literal might be:"
{ $code "RECT[ 100 * 200 ]" }
"Without further effort, the literal does not print in the same way:"
{ $unchecked-example "RECT[ 100 * 200 ] ." "T{ rect f 100 200 }" }
"However, we can define three methods easily enough:"
{ $code
    "M: rect pprint-delims drop \\ RECT[ \\ ] ;"
    "M: rect >pprint-sequence dup w>> \\ * rot h>> 3array ;"
    "M: rect pprint* pprint-object ;"
}
"Now, it will be printed in a custom way:"
{ $unchecked-example "RECT[ 100 * 200 ] ." "RECT[ 100 * 200 ]" } ;

ARTICLE: "prettyprint-literal-more" "Prettyprinting more complex literals"
"If the " { $link "prettyprint-literal" } " is insufficient, a method can be defined to control prettyprinting directly:"
{ $subsections pprint* }
"Some utilities which can be called from methods on " { $link pprint* } ":"
{ $subsections
    pprint-object
    pprint-word
    pprint-elements
    pprint-string
    pprint-prefix
}
"Custom methods defined on " { $link pprint* } " do not perform I/O directly, instead they call prettyprinter words to construct " { $emphasis "sections" } " of output. See " { $link "prettyprint-sections" } "." ;

ARTICLE: "prettyprint-extension" "Extending the prettyprinter"
"One can define literal syntax for a new class using the " { $link "parser" } " together with corresponding prettyprinting methods which print instances of the class using this syntax."
{ $subsections
    "prettyprint-literal"
    "prettyprint-literal-more"
}
"The prettyprinter actually exposes a general source code output engine and is not limited to printing object structure."
{ $subsections "prettyprint-sections" } ;

ARTICLE: "prettyprint" "The prettyprinter"
"One of Factor's key features is the ability to print almost any object as a valid source literal expression. This greatly aids debugging and provides the building blocks for light-weight object serialization facilities."
$nl
"Prettyprinter words are found in the " { $vocab-link "prettyprint" } " vocabulary."
$nl
"The key words to print an object to " { $link output-stream } "; the first three emit a trailing newline, the second three do not:"
{ $subsections
    .
    ...
    short.
    pprint
    pprint-short
    pprint-use
}
"The string representation of an object can be requested:"
{ $subsections
    unparse
    unparse-use
}
"Utility for tabular output:"
{ $subsections pprint-cell }
"More prettyprinter usage:"
{ $subsections
    "prettyprint-numbers"
    "prettyprint-stacks"
}
"Prettyprinter customization:"
{ $subsections
    "prettyprint-variables"
    "prettyprint-extension"
    "prettyprint-limitations"
}
{ $see-also "number-strings" "see" } ;

ABOUT: "prettyprint"

HELP: pprint
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } ". Output is influenced by many variables; see " { $link "prettyprint-variables" } "." }
{ $warning
    "Unparsing a large object can take a long time and consume a lot of memory. If you need to print large objects, use " { $link pprint-short } " or set some " { $link "prettyprint-variables" } " to limit output size."
} ;

{ pprint pprint* with-pprint } related-words

HELP: .
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } " with a trailing line break. Output is influenced by many variables; see " { $link "prettyprint-variables" } "." }
{ $warning
    "Printing a large object can take a long time and consume a lot of memory. If you need to print large objects, use " { $link short. } " or set some " { $link "prettyprint-variables" } " to limit output size."
} ;

HELP: ...
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } " with a trailing line break. Output is unlimited in length." }
{ $warning
    "Printing a large object can take a long time and consume a lot of memory. If you need to print large objects, use " { $link short. } " or set some " { $link "prettyprint-variables" } " to limit output size."
} ;

{ . ... } related-words

HELP: unparse
{ $values { "obj" object } { "str" "Factor source string" } }
{ $description "Outputs a prettyprinted string representation of an object. Output is influenced by many variables; see " { $link "prettyprint-variables" } "." }
{ $warning
    "Unparsing a large object can take a long time and consume a lot of memory. If you need to unparse large objects, use " { $link unparse-short } " or set some " { $link "prettyprint-variables" } " to limit output size."
} ;

HELP: pprint-short
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } ". This word rebinds printer control variables to enforce “shorter” output. See " { $link "prettyprint-variables" } "." } ;

HELP: short.
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } " with a trailing line break. This word rebinds printer control variables to enforce “shorter” output." } ;

HELP: .b
{ $values { "n" integer } }
{ $description "Outputs an integer in binary." } ;

HELP: .o
{ $values { "n" integer } }
{ $description "Outputs an integer in octal." } ;

HELP: .h
{ $values { "n" "an integer or floating-point value" } }
{ $description "Outputs an integer or floating-point value in hexadecimal." } ;

HELP: stack.
{ $values { "seq" sequence } }
{ $description "Prints a the elements of the sequence, one per line." }
{ $notes "This word is used in the implementation of " { $link .s } " and " { $link .r } "." } ;

HELP: callstack.
{ $values { "callstack" callstack } }
{ $description "Displays the " { $link callstack } " in a user friendly fashion with outermost stack frames first and innermost frames at the bottom. The current execution point in every call frame is highlighted with " { $link => } "." } ;

HELP: .c
{ $description "Displays the contents of the call stack, with the top of the stack printed first." } ;

HELP: .r
{ $description "Displays the contents of the retain stack, with the top of the stack printed first." } ;

HELP: .s
{ $description "Displays the contents of the data stack, with the top of the stack printed first." } ;
