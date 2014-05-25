USING: help.markup help.syntax math sequences ;
IN: sequences.extras

HELP: subseq*
{ $values
     { "from" integer } { "to" integer } { "seq" sequence } { "subseq" sequence } }
{ $description "Outputs a new sequence using positions relative to one or both ends of the sequence. Positive values describes offsets relative to the start of the sequence, negative values relative to the end. Values of " { $link f } " for " { $snippet "from" } " indicate the beginning of the sequence, while an " { $link f } " for " { $snippet "to" } " indicates the end of the sequence." }
{ $notes "Both " { $snippet "from" } " and " { $snippet "to" } " can be safely set to values outside the length of the sequence. Also, " { $snippet "from" } " can safely reference a smaller or greater index position than " { $snippet "to" } "." }
{ $examples
    "Using a negative relative index:"
    { $example "USING: prettyprint sequences.extras ; 2 -1 \"abcdefg\" subseq* ."
               "\"cdef\""
    }
    "Using optional indices:"
    { $example "USING: prettyprint sequences.extras ; f -4 \"abcdefg\" subseq* ."
               "\"abc\""
    }
    "Using larger-than-necessary indices:"
    { $example "USING: prettyprint sequences.extras ; 0 10 \"abcdefg\" subseq* ."
               "\"abcdefg\""
    }
    "Trimming from either end of the sequence."
    { $example "USING: prettyprint sequences.extras ; 1 -1 \"abcdefg\" subseq* ."
               "\"bcdef\""
    }
} ;
