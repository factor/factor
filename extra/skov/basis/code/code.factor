! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators
combinators.short-circuit combinators.smart compiler.units
effects fry hashtables.private kernel listener locals math
math.order math.parser namespaces prettyprint sequences sorting
sequences.deep sequences.extras sets splitting strings
ui.gadgets vectors vocabs.parser definitions ;
QUALIFIED: vocabs
QUALIFIED: words
IN: code

TUPLE: element < identity-tuple  name parent contents default-name target ;

TUPLE: vocab < element ;
TUPLE: word < element  defined? result ;

TUPLE: node < element  quoted? ;
TUPLE: introduce < node  id ;
TUPLE: return < node ;
TUPLE: call < node  completion ;
TUPLE: text < node ;
TUPLE: setter < node  id ;
TUPLE: getter < node  id ;

TUPLE: result < element ;

UNION: input/output  introduce return ;
UNION: link  setter getter ;
UNION: source  introduce text getter ;
UNION: sink  return setter ;

PREDICATE: quoted-node < node  quoted?>> ;

SYMBOL: skov-root
vocab new "●" >>name skov-root set-global

SYMBOL: left
SYMBOL: right

: arity ( node -- n )
    ! returns the number of children of a node
    contents>> length ;

: walk ( node -- seq )
    [ contents>> [ walk ] map ] [ ] bi 2array ;

: sort-tree ( word -- seq )
    contents>> [ walk ] map flatten ;

: vocabs ( elt -- seq )  contents>> [ vocab? ] filter ;
: words ( elt -- seq )  contents>> [ word? ] filter ;
: calls ( elt -- seq )  sort-tree [ call? ] filter ;
: introduces ( elt -- seq )  sort-tree [ introduce? ] filter ;
: returns ( elt -- seq )  contents>> [ return? ] filter ;
: links ( elt -- seq )  sort-tree [ link? ] filter ;

: own-introduces ( elt -- seq )
    ! returns all "introduce" nodes in the child tree but ignores quoted nodes
    contents>> [ [ introduce? ] filter ]
    [ [ quoted?>> ] reject [ own-introduces ] map-concat ] bi
    append ;

:: add-element ( elt child-elt -- elt )
    ! sets an existing element as the child of another existing element
    child-elt elt >>parent elt [ ?push ] change-contents ;

: add-from-class ( elt child-class -- elt )
    ! sets a new element of a certain class as the child of an existing element
    new add-element ;

: add-with-name ( elt child-name child-class -- elt )
    ! sets a new element of a certain class and with a certain name
    ! as the child of an existing element
    new swap >>name add-element ;

: ?forget ( elt -- elt )
    ! removes the corresponding Factor vocabulary or word
    dup target>> [ [ forget ] with-compilation-unit ] when* ;

:: remove-element ( elt -- parent )
    ! removes a node from its parent
    elt ?forget parent>> [ elt swap remove-eq ] change-contents ;

: replace* ( seq old rep -- seq )
    ! replaces an element with another element in a sequence
    [ 1array ] bi@ replace ;

:: replace-element ( old rep -- rep )
    ! replaces an element with another element
    old parent>> [ old rep old parent>> >>parent replace* ] change-contents drop rep ;

: replace-parent ( node -- node )
    ! replaces the parent of the node with the node
    dup parent>> [ node? ] [ swap replace-element ] smart-when* ;

: insert-new-parent ( old -- new )
    ! replaces an element with a new element of a certain class
    ! and sets the old element as a child of the new one
    dup call new replace-element swap add-element ;

:: exchange-node-side ( node side -- node )
    ! exchanges a node and the node the left/right
    node parent>> [ vocab? ] [ [ [ class-of ] sort-with ] change-contents ] smart-when
    contents>> :> nodes
    node nodes index dup side left eq? -1 1 ? +
    nodes length 1 - min 0 max nodes exchange node ;

: top-node? ( node -- ? )
    ! tells if the node has no children
    contents>> empty? ;

: bottom-node? ( node -- ? )
    ! tells if the node has no parent
    parent>> node? not ;

: leftmost-node? ( node -- ? )
    ! tells if a node has no brother on the left
    dup parent>> contents>> index 0 = ;

: rightmost-node? ( node -- ? )
    ! tells if a node has no brother on the right
    dup parent>> contents>> [ index ] keep length 1 - = ;

: middle-node? ( node -- ? )
    ! tells if a node has a parent and has children
    [ top-node? ] [ bottom-node? ] bi or not ;

: parent-node ( node -- node )
    ! returns the parent of the node, or the same node if the parent is a "word"
    [ parent>> dup word? not and ] [ parent>> ] smart-when ;

: child-node ( node -- node )
    ! returns the first child of the node, or the same node if it has no children
    [ contents>> empty? ] [ contents>> first ] smart-unless ;

:: side-node ( node side -- node )
    ! returns the brother node on the left/right, 
    ! or the same node if there is nothing to the left/right
    node parent>> contents>> :> nodes
    node nodes index 1 side left eq? [ - ] [ + ] if nodes ?nth [ node ] unless* ;

:: change-nodes-above ( elt names -- )
    elt arity :> old-n
    names length :> n
    elt {
      { [ n old-n > ] [ n old-n - [ call add-from-class ] times drop ] }
!     { [ n old-n < ] [ contents>> n swap shorten ] }
      [ drop ]
    } cond
    names elt contents>> [ default-name<< ] 2each ;

:: change-node-type ( node class -- new-node )
    ! replaces a node by a node of a different type that has the same name and contents
    node class new node name>> >>name node quoted?>> >>quoted?
    node contents>> [ add-element ] each replace-element ;

: no-return? ( node -- ? )
    ! tells if the word that contains the node has no "return" child
    [ word? ] find-parent returns empty? ;

: ?change-node-type ( node class -- new-node )
    ! replaces a node by a node of a different type that has the same name and contents
    ! only if certain conditions are met
    2dup {
        { introduce [ top-node? ] }
        { text      [ top-node? ] }
        { getter    [ top-node? ] }
        { return    [ [ bottom-node? ] [ no-return? ] bi and ] }
        { setter    [ bottom-node? ] }
        [ drop drop t ]
    } case [ change-node-type ] [ drop ] if ;

: name-or-default ( elt -- str )
    ! returns the name of the element, or its default name, or its class
    { { [ dup name>> empty? not ] [ name>> ] }
      { [ dup default-name>> empty? not ] [ default-name>> ] }
      { [ dup introduce? ] [ drop "input" ] }
      { [ dup return? ] [ drop "output" ] }
      { [ dup call? ] [ drop "word" ] }
      { [ dup vocab? ] [ drop "vocabulary" ] }
      { [ dup getter? ] [ drop "get" ] }
      { [ dup setter? ] [ drop "set" ] }
      [ class-of unparse ] } cond >string ;

CONSTANT: special-words { "while" "until" "if" "times" "produce" }
GENERIC: factor-name ( elt -- str )

M: element factor-name
    name>> ;

M: call factor-name
    name>> dup special-words member? [ "special " prepend ] when ;

GENERIC: path ( elt -- str )

M: vocab path
    parents reverse rest [ factor-name ] map "." join [ "scratchpad" ] when-empty ;

M: word path
    parents reverse rest but-last [ factor-name ] map "." join [ "scratchpad" ] when-empty ;

M: call path
    target>> [ words:word? ] [ vocabulary>> ] [ drop f ] smart-if ;

M: node path
    drop f ;

: replace-quot ( seq -- seq )
    [ array? ] [ first [ "quot" swap subseq? not ] [ " quot" append ] smart-when ] smart-when ;

: convert-stack-effect ( stack-effect -- seq seq )
    ! converts a stack effect into two sequences of input and output names
    [ in>> ] [ out>> ] bi [ [ replace-quot ] map ] bi@ ;

: same-name-as-parent? ( call -- ? )
    ! tells if a call has the same name as its parent
    dup [ word? ] find-parent [ name>> ] bi@ = ;

: input-output-names ( word -- seq seq )
    ! returns two sequences containing the input and output names of a word
    [ introduces ] [ returns ] bi [ [ name>> ] map sift members ] bi@ ;

SINGLETON: recursion

GENERIC: (in-out) ( elt -- seq seq )

M: source (in-out)
    drop f { "" } ;

M: sink (in-out)
    drop { "" } f ;

M:: call (in-out) ( call -- seq seq )
    call target>>
    { { [ dup recursion? ] [ drop call [ word? ] find-parent input-output-names ] }
      { [ dup number? ] [ drop { } { "" } ] }
      { [ dup not ] [ drop { } { } ] }
      [ "declared-effect" words:word-prop convert-stack-effect ]
    } cond ;

CONSTANT: sequence-variadic-words { "array" } ! "sequence" "each" "map" "append" "produce" }
CONSTANT: special-variadic-words { "call" }

: simple-variadic? ( call -- ? )
    (in-out) { [ drop length 2 = ] [ nip length 1 = ]
        [ first swap first2 dupd = -rot = and ] } 2&& ;

: comparison-variadic? ( call -- ? )
    (in-out) [ length 2 = ] [ ?first "?" = ] bi* and ;

: sequence-variadic? ( call -- ? )
    name>> sequence-variadic-words member? ;

: special-variadic? ( call -- ? )
    name>> special-variadic-words member? ;

: variadic? ( call -- ? )
    { [ simple-variadic? ] [ comparison-variadic? ]
      [ sequence-variadic? ] [ special-variadic? ] } cleave or or or ;

:: insert-node-side ( node side -- new-node )
    ! inserts a new "call" to the left/right of a node
    node dup parent>> { [ word? ] [ variadic? ] } 1||
    [ parent>> contents>> :> nodes
      call new node parent>> >>parent dup :> new-node
      node nodes index side right eq? [ 1 + ] when
      nodes insert-nth! new-node ] when ;

:: in-out ( elt -- seq seq )
    { { [ elt call? not ] [ elt (in-out) ] }
      { [ elt simple-variadic? ]
        [ elt (in-out) [ first [  ] curry elt arity 2 max swap replicate ] dip ] }
      { [ elt sequence-variadic? ]
        [ elt arity 1 max [ "x" ] replicate { "seq" } ] }
      { [ elt name>> "call" = ]
        [ f elt arity 1 - [ "x" suffix ] times "quot" suffix { "result" } ] }
      [ elt (in-out) ]
    } cond ;

: short-name ( str -- str )
    " (constructor)" " (accessor)" " (mutator)" [ "" replace ] tri@ ;

:: matching-words ( str -- seq )
    ! returns all Factor words whose name begins with a certain string
    interactive-vocabs get [ vocabs:vocab-words ] map concat [ name>> str head? ] filter ;

:: matching-words-exact ( str -- seq )
    ! returns all Factor words that have a certain name
    interactive-vocabs get [ vocabs:vocab-words ] map concat [ name>> short-name str = ] filter ;

:: find-target ( call -- seq )
    ! returns the Factor word that has the same name as the call
    call factor-name :> name
    { { [ call same-name-as-parent? ] [ recursion 1array ] }
      { [ name string>number ] [ name string>number 1array ] }
      [ name matching-words-exact ]
    } cond ;

: (un)quote ( node -- node )
    ! toggles the "quoted?" attribute of a node
    [ not ] change-quoted? ;

:: ?add-words-above ( elt -- )
    elt elt in-out drop change-nodes-above
    elt contents>> [ ?add-words-above ] each ;

:: ?add-word-below ( elt -- )
    elt in-out nip [ first elt insert-new-parent default-name<< ] unless-empty ;

:: ?add-words ( word -- word )
    word contents>>
    [ word call add-from-class drop ]
    [ [ dup ?add-word-below ?add-words-above ] each ]
    if-empty word ;

: any-empty-name? ( word -- ? )
    ! tells if there are any empty names in the child tree of a word
    sort-tree
    [ [ introduce? ] [ [ quoted-node? ] find-parent ] bi and ] reject
    [ name>> empty? ] any? ;

: executable? ( word -- ? )
    ! tells if a word has the right properties to be executable
   { [ word? ]
     [ introduces [ [ quoted-node? ] find-parent ] reject empty? ]
     [ returns empty? ]
     [ calls empty? not ]
     [ any-empty-name? not ]
     [ defined?>> ]
   } 1&& ;

: error? ( word -- ? )
    ! tells if a word contains any error
    { [ defined?>> not ]
      [ any-empty-name? ] 
      [ contents>> empty? ]
    } 1|| ;

: save-result ( str word  -- )
    ! stores a string as the result of a word
    swap dupd result new swap >>contents swap >>parent >>result drop ;
