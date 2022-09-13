USING: combinators.smart kernel ;
IN: sequences

: special-produce ( initial pred: ( a -- ? ) body: ( b -- a ) -- seq )
    [ [ preserving ] curry ] dip [ dup ] compose produce nip ; inline
