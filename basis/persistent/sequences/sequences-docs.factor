IN: persistent.sequences
USING: help.markup help.syntax math sequences kernel ;

HELP: new-nth
{ $values { "val" object } { "i" integer } { "seq" sequence } { "seq'" sequence } }
{ $contract "Persistent analogue of " { $link set-nth } ". Outputs a new sequence with the " { $snippet "i" } "th element replaced by " { $snippet "val" } "." }
{ $notes "This operation runs in " { $snippet "O(log_32 n)" } " time on " { $vocab-link "persistent.vectors" } " and " { $snippet "O(n)" } " time on all other sequences." } ;

HELP: ppush
{ $values { "val" object } { "seq" sequence } { "seq'" sequence } }
{ $contract "Persistent analogue of " { $link push } ". Outputs a new sequence with all elements of " { $snippet "seq" } " together with " { $snippet "val" } " added at the end." }
{ $notes "This operation runs in amortized " { $snippet "O(1)" } " time on " { $vocab-link "persistent.vectors" } " and " { $snippet "O(n)" } " time on all other sequences." } ;

HELP: ppop
{ $values { "seq" sequence } { "seq'" sequence } }
{ $contract "Persistent analogue of " { $link pop* } ". Outputs a new sequence with all elements of " { $snippet "seq" } " except for the final element." }
{ $notes "This operation runs in amortized " { $snippet "O(1)" } " time on " { $vocab-link "persistent.vectors" } " and " { $snippet "O(n)" } " time on all other sequences." } ;
