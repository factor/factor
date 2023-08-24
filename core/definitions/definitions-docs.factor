USING: compiler.units generic hash-sets help.markup help.syntax
parser ;
IN: definitions

ARTICLE: "definition-protocol" "Definition protocol"
"A common protocol is used to build generic tools for working with all definitions."
$nl
"Definitions must know what source file they were loaded from, and provide a way to set this:"
{ $subsections
    where
    set-where
}
"Definitions can be removed:"
{ $subsections forget }
"Definitions must implement a few operations used for printing them in source form:"
{ $subsections
    definer
    definition
}
{ $see-also "see" } ;

ARTICLE: "definition-checking" "Definition sanity checking"
"When a source file is reloaded, the parser compares the previous list of definitions with the current list; any definitions which are no longer present in the file are removed by a call to " { $link forget } "."
$nl
"The parser also catches forward references when reloading source files. This is best illustrated with an example. Suppose we load a source file " { $snippet "a.factor" } ":"
{ $code
    "USING: io sequences ;"
    "IN: a"
    ": hello ( -- str ) \"Hello\" ;"
    ": world ( -- str ) \"world\" ;"
    ": hello-world ( -- ) hello \" \" world 3append print ;"
}
"The definitions for " { $snippet "hello" } ", " { $snippet "world" } ", and " { $snippet "hello-world" } " are in the dictionary."
$nl
"Now, after some heavily editing and refactoring, the file looks like this:"
{ $code
    "USING: make ;"
    "IN: a"
    ": hello ( -- ) \"Hello\" % ;"
    ": hello-world ( -- str ) [ hello \" \" % world ] \"\" make ;"
    ": world ( -- ) \"world\" % ;"
}
"Note that the developer has made a mistake, placing the definition of " { $snippet "world" } " " { $emphasis "after" } " its usage in " { $snippet "hello-world" } "."
$nl
"If the parser did not have special checks for this case, then the modified source file would still load, because when the definition of " { $snippet "hello-world" } " on line 4 is being parsed, the " { $snippet "world" } " word is already present in the dictionary from an earlier run. The developer would then not discover this mistake until attempting to load the source file into a fresh image."
$nl
"Since this is undesirable, the parser explicitly raises a " { $link no-word } " error if a source file refers to a word which is in the dictionary, but defined after it is used."
$nl
"The parser also catches duplicate definitions. If an artifact is defined twice in the same source file, the earlier definition will never be accessible, and this is almost always a mistake, perhaps due to a bad choice of word names, or a copy and paste error. The parser raises an error in this case."
{ $subsections redefine-error } ;

ARTICLE: "definitions" "Definitions"
"A " { $emphasis "definition" } " is an artifact read from a source file. Words for working with definitions are found in the " { $vocab-link "definitions" } " vocabulary."
$nl
"Definitions are defined using parsing words. Examples of definitions together with their defining parsing words are words (" { $link POSTPONE: : } "), methods (" { $link POSTPONE: M: } "), and vocabularies (" { $link POSTPONE: IN: } ")."
$nl
"All definitions share some common traits:"
{ $list
  "There is a word to list all definitions of a given type"
  "There is a parsing word for creating new definitions"
  "There is an ordinary word which is the runtime equivalent of the parsing word, for introspection"
  "Instances of the definition may be introspected and modified with the definition protocol"
}
"For every source file loaded into the system, a list of definitions is maintained. Pathname objects implement the definition protocol, acting over the definitions their source files contain. See " { $link "source-files" } " for details."
{ $subsections
    "definition-protocol"
    "definition-checking"
    "compilation-units"
}
"A parsing word to remove definitions:"
{ $subsections POSTPONE: FORGET: }
{ $see-also "see" "parser" "source-files" "words" "generic" "help-impl" } ;

ABOUT: "definitions"

HELP: changed-definition
{ $values { "defspec" "definition" } }
{ $description "Adds the definition to the unit's " { $link changed-definitions } "." } ;

HELP: changed-definitions
{ $var-description "A set that contains all words and vocabs whose definitions have changed or are new." }
{ $see-also changed-definition } ;

HELP: changed-effects
{ $var-description "A set that contains all words whose stack effects have changed in the compilation unit." } ;

HELP: forget
{ $values { "defspec" "a definition specifier" } }
{ $description "Forgets about a definition. For example, if it is a word, it will be removed from its vocabulary." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." } ;

HELP: forget-all
{ $values { "definitions" { $sequence "definition specifiers" } } }
{ $description "Forgets every definition in a sequence." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." } ;

HELP: maybe-changed
{ $var-description "The set of definitions that has maybe changed in the compilation unit. For example, if a union class is redefined it will be added to this set because it is possible but not certain that it has become different." } ;

HELP: outdated-generics
{ $var-description "A " { $link hash-set } " where newly defined generic words are kept until they are being remade." }
{ $see-also remake-generic remake-generics } ;

HELP: set-where
{ $values { "loc" "a " { $snippet "{ path line# }" } " pair" } { "defspec" "a definition specifier" } }
{ $description "Sets the definition's location." }
{ $notes "This word is used by the parser." } ;

HELP: where
{ $values { "defspec" "a definition specifier" } { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Outputs the location of a definition. If the location is not known, will output " { $link f } "." } ;
