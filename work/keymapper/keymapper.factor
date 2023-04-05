! File: keymapper.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs io.directories io.encodings.utf8
io.files kernel locals prettyprint sequences variables xml xml.data
xml.traversal xml.writer ;

IN: keymapper

VAR: ww2ol-dir
VAR: cfml

CONSTANT: cfml_defaults  "/Sources/Factor/work/keymapper/cfml_defaults/"
CONSTANT: cfml_prefs  "/Users/davec/Library/Preferences/ww2ol/cfml/" 

: set-cfml-path ( path -- )
    set: ww2ol-dir ; 

FROM: string => to-folder ; 
: list-cfml ( -- )
    ww2ol-dir dup printx
    directory-files printx ; 

: use-cfml ( name -- )
    ".cfml" append
    ww2ol-dir prepend
    file>xml  set: cfml ;

: find-sa-functions ( -- seq )
    cfml children-tags [ attrs>> alist>> >boolean not ] filter ;

: tag-name ( tag -- name )
    name>> main>> ;

:: tag-func ( tag -- newtag )
    tag name>> :> origName
    tag children-tags  
    [ second ] keep  first
    :> theFunc  :> funcChildren
    "" theFunc name>> main>> "" <name> :> newTagAttr
    theFunc children>> first :> newTagAttrValue
    newTagAttr  newTagAttrValue 2array :> newAttr
    origName V{ newAttr } funcChildren <tag>
;

: goodone ( -- tag )
    cfml children-tags first ; 

: func-names ( -- seq )
    cfml "control" tags-named 
    [ attrs>> ] map [ alist>> first second ] map 
    ;

:: newxml ( -- <xml> )
    T{ prolog f "1.0" "UTF-8" f } :> cfml-prolog
    T{ name f "" "controlset" "" } :> cfml-controlset
    V{ }
    T{ name f "" "version" "" } "1.0.0" 2array 1array append
    T{ name f "" "keyboard" "" } "us" 2array 1array append
    T{ name f "" "language" "" } "english" 2array 1array append
    >alist <attrs>
    :> cfml-controlset-attr
    V{ } :> cfml-controlset-children
    cfml-controlset cfml-controlset-attr cfml-controlset-children <tag> :> cfml-body
    cfml-prolog V{ } cfml-body V{ "" } <xml>
    ;

: write-cfml ( <xml> -- )
    ww2ol-dir "test.cfml" append  utf8 
    [ write-xml ] with-file-writer ;


: test ( -- )
    find-sa-functions [ tag-func ] map
    newxml dup body>>  rot >>children  >>body
    write-cfml
    ;


cfml_defaults set-cfml-path
  "general" use-cfml