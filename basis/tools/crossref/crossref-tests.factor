USING: assocs deques dlists hash-sets hash-sets.identity
hash-sets.sequences linked-assocs lists persistent.hashtables
persistent.vectors sets trees trees.avl trees.splay vlists arrays quotations vectors hashtables.identity
hashtables.numbers hashtables.sequences fry math kernel sequences io.files io.pathnames
tools.crossref tools.crossref.private tools.test parser
namespaces source-files generic definitions words accessors
compiler.units classes ;
IN: tools.crossref.tests

: fry-target ( x -- y ) 1 + ;
: fry-user ( x -- quot ) '[ _ fry-target ] ;
: nested-fry-user ( x -- quot ) '[ _ '[ _ fry-target ] ] ;

{ t } [ \ fry-target \ fry-user uses member? ] unit-test
{ t } [ \ fry-user \ fry-target usage member? ] unit-test
{ t } [ \ fry-target \ nested-fry-user uses member? ] unit-test
{ t } [ \ nested-fry-user \ fry-target usage member? ] unit-test

! Forgetting the enclosing definition also removes its fried references.
{ } [ [ \ fry-user forget ] with-compilation-unit ] unit-test
{ f } [
    \ fry-target usage [ word? ] filter [ name>> "fry-user" = ] any?
] unit-test

GENERIC: predicate-test ( a -- b )

M: class predicate-test ;

M: generic predicate-test ;

{ f } [ \ + irrelevant? ] unit-test
{ t } [ \ predicate-test "engines" word-prop first irrelevant? ] unit-test

GENERIC: foo ( a b -- c )

M: integer foo + ;

"vocab:tools/crossref/test/foo.factor" run-file

{ t } [ integer \ foo lookup-method \ + usage member? ] unit-test
{ t } [ \ foo usage [ pathname? ] any? ] unit-test

! Issues with forget
GENERIC: generic-forget-test-1 ( a b -- c )

M: integer generic-forget-test-1 / ;

{ t } [
    \ / usage [ word? ] filter
    [ name>> "integer=>generic-forget-test-1" = ] any?
] unit-test

{ } [
    [ \ generic-forget-test-1 forget ] with-compilation-unit
] unit-test

{ f } [
    \ / usage [ word? ] filter
    [ name>> "integer=>generic-forget-test-1" = ] any?
] unit-test

GENERIC: generic-forget-test-2 ( a b -- c )

M: sequence generic-forget-test-2 = ;

{ t } [
    \ = usage [ word? ] filter
    [ name>> "sequence=>generic-forget-test-2" = ] any?
] unit-test

{ } [
    [ M\ sequence generic-forget-test-2 forget ] with-compilation-unit
] unit-test

{ f } [
    \ = usage [ word? ] filter
    [ name>> "sequence=>generic-forget-test-2" = ] any?
] unit-test

! #2832: quotation literals can contain vectors and uninterned words.
: literal-target ( -- ) ;
{ t } [ \ literal-target [ V{ [ literal-target ] } ] uses member? ] unit-test

{ t } [
    [ gensym dup [ literal-target ] define ] with-compilation-unit
    1quotation uses \ literal-target swap member?
] unit-test

! Self-referential vectors must not make the traversal loop forever.
{ t } [
    V{ } clone dup dup push
    [ literal-target ] over push
    1quotation uses \ literal-target swap member?
] unit-test

{ t } [ \ literal-target [ IH{ { 0 [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ NH{ { 0 [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ SH{ { { 0 } [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ IH{ { [ literal-target ] 0 } } ] uses member? ] unit-test

! #2832: other literal collections must also retain their word references.
{ t } [ \ literal-target [ L{ [ literal-target ] } ] uses member? ] unit-test
{ t } [ \ literal-target [ VL{ [ literal-target ] } ] uses member? ] unit-test
{ t } [ \ literal-target [ VA{ { 0 [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ PH{ { 0 [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ PV{ [ literal-target ] } ] uses member? ] unit-test
{ t } [ \ literal-target [ LH{ { 0 [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ DL{ [ literal-target ] } ] uses member? ] unit-test
{ t } [ \ literal-target [ HS{ [ literal-target ] } ] uses member? ] unit-test
{ t } [ \ literal-target [ IHS{ [ literal-target ] } ] uses member? ] unit-test
{ t } [ \ literal-target [ SHS{ [ literal-target ] } ] uses member? ] unit-test
{ t } [ \ literal-target [ AVL{ { 0 [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ TREE{ { 0 [ literal-target ] } } ] uses member? ] unit-test
{ t } [ \ literal-target [ SPLAY{ { 0 [ literal-target ] } } ] uses member? ] unit-test

{ t } [
    IH{ } clone dup "self" pick set-at
    [ literal-target ] "ref" pick set-at
    1quotation uses \ literal-target swap member?
] unit-test
{ t } [
    IHS{ } clone dup dup adjoin
    [ literal-target ] over adjoin
    1quotation uses \ literal-target swap member?
] unit-test
{ t } [
    <dlist> dup dup push-back
    [ literal-target ] over push-back
    1quotation uses \ literal-target swap member?
] unit-test

! Do not expand arbitrary virtual sequences while indexing literal objects.
TUPLE: nonliteral-sequence ;
INSTANCE: nonliteral-sequence sequence
M: nonliteral-sequence length drop 1 ;
M: nonliteral-sequence nth 2drop "Unexpected virtual sequence traversal" throw ;
{ t } [ [ T{ nonliteral-sequence } ] uses empty? ] unit-test
