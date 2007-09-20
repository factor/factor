USING: help.markup help.syntax words debugger generator.fixup
generator.registers quotations kernel vectors arrays ;
IN: generator

ARTICLE: "generator" "Compiled code generator"
"Most of the words in the " { $vocab-link "generator" } " vocabulary are internal to the compiler and user code has no reason to call them."
$nl
"Debugging information can be enabled or disabled; these hooks are used by " { $link "profiling" } " and " { $link "tools.deploy" } ":"
{ $subsection profiler-prologues }
{ $subsection compiled-stack-traces }
"Assembler intrinsics can be defined for low-level optimization:"
{ $subsection define-intrinsic }
{ $subsection define-intrinsics }
{ $subsection define-if-intrinsic }
{ $subsection define-if-intrinsics }
"The main entry point into the code generator:"
{ $subsection generate }
"Primitive compiler interface exported by the Factor VM:"
{ $subsection add-compiled-block }
{ $subsection finalize-compile } ;

ABOUT: "generator"

HELP: compiled-xts
{ $var-description "During compilation, holds a hashtable mapping words to temporary uninterned words. The XT of each value points to the compiled code block of each key; at the end of compilation, the XT of each key is set to the XT of the value." } ;

HELP: compiling?
{ $values { "word" word } { "?" "a boolean" } }
{ $description "Tests if a word is going to be or already is compiled." } ;

HELP: finalize-compile ( xts -- )
{ $values { "xts" "an association list mapping words to uninterned words" } }
{ $description "Performs relocation, atomically changes the XT of each key to the XT of each value, and flushes the CPU instruction cache on architectures where this has to be done manually." } ;

HELP: add-compiled-block ( literals words rel labels code -- xt )
{ $values { "literals" vector } { "words" "a vector of words" } { "rel" "a vector of integers" } { "labels" "an array of integers" } { "code" "a vector of integers" } { "xt" "an uninterned word" } }
{ $description "Adds a new compiled block and outputs an uninterned word whose XT points at this block. This uninterned word can then be passed to " { $link finalize-compile } "." } ;

HELP: compiling-word
{ $var-description "The word currently being compiled, set by " { $link generate-1 } "." } ;

HELP: compiling-label
{ $var-description "The label currently being compiled, set by " { $link generate-1 } "." } ;

HELP: compiled-stack-traces
{ $var-description "If set to true, compiled code blocks will retain what word they were compiled from. This information is used by " { $link :c } " to display call stack traces after an error is thrown from compiled code. This variable is on by default; the deployment tool switches it off to save some space in the deployed image." } ;

HELP: literal-table
{ $var-description "Holds a vector of literal objects referenced from the currently compiling word. If " { $link compiled-stack-traces } " is on, " { $link init-generator } " ensures that the first entry is the word being compiled." } ;

HELP: init-generator
{ $values { "word" word } }
{ $description "Prepares to generate machine code for a word." } ;

HELP: generate-1
{ $values { "label" word } { "node" "a dataflow node" } { "quot" "a quotation with stack effect " { $snippet "( node -- )" } } }
{ $description "Generates machine code for " { $snippet "label" } " by applying the quotation to the dataflow node." } ;

HELP: generate-node
{ $values { "node" "a dataflow node" } { "next" "a dataflow node" } }
{ $contract "Generates machine code for a dataflow node, and outputs the next node to generate machine code for." }
{ $notes "This word can only be called from inside the quotation passed to " { $link generate-1 } "." } ;

HELP: generate-nodes
{ $values { "node" "a dataflow node" } } 
{ $description "Recursively generate machine code for a dataflow graph." }
{ $notes "This word can only be called from inside the quotation passed to " { $link generate-1 } "." } ;

HELP: profiler-prologue
{ $description "Compiles a prologue which increment's the currently compiling word's call count, if such prologues were enabled by setting " { $link profiler-prologues } " to a true value." } ;

HELP: generate
{ $values { "word" word } { "label" word } { "node" "a dataflow node" } }
{ $description "Generates machine code for " { $snippet "label" } " from " { $snippet "node" } ". The value of " { $snippet "word" } " is retained for debugging purposes; it is the word which will appear in a call stack trace if this compiled code block throws an error when run." } ;

HELP: word-dataflow
{ $values { "word" word } { "dataflow" "a dataflow graph" } }
{ $description "Outputs the dataflow graph of a word, taking specializers into account (see " { $link "specializers" } ")." } ;

HELP: define-intrinsics
{ $values { "word" word } { "intrinsics" "a sequence of " { $snippet "{ quot assoc }" } " pairs" } }
{ $description "Defines a set of assembly intrinsics for the word. When a call to the word is being compiled, each intrinsic is tested in turn; the first applicable one will be called to generate machine code. If no suitable intrinsic is found, a simple call to the word is compiled instead."
$nl
"See " { $link with-template } " for an explanation of the keys which may appear in " { $snippet "assoc" } "." } ;

HELP: define-intrinsic
{ $values { "word" word } { "quot" quotation } { "assoc" "an assoc" } }
{ $description "Defines an assembly intrinsic for the word. When a call to the word is being compiled, this intrinsic will be used if it is found to be applicable. If it is not applicable, a simple call to the word is compiled instead."
$nl
"See " { $link with-template } " for an explanation of the keys which may appear in " { $snippet "assoc" } "." } ;

HELP: if>boolean-intrinsic
{ $values { "quot" "a quotation with stack effect " { $snippet "( label -- )" } } }
{ $description "Generates code which pushes " { $link t } " or " { $link f } " on the data stack, depending on whether the quotation jumps to the label or not." } ;

HELP: define-if-intrinsics
{ $values { "word" word } { "intrinsics" "a sequence of " { $snippet "{ quot inputs }" } " pairs" } }
{ $description "Defines a set of conditional assembly intrinsics for the word, which must have a boolean value as its single output."
$nl
"The quotations must have stack effect " { $snippet "( label -- )" } "; they are required to branch to the label if the word evaluates to true."
$nl
"The " { $snippet "inputs" } " are in the same format as the " { $link +input+ } " key to " { $link with-template } "; a description can be found in the documentation for thatt word." }
{ $notes "Conditional intrinsics are used when the word is followed by a call to " { $link if } ". They allow for tighter code to be generated in certain situations; for example, if two integers are being compared and the result is immediately used to branch, the intermediate boolean does not need to be pushed at all." } ;

HELP: define-if-intrinsic
{ $values { "word" word } { "quot" "a quotation with stack effect " { $snippet "( label -- )" } } { "inputs" "a sequence of input register specifiers" } }
{ $description "Defines a conditional assembly intrinsic for the word, which must have a boolean value as its single output."
$nl
"See " { $link define-if-intrinsics } " for a description of the parameters." } ;
