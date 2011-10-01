! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel namespaces assocs words.symbol ;
IN: bootstrap.image.syntax

SYMBOL: special-objects

SYNTAX: RESET H{ } clone special-objects set-global ;

SYNTAX: SPECIAL-OBJECT:
    scan-new-word scan-number
    [ swap special-objects get set-at ]
    [ drop define-symbol ]
    2bi ;
