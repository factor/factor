USING: help.markup help.syntax make math strings vectors ;
IN: tools.completion

ARTICLE: "tools.completion" "Fuzzy completion"
"Various developer tools make use of a general-purpose fuzzy completion algorithm."
$nl
"The main entry point:"
{ $subsections completions }
"The words used to implement the algorithm can be called as well, for finer control over fuzzy matching:"
{ $subsections
    fuzzy
    runs
    score
    complete
    rank-completions
} ;

ABOUT: "tools.completion"

HELP: fuzzy
{ $values { "full" string } { "short" string } { "indices" vector } }
{ $description "If " { $snippet "short" } " can be obtained from " { $snippet "full" } " by removing subsequences, then outputs the index of every character from " { $snippet "short" } " in " { $snippet "full" } ", otherwise outputs " { $link f } "." } ;

HELP: runs
{ $values { "seq" "a sequence of integers" } { "newseq" "a sequence of sequences of integers" } }
{ $description "Groups subsequences of consecutive integers." }
{ $examples
    { $example "USING: prettyprint sequences tools.completion ;" "{ 1 2 3 5 6 9 10 } runs [ { } like ] map ." "{ { 1 2 3 } { 5 6 } { 9 10 } }" }
} ;

HELP: score
{ $values { "full" string } { "fuzzy" "a sequence of sequences of integers" } { "n" integer } }
{ $description "Ranks " { $snippet "fuzzy" } " by how closely it approximates the sequence " { $snippet "{ { 0 ... n-1 } }" } " where " { $snippet "n" } " is the length of " { $snippet "full" } "." } ;

HELP: rank-completions
{ $values { "results" "an alist" } { "newresults" "an alist" } }
{ $description "Sorts " { $snippet "results" } " by the first element of each pair, and discards the low 33% of the results." } ;

HELP: complete
{ $values { "full" string } { "short" string } { "score" "a rational number between 0 and 1" } }
{ $description "Ranks how close " { $snippet "short" } " is to " { $snippet "full" } " by edit distance." } ;

HELP: completion
{ $values { "short" string } { "candidate" "a pair " { $snippet "{ obj full }" } } { "score" number } }
{ $description "Outputs a score for matching two elements indicating how close " { $snippet "short" } " is to " { $snippet "full" } " by edit distance" } ;

HELP: completion,
{ $values { "short" string } { "candidate" "a pair " { $snippet "{ obj full }" } } }
{ $description
    "Adds the result of " { $link completion }
    " to the end of the sequence being constructed by " { $link make }
    " if the score is positive."
} ;

HELP: completions
{ $values { "short" string } { "candidates" "a sequence of pairs of the shape " { $snippet "{ obj full }" } } { "seq" "a sequence of pairs of the shape " { $snippet "{ score obj }" } } }
{ $description "Calls " { $link completion } " to produce a sequence of " { $snippet "{ score obj }" } " pairs, then calls " { $link rank-completions } " to sort them and discard the low 33%." } ;
