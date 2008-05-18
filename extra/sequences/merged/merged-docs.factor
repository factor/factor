USING: help.markup help.syntax sequences ;
IN: sequences.merged

ARTICLE: "sequences-merge" "Merging sequences"
"When multiple sequences are merged into one sequence, the new sequence takes an element from each input sequence in turn. For example, if we merge " { $code "{ 1 2 3 }" } "and" { $code "{ \"a\" \"b\" \"c\" }" } "we get:" { $code "{ 1 \"a\" 2 \"b\" 3 \"c\" }" } "."
{ $subsection merge }
{ $subsection 2merge }
{ $subsection 3merge }
{ $subsection <merged> }
{ $subsection <2merged> }
{ $subsection <3merged> } ;

ABOUT: "sequences-merge"

HELP: merged
{ $class-description "A virtual sequence which presents a merged view of its underlying elements. New instances are created by calling one of " { $link <merged> } ", " { $link <2merged> } ", or " { $link <3merged> } "." }
{ $see-also merge } ;

HELP: <merged> ( seqs -- merged )
{ $values { "seqs" "a sequence of sequences to merge" } { "merged" "a virtual sequence" } }
{ $description "Creates an instance of the " { $link merged } " virtual sequence." }
{ $see-also <2merged> <3merged> merge } ;

HELP: <2merged> ( seq1 seq2 -- merged )
{ $values { "seq1" sequence } { "seq2" sequence } { "merged" "a virtual sequence" } }
{ $description "Creates an instance of the " { $link merged } " virtual sequence which merges the two input sequences." }
{ $see-also <merged> <3merged> 2merge } ;

HELP: <3merged> ( seq1 seq2 seq3 -- merged )
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "merged" "a virtual sequence" } }
{ $description "Creates an instance of the " { $link merged } " virtual sequence which merges the three input sequences." }
{ $see-also <merged> <2merged> 3merge } ;

HELP: merge ( seqs -- seq )
{ $values { "seqs" "a sequence of sequences to merge" } { "seq" "a new sequence" } }
{ $description "Outputs a new sequence which merges the elements of each sequence in " { $snippet "seqs" } "." }
{ $examples
    { $example "USING: prettyprint sequences.merged ;" "{ { 1 2 } { 3 4 } { 5 6 } } merge ." "{ 1 3 5 2 4 6 }" }
    { $example "USING: prettyprint sequences.merged ;" "{ \"abc\" \"def\" } merge ." "\"adbecf\"" }
}
{ $see-also 2merge 3merge <merged> } ;

HELP: 2merge ( seq1 seq2 -- seq )
{ $values { "seq1" sequence } { "seq2" sequence } { "seq" "a new sequence" } }
{ $description "Creates a new sequence of the same type as " { $snippet "seq1" } " which merges the elements of " { $snippet "seq1" } " and " { $snippet "seq2" } }
{ $see-also merge 3merge <2merged> } ;

HELP: 3merge ( seq1 seq2 seq3 -- seq )
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "seq" "a new sequence" } }
{ $description "Creates a new sequence of the same type as " { $snippet "seq1" } " which merges the elements of all three sequences" }
{ $see-also merge 2merge <3merged> } ;
