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
{ $subsections "factor-roots" }
"Finally, you can add vocabulary roots dynamically using a word:"
{ $subsections add-vocab-root } ;

ARTICLE: "vocabs.roots" "Vocabulary roots"
"The vocabulary loader searches for vocabularies in one of the root directories:"
{ $subsections vocab-roots }
"The default set of roots includes the following directories in the Factor source directory:"
{ $list
    { { $snippet "core" } " - essential system vocabularies such as " { $vocab-link "parser" } " and " { $vocab-link "sequences" } ". The vocabularies in this root constitute the boot image; see " { $link "bootstrap.image" } "." }
    { { $snippet "basis" } " - useful libraries and tools, such as " { $vocab-link "compiler" } ", " { $vocab-link "ui" } ", " { $vocab-link "calendar" } ", and so on." }
    { { $snippet "extra" } " - additional contributed libraries." }
    { { $snippet "work" } " - a root for vocabularies which are not intended to be contributed back to Factor." }
}
"You can store your own vocabularies in the " { $snippet "work" } " directory."
{ $subsections "add-vocab-roots" } ;

ARTICLE: "vocabs.icons" "Vocabulary icons"
"An icon file representing the vocabulary can be provided for use by " { $link "tools.deploy" } ". A file named " { $snippet "icon.ico" } " will be used as the application icon when the application is deployed on Windows. A file named " { $snippet "icon.icns" } " will be used when the application is deployed on MacOS X." ;

ARTICLE: "vocabs.loader" "Vocabulary loader"
"The " { $link POSTPONE: USE: } " and " { $link POSTPONE: USING: } " words load vocabularies using the vocabulary loader. The vocabulary loader is implemented in the " { $vocab-link "vocabs.loader" } " vocabulary."
$nl
"The vocabulary loader searches for vocabularies in a set of directories known as vocabulary roots."
{ $subsections "vocabs.roots" }
"Vocabulary names map directly to source files inside these roots. A vocabulary named " { $snippet "foo.bar" } " is defined in " { $snippet "foo/bar/bar.factor" } "; that is, a source file named " { $snippet "bar.factor" } " within a " { $snippet "bar" } " directory nested inside a " { $snippet "foo" } " directory of a vocabulary root. Any level of nesting, separated by dots, is permitted."
$nl
"The vocabulary directory - " { $snippet "bar" } " in our example - contains a source file:"
{ $list
  { { $snippet "foo/bar/bar.factor" } " - the source file must define words in the " { $snippet "foo.bar" } " vocabulary with an " { $snippet "IN: foo.bar" } " form" }
}
"Two other Factor source files, storing documentation and tests, respectively, may optionally be placed alongside the source file:"
{ $list
    { { $snippet "foo/bar/bar-docs.factor" } " - documentation, see " { $link "writing-help" } }
    { { $snippet "foo/bar/bar-tests.factor" } " - unit tests, see " { $link "tools.test" } }
}
"Optional text files may contain metadata."
{ $subsections "vocabs.metadata" "vocabs.icons" }
"Vocabularies can also be loaded at run time, without altering the vocabulary search path. This is done by calling a word which loads a vocabulary if it is not in the image, doing nothing if it is:"
{ $subsections require }
"The above word will only ever load a vocabulary once in a given session. There is another word which unconditionally loads vocabulary from disk, regardless of whether or not is has already been loaded:"
{ $subsections reload }
"For interactive development in the listener, calling " { $link reload } " directly is usually not necessary, since a better facility exists for " { $link "vocabs.refresh" } "."
$nl
"Application vocabularies can define a main entry point, giving the user a convenient way to run the application:"
{ $subsections
    POSTPONE: MAIN:
    run
    runnable-vocab
}
{ $see-also "vocabularies" "parser" "source-files" } ;

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
{ $description "Reloads the source code and documentation for a vocabulary." }
{ $errors "Throws a " { $link no-vocab } " error if the vocabulary does not exist on disk." } ;

HELP: require
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Loads a vocabulary if it has not already been loaded." }
{ $notes "To unconditionally reload a vocabulary, use " { $link reload } ". To reload changed source files only, use the words in " { $link "vocabs.refresh" } "." } ;

HELP: run
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Runs a vocabulary's main entry point. The main entry point is set with the " { $link POSTPONE: MAIN: } " parsing word." } ;

HELP: vocab-source-path
{ $values { "vocab" "a vocabulary specifier" } { "path/f" "a pathname string or " { $link f } } }
{ $description "Outputs a pathname where source code for " { $snippet "vocab" } " might be found. Outputs " { $link f } " if the vocabulary does not have a directory on disk." } ;

HELP: vocab-docs-path
{ $values { "vocab" "a vocabulary specifier" } { "path/f" "a pathname string or " { $link f } } }
{ $description "Outputs a pathname where the documentation for " { $snippet "vocab" } " might be found. Outputs " { $link f } " if the vocabulary does not have a directory on disk." } ;
