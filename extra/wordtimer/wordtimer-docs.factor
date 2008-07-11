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

HELP: profile-vocab
{ $values { "vocabspec" "string name of a vocab" }
          { "quot" "a quotation to run" } }
{ $description "Annotates the words in the vocab with timing code then runs the quotation. Finally resets the words and prints the timings information."
} ;

    
ARTICLE: "wordtimer" "Word Timer"
"The " { $vocab-link "wordtimer" } " vocabulary measures accumulated execution time for words. If you just want to profile the accumulated time taken by all words in a vocab you can use " { $vocab-link "profile-vocab" } ". If you need more fine grained control then do the following: First annotate individual words with the " { $link add-timer } " word or whole vocabularies with " { $link add-timers } ". Then reset the clock with " { $link reset-word-timer } " and execute your code. Finally you can view the timings with " { $link print-word-timings } ". If you have functions that are quick and called often you may want to " { $link correct-for-timing-overhead } ". To remove all the annotations in the vocab you can use " { $link reset-vocab } ". Alternatively if you just want to time the contents of a vocabulary you can use profile-vocab." ;
    
ABOUT: "wordtimer"
