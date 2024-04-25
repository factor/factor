
USING: help.markup help.syntax memoize.syntax ;

HELP: MEMO[
{ $syntax "MEMO[ elements... ]" }
{ $description "Defines the given literal quotation as one which memoizes its outputs given a particular input." } ;

HELP: IDENTITY-MEMO[
{ $syntax "IDENTITY-MEMO[ elements... ]" }
{ $description "Defines the given literal quotation as one which memoizes its outputs given a particular input which is identical to another input." } ;
