! Copyright (C) 2007, 2008 Slava Pestov, 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs fry io io.directories io.encodings.utf8
io.launcher io.pathnames kernel math.statistics prettyprint
sequences sorting system ;
IN: contributors

CONSTANT: aliases {
    { "Alexander Ilin" "Alexander Iljin" }
    { "Björn Lindqvist" "bjourne@gmail.com" }
    { "Cat Stevens" "catb0t" }
    { "Daniel Ehrenberg" "Dan Ehrenberg" }
    { "Doug Coleman" "U-FROGGER\\erg" "erg" }
    { "Erik Charlebois" "erikc" }
    { "KUSUMOTO Norio" "kusumotonorio" }
    { "Mighty Sheeple" "sheeple" "U-ENCHILADA\\sheeple" }
    { "Nicolas Pénet" "nicolas-p" }
    { "Slava Pestov" "slava" "Slava"
        "U-SLAVA-FB3999113\\Slava" "U-SLAVA-DFB8FF805\\Slava" }
    { "dharmatech" "U-CUTLER\\dharmatech" }
}

: changelog ( -- authors )
    image-path parent-directory [
        "git log --no-merges --pretty=format:%an" process-lines
    ] with-directory ;

: merge-aliases ( authors -- authors' )
    aliases [
        unclip '[ over delete-at* [ _ pick at+ ] [ drop ] if ] each
    ] each ;

: contributors ( -- )
    changelog histogram merge-aliases
    inv-sort-values
    simple-table. ;

MAIN: contributors
