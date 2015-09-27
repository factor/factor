! Copyright (C) 2008 Ben Schlingelhof.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.standard-paths kernel make math.parser
namespaces sequences ;
IN: editors.textwrangler

! TextWrangler ships with a program called ``edit`` if you don't download
! it from the App Store. Since the App Store version is lacking ``edit``,
! there's a separate .zip you can download from:
! http://pine.barebones.com/files/tw-cmdline-tools.zip

! Note that launching with ``open -a`` does not support line numbers.

SINGLETON: textwrangler
textwrangler editor-class set-global

M: textwrangler editor-command
    "edit" find-in-path [
        [ , number>string "+" prepend , , ] { } make
    ] [
        [
            "open" , "-a" , "TextWrangler" ,
            [ , ] [ "--args" , number>string "+" prepend , ] bi*
        ] { } make
    ] if* ;
