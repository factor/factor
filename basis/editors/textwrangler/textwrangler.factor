! Copyright (C) 2008 Ben Schlingelhof.
! See https://factorcode.org/license.txt for BSD license.
USING: editors io.standard-paths kernel make math.parser
namespaces sequences ;
IN: editors.textwrangler

! TextWrangler ships with a program called ``edit`` if you download
! it from the website. Since the App Store version is lacking ``edit``,
! there's a separate .zip you can download from:
! https://pine.barebones.com/files/tw-cmdline-tools.zip

! Note that launching with ``open -a`` does not support line numbers.

SINGLETON: textwrangler

M: textwrangler editor-command
    "edit" find-in-path [
        [ , number>string "+" prepend , , ] { } make
    ] [
        [
            "open" , "-a" , "TextWrangler" ,
            [ , ] [ "--args" , number>string "+" prepend , ] bi*
        ] { } make
    ] if* ;
