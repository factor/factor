USING: tools.profiler.private tools.time help.markup help.syntax
quotations io strings words definitions generator ;
IN: tools.profiler

ARTICLE: "profiling" "Profiling code" 
"A simple call counting profiler is included. Both compiled and interpreted code can be profiled. There are a number of limitations when profiling compiled code:"
{ $list
    { "Calls to " { $link POSTPONE: inline } " words are not counted" }
    "Calls to primitives are not counted"
}
"The profiler must be enabled before use:"
{ $subsection enable-profiler }
"Since enabling the profiler reduces performance, it should be disabled after use:"
{ $subsection disable-profiler }
"While enabled, a combinator which counts all calls made by a quotation can be used:"
{ $subsection profile }
"After a quotation has been profiled, call counts can be presented in various ways:"
{ $subsection profile. }
{ $subsection vocab-profile. }
{ $subsection usage-profile. }
{ $subsection vocabs-profile. } ;

ABOUT: "profiling"

HELP: reset-counters
{ $description "Reset the call count of all words in the dictionary." }
{ $notes "This word is automatically called by the profiler when profiling begins." } ;

HELP: counters
{ $values { "words" "a sequence of words" } { "assoc" "an association list mapping words to integers" } }
{ $description "Outputs an association list of word call counts." } ;

HELP: counters.
{ $values { "assoc" "an association list mapping words to integers" } }
{ $description "Prints an association list of call counts to the " { $link stdio } " stream." } ;

HELP: enable-profiler
{ $description "Recompiles all words in the dictionary to include a stub which increments the call count during profiling. Once this is done, the " { $link profile } " combinator may be used." }
{ $notes "Performance is affected when profiling is enabled, so profiling should only be enabled when necessary." } ;

HELP: disable-profiler
{ $description "Recompiles all words in the dictionary to exclude a stub which increments the call count during profiling. This should be done when you no longer wish to use the " { $link profile } " combinator." } ;

HELP: check-profiler
{ $description "Throws an error if the profiler has not yet been enabled by a call to " { $link enable-profiler } "." } ;

HELP: profile
{ $values { "quot" quotation } }
{ $description "Calls the quotation while collecting word call counts, which can then be displayed using " { $link profile. } " or related words." }
{ $errors "Throws an error if the profiler has not been enabled by a prior call to " { $link enable-profiler } "." } ;

HELP: profile.
{ $description "Prints a table of call counts from the most recent invocation of " { $link profile } "." } ;

HELP: vocab-profile.
{ $values { "vocab" string } }
{ $description "Prints a table of call counts from the most recent invocation of " { $link profile } ", for words in the " { $snippet "vocab" } " vocabulary only." }
{ $examples { $code "\"math\" vocab-profile." } } ;

HELP: usage-profile.
{ $values { "word" word } }
{ $description "Prints a table of call counts from the most recent invocation of " { $link profile } ", for words which directly call " { $snippet "word" } " only." }
{ $notes "This word obtains the list of static usages with the " { $link usage } " word, and is not aware of dynamic call history. Consider the following scenario. A word " { $snippet "X" } " can execute word " { $snippet "Y" } " in a conditional branch, and " { $snippet "X" } " is executed many times during the profiling run, but this particular branch executing " { $snippet "Y" } " is never taken. However, some other word does execute " { $snippet "Y" } " multiple times. Then " { $snippet "\\ Y usage-profile." } " will list a number of calls to " { $snippet "X" } ", even though " { $snippet "Y" } " was never executed " { $emphasis "from" } " " { $snippet "X" } "." }
{ $examples { $code "\\ + usage-profile." } } ;

HELP: vocabs-profile.
{ $description "Print a table of cumilative call counts for each vocabulary. Vocabularies whose words were not called are supressed from the output." } ;

HELP: profiling ( ? -- )
{ $values { "?" "a boolean" } }
{ $description "Internal primitive to switch on call counting. This word should not be used; instead see " { $link enable-profiler } ", " { $link profile } " and " { $link disable-profiler } "." } ;

{ time profile } related-words

HELP: profiler-prologues
{ $var-description "If set, each word will be compiled with an extra prologue which checks if profiling is enabled, and if so, increments the word's call count. This variable is off by default. It should never be set directly; " { $link enable-profiler } " and " { $link disable-profiler } " should be used instead." } ;
