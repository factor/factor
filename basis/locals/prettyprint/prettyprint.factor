! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors effects kernel locals locals.definitions
locals.types prettyprint.backend prettyprint.custom
prettyprint.sections see sequences words ;
IN: locals.prettyprint

: pprint-var ( var -- )
    ! Prettyprint a read/write local as its writer, just like
    ! in the input syntax: |[ x! | ... x 3 + x! ]
    dup local-reader? [
        "local-writer" word-prop
    ] when pprint-word ;

: pprint-vars ( vars -- ) [ pprint-var ] each ;

M: lambda pprint*
    <flow
    \ |[ pprint-word
    dup vars>> pprint-vars
    "|" text
    f <inset body>> pprint-elements block>
    \ ] pprint-word
    block> ;

: pprint-let ( let word -- )
    pprint-word
    <block body>> pprint-elements block>
    \ ] pprint-word ;

M: let pprint* \ let[ pprint-let ;

M: def pprint*
    dup local>> word?
    [ <block \ :> pprint-word local>> pprint-var block> ]
    [ pprint-tuple ] if ;

M: multi-def pprint*
    dup locals>> [ word? ] all?
    [ <block \ :> pprint-word "(" text locals>> [ pprint-var ] each ")" text block> ]
    [ pprint-tuple ] if ;

M: lambda-method synopsis*
    dup dup dup definer.
    "method-class" word-prop pprint-word
    "method-generic" word-prop pprint-word
    method-stack-effect effect>string comment. ;
