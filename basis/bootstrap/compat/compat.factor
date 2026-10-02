! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Source-level updates needed before older seed images load new code.
USING: accessors alien arrays assocs classes classes.predicate
classes.union fry kernel quotations vocabs words words.symbol ;
IN: bootstrap.compat

! Older images used the parsing word f as the built-in class of false.
! Preserve the class identity so existing methods and unions still refer
! to it, and give the literal its own parsing word.
<<
"false" "kernel" lookup-word [
    f class-of
    dup parsing-word? [ [ def>> ] keep ] [ f swap ] if
    dup [ name>> ] [ vocabulary>> vocab-words-assoc ] bi delete-at
    "false" >>name "kernel" >>vocabulary
    dup "false" "kernel" vocab-words-assoc set-at
    dup "parsing" remove-word-prop
    dup define-symbol
    dup create-predicate-word
    dup [ not ] ( object -- ? ) define-declared
    dup pick "predicating" set-word-prop
    1quotation "predicate" set-word-prop
    [ "f" "syntax" create-word swap define-syntax ] when*
] unless
>>

! The canonical true value remains the word t. Its class is a separate
! predicate over words, rather than a singleton whose instance is itself.
<<
"true" "kernel" lookup-word [
    "true" "kernel" create-word \ word
    [ t eq? ] define-predicate-class
] unless
"true" "kernel" lookup-word t "initial-value" set-word-prop

! A host compiler built before this change uses t itself as type metadata.
! Keep that metadata while generating a new seed; the target is created with
! a plain t symbol. Older seeds have no compiler and can migrate directly.
"compiler.tree.propagation.info" lookup-vocab
dup [ source-loaded?>> ] when not t class? and [
    "boolean" "kernel" lookup-word
    "true" "kernel" lookup-word "false" "kernel" lookup-word
    2array define-union-class
    t forget-class
] when
>>

! This is a compile-only word, not a VM primitive. Keep its declaration in
! sync with core/alien/alien.factor. Preserve the existing word and inference
! properties when bootstrapping from a seed that already contains it.
<<
"alien-callback-varargs" "alien" lookup-word [
    "alien-callback-varargs" "alien" create-word
    dup '[ _ callsite-not-compiled ]
    ( return named-parameters abi quot -- alien ) define-declared
] unless
>>
