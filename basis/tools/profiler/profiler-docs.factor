USING: tools.profiler.private tools.time help.markup help.syntax
quotations io strings words definitions ;
IN: tools.profiler

ARTICLE: "profiler-limitations" "Profiler limitations"
"Certain optimizations performed by the compiler can inhibit accurate call counting:"
{ $list
    "Calls to open-coded intrinsics are not counted. Certain words are open-coded as inline machine code, and in some cases optimized out altogether; this includes stack shuffling operations, conditionals, and many object allocation operations."
    { "Calls to " { $link POSTPONE: inline } " words are not counted." }
    { "Calls to methods which were inlined as a result of type inference are not counted." }
    "Tail-recursive loops will only count the initial invocation of the word, not every tail call."
} ;

ARTICLE: "profiling" "Profiling code" 
"The " { $vocab-link "tools.profiler" } " vocabulary implements a simple call counting profiler."
$nl
"Quotations can be passed to a combinator which calls them with the profiler enabled:"
{ $subsection profile }
"After a quotation has been profiled, call counts can be presented in various ways:"
{ $subsection profile. }
{ $subsection vocab-profile. }
{ $subsection usage-profile. }
{ $subsection vocabs-profile. }
{ $subsection method-profile. }
{ $subsection "profiler-limitations" }
{ $see-also "ui.tools.profiler" } ;

ABOUT: "profiling"

HELP: counters
{ $values { "words" "a sequence of words" } { "alist" "an association list mapping words to integers" } }
{ $description "Outputs an association list of word call counts." } ;

HELP: counters.
{ $values { "assoc" "an association list mapping words to integers" } }
{ $description "Prints an association list of call counts to " { $link output-stream } "." } ;

HELP: profile
{ $values { "quot" quotation } }
{ $description "Calls the quotation while collecting word call counts, which can then be displayed using " { $link profile. } " or related words." } ;

HELP: profile.
{ $description "Prints a table of call counts from the most recent invocation of " { $link profile } "." } ;

HELP: vocab-profile.
{ $values { "vocab" string } }
{ $description "Prints a table of call counts from the most recent invocation of " { $link profile } ", for words in the " { $snippet "vocab" } " vocabulary only." }
{ $examples { $code "\"math\" vocab-profile." } } ;

HELP: usage-profile.
{ $values { "word" word } }
{ $description "Prints a table of call counts from the most recent invocation of " { $link profile } ", for words which directly call " { $snippet "word" } " only." }
{ $notes "This word obtains the list of static usages with the " { $link smart-usage } " word, and is not aware of dynamic call history. Consider the following scenario. A word " { $snippet "X" } " can execute word " { $snippet "Y" } " in a conditional branch, and " { $snippet "X" } " is executed many times during the profiling run, but this particular branch executing " { $snippet "Y" } " is never taken. However, some other word does execute " { $snippet "Y" } " multiple times. Then " { $snippet "\\ Y usage-profile." } " will list a number of calls to " { $snippet "X" } ", even though " { $snippet "Y" } " was never executed " { $emphasis "from" } " " { $snippet "X" } "." }
{ $examples { $code "\\ + usage-profile." } } ;

HELP: vocabs-profile.
{ $description "Print a table of cumilative call counts for each vocabulary. Vocabularies whose words were not called are supressed from the output." } ;

HELP: method-profile.
{ $description "Print a table of cumilative call counts for each method. Methods which were not called are supressed from the output." } ;

HELP: profiling ( ? -- )
{ $values { "?" "a boolean" } }
{ $description "Internal primitive to switch on call counting. This word should not be used; instead use " { $link profile } "." } ;

{ time profile } related-words
