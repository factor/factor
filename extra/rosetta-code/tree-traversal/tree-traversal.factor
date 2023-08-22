! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators deques dlists io kernel
math.parser ;
IN: rosetta-code.tree-traversal

! https://rosettacode.org/wiki/Tree_traversal

! Implement a binary tree where each node carries an integer,
! and implement preoder, inorder, postorder and level-order
! traversal. Use those traversals to output the following tree:

!         1
!        / \
!       /   \
!      /     \
!     2       3
!    / \     /
!   4   5   6
!  /       / \
! 7       8   9

! The correct output should look like this:

! preorder:    1 2 4 7 5 3 6 8 9
! inorder:     7 4 2 5 1 8 6 9 3
! postorder:   7 4 5 2 8 9 6 3 1
! level-order: 1 2 3 4 5 6 7 8 9

TUPLE: node data left right ;

CONSTANT: example-tree
    T{ node f 1
        T{ node f 2
            T{ node f 4
                T{ node f 7 f f }
                f
            }
            T{ node f 5 f f }
        }
        T{ node f 3
            T{ node f 6
                T{ node f 8 f f }
                T{ node f 9 f f }
            }
            f
        }
    }

: preorder ( node quot: ( data -- ) -- )
    [ [ data>> ] dip call ]
    [ [ left>> ] dip over [ preorder ] [ 2drop ] if ]
    [ [ right>> ] dip over [ preorder ] [ 2drop ] if ]
    2tri ; inline recursive

: inorder ( node quot: ( data -- ) -- )
    [ [ left>> ] dip over [ inorder ] [ 2drop ] if ]
    [ [ data>> ] dip call ]
    [ [ right>> ] dip over [ inorder ] [ 2drop ] if ]
    2tri ; inline recursive

: postorder ( node quot: ( data -- ) -- )
    [ [ left>> ] dip over [ postorder ] [ 2drop ] if ]
    [ [ right>> ] dip over [ postorder ] [ 2drop ] if ]
    [ [ data>> ] dip call ]
    2tri ; inline recursive

: (levelorder) ( dlist quot: ( data -- ) -- )
    over deque-empty? [ 2drop ] [
        [ dup pop-front ] dip {
            [ [ data>> ] dip call drop ]
            [ drop left>> [ swap push-back ] [ drop ] if* ]
            [ drop right>> [ swap push-back ] [ drop ] if* ]
            [ nip (levelorder) ]
        } 3cleave
    ] if ; inline recursive

: levelorder ( node quot: ( data -- ) -- )
    [ 1dlist ] dip (levelorder) ; inline

: levelorder2 ( node quot: ( data -- ) -- )
    [ 1dlist ] dip
    [ dup deque-empty? not ] swap '[
        dup pop-front
        [ data>> @ ]
        [ left>> [ over push-back ] when* ]
        [ right>> [ over push-back ] when* ] tri
    ] while drop ; inline

: tree-traversal-main ( -- )
    example-tree [ number>string write bl ] {
        [ "preorder:    " write preorder    nl ]
        [ "inorder:     " write inorder     nl ]
        [ "postorder:   " write postorder   nl ]
        [ "levelorder:  " write levelorder  nl ]
        [ "levelorder2: " write levelorder2 nl ]
    } 2cleave ;

MAIN: tree-traversal-main
