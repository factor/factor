! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml kernel sequences xml.utilities combinators.lib
math xml.data arrays assocs xml.generator namespaces math.parser ;
IN: faq

: find-after ( seq quot -- elem after )
    over >r find r> rot 1+ tail ; inline

: tag-named? ( tag name -- ? )
    assure-name swap (get-tag) ;

! Questions
TUPLE: q/a question answer ;
C: <q/a> q/a

: li>q/a ( li -- q/a )
    [ "br" tag-named? not ] subset
    [ "strong" tag-named? ] find-after
    >r tag-children r> <q/a> ;

: q/a>li ( q/a -- li )
    [ q/a-question "strong" build-tag* f "br" build-tag* 2array ] keep
    q/a-answer append "li" build-tag* ;

: xml>q/a ( xml -- q/a )
    [ "question" tag-named tag-children ] keep
    "answer" tag-named tag-children <q/a> ;

: q/a>xml ( q/a -- xml )
    [ q/a-question "question" build-tag* ] keep
    q/a-answer "answer" build-tag*
    "\n" swap 3array "qa" build-tag* ;

! Lists of questions
TUPLE: question-list title seq ;
C: <question-list> question-list

: xml>question-list ( list -- question-list )
    [ "title" swap at ] keep
    tag-children [ tag? ] subset [ xml>q/a ] map
    <question-list> ;

: question-list>xml ( question-list -- list )
    [ question-list-seq [ q/a>xml "\n" swap 2array ]
      map concat "list" build-tag* ] keep
    question-list-title [ "title" pick set-at ] when* ;

: html>question-list ( h3 ol -- question-list )
    >r [ children>string ] [ f ] if* r>
    children-tags [ li>q/a ] map <question-list> ;

: question-list>h3 ( id question-list -- h3 )
    question-list-title [
        "h3" build-tag
        swap number>string "id" pick set-at
    ] [ drop f ] if* ;

: question-list>html ( question-list start id -- h3/f ol )
    -rot >r [ question-list>h3 ] keep
    question-list-seq [ q/a>li ] map "ol" build-tag* r>
    number>string "start" pick set-at
    "margin-left: 5em" "style" pick set-at ;

! Overall everything
TUPLE: faq header lists ;
C: <faq> faq

: html>faq ( div -- faq )
    unclip swap { "h3" "ol" } [ tags-named ] curry* map
    first2 >r f add* r> [ html>question-list ] 2map <faq> ;

: header, ( faq -- )
    dup faq-header ,
    faq-lists first 1 -1 question-list>html nip , ;

: br, ( -- )
    "br" contained, nl, ;

: toc-link, ( question-list number -- )
    number>string "#" swap append "href" swap 2array 1array
    "a" swap [ question-list-title , ] tag*, br, ;

: toc, ( faq -- )
    "div" { { "style" "background-color: #eee; margin-left: 30%; margin-right: 30%; width: auto; padding: 5px; margin-top: 1em; margin-bottom: 1em" } } [
        "strong" [ "The big questions" , ] tag, br,
        faq-lists 1 tail dup length [ toc-link, ] 2each
    ] tag*, ;

: faq-sections, ( question-lists -- )
    unclip question-list-seq length 1+ dupd
    [ question-list-seq length + ] accumulate nip
    0 -rot [ pick question-list>html [ , nl, ] 2apply 1+ ] 2each drop ;

: faq>html ( faq -- div )
    "div" [
        dup header,
        dup toc,
        faq-lists faq-sections,
    ] make-xml ;

: xml>faq ( xml -- faq )
    [ "header" tag-named children>string ] keep
    "list" tags-named [ xml>question-list ] map <faq> ;

: faq>xml ( faq -- xml )
    "faq" [
        "header" [ dup faq-header , ] tag,
        faq-lists [ question-list>xml , nl, ] each
    ] make-xml ;

: read-write-faq ( xml-stream -- )
    [ read-xml ] with-stream xml>faq faq>html write-xml ;
