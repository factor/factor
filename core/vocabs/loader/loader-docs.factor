USING: vocabs vocabs.loader.private help.markup help.syntax
words strings io ;
IN: vocabs.loader

ARTICLE: "add-vocab-roots" "Working with code outside of the Factor source tree"
"You can work with code outside of the Factor source tree by adding additional directories to the list of vocabulary roots."
$nl
"There are three ways of doing this."
$nl
"The first way is to use an environment variable. Factor looks at the " { $snippet "FACTOR_ROOTS" } " environment variable for a list of " { $snippet ":" } "-separated paths (on Unix) or a list of " { $snippet ";" } "-separated paths (on Windows)."
$nl
"The second way is to create a configuration file. You can list additional vocabulary roots in a file that Factor reads at startup:"
{ $subsection "factor-roots" }
"Finally, you can add vocabulary roots dynamically using a word:"
{ $subsection add-vocab-root } ;

ARTICLE: "vocabs.roots" "Vocabulary roots"
"The vocabulary loader searches for it in one of the root directories:"
{ $subsection vocab-roots }
"The default set of roots includes the following directories in the Factor source directory:"
{ $list
    { { $snippet "core" } " - essential system vocabularies such as " { $vocab-link "parser" } " and " { $vocab-link "sequences" } ". The vocabularies in this root constitute the boot image; see " { $link "bootstrap.image" } "." }
    { { $snippet "basis" } " - useful libraries and tools, such as " { $vocab-link "compiler" } ", " { $vocab-link "ui" } ", " { $vocab-link "calendar" } ", and so on." }
    { { $snippet "extra" } " - additional contributed libraries." }
    { { $snippet "work" } " - a root for vocabularies which are not intended to be contributed back to Factor." }
}
"You can store your own vocabularies in the " { $snippet "work" } " directory."
{ $subsection "add-vocab-roots" } ;

ARTICLE: "vocabs.loader" "Vocabulary loader"
"The vocabulary loader is defined in the " { $vocab-link "vocabs.loader" } " vocabulary."
$nl
"Vocabularies are searched for in vocabulary roots."
{ $subsection "vocabs.roots" }
"Vocabulary names map directly to source files. A vocabulary named " { $snippet "foo.bar" } " must be defined in a " { $snippet "bar" } " directory nested inside a " { $snippet "foo" } " directory of a vocabulary root. Any level of vocabulary nesting is permitted."
$nl
"The vocabulary directory - " { $snippet "bar" } " in our example - contains a source file:"
{ $list
  { { $snippet "foo/bar/bar.factor" } " - the source file, must define words in the " { $snippet "foo.bar" } " vocabulary with an " { $snippet "IN: foo.bar" } " form" }
}
"Two other Factor source files, storing documentation and tests, respectively, are optional:"
{ $list
    { { $snippet "foo/bar/bar-docs.factor" } " - documentation, see " { $link "writing-help" } }
    { { $snippet "foo/bar/bar-tests.factor" } " - unit tests, see " { $link "tools.test" } }
}
"Finally, three text files can contain meta-data:"
{ $list
    { { $snippet "foo/bar/authors.txt" } " - a series of lines, with one author name per line. These are listed under " { $link "vocab-authors" } }
    { { $snippet "foo/bar/summary.txt" } " - a one-line description" }
    { { $snippet "foo/bar/tags.txt" } " - a whitespace-separated list of tags which classify the vocabulary. Consult " { $link "vocab-tags" } " for a list of existing tags you can re-use" }
}
"While " { $link POSTPONE: USE: } " and " { $link POSTPONE: USING: } " load vocabularies which have not been loaded before adding them to the search path, it is also possible to load a vocabulary without adding it to the search path:"
{ $subsection require }
"Forcing a reload of a vocabulary, even if it has already been loaded:"
{ $subsection reload }
"Application vocabularies can define a main entry point, giving the user a convenient way to run the application:"
{ $subsection POSTPONE: MAIN: }
{ $subsection run }
{ $subsection runnable-vocab }
{ $see-also "vocabularies" "parser-files" "source-files" } ;

ABOUT: "vocabs.loader"

HELP: load-vocab
{ $values { "name" "a string" } { "vocab" "a hashtable or " { $link f } } }
{ $description "Outputs a named vocabulary. If the vocabulary does not exist, throws a restartable " { $link no-vocab } " error. If the user invokes the restart, this word outputs " { $link f } "." }
{ $error-description "Thrown by " { $link POSTPONE: USE: } " and " { $link POSTPONE: USING: } " when a given vocabulary does not exist. Vocabularies must be created by " { $link POSTPONE: IN: } " before being used." } ;

HELP: vocab-main
{ $values { "vocab-spec" "a vocabulary specifier" } { "main" word } }
{ $description "Outputs the main entry point for a vocabulary. The entry point can be executed with " { $link run } " and set with " { $link POSTPONE: MAIN: } "." } ;

HELP: vocab-roots
{ $var-description "A sequence of pathname strings to search for vocabularies." } ;

HELP: add-vocab-root
{ $values { "root" "a pathname string" } }
{ $description "Adds a directory pathname to the list of vocabulary roots." }
{ $see-also "factor-roots" } ;

HELP: find-vocab-root
{ $values { "vocab" "a vocabulary specifier" } { "path/f" "a pathname string" } }
{ $description "Searches for a vocabulary in the vocabulary roots." } ;

HELP: no-vocab
{ $values { "name" "a vocabulary name" } } 
{ $description "Throws a " { $link no-vocab } "." }
{ $error-description "Thrown when a " { $link POSTPONE: USE: } " or " { $link POSTPONE: USING: } " form refers to a non-existent vocabulary." } ;

HELP: load-help?
{ $var-description "If set to a true value, documentation will be automatically loaded when vocabularies are loaded. This variable is usually on, except when Factor has been bootstrapped without the help system." } ;

HELP: load-source
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Loads a vocabulary's source code." } ;

HELP: load-docs
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "If " { $link load-help? } " is on, loads a vocabulary's documentation." } ;

HELP: reload
{ $values { "name" "a vocabulary name" } }
{ $description "Loads it's source code and documentation." }
{ $errors "Throws a " { $link no-vocab } " error if the vocabulary does not exist on disk." } ;

HELP: require
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Loads a vocabulary if it has not already been loaded." }
{ $notes "To unconditionally reload a vocabulary, use " { $link reload } ". To reload changed source files only, use the words in " { $link "tools.vocabs" } "." } ;

HELP: run
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Runs a vocabulary's main entry point. The main entry point is set with the " { $link POSTPONE: MAIN: } " parsing word." } ;

HELP: vocab-source-path
{ $values { "vocab" "a vocabulary specifier" } { "path/f" "a pathname string or " { $link f } } }
{ $description "Outputs a pathname where source code for " { $snippet "vocab" } " might be found. Outputs " { $link f } " if the vocabulary does not have a directory on disk." } ;

HELP: vocab-docs-path
{ $values { "vocab" "a vocabulary specifier" } { "path/f" "a pathname string or " { $link f } } }
{ $description "Outputs a pathname where the documentation for " { $snippet "vocab" } " might be found. Outputs " { $link f } " if the vocabulary does not have a directory on disk." } ;
