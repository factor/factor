USING: arrays help.markup help.syntax math
sequences.private vectors strings kernel math.order layouts
quotations generic.single ;
IN: sequences.extras

HELP: trim-pos
{ $values
     { "n" "an integer" } { "m" "an integer" } { "seq" "sequence" } { "newseq" "sequence" } }
{ $description "Trims the sequence to positions relative to one or both ends of the sequence. Positive values describes offsets relative to the start of the sequence, negative values relative to the end." }
{ $notes "n and m can be safely set to values outside the range of the sequence. n can safely reference a smaller or greater index position than m." }
{ $examples "The following two lines are equivalent."
    { $example 
               "2 -1 \"abcdefg\" trim-pos\n\"abcdefg\" 2 tail 1 head*"
               "\"cdef\"\n\"cdef\""
    }
            "\nSequences can be trimmed to a fixed length. Sequences smaller than that length are not trimmed."
    { $example 
               "0 10 \"abcdefg\" trim-pos"
               "\"abcdefg\""
    }    
            "\nEither n or m values can denote the beginning of the subsequence."
    { $example 
               "-3 1 \"abcdefg\" trim-pos"
               "\"bcd\""
    }
            "\nPositions 1 -1 trim one position from either end of the sequence."
    { $example 
               "1 -1 \"abcdefg\" trim-pos"
               "\"bcdef\""
    }
            "\nPositions 0 0 trims no element of the sequence."    
    { $example 
               "0 0 \"abcdefg\" trim-pos"
               "\"abcdefg\""
    }
    
} ;