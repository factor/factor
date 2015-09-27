USING: macros kernel words quotations io sequences combinators
continuations ;
IN: calendar.format.macros

MACRO: formatted ( spec -- quot )
    [
        {
            { [ dup word? ] [ 1quotation ] }
            { [ dup quotation? ] [ ] }
            [ [ nip write ] curry [ ] like ]
        } cond
    ] map [ cleave ] curry ;

MACRO: attempt-all-quots ( quots -- quot )
    dup length 1 = [ first ] [
        unclip swap
        [ nip attempt-all-quots ] curry
        [ recover ] 2curry
    ] if ;
