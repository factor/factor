USING: help.syntax help.markup sequences ;
IN: lcs

HELP: levenshtein
{ $values { "old" sequence } { "new" sequence } { "n" "the Levenshtein distance" } }
{ $description "Calculates the Levenshtein distance between old and new, that is, the minimal number of changes from the old sequence to the new one, in terms of deleting, inserting and replacing characters." } ;

HELP: lcs
{ $values { "seq1" sequence } { "seq2" sequence } { "lcs" "a longest common subsequence" } }
{ $description "Given two sequences, calculates a longest common subsequence between them. Note two things: this is only one of the many possible LCSs, and the LCS may not be contiguous." } ;

HELP: lcs-diff
{ $values { "old" sequence } { "new" sequence } { "diff" "an edit script" } }
{ $description "Given two sequences, find a minimal edit script from the old to the new. There may be more than one minimal edit script, and this chooses one arbitrarily. This script is in the form of an array of the tuples of the classes " { $link retain } ", " { $link delete } " and " { $link insert } " which have their information stored in the 'item' slot." } ;

HELP: retain
{ $class-description "Represents an action in an edit script where an item is kept, going from the initial sequence to the final sequence. This has one slot, called item, containing the thing which is retained" } ;

HELP: delete
{ $class-description "Represents an action in an edit script where an item is deleted, going from the initial sequence to the final sequence. This has one slot, called item, containing the thing which is deleted" } ;

HELP: insert
{ $class-description "Represents an action in an edit script where an item is added, going from the initial sequence to the final sequence. This has one slot, called item, containing the thing which is inserted" } ;

ARTICLE: "lcs" "LCS, diffing and distance"
"This vocabulary provides words for three apparently unrelated but in fact very similar problems: finding a longest common subsequence between two sequences, getting a minimal edit script (diff) between two sequences, and calculating the Levenshtein distance between two sequences. The implementations of these algorithms are very closely related, and all running times are O(nm), where n and m are the lengths of the input sequences."
{ $subsections
    lcs
    lcs-diff
    levenshtein
}
"The " { $link lcs-diff } " word returns a sequence of tuples of the following classes. They all hold their contents in the 'item' slot."
{ $subsections
    insert
    delete
    retain
} ;

ABOUT: "lcs"
