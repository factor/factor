
USING: kernel words accessors
       classes
       classes.builtin
       classes.tuple
       classes.predicate
       vocabs
       arrays
       sequences sorting
       io help.markup
       effects
       generic
       prettyprint
       prettyprint.sections
       prettyprint.backend
       combinators.cleave
       obj.print ;

IN: vocab-browser

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: word-effect-as-string ( word -- string )
  stack-effect dup
    [ effect>string ]
    [ drop "" ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: print-vocabulary-summary ( vocabulary -- )

  dup vocab words [ builtin-class? ] filter natural-sort
  dup empty?
    [ drop ]
    [
      "Builtin Classes" $heading nl
      print-seq
    ]
  if

  dup vocab words [ tuple-class? ] filter natural-sort
  dup empty?
    [ drop ]
    [
      "Tuple Classes" $heading nl
      [
        { [ ] [ superclass ] [ "slots" word-prop [ name>> ] map " " join ] }
        1arr
      ]
      map
      { "CLASS" "PARENT" "SLOTS" } prefix
      print-table
    ]
  if

  dup vocab words [ predicate-class? ] filter natural-sort
  dup empty?
    [ drop ]
    [
      "Predicate Classes" $heading nl
      ! [ pprint-class ] each
      [ { [ ] [ superclass ] } 1arr ] map
      { "CLASS" "SUPERCLASS" } prefix
      print-table
    ]
  if

  dup vocab words [ class? not ] filter [ symbol? ] filter natural-sort
  dup empty?
    [ drop ]
    [
      "Symbols" $heading nl
      print-seq
    ]
  if

  dup vocab words [ generic? ] filter natural-sort
  dup empty?
    [ drop ]
    [
      "Generic words" $heading nl
      [ [ ] [ stack-effect effect>string ] bi 2array ] map
      print-table
    ]
  if

  "Words" $heading nl
  dup vocab words
    [ predicate-class? not ] filter
    [ builtin-class?   not ] filter
    [ tuple-class?     not ] filter
    [ generic?         not ] filter
    [ symbol?          not ] filter
    [ word?                ] filter
    natural-sort
    [ [ ] [ word-effect-as-string ] bi 2array ] map
  print-table

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: vocabs.loader tools.vocabs.browser ;

: $vocab-summary ( seq -- )
  first
  dup vocab
    [
      dup print-vocabulary-summary
      dup describe-help
      ! dup describe-uses
      ! dup describe-usage
    ]
  when
  dup find-vocab-root
    [
      dup describe-summary
      dup describe-tags
      dup describe-authors
      ! dup describe-files
    ]
  when
  ! dup describe-children
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: assocs ui.tools.browser ui.operations io.styles ;

! IN: tools.vocabs.browser

! : $describe-vocab ( element -- ) $vocab-summary ;

USING: tools.vocabs ;

: print-vocabs ( -- )
  vocabs
    [ { [ vocab ] [ vocab-summary ] } 1arr ]
  map
  print-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : $all-vocabs ( seq -- ) drop print-vocabs ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: help.syntax help.topics ;

! ARTICLE: "vocab-index" "Vocabulary Index" { $all-vocabs } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: vocab-spec article-content ( vocab-spec -- content )
   { $vocab-summary } swap name>> suffix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: loaded-and-unloaded-vocabs ( -- seq )
  "" all-child-vocabs values concat [ name>> ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! ARTICLE: "loaded-vocabs-index" "Loaded Vocabularies" { $loaded-vocabs } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: debugger ;

TUPLE: load-this-vocab name ;

! : do-load-vocab ( ltv -- )
!   dup name>> require
!   name>> vocab com-follow ;

: do-load-vocab ( ltv -- )
  [
    dup name>> require
    name>> vocab com-follow
  ]
  curry
  try ;

[ load-this-vocab? ] \ do-load-vocab { { +primary+ t } } define-operation

M: load-this-vocab pprint* ( obj -- )
   [ name>> "*" append ] [ ] bi write-object ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: vocab-or-loader ( name -- obj )
  dup vocab
    [ vocab ]
    [ load-this-vocab boa ]
  if ;

: vocab-summary-text ( vocab-name -- text )
  dup vocab-summary-path vocab-file-contents
  dup empty?
    [ drop "" ]
    [ first   ]
  if ;

! : vocab-table-entry ( vocab-name -- seq )
!   { [ vocab-or-loader ] [ vocab-summary ] } 1arr ;

: vocab-table-entry ( vocab-name -- seq )
  { [ vocab-or-loader ] [ vocab-summary-text ] } 1arr ;

: print-these-vocabs ( seq -- ) [ vocab-table-entry ] map print-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : vocab-list ( -- seq ) "" all-child-vocabs values concat [ name>> ] map ;

: all-vocab-names ( -- seq )
  all-vocabs values concat [ name>> ] map natural-sort ;

: loaded-vocab-names ( -- seq ) all-vocab-names [ vocab ] filter ;

: unloaded-vocab-names ( -- seq ) all-vocab-names [ vocab not ] filter ;

: root->names ( root -- seq ) all-vocabs at [ name>> ] map natural-sort ;

: vocab-names-core  ( -- seq ) "resource:core"  root->names ;
: vocab-names-basis ( -- seq ) "resource:basis" root->names ;
: vocab-names-extra ( -- seq ) "resource:extra" root->names ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: $all-vocabs      ( seq -- ) drop all-vocab-names      print-these-vocabs ;
: $loaded-vocabs   ( seq -- ) drop loaded-vocab-names   print-these-vocabs ;
: $unloaded-vocabs ( seq -- ) drop unloaded-vocab-names print-these-vocabs ;

: $vocabs-core     ( seq -- ) drop vocab-names-core     print-these-vocabs ;
: $vocabs-basis    ( seq -- ) drop vocab-names-basis    print-these-vocabs ;
: $vocabs-extra    ( seq -- ) drop vocab-names-extra    print-these-vocabs ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! { "" }

! all-child-vocabs values concat [ name>> ] map

! : vocab-tree ( vocab -- seq )
!   dup
!   all-child-vocabs values concat [ name>> ] map prune
!   [ vocab-tree ]
!   map
!   concat
!   swap prefix
!   [ vocab-source-path ] filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: vocab-author pprint* ( vocab-author -- ) [ name>> ] [ ] bi write-object ;

: $vocab-authors ( seq -- )
  drop all-authors [ vocab-author boa ] map print-seq ;

ARTICLE: "vocab-authors" "Vocabulary Authors" { $vocab-authors } ;

: vocabs-by-author ( author -- vocab-names )
  authored values concat [ name>> ] map ;

: $vocabs-by-author ( seq -- )
  first name>> vocabs-by-author print-these-vocabs ;

M: vocab-author article-content ( vocab-author -- content )
   { $vocabs-by-author } swap suffix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: vocab-tag pprint* ( vocab-tag -- ) [ name>> ] [ ] bi write-object ;

: print-vocab-tags ( -- ) all-tags [ vocab-tag boa ] map print-seq ;

: $vocab-tags ( seq -- ) drop print-vocab-tags ;

ARTICLE: "vocab-tags" "Vocabulary Tags" { $vocab-tags } ;

: $vocabs-with-tag ( seq -- )
  first tagged values concat [ name>> ] map print-these-vocabs ;

M: vocab-tag article-content ( vocab-tag -- content )
   name>> { $vocabs-with-tag } swap suffix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "vocab-index-all"      "All Vocabularies"      { $all-vocabs    } ;
ARTICLE: "vocab-index-loaded"   "Loaded Vocabularies"   { $loaded-vocabs } ;
ARTICLE: "vocab-index-unloaded" "Unloaded Vocabularies" { $loaded-vocabs } ;

ARTICLE: "vocab-index-core"      "Core Vocabularies"    { $vocabs-core   } ;
ARTICLE: "vocab-index-basis"     "Basis Vocabularies"   { $vocabs-basis  } ;
ARTICLE: "vocab-index-extra"     "Extra Vocabularies"   { $vocabs-extra  } ;

ARTICLE: "vocab-indices" "Vocabulary Indices"
  { $subsection "vocab-index-core"     }
  { $subsection "vocab-index-basis"    }
  { $subsection "vocab-index-extra"    }
  { $subsection "vocab-index-all"      }
  { $subsection "vocab-index-loaded"   }
  { $subsection "vocab-index-unloaded" }
  { $subsection "vocab-authors"        }
  { $subsection "vocab-tags"           } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

