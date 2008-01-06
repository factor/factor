USING: kernel math sequences vectors classes combinators
generic.standard arrays words combinators.lib assocs parser ;
IN: multi-methods

: maximal-element ( seq quot -- n elt )
    dupd [
        swapd [ call 0 < ] 2curry subset empty?
    ] 2curry find [ "Topological sort failed" throw ] unless* ;
    inline

: topological-sort ( seq quot -- newseq )
    >r >vector [ dup empty? not ] r>
    [ dupd maximal-element >r over delete-nth r> ] curry
    [ ] unfold nip ; inline

: classes< ( seq1 seq2 -- -1/0/1 )
    [
        {
            { [ 2dup eq? ] [ 0 ] }
            { [ 2dup class< ] [ -1 ] }
            { [ 2dup swap class< ] [ 1 ] }
            { [ t ] [ 0 ] }
        } cond 2nip
    ] 2map [ zero? not ] find nip 0 or ;

: multi-predicate ( classes -- quot )
    dup length <reversed> [
        >r "predicate" word-prop r>
        (picker) swap append
    ] 2map [ && ] curry ;

: multi-dispatch-quot ( methods -- quot )
    [ >r multi-predicate r> ] assoc-map
    [ "No method" throw ] swap reverse alist>quot ;

: sorted-methods ( word -- methods )
    "multi-methods" word-prop >alist
    [ [ first ] 2apply classes< ] topological-sort ;

: make-generic ( word -- )
    dup sorted-methods multi-dispatch-quot define ;

: GENERIC:
    CREATE
    dup H{ } clone "multi-methods" set-word-prop
    make-generic ; parsing

: add-method ( quot classes word -- )
    [ "multi-methods" word-prop set-at ] keep make-generic ;

: METHOD:
    parse-definition unclip swap unclip swap spin
    add-method ; parsing
