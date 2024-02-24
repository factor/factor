USING: vocabs vocabs.loader.private help.markup help.syntax
words hashtables ;
IN: vocabs.loader

ARTICLE: "add-vocab-roots" "Working with code outside of the Factor source tree"
"You can work with code outside of the Factor source tree by adding additional directories to the list of vocabulary roots."
$nl
"There are four ways of doing this:"
$nl
"The first way is to use an environment variable. Factor looks at the " { $snippet "FACTOR_ROOTS" } " environment variable for a list of " { $snippet ":" } "-separated paths (on Unix) or a list of " { $snippet ";" } "-separated paths (on Windows)."
$nl
"The second way is to use the " { $snippet "-roots=" } " command-line argument. The format is the same as for the environment variable."
$nl
"The third way is to create a configuration file. You can list additional vocabulary roots in a file that Factor reads at startup:"
{ $subsections ".factor-roots" }
"Finally, you can add vocabulary roots by calling a word from your " { $snippet ".factor-rc" } " file (see " { $link ".factor-rc" } "):"
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
"An icon file representing the vocabulary can be provided for use by " { $link "tools.deploy" } ". If any of the following files exist inside the vocabulary directory, they will be used as icons when the application is deployed."
{ $list
    { { $snippet "icon.ico" } " on Windows and Linux" }
    { { $snippet "icon.icns" } " on MacOS X" }
    { { $snippet "icon.png" } " on Linux" }
}
"The icon file will be embedded in the vocab's image file." ;

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
"The above word will only ever load a vocabulary once in a given session. Sometimes, two vocabularies require special code to interact. The following word is used to load one vocabulary when another is present:"
{ $subsections require-when }
"There is another word which unconditionally loads vocabulary from disk, regardless of whether or not is has already been loaded:"
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
{ $values { "name" "a string" } { "vocab" { $maybe hashtable } } }
{ $description "Attempts to load a vocabulary from disk, or looks up the vocabulary in the dictionary, and then outputs that vocabulary object." } ;

HELP: vocab-main
{ $values { "vocab-spec" "a vocabulary specifier" } { "main" word } }
{ $description "Outputs the main entry point for a vocabulary. The entry point can be executed with " { $link run } " and set with " { $link POSTPONE: MAIN: } "." } ;

HELP: vocab-roots
{ $var-description "A sequence of pathname strings to search for vocabularies." } ;

HELP: add-vocab-root
{ $values { "root" "a pathname string" } }
{ $description "Adds a directory pathname to the list of vocabulary roots." }
{ $see-also ".factor-roots" add-vocab-root-hook } ;

HELP: add-vocab-root-hook
{ $var-description "A quotation that is run when a vocab root is added." }
{ $see-also add-vocab-root } ;

HELP: find-vocab-root
{ $values { "vocab" "a vocabulary specifier" } { "path/f" "a pathname string" } }
{ $description "Searches for a vocabulary in the vocabulary roots." } ;

HELP: no-vocab
{ $values { "name" "a vocabulary name" } }
{ $description "A " { $link no-vocab } " error tuple. Call " { $link no-vocab } " to throw it." }
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

HELP: require-when
{ $values { "if" { $sequence "vocabulary specifiers" } } { "then" "a vocabulary specifier" } }
{ $description "Loads the " { $snippet "then" } " vocabulary if it is not loaded and all of the " { $snippet "if" } " vocabulary is. If some of the " { $snippet "if" } " vocabularies are not loaded now, but they are later, then the " { $snippet "then" } " vocabulary will be loaded along with the final one." }
{ $notes "This is used to express a joint dependency of vocabularies. If vocabularies " { $snippet "a" } " and " { $snippet "b" } " use code in vocabulary " { $snippet "c" } " to interact, then the following line, which can be placed in " { $snippet "a" } " or " { $snippet "b" } ", expresses the dependency."
{ $code "{ \"a\" \"b\" } \"c\" require-when" } } ;

HELP: run
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Runs a vocabulary's main entry point. The main entry point is set with the " { $link POSTPONE: MAIN: } " parsing word." } ;

HELP: vocab-source-path
{ $values { "vocab" "a vocabulary specifier" } { "path/f" { $maybe "a pathname string" } } }
{ $description "Outputs a pathname where source code for " { $snippet "vocab" } " might be found. Outputs " { $link f } " if the vocabulary does not have a known directory on disk." } ;

HELP: vocab-docs-path
{ $values { "vocab" "a vocabulary specifier" } { "path/f" { $maybe "a pathname string" } } }
{ $description "Outputs a pathname where the documentation for " { $snippet "vocab" } " might be found. Outputs " { $link f } " if the vocabulary does not have a directory on disk." } ;
