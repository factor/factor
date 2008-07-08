USING: help.syntax help.markup kernel prettyprint sequences ;
IN: wordtimer

HELP: reset-word-timer
{ $description "resets the global wordtimes datastructure. Must be called before calling any word-timer annotated code"
} ;

HELP: add-timer
{ $values { "word" "a word" } } 
{ $description "annotates the word with timing code which stores timing information globally. You can then view the info with print-word-timings"
} ;

HELP: add-timers
{ $values { "vocab" "a string" } } 
{ $description "annotates all the words in the vocab with timer code. After profiling you can remove the annotations with reset-vocab"
} ;


HELP: reset-vocab
{ $values { "vocab" "a string" } } 
{ $description "removes the annotations from all the words in the vocab"
} ;

HELP: print-word-timings
{ $description "Displays the timing information for each word-timer annotated word. Columns are: total time taken in microseconds, number of invocations, wordname"
} ;

HELP: correct-for-timing-overhead
{ $description "attempts to correct the timings to take into account the overhead of the timing function. This is pretty error-prone but can be handy when you're timing words that only take a handful of milliseconds but are called a lot" } ;
    
ARTICLE: "wordtimer" "Word Timer"
"The " { $vocab-link "wordtimer" } " vocabulary measures accumulated execution time for words. You first annotate individual words with the " { $link add-timer } " word or whole vocabularies with " { $link add-timers } ". Then you reset the clock with " { $link reset-word-timer } " and execute your code. Finally you can view the timings with " { $link print-word-timings } ". If you have functions that are quick and called often you may want to " { $link correct-for-timing-overhead } ". To remove all the annotations in the vocab you can use " { $link reset-vocab } "." ;
    
ABOUT: "wordtimer"
