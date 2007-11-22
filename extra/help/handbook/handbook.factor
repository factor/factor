USING: help help.markup help.syntax help.topics
namespaces words sequences classes assocs vocabs kernel
arrays prettyprint.backend kernel.private io tools.browser
generic ;
IN: help.handbook

ARTICLE: "conventions" "Conventions"
"Various conventions are used throughout the Factor documentation and source code."
{ $heading "Documentation conventions" }
"Factor documentation consists of two distinct bodies of text. There is a hierarchy of articles, much like this one, and there is word documentation. Help articles reference word documentation, and vice versa, but not every documented word is referenced from some help article."
$nl
"Every article has links to parent articles at the top. These can be persued if the article is too specific."
$nl
"Some generic words have " { $strong "Description" } " headings, and others have " { $strong "Contract" } " headings. A distinction is made between words which are not intended to be extended with user-defined methods, and those that are."
{ $heading "Vocabulary naming conventions" }
"A vocabulary name ending in " { $snippet ".private" } " contains words which are either implementation detail, unsafe, or both. For example, the " { $snippet "sequence.private" } " vocabulary contains words which access sequence elements without bounds checking (" { $link "sequences-unsafe" } ")."
$nl
"You should should avoid using internal words from the Factor library unless absolutely necessary. Similarly, your own code can place words in internal vocabularies if you do not want other people to use them unless they have a good reason."
{ $heading "Word naming conventions" }
"These conventions are not hard and fast, but are usually a good first step in understanding a word's behavior:"
{ $table
    { "General form" "Description" "Examples" }
    { { $snippet { $emphasis "foo" } "?" } "outputs a boolean" { { $link empty? } } }
    { { $snippet "?" { $emphasis "foo" } } { "conditionally performs " { $snippet { $emphasis "foo" } } } { { $links ?nth } } }
    { { $snippet "<" { $emphasis "foo" } ">" } { "creates a new " { $snippet "foo" } } { { $link <array> } } }
    { { $snippet { $emphasis "foo" } "*" } { "alternative form of " { $snippet "foo" } ", or a generic word called by " { $snippet "foo" } } { { $links at* pprint* } } }
    { { $snippet "(" { $emphasis "foo" } ")" } { "implementation detail word used by " { $snippet "foo" } } { { $link (clone) } } }
    { { $snippet "set-" { $emphasis "foo" } } { "sets " { $snippet "foo" } " to a new value" } { $links set-length } }
    { { $snippet { $emphasis "foo" } "-" { $emphasis "bar" } } { "(tuple accessors) outputs the value of the " { $snippet "bar" } " slot of the " { $snippet "foo" } " at the top of the stack" } { } }
    { { $snippet "set-" { $emphasis "foo" } "-" { $emphasis "bar" } } { "(tuple mutators) sets the value of the " { $snippet "bar" } " slot of the " { $snippet "foo" } " at the top of the stack" } { } }
    { { $snippet "with-" { $emphasis "foo" } } { "performs some kind of initialization and cleanup related to " { $snippet "foo" } ", usually in a new dynamic scope" } { $links with-scope with-stream } }
    { { $snippet "$" { $emphasis "foo" } } { "help markup" } { $links $heading $emphasis } }
}
{ $heading "Glossary of terms" }
"Common terminology and abbreviations used throughout Factor and its documentation:"
{ $table
    { "Term" "Definition" }
    { "alist" { "an association list. See " { $link "alists" } } }
    { "assoc" "an associative mapping" }
    { "associative mapping" { "an object whose class implements the " { $link "assocs-protocol" } } }
    { "boolean"               { { $link t } " or " { $link f } } }
    { "class"                 { "a set of objects identified by a " { $emphasis "class word" } " together with a discriminating predicate. See " { $link "classes" } } }
    { "definition specifier"  { "a " { $link word } ", " { $link method-spec } ", " { $link link } ", vocabulary specifier, or any other object whose class implements the " { $link "definition-protocol" } } }
    { "generalized boolean"   { "an object interpreted as a boolean; a value of " { $link f } " denotes false and anything else denotes true" } }
    { "generic word"          { "a word whose behavior depends can be specialized on the class of one of its inputs. See " { $link "generic" } } }
    { "method"                { "a specialized behavior of a generic word on a class. See " { $link "generic" } } }
    { "object"                { "any datum which can be identified" } }
    { "pathname string"       { "an OS-specific pathname which identifies a file" } }
    { "sequence" { "an object whose class implements the " { $link "sequence-protocol" } } }
    { "slot"                  { "a component of an object which can store a value" } }
    { "stack effect"          { "a pictorial representation of a word's inputs and outputs, for example " { $snippet "+ ( x y -- z )" } ". See " { $link "effects" } } }
    { "true value"            { "any object not equal to " { $link f } } }
    { "vocabulary" { "a named set of words. See " { $link "vocabularies" } } }
    { "vocabulary specifier"  { "a " { $link vocab } ", " { $link vocab-link } " or a string naming a vocabulary" } }
    { "word"                  { "the basic unit of code, analogous to a function or procedure in other programming languages. See " { $link "words" } } }
} ;

ARTICLE: "evaluator" "Evaluation semantics"
{ $link "quotations" } " are evaluated sequentially from beginning to end. When the end is reached, the quotation returns to its caller. As each object in the quotation is evaluated in turn, an action is taken based on its type:"
{ $list
    { "a " { $link symbol } " - pushed on the data stack. See " { $link "symbols" } }
    { "a " { $link compound } " - the associated definition is called. See " { $link "colon-definition" } }
    { "a" { $link primitive } " - a primitive in the Factor VM is called. See " { $link "primitives" } }
    { "an " { $link undefined } " -  an error is raised. See " { $link "deferred" } }
    { "a " { $link wrapper } " - the wrapped object is pushed on the data stack. Wrappers are used to push word objects directly on the stack when they would otherwise execute. See the " { $link POSTPONE: \ } " parsing word." }
    { "All other types of objects are pushed on the data stack." }
}
"If the last action performed is the execution of a word, the current quotation is not saved on the call stack; this is known as " { $snippet "tail-recursion" } " and allows iterative algorithms to execute without incurring unbounded call stack usage."
$nl
"There are various ways of implementing these evaluation semantics. See " { $link "compiler" } " and " { $link "meta-interpreter" } "." ;

ARTICLE: "dataflow" "Data and control flow"
{ $subsection "evaluator" }
{ $subsection "words" }
{ $subsection "effects" }
{ $subsection "shuffle-words" }
{ $subsection "booleans" }
{ $subsection "conditionals" }
{ $subsection "basic-combinators" }
{ $subsection "combinators" }
{ $subsection "continuations" }
{ $subsection "threads" } ;

ARTICLE: "objects" "Objects"
"An " { $emphasis "object" } " is any datum which may be identified. All values are objects in Factor. Each object carries type information, and types are checked at runtime; Factor is dynamically typed."
{ $subsection "equality" }
{ $subsection "classes" }
{ $subsection "tuples" }
{ $subsection "generic" }
{ $subsection "mirrors" } ;

USE: random

ARTICLE: "numbers" "Numbers"
{ $subsection "arithmetic" }
{ $subsection "math-constants" }
{ $subsection "math-functions" }
{ $subsection "number-strings" }
{ $subsection "random-numbers" }
"Number implementations:"
{ $subsection "integers" }
{ $subsection "rationals" }
{ $subsection "floats" }
{ $subsection "complex-numbers" }
"Advanced features:"
{ $subsection "math-vectors" }
{ $subsection "math-intervals" }
{ $subsection "math-bitfields" } ;

USE: io.buffers

ARTICLE: "collections" "Collections" 
{ $heading "Sequences" }
{ $subsection "sequences" }
"Sequence implementations:"
{ $subsection "arrays" }
{ $subsection "vectors" }
{ $subsection "bit-arrays" }
{ $subsection "byte-arrays" }
{ $subsection "float-arrays" }
{ $subsection "strings" }
{ $subsection "sbufs" }
{ $subsection "quotations" }
{ $heading "Associative mappings" }
{ $subsection "assocs" }
{ $subsection "namespaces" }
"Implementations:"
{ $subsection "hashtables" }
{ $subsection "alists" }
{ $heading "Other collections" }
{ $subsection "dlists" }
{ $subsection "heaps" }
{ $subsection "graphs" }
{ $subsection "buffers" } ;

USING: io.sockets io.launcher io.mmap ;

ARTICLE: "io" "Input and output" 
{ $subsection "streams" }
"Stream implementations:"
{ $subsection "file-streams" }
{ $subsection "io.streams.duplex" }
{ $subsection "io.streams.lines" }
{ $subsection "io.streams.plain" }
{ $subsection "io.streams.string" }
"Advanced features:"
{ $subsection "stream-binary" }
{ $subsection "styles" }
{ $subsection "network-streams" }
{ $subsection "io.launcher" }
{ $subsection "io.mmap" } ;

ARTICLE: "tools" "Developer tools"
{ $subsection "tools.annotations" }
{ $subsection "tools.crossref" }
{ $subsection "editor" }
{ $subsection "inspector" }
{ $subsection "meta-interpreter" }
{ $subsection "tools.memory" }
{ $subsection "profiling" }
{ $subsection "tools.test" }
{ $subsection "timing" }
{ $subsection "tools.deploy" } ;

ARTICLE: "article-index" "Article index"
{ $index [ articles get keys ] } ;

ARTICLE: "primitive-index" "Primitive index"
{ $index [ all-words [ primitive? ] subset ] } ;

ARTICLE: "error-index" "Error index"
{ $index [ all-errors ] } ;

ARTICLE: "type-index" "Type index"
{ $index [ builtins get [ ] subset ] } ;

ARTICLE: "class-index" "Class index"
{ $index [ classes ] } ;

ARTICLE: "program-org" "Program organization"
{ $subsection "definitions" }
{ $subsection "vocabularies" }
{ $subsection "parser" }
{ $subsection "vocabs.loader" } ;

USE: help.cookbook

ARTICLE: "handbook" "Factor documentation"
{ $heading "Starting points" }
{ $subsection "cookbook" }
{ $subsection "vocab-index" }
{ $subsection "changes" }
{ $subsection "cli" }
{ $heading "Language reference" }
{ $subsection "conventions" }
{ $subsection "syntax" }
{ $subsection "dataflow" }
{ $subsection "objects" }
{ $subsection "program-org" }
{ $heading "Library reference" }
{ $subsection "numbers" }
{ $subsection "collections" }
{ $subsection "io" }
{ $subsection "os" }
{ $subsection "alien" }
{ $heading "Environment reference" }
{ $subsection "prettyprint" }
{ $subsection "tools" }
{ $subsection "help" }
{ $subsection "inference" }
{ $subsection "compiler" }
{ $heading "User interface" }
{ $about "ui" }
{ $about "ui.tools" }
{ $heading "Index" }
{ $subsection "primitive-index" }
{ $subsection "error-index" }
{ $subsection "type-index" }
{ $subsection "class-index" } ;


USING: io.files io.sockets float-arrays inference ;

ARTICLE: "changes" "Changes in the latest release"
{ $heading "Factor 0.90" }
{ $subheading "Core" }
{ $list
    { "New module system; see " { $link "vocabs.loader" } ". (Eduardo Cavazos)" }
    { "Tuple constructors are defined differently now; see " { $link "tuple-constructors" } "." }
    { "Mixin classes implemented; these are essentially extensible unions. See " { $link "mixins" } "."  }
    { "New " { $link float-array } " data type implements a space-efficient sequence of floats." }
    { "Moved " { $link <file-appender> } ", " { $link delete-file } ", " { $link make-directory } ", " { $link delete-directory } " words from " { $snippet "libs/io" } " into the core, and fixed them to work on more platforms." }
    { "New " { $link host-name } " word." }
    { "The " { $link directory } " word now outputs an array of pairs, with the second element of each pair indicating if that entry is a subdirectory. This saves an unnecessary " { $link stat } " call when traversing directory hierarchies, which speeds things up." }
    { "IPv6 is now supported, along with Unix domain sockets (the latter on Unix systems only). The stack effects of " { $link <client> } " and " { $link <server> } " have changed, since they now take generic address specifiers; see " { $link "network-streams" } "." }
    { "The stage 2 bootstrap process is more flexible, and various subsystems such as help, tools and the UI can be omitted by supplying command line switches; see " { $link "bootstrap-cli-args" } "." }
    { "The " { $snippet "-shell" } " command line switch has been replaced by a " { $snippet "-run" } " command line switch; see " { $link "standard-cli-args" } "." }
    { "Variable usage inference has been removed; the " { $link infer } " word no longer reports this information." }

}
{ $subheading "Tools" }
{ $list
    { "Stand-alone image deployment; see " { $link "tools.deploy" } "." }
    { "Stand-alone application bundle deployment on Mac OS X; see " { $vocab-link "tools.deploy.app" } "." }
    { "New vocabulary browser tool in the UI." }
    { "New profiler tool in the UI." }
}
{ $subheading "Extras" }
"Most existing libraries were improved when ported to the new module system; the most notable changes include:"
{ $list
    { { $vocab-link "asn1" } ": ASN1 parser and writer. (Elie Chaftari)" }
    { { $vocab-link "benchmarks" } ": new set of benchmarks." }
    { { $vocab-link "cfdg" } ": Context-free design grammar implementation; see " { $url "http://www.chriscoyne.com/cfdg/" } ". (Eduardo Cavazos)" }
    { { $vocab-link "cryptlib" } ": Cryptlib library binding. (Elie Chaftari)" }
    { { $vocab-link "cryptlib.streams" } ": Streams which perform SSL encryption and decryption. (Matthew Willis)" }
    { { $vocab-link "hints" } ": Give type specialization hints to the compiler." }
    { { $vocab-link "inverse" } ": Invertible computation and concatenative pattern matching. (Daniel Ehrenberg)" }
    { { $vocab-link "ldap" } ": OpenLDAP library binding. (Elie Chaftari)" }
    { { $vocab-link "locals" } ": Efficient lexically scoped locals, closures, and local words." }
    { { $vocab-link "mortar" } ": Experimental message-passing object system. (Eduardo Cavazos)" }
    { { $vocab-link "openssl" } ": OpenSSL library binding. (Elie Chaftari)" }
    { { $vocab-link "pack" } ": Utility for reading and writing binary data. (Doug Coleman)" }
    { { $vocab-link "pdf" } ": Haru PDF library binding. (Elie Chaftari)" }
    { { $vocab-link "qualified" } ": Refer to words from another vocabulary without adding the entire vocabulary to the search path. (Daniel Ehrenberg)" }
    { { $vocab-link "roman" } ": Reading and writing Roman numerals. (Doug Coleman)" }
    { { $vocab-link "scite" } ": SciTE editor integration. (Clemens Hofreither)" }
    { { $vocab-link "smtp" } ": SMTP client with support for CRAM-MD5 authentication. (Elie Chaftari, Dirk Vleugels)" }
    { { $vocab-link "tuple-arrays" } ": Space-efficient packed tuple arrays. (Daniel Ehrenberg)" }
    { { $vocab-link "unicode" } ": major new functionality added. (Daniel Ehrenberg)" }
}
{ $subheading "Performance" }
{ $list
    { "The " { $link curry } " word now runs in constant time, and curried quotations can be called from compiled code; this allows for abstractions and idioms which were previously impractical due to performance issues. In particular, words such as " { $snippet "each-with" } " and " { $snippet "map-with" } " are gone; " { $snippet "each-with" } " can now be written as " { $snippet "curry* each" } ", and similarly for other " { $snippet "-with" } " combinators." }
    "Improved generational promotion strategy in garbage collector reduces the amount of junk which makes its way into tenured space, which in turn reduces the frequency of full garbage collections."
    "Faster generic word dispatch and union membership testing."
    { "Alien memory accessors (" { $link "reading-writing-memory" } ") are compiled as intrinsics where possible, which improves performance in code which iteroperates with C libraries." }
}
{ $subheading "Platforms" }
{ $list
    "Networking support added for Windows CE. (Doug Coleman)"
    "UDP/IP networking support added for all Windows platforms. (Doug Coleman)"
    "Solaris/x86 fixes. (Samuel Tardieu)"
    "Linux/AMD64 port works again."
} ;
