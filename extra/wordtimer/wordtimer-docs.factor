USING: help.syntax help.markup kernel prettyprint sequences
quotations words strings ;
IN: wordtimer

HELP: reset-word-timer
{ $description "resets the global wordtimes datastructure. Must be called before calling any word-timer annotated code"
} ;

HELP: add-timer
{ $values { "word" word } }
{ $description "annotates the word with timing code which stores timing information globally. You can then view the info with print-word-timings"
} ;

HELP: add-timers
{ $values { "vocab" string } }
{ $description "annotates all the words in the vocab with timer code. After profiling you can remove the annotations with reset-vocab"
} ;


HELP: reset-vocab
{ $values { "vocab" string } }
{ $description "removes the annotations from all the words in the vocab"
} ;

HELP: print-word-timings
{ $description "Displays the timing information for each word-timer annotated word. Columns are: total time taken in microseconds, number of invocations, wordname"
} ;

HELP: correct-for-timing-overhead
{ $description "attempts to correct the timings to take into account the overhead of the timing function. This is pretty error-prone but can be handy when you're timing words that only take a handful of milliseconds but are called a lot" } ;

HELP: profile-vocab
{ $values { "vocab" string }
          { "quot" "a quotation to run" } }
{ $description "Annotates the words in the vocab with timing code then runs the quotation. Finally resets the words and prints the timings information."
} ;

HELP: wordtimer-call
{ $values { "quot" quotation } }
{ $description "Resets the wordtimer hash and runs the quotation. After the quotation has run it prints out the timed words"
} ;


ARTICLE: "wordtimer" "Word Timer"
"The " { $vocab-link "wordtimer" } " vocabulary measures accumulated execution time for words. If you just want to profile the accumulated time taken by all words in a vocab you can use " { $link profile-vocab } ". If you need more fine grained control then do the following: First annotate individual words with the " { $link add-timer } " word or whole vocabularies with " { $link add-timers } ". Then use " { $link wordtimer-call } " to invoke a quotation and print out the timings." ;

ABOUT: "wordtimer"
