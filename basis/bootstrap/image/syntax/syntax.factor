! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel namespaces assocs words.symbol ;
IN: bootstrap.image.syntax

SYMBOL: userenvs

SYNTAX: RESET H{ } clone userenvs set-global ;

SYNTAX: USERENV:
    CREATE-WORD scan-word
    [ swap userenvs get set-at ]
    [ drop define-symbol ]
    2bi ;