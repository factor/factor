! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators
combinators.short-circuit io.encodings.utf8
io.files json kernel locals math math.order math.parser math.bitwise memoize modern.slices namespaces splitting
sequences sequences.extras sets strings unicode words ;

IN: html5

: 1sbuf ( ch -- sbuf ) [ SBUF" " clone ] dip over push ; inline
: ?1sbuf ( ch -- sbuf ) [ SBUF" " clone ] dip [ over push ] when* ; inline

! https://html.spec.whatwg.org/multipage/parsing.html#tokenization

! https://infra.spec.whatwg.org/#namespaces
CONSTANT: html-namespace "http://www.w3.org/1999/xhtml"
CONSTANT: mathml-namespace "http://www.w3.org/1998/Math/MathML"
CONSTANT: svg-namespace "http://www.w3.org/2000/svg"
CONSTANT: xlink-namespace "http://www.w3.org/1999/xlink"
CONSTANT: xml-namespace "http://www.w3.org/XML/1998/namespace"
CONSTANT: xmlns-namespace "http://www.w3.org/2000/xmlns/"

DEFER: data-state
DEFER: (data-state)
DEFER: rcdata-state
DEFER: (rcdata-state)
DEFER: rawtext-state
DEFER: (rawtext-state)
DEFER: script-data-state
DEFER: (script-data-state)
DEFER: plaintext-state
DEFER: (plaintext-state)
DEFER: tag-open-state
DEFER: (tag-open-state)
DEFER: end-tag-open-state
DEFER: (end-tag-open-state)
DEFER: tag-name-state
DEFER: (tag-name-state)
DEFER: rcdata-less-than-sign-state
DEFER: (rcdata-less-than-sign-state)
DEFER: rcdata-end-tag-open-state
DEFER: (rcdata-end-tag-open-state)
DEFER: rcdata-end-tag-name-state
DEFER: (rcdata-end-tag-name-state)
DEFER: rawtext-less-than-sign-state
DEFER: (rawtext-less-than-sign-state)
DEFER: rawtext-end-tag-open-state
DEFER: (rawtext-end-tag-open-state)
DEFER: rawtext-end-tag-name-state
DEFER: (rawtext-end-tag-name-state)
DEFER: script-data-less-than-sign-state
DEFER: (script-data-less-than-sign-state)
DEFER: script-data-end-tag-open-state
DEFER: (script-data-end-tag-open-state)
DEFER: script-data-end-tag-name-state
DEFER: (script-data-end-tag-name-state)
DEFER: script-data-escape-start-state
DEFER: (script-data-escape-start-state)
DEFER: script-data-escape-start-dash-state
DEFER: (script-data-escape-start-dash-state)
DEFER: script-data-escaped-state
DEFER: (script-data-escaped-state)
DEFER: script-data-escaped-dash-state
DEFER: (script-data-escaped-dash-state)
DEFER: script-data-escaped-dash-dash-state
DEFER: (script-data-escaped-dash-dash-state)
DEFER: script-data-escaped-less-than-sign-state
DEFER: (script-data-escaped-less-than-sign-state)
DEFER: script-data-escaped-end-tag-open-state
DEFER: (script-data-escaped-end-tag-open-state)
DEFER: script-data-escaped-end-tag-name-state
DEFER: (script-data-escaped-end-tag-name-state)
DEFER: script-data-double-escape-start-state
DEFER: (script-data-double-escape-start-state)
DEFER: script-data-double-escaped-state
DEFER: (script-data-double-escaped-state)
DEFER: script-data-double-escaped-dash-state
DEFER: (script-data-double-escaped-dash-state)
DEFER: script-data-double-escaped-dash-dash-state
DEFER: (script-data-double-escaped-dash-dash-state)
DEFER: script-data-double-escaped-less-than-sign-state
DEFER: (script-data-double-escaped-less-than-sign-state)
DEFER: script-data-double-escape-end-state
DEFER: (script-data-double-escape-end-state)
DEFER: before-attribute-name-state
DEFER: (before-attribute-name-state)
DEFER: attribute-name-state
DEFER: (attribute-name-state)
DEFER: after-attribute-name-state
DEFER: (after-attribute-name-state)
DEFER: before-attribute-value-state
DEFER: (before-attribute-value-state)
DEFER: attribute-value-double-quoted-state
DEFER: (attribute-value-double-quoted-state)
DEFER: attribute-value-single-quoted-state
DEFER: (attribute-value-single-quoted-state)
DEFER: attribute-value-unquoted-state
DEFER: (attribute-value-unquoted-state)
DEFER: after-attribute-value-quoted-state
DEFER: (after-attribute-value-quoted-state)
DEFER: self-closing-start-tag-state
DEFER: (self-closing-start-tag-state)
DEFER: bogus-comment-state
DEFER: (bogus-comment-state)
DEFER: markup-declaration-open-state
DEFER: (markup-declaration-open-state)
DEFER: comment-start-state
DEFER: (comment-start-state)
DEFER: comment-start-dash-state
DEFER: (comment-start-dash-state)
DEFER: comment-state
DEFER: (comment-state)
DEFER: comment-less-than-sign-state
DEFER: (comment-less-than-sign-state)
DEFER: comment-less-than-sign-bang-state
DEFER: (comment-less-than-sign-bang-state)
DEFER: comment-less-than-sign-bang-dash-state
DEFER: (comment-less-than-sign-bang-dash-state)
DEFER: comment-less-than-sign-bang-dash-dash-state
DEFER: (comment-less-than-sign-bang-dash-dash-state)
DEFER: comment-end-dash-state
DEFER: (comment-end-dash-state)
DEFER: comment-end-state
DEFER: (comment-end-state)
DEFER: comment-end-bang-state
DEFER: (comment-end-bang-state)
DEFER: doctype-state
DEFER: (doctype-state)
DEFER: before-doctype-name-state
DEFER: (before-doctype-name-state)
DEFER: doctype-name-state
DEFER: (doctype-name-state)
DEFER: after-doctype-name-state
DEFER: (after-doctype-name-state)
DEFER: after-doctype-public-keyword-state
DEFER: (after-doctype-public-keyword-state)
DEFER: before-doctype-public-identifier-state
DEFER: (before-doctype-public-identifier-state)
DEFER: doctype-public-identifier-double-quoted-state
DEFER: (doctype-public-identifier-double-quoted-state)
DEFER: doctype-public-identifier-single-quoted-state
DEFER: (doctype-public-identifier-single-quoted-state)
DEFER: after-doctype-public-identifier-state
DEFER: (after-doctype-public-identifier-state)
DEFER: between-doctype-public-and-system-identifiers-state
DEFER: (between-doctype-public-and-system-identifiers-state)
DEFER: after-doctype-system-keyword-state
DEFER: (after-doctype-system-keyword-state)
DEFER: before-doctype-system-identifier-state
DEFER: (before-doctype-system-identifier-state)
DEFER: doctype-system-identifier-double-quoted-state
DEFER: (doctype-system-identifier-double-quoted-state)
DEFER: doctype-system-identifier-single-quoted-state
DEFER: (doctype-system-identifier-single-quoted-state)
DEFER: after-doctype-system-identifier-state
DEFER: (after-doctype-system-identifier-state)
DEFER: bogus-doctype-state
DEFER: (bogus-doctype-state)
DEFER: cdata-section-state
DEFER: (cdata-section-state)
DEFER: cdata-section-bracket-state
DEFER: (cdata-section-bracket-state)
DEFER: cdata-section-end-state
DEFER: (cdata-section-end-state)
DEFER: processing-instruction-open-state
DEFER: (processing-instruction-open-state)
DEFER: processing-instruction-target-state
DEFER: (processing-instruction-target-state)
DEFER: after-processing-instruction-target-state
DEFER: (after-processing-instruction-target-state)
DEFER: processing-instruction-data-state
DEFER: (processing-instruction-data-state)
DEFER: processing-instruction-questionable-state
DEFER: (processing-instruction-questionable-state)
DEFER: character-reference-state
DEFER: (character-reference-state)
DEFER: named-character-reference-state
DEFER: (named-character-reference-state)
DEFER: ambiguous-ampersand-state
DEFER: (ambiguous-ampersand-state)
DEFER: numeric-character-reference-state
DEFER: (numeric-character-reference-state)
DEFER: hexadecimal-character-reference-start-state
DEFER: (hexadecimal-character-reference-start-state)
DEFER: decimal-character-reference-start-state
DEFER: (decimal-character-reference-start-state)
DEFER: hexadecimal-character-reference-state
DEFER: (hexadecimal-character-reference-state)
DEFER: decimal-character-reference-state
DEFER: (decimal-character-reference-state)
DEFER: numeric-character-reference-end-state
DEFER: (numeric-character-reference-end-state)


ERROR: unimplemented string ;
ERROR: unimplemented* ;

! Errors: https://html.spec.whatwg.org/multipage/parsing.html#parse-errors
ERROR: abrupt-closing-of-empty-comment ;
ERROR: abrupt-doctype-public-identifier ;
ERROR: abrupt-doctype-system-identifier ;
ERROR: absence-of-digits-in-numeric-character-reference ;
ERROR: cdata-in-html-content ;
ERROR: character-reference-outside-unicode-range ;
ERROR: control-character-in-input-stream ;
ERROR: control-character-reference ;
ERROR: end-tag-with-attributes ;
ERROR: duplicate-attribute ;
ERROR: end-tag-with-trailing-solidus ;
ERROR: eof-before-tag-name ;
ERROR: eof-in-cdata ;
ERROR: eof-in-comment ;
ERROR: eof-in-doctype ;
ERROR: eof-in-script-html-comment-like-text ;
ERROR: eof-in-tag ;
ERROR: incorrectly-closed-comment ;
ERROR: incorrectly-opened-comment ;
ERROR: invalid-character-sequence-after-doctype-name ;
ERROR: invalid-first-character-of-tag-name ;
ERROR: missing-attribute-value ;
ERROR: missing-doctype-name ;
ERROR: missing-doctype-public-identifier ;
ERROR: missing-doctype-system-identifier ;
ERROR: missing-end-tag-name ;
ERROR: missing-quote-before-doctype-public-identifier ;

ERROR: missing-quote-before-doctype-system-identifier ;
ERROR: missing-semicolon-after-character-reference ;
ERROR: missing-whitespace-after-doctype-public-keyword ;
ERROR: missing-whitespace-after-doctype-system-keyword ;
ERROR: missing-whitespace-before-doctype-name ;
ERROR: missing-whitespace-between-attributes ;
ERROR: missing-whitespace-between-doctype-public-and-system-identifiers ;
ERROR: nested-comment ;
ERROR: noncharacter-character-reference ;
ERROR: noncharacter-in-input-stream ;
ERROR: non-void-html-element-start-tag-with-trailing-solidus ;
ERROR: null-character-reference ;
ERROR: surrogate-character-reference ;
ERROR: surrogate-in-input-stream ;
ERROR: unexpected-character-after-doctype-system-identifier ;
ERROR: unexpected-character-in-attribute-name ;
ERROR: unexpected-character-in-unquoted-attribute-value ;
ERROR: unexpected-equals-sign-before-attribute-name ;
ERROR: unexpected-null-character ;
ERROR: unexpected-question-mark-instead-of-tag-name ;
ERROR: unexpected-solidus-in-tag ;
ERROR: unknown-named-character-reference ;

! Tree insertion modes
SINGLETONS: initial-mode before-html-mode before-head-mode
in-head-mode in-head-noscript-mode after-head-mode
in-body-mode text-mode in-table-mode in-table-text-mode
in-caption-mode in-column-group-mode in-table-body-mode
in-row-mode in-cell-mode in-select-mode in-select-in-table-mode in-template-mode
after-body-mode in-frameset-mode after-frameset-mode after-after-body-mode
after-after-frameset-mode ;

SYMBOL: current-html5-document

TUPLE: document
parse-errors
skip-leading-newline?
pending-table-characters
template-insertion-modes
active-formatting-elements
quirks-mode?
limited-quirks-mode?
iframe-srcdoc?
scripting? ! set in constructor
frameset-ok?
fostering-parent?
tree
tree-doctype
head-element-pointer ! set during insertion time
form-element-pointer
parser-cannot-change-mode-flag
insertion-mode
original-insertion-mode
last
node
context
doctype
tag
end-tag

tag-name
end-tag-name
attribute-name
attribute-value
temporary-buffer
comment-token
processing-instruction-token
open-elements
return-state ;

! "reset the insertion mode appropriately"
! : reset-insertion-mode ( document -- document )
!     f >>last
!     dup open-elements>> ?last >>node
!     dup [ open-elements>> ?first ] [ node>> ] bi = [
!         t >>last dup node>> >>context
!     ] when
!     dup node>> {
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [
!             dup name>> >lower { "td" "th" } member?
!             pick last>> f = and
!         ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!     } cond
!     ;

: temporary-buffer-attribute? ( document -- ? )
    return-state>>
    {
        attribute-value-unquoted-state
        attribute-value-single-quoted-state
        attribute-value-double-quoted-state
    } member? ;

! name, public/system identifier should not be empty strings
! until the state machine demands it
TUPLE: doctype
    name
    public-identifier
    system-identifier
    quirks? ;

: <doctype> ( -- doctype )
    doctype new ; inline

: new-doctype-from-ch ( ch document -- )
    [
        doctype new
            swap ?1sbuf >>name
    ] dip doctype<< ; inline

: new-doctype-with-quirks ( document -- )
    <doctype> t >>quirks? >>doctype drop ;

! template-contents is a vector for HTML template fragments, otherwise f.
TUPLE: tag self-closing? name attributes children end-tag namespace template-contents parent ;

: <tag> ( -- tag )
    tag new
        html-namespace >>namespace
        SBUF" " clone >>name
        V{ } clone >>attributes
        V{ } clone >>children ;

TUPLE: end-tag self-closing? name attributes ;

: <end-tag> ( -- tag )
    end-tag new
        SBUF" " clone >>name
        V{ } clone >>attributes ;

: new-tag ( document -- )
    <tag> >>tag drop ;

: new-end-tag ( document -- )
    <end-tag> >>tag drop ;

: set-self-closing ( document -- )
    tag>> t >>self-closing? drop ;

: <document> ( -- document )
    document new
        V{ } clone >>parse-errors
        V{ } clone >>active-formatting-elements
        V{ } clone >>template-insertion-modes
        V{ } clone >>pending-table-characters
        V{ } clone >>tree
        initial-mode >>insertion-mode
        <doctype> >>doctype
        t >>frameset-ok?
        ! SBUF" " clone >>tag-name
        SBUF" " clone >>attribute-name
        SBUF" " clone >>attribute-value
        SBUF" " clone >>temporary-buffer
        SBUF" " clone >>comment-token
        V{ } clone >>open-elements
    ; inline

TUPLE: comment open payload close ;

: <comment> ( payload -- comment )
    comment new
        swap >>payload ; inline

: force-quirks ( document -- )
    doctype>> t >>quirks? drop ;

: initialize-doctype-name ( document -- )
    [ SBUF" " clone ] dip doctype>> name<< ;

: initialize-doctype-public-identifier ( document -- )
    [ SBUF" " clone ] dip doctype>> public-identifier<< ;

: initialize-doctype-system-identifier ( document -- )
    [ SBUF" " clone ] dip doctype>> system-identifier<< ;

: push-doctype-name ( ch document -- )
    doctype>> name>> push ;

: push-doctype-public-identifier ( ch document -- )
    doctype>> public-identifier>> push ;

: push-doctype-system-identifier ( ch document -- )
    doctype>> system-identifier>> push ;

: report-parse-error ( name -- )
    current-html5-document get parse-errors>> push ;

TUPLE: processing-instruction target data ;

: misc-node? ( obj -- ? )
    { [ comment? ] [ processing-instruction? ] } 1|| ;

! Tree construction.
CONSTANT: void-elements {
    "area" "base" "basefont" "bgsound" "br" "col" "embed" "frame" "hr" "img" "input" "keygen" "link"
    "meta" "param" "source" "track" "wbr"
}

: element-children ( element -- children )
    dup template-contents>> [ nip ] [ children>> ] if* ;

: current-children ( document -- children )
    dup open-elements>> ?last [ nip element-children ] [ tree>> ] if* ;

CONSTANT: table-text-elements { "table" "tbody" "tfoot" "thead" "tr" }

: html-element? ( element -- ? ) namespace>> html-namespace = ;

:: html-element-named? ( element name -- ? )
    element { [ html-element? ] [ name>> name = ] } 1&& ;

:: start-tag-named? ( obj name -- ? )
    obj { [ tag? ] [ name>> name = ] } 1&& ;

:: end-tag-named? ( obj name -- ? )
    obj { [ end-tag? ] [ name>> name = ] } 1&& ;

:: current-element-matches? ( document quot -- ? )
    document open-elements>> ?last quot [ f ] if* ; inline

:: current-element-named? ( document name -- ? )
    document [ name>> name = ] current-element-matches? ;

! Formatting list and open-stack membership use node identity.
:: node-index ( node sequence -- index/f )
    sequence [ node eq? ] find drop ;

: node-member? ( node sequence -- ? ) node-index f = not ;

:: remove-node ( node sequence -- )
    node sequence node-index [ sequence remove-nth! drop ] when* ;

: parent-children ( parent -- children )
    dup document? [ tree>> ] [ element-children ] if ;

:: set-node-parent ( node parent -- )
    node tag? [ node parent >>parent drop ] when ;

:: attach-node ( node parent -- )
    node parent set-node-parent node parent parent-children push ;

:: detach-node ( node -- )
    node parent>> [ node swap parent-children remove-node ] when*
    node f >>parent drop ;

CONSTANT: formatting-marker-elements { "applet" "object" "marquee" "template" "td" "th" "caption" }

:: clear-formatting ( document -- )
    document active-formatting-elements>> :> entries
    f :> done!
    [ entries empty? not done not and ] [ entries pop f = done! ] while ;

:: insert-before-node ( node sibling -- )
    sibling parent>> :> parent
    parent parent-children :> children
    sibling children node-index :> position
    node parent set-node-parent
    node position children insert-nth! ;

:: foster-node ( document node fallback -- )
    document open-elements>> :> stack
    stack [ "table" html-element-named? ] find-last drop :> table-index
    stack [ "template" html-element-named? ] find-last drop :> template-index
    {
        { [ template-index [ table-index [ template-index table-index > ] [ t ] if ] [ f ] if ]
          [ node template-index stack nth attach-node ] }
        { [ table-index ] [
            table-index stack nth :> table
            table parent>> [ node table insert-before-node ] [ node stack first attach-node ] if
        ] }
        [ node fallback attach-node ]
    } cond ;

:: append-node ( document obj -- )
    obj dup integer? [ 1string ] when :> node
    document open-elements>> ?last [ ] [ document ] if* :> parent
    document fostering-parent?>>
    document [ { [ html-element? ] [ name>> table-text-elements member? ] } 1&& ]
    current-element-matches? and [
        document node parent foster-node
    ] [ node parent attach-node ] if ;

:: insert-element ( document element -- )
    document element append-node
    element namespace>> html-namespace = [
        element name>> void-elements member?
    ] [ element self-closing?>> ] if [
        element document open-elements>> push
        element html-element? element name>> formatting-marker-elements member? and [
            f document active-formatting-elements>> push
        ] when
    ] unless ;

:: close-element ( document token -- )
    document open-elements>> :> stack
    stack [ { [ html-element? ] [ name>> token name>> sequence= ] } 1&& ] find-last drop [
        dup stack nth token >>end-tag drop
        stack shorten
        token name>> formatting-marker-elements member? [ document clear-formatting ] when
    ] when* ;

:: implied-element ( document name -- )
    document <tag> name >>name insert-element ;

: html-space? ( obj -- ? ) "\t\n\f\r\s" member? ;

DEFER: tree-insert

:: mark-end-tag ( document token -- )
    document open-elements>> [ name>> token name>> = ] find-last nip
    [ token >>end-tag drop ] when* ;

! Namespace-aware names are used for foreign attributes; HTML attributes
! retain their existing string keys.
TUPLE: foreign-attribute prefix name namespace ;

CONSTANT: svg-tag-adjustments H{
    { "altglyph" "altGlyph" }
    { "altglyphdef" "altGlyphDef" }
    { "altglyphitem" "altGlyphItem" }
    { "animatecolor" "animateColor" }
    { "animatemotion" "animateMotion" }
    { "animatetransform" "animateTransform" }
    { "clippath" "clipPath" }
    { "feblend" "feBlend" }
    { "fecolormatrix" "feColorMatrix" }
    { "fecomponenttransfer" "feComponentTransfer" }
    { "fecomposite" "feComposite" }
    { "feconvolvematrix" "feConvolveMatrix" }
    { "fediffuselighting" "feDiffuseLighting" }
    { "fedisplacementmap" "feDisplacementMap" }
    { "fedistantlight" "feDistantLight" }
    { "fedropshadow" "feDropShadow" }
    { "feflood" "feFlood" }
    { "fefunca" "feFuncA" }
    { "fefuncb" "feFuncB" }
    { "fefuncg" "feFuncG" }
    { "fefuncr" "feFuncR" }
    { "fegaussianblur" "feGaussianBlur" }
    { "feimage" "feImage" }
    { "femerge" "feMerge" }
    { "femergenode" "feMergeNode" }
    { "femorphology" "feMorphology" }
    { "feoffset" "feOffset" }
    { "fepointlight" "fePointLight" }
    { "fespecularlighting" "feSpecularLighting" }
    { "fespotlight" "feSpotLight" }
    { "fetile" "feTile" }
    { "feturbulence" "feTurbulence" }
    { "foreignobject" "foreignObject" }
    { "glyphref" "glyphRef" }
    { "lineargradient" "linearGradient" }
    { "radialgradient" "radialGradient" }
    { "textpath" "textPath" }
}

CONSTANT: svg-attribute-adjustments H{
    { "attributename" "attributeName" }
    { "attributetype" "attributeType" }
    { "basefrequency" "baseFrequency" }
    { "baseprofile" "baseProfile" }
    { "calcmode" "calcMode" }
    { "clippathunits" "clipPathUnits" }
    { "diffuseconstant" "diffuseConstant" }
    { "edgemode" "edgeMode" }
    { "filterunits" "filterUnits" }
    { "glyphref" "glyphRef" }
    { "gradienttransform" "gradientTransform" }
    { "gradientunits" "gradientUnits" }
    { "kernelmatrix" "kernelMatrix" }
    { "kernelunitlength" "kernelUnitLength" }
    { "keypoints" "keyPoints" }
    { "keysplines" "keySplines" }
    { "keytimes" "keyTimes" }
    { "lengthadjust" "lengthAdjust" }
    { "limitingconeangle" "limitingConeAngle" }
    { "markerheight" "markerHeight" }
    { "markerunits" "markerUnits" }
    { "markerwidth" "markerWidth" }
    { "maskcontentunits" "maskContentUnits" }
    { "maskunits" "maskUnits" }
    { "numoctaves" "numOctaves" }
    { "pathlength" "pathLength" }
    { "patterncontentunits" "patternContentUnits" }
    { "patterntransform" "patternTransform" }
    { "patternunits" "patternUnits" }
    { "pointsatx" "pointsAtX" }
    { "pointsaty" "pointsAtY" }
    { "pointsatz" "pointsAtZ" }
    { "preservealpha" "preserveAlpha" }
    { "preserveaspectratio" "preserveAspectRatio" }
    { "primitiveunits" "primitiveUnits" }
    { "refx" "refX" }
    { "refy" "refY" }
    { "repeatcount" "repeatCount" }
    { "repeatdur" "repeatDur" }
    { "requiredextensions" "requiredExtensions" }
    { "requiredfeatures" "requiredFeatures" }
    { "specularconstant" "specularConstant" }
    { "specularexponent" "specularExponent" }
    { "spreadmethod" "spreadMethod" }
    { "startoffset" "startOffset" }
    { "stddeviation" "stdDeviation" }
    { "stitchtiles" "stitchTiles" }
    { "surfacescale" "surfaceScale" }
    { "systemlanguage" "systemLanguage" }
    { "tablevalues" "tableValues" }
    { "targetx" "targetX" }
    { "targety" "targetY" }
    { "textlength" "textLength" }
    { "viewbox" "viewBox" }
    { "viewtarget" "viewTarget" }
    { "xchannelselector" "xChannelSelector" }
    { "ychannelselector" "yChannelSelector" }
    { "zoomandpan" "zoomAndPan" }
}

CONSTANT: foreign-attribute-adjustments H{
    { "xlink:actuate" { "xlink" "actuate" } }
    { "xlink:arcrole" { "xlink" "arcrole" } }
    { "xlink:href" { "xlink" "href" } }
    { "xlink:role" { "xlink" "role" } }
    { "xlink:show" { "xlink" "show" } }
    { "xlink:title" { "xlink" "title" } }
    { "xlink:type" { "xlink" "type" } }
    { "xml:lang" { "xml" "lang" } }
    { "xml:space" { "xml" "space" } }
    { "xmlns" { f "xmlns" } }
    { "xmlns:xlink" { "xmlns" "xlink" } }
}

: ascii-downcase ( string -- string' )
    [ dup CHAR: A CHAR: Z between? [ 0x20 + ] when ] map ;

: attribute-namespace ( prefix/f -- namespace )
    { { "xlink" [ xlink-namespace ] } { "xml" [ xml-namespace ] }
      [ drop xmlns-namespace ] } case ;

: adjust-foreign-attribute ( name -- name' )
    dup foreign-attribute-adjustments at [
        nip first2 foreign-attribute new swap >>name swap >>prefix
        dup prefix>> attribute-namespace >>namespace
    ] when* ;

:: adjust-foreign-element ( element namespace -- element )
    namespace svg-namespace = [
        element dup name>> svg-tag-adjustments at [ >>name ] when* drop
    ] when
    element attributes>> [
        first2 swap
        namespace svg-namespace = [
            dup svg-attribute-adjustments at [ nip ] when*
        ] when
        namespace mathml-namespace = over "definitionurl" = and [ drop "definitionURL" ] when
        adjust-foreign-attribute swap 2array
    ] map element swap >>attributes namespace >>namespace ;

:: insert-foreign-element ( document element namespace -- )
    document element namespace adjust-foreign-element insert-element ;

: mathml-text-integration-point? ( element -- ? )
    { [ namespace>> mathml-namespace = ] [ name>> { "mi" "mo" "mn" "ms" "mtext" } member? ] } 1&& ;

: html-integration-point? ( element -- ? )
    {
        [ { [ namespace>> svg-namespace = ] [ name>> { "foreignObject" "desc" "title" } member? ] } 1&& ]
        [ { [ namespace>> mathml-namespace = ] [ name>> "annotation-xml" = ]
            [ attributes>> "encoding" of [ ascii-downcase { "text/html" "application/xhtml+xml" } member? ] [ f ] if* ]
        } 1&& ]
    } 1|| ;

:: foreign-token? ( document obj -- ? )
    document open-elements>> ?last [
        :> current
        current html-element? not obj f = not and
        current mathml-text-integration-point? obj integer? and not and
        current mathml-text-integration-point?
        obj tag? [ obj name>> { "mglyph" "malignmark" } member? not ] [ f ] if and not and
        current html-integration-point? obj tag? obj integer? or and not and
        current namespace>> mathml-namespace = current name>> "annotation-xml" = and
        obj "svg" start-tag-named? and not and
    ] [ f ] if* ;

CONSTANT: scope-boundaries {
    "applet" "caption" "html" "table" "td" "th" "marquee" "object" "select" "template"
}
CONSTANT: block-elements {
    "address" "article" "aside" "blockquote" "center" "details" "dialog"
    "dir" "div" "dl" "fieldset" "figcaption" "figure" "footer" "header"
    "hgroup" "main" "menu" "nav" "ol" "p" "search" "section" "summary" "ul"
}
CONSTANT: heading-elements { "h1" "h2" "h3" "h4" "h5" "h6" }
CONSTANT: implied-end-elements { "dd" "dt" "li" "optgroup" "option" "p" "rb" "rp" "rt" "rtc" }

:: element-in-scope? ( document name boundaries -- ? )
    document open-elements>> [
        dup html-element? [ name>> dup name = swap boundaries member? or ] [
            { [ mathml-text-integration-point? ]
              [ { [ namespace>> mathml-namespace = ] [ name>> "annotation-xml" = ] } 1&& ]
              [ { [ namespace>> svg-namespace = ] [ name>> { "foreignObject" "desc" "title" } member? ] } 1&& ]
            } 1|| "td" boundaries member? and
        ] if
    ] find-last nip [ { [ html-element? ] [ name>> name = ] } 1&& ] [ f ] if* ;

:: generate-implied-end-tags ( document except -- )
    document open-elements>> :> stack
    [ stack ?last [ { [ html-element? ] [ name>> dup except = not swap implied-end-elements member? and ] } 1&& ] [ f ] if* ] [
        stack pop drop
    ] while ;

:: close-paragraph ( document -- )
    document "p" scope-boundaries "button" suffix element-in-scope? [
        document "p" generate-implied-end-tags
        document <end-tag> "p" >>name close-element
    ] when ;

:: close-list-item ( document name -- )
    document open-elements>> [
        name>> dup name = swap
        { "html" "table" "td" "th" "applet" "object" "marquee" "template" "ol" "ul" "dl" } member? or
    ] find-last nip [ name>> name = ] [ f ] if* [
        document <end-tag> name >>name close-element
    ] when ;

CONSTANT: formatting-elements { "a" "b" "big" "code" "em" "font" "i" "nobr" "s" "small" "strike" "strong" "tt" "u" }
CONSTANT: special-html-elements {
    "address" "applet" "area" "article" "aside" "base" "basefont" "bgsound"
    "blockquote" "body" "br" "button" "caption" "center" "col" "colgroup"
    "dd" "details" "dialog" "dir" "div" "dl" "dt" "embed" "fieldset" "figcaption"
    "figure" "footer" "form" "frame" "frameset" "h1" "h2" "h3" "h4" "h5" "h6"
    "head" "header" "hgroup" "hr" "html" "iframe" "img" "input" "keygen" "li"
    "link" "listing" "main" "marquee" "menu" "meta" "nav" "noembed" "noframes"
    "noscript" "object" "ol" "p" "param" "plaintext" "pre" "script" "search"
    "section" "select" "source" "style" "summary" "table" "tbody" "td" "template"
    "textarea" "tfoot" "th" "thead" "title" "tr" "track" "ul" "wbr" "xmp"
}

: special-element? ( element -- ? )
    {
        [ { [ html-element? ] [ name>> special-html-elements member? ] } 1&& ]
        [ mathml-text-integration-point? ]
        [ { [ namespace>> mathml-namespace = ] [ name>> "annotation-xml" = ] } 1&& ]
        [ { [ namespace>> svg-namespace = ] [ name>> { "foreignObject" "desc" "title" } member? ] } 1&& ]
    } 1|| ;

: clone-formatting-element ( element -- clone )
    [ name>> ] [ attributes>> clone ] [ namespace>> ] tri
    <tag> swap >>namespace swap >>attributes swap >>name ;

:: formatting-index ( document name -- index/f )
    document active-formatting-elements>> :> entries
    entries [ dup f = [ drop t ] [ name>> name = ] if ] find-last drop
    dup [ dup entries nth f = [ drop f ] when ] when ;

: formatting-equivalent? ( a b -- ? )
    { [ [ name>> ] bi@ = ] [ [ namespace>> ] bi@ = ]
      [ [ attributes>> ] bi@ assoc= ] } 2&& ;

:: push-formatting ( document element -- )
    document active-formatting-elements>> :> entries
    entries [ f = ] find-last drop [ 1 + ] [ 0 ] if* :> start
    entries length <iota>
    [ dup start >= [ entries nth element formatting-equivalent? ] [ drop f ] if ] filter :> matches
    matches length 3 >= [ matches first entries remove-nth! drop ] when
    element entries push ;

:: reconstruct-formatting ( document -- )
    document active-formatting-elements>> :> entries
    document open-elements>> :> stack
    entries length :> i!
    [ i 0 > [ i 1 - entries nth dup f = [ drop f ] [ stack node-member? not ] if ] [ f ] if ] [
        i 1 - i!
    ] while
    [ i entries length < ] [
        i entries nth clone-formatting-element :> element
        document element insert-element
        element i entries set-nth
        i 1 + i!
    ] while ;

:: node-in-scope? ( document target -- ? )
    document open-elements>> [
        dup target eq? [ drop t ] [
            dup html-element? [ name>> scope-boundaries member? ] [
                { [ mathml-text-integration-point? ] [ html-integration-point? ]
                  [ { [ namespace>> mathml-namespace = ] [ name>> "annotation-xml" = ] } 1&& ]
                } 1||
            ] if
        ] if
    ] find-last nip target eq? ;

:: other-formatting-end-tag ( document token -- )
    document open-elements>> [
        { [ { [ html-element? ] [ name>> token name>> = ] } 1&& ] [ special-element? ] } 1||
    ] find-last nip [
        dup html-element? over name>> token name>> = and [
            drop document token name>> generate-implied-end-tags
            document token close-element
        ] [ drop ] if
    ] when* ;

DEFER: adoption-agency

! Reconstruct only for the start tags whose HTML rules require it.
CONSTANT: non-reconstructing-elements {
    "address" "article" "aside" "blockquote" "center" "details" "dialog" "dir"
    "div" "dl" "fieldset" "figcaption" "figure" "footer" "header" "hgroup"
    "main" "menu" "nav" "ol" "p" "search" "section" "summary" "ul"
    "h1" "h2" "h3" "h4" "h5" "h6" "pre" "listing" "form" "li" "dd" "dt"
    "plaintext" "table" "hr" "textarea" "iframe" "noembed" "base" "basefont"
    "bgsound" "link" "meta" "noframes" "script" "style" "title" "template"
    "param" "source" "track"
}

:: prepare-formatting-start ( document element -- )
    element name>> :> name
    name "a" = [
        document "a" formatting-index [
            document active-formatting-elements>> nth :> previous
            document <end-tag> "a" >>name adoption-agency
            previous document active-formatting-elements>> remove-node
            previous document open-elements>> remove-node
        ] when*
    ] when
    name non-reconstructing-elements member? [ document reconstruct-formatting ] unless
    name "nobr" = document "nobr" scope-boundaries element-in-scope? and [
        document <end-tag> "nobr" >>name adoption-agency
        document reconstruct-formatting
    ] when ;

:: merge-element-attributes ( element token -- )
    element attributes>> :> attributes
    token attributes>> [
        dup first attributes key? [ drop ] [ attributes push ] if
    ] each ;

:: merge-body-attributes ( document token -- )
    document template-insertion-modes>> empty?
    document open-elements>> length 1 > and [
        document open-elements>> second :> body
        body html-element? body name>> "body" = and [
            body token merge-element-attributes
            document f >>frameset-ok? drop
        ] when
    ] when ;

:: close-heading ( document token -- )
    heading-elements [ document swap scope-boundaries element-in-scope? ] any? [
        document "" generate-implied-end-tags
        document open-elements>> :> stack
        stack [ { [ html-element? ] [ name>> heading-elements member? ] } 1&& ] find-last drop [
            dup stack nth token >>end-tag drop stack shorten
        ] when*
    ] when ;

CONSTANT: frameset-blocking-elements {
    "pre" "listing" "li" "dd" "dt" "button" "applet" "marquee" "object"
    "table" "area" "br" "embed" "img" "keygen" "wbr" "hr" "textarea"
    "xmp" "iframe" "select"
}

:: update-frameset-for-element ( document element -- )
    element name>> frameset-blocking-elements member?
    element name>> "input" = [
        element attributes>> "type" of [ ascii-downcase "hidden" = ] [ f ] if* not
    ] [ f ] if or [ document f >>frameset-ok? drop ] when ;

:: update-frameset-for-character ( document char -- )
    char html-space? not [ document f >>frameset-ok? drop ] when ;

:: start-body-frameset ( document element -- )
    document open-elements>> :> stack
    document frameset-ok?>> stack length 1 > and [
        stack second :> body
        body html-element? body name>> "body" = and [
            body stack first children>> remove! drop
            1 stack shorten
            document element insert-element
            document in-frameset-mode >>insertion-mode drop
        ] when
    ] when ;

:: adoption-foster-node ( document node -- )
    document node document open-elements>> first foster-node ;

:: adoption-insert ( document node ancestor -- )
    node detach-node
    ancestor html-element? ancestor name>> { "table" "tbody" "tfoot" "thead" "tr" } member? and [
        document node adoption-foster-node
    ] [ node ancestor attach-node ] if ;

:: adoption-inner-loop ( document formatting block -- last-node bookmark )
    document active-formatting-elements>> :> entries
    document open-elements>> :> stack
    formatting entries node-index :> bookmark!
    block stack node-index :> cursor!
    block :> last-node!
    0 :> count!
    f :> done!
    [ done not ] [
        cursor 1 - cursor!
        cursor stack nth :> node
        node formatting eq? [ t done! ] [
            count 1 + count!
            node entries node-index :> entry-index!
            count 3 > entry-index f = not and [
                entry-index bookmark < [ bookmark 1 - bookmark! ] when
                node entries remove-node f entry-index!
            ] when
            entry-index [
                drop node clone-formatting-element :> replacement
                replacement entry-index entries set-nth
                replacement cursor stack set-nth
                last-node block eq? [ entry-index 1 + bookmark! ] when
                last-node detach-node
                last-node replacement attach-node
                replacement last-node!
            ] [ node stack remove-node ] if*
        ] if
    ] while last-node bookmark ;

:: move-children ( source target -- )
    source children>> clone [
        dup tag? [ dup detach-node ] when
        target attach-node
    ] each
    source children>> delete-all ;

:: replace-formatting-entry ( formatting replacement bookmark entries -- )
    formatting entries node-index bookmark < [ bookmark 1 - ] [ bookmark ] if :> index
    formatting entries remove-node
    replacement index entries insert-nth! ;

:: replace-adopted-element ( formatting replacement block stack -- )
    formatting stack remove-node
    replacement block stack node-index 1 + stack insert-nth! ;

:: adopt-formatting-block ( document formatting block index -- )
    document open-elements>> :> stack
    index 1 - stack nth :> ancestor
    document formatting block adoption-inner-loop :> bookmark :> last-node
    document last-node ancestor adoption-insert
    formatting clone-formatting-element :> replacement
    block replacement move-children
    replacement block attach-node
    formatting replacement bookmark document active-formatting-elements>> replace-formatting-entry
    formatting replacement block stack replace-adopted-element ;

:: adopt-open-formatting ( document formatting index -- continue? )
    document open-elements>> :> stack
    index 1 + stack [ special-element? ] find-from nip [
        document formatting rot index adopt-formatting-block t
    ] [
        index stack shorten
        formatting document active-formatting-elements>> remove-node f
    ] if* ;

:: adopt-formatting ( document formatting -- continue? )
    formatting document open-elements>> node-index [
        :> index
        document formatting node-in-scope? [
            document formatting index adopt-open-formatting
        ] [ "formatting-element-out-of-scope" report-parse-error f ] if
    ] [
        formatting document active-formatting-elements>> remove-node
        "formatting-element-not-open" report-parse-error f
    ] if* ;

:: adoption-pass ( document token -- continue? )
    document token name>> formatting-index [
        document active-formatting-elements>> nth
        document swap adopt-formatting
    ] [ document token other-formatting-end-tag f ] if* ;

:: adoption-agency ( document token -- )
    document open-elements>> :> stack
    document active-formatting-elements>> :> entries
    stack ?last [
        { [ html-element? ] [ name>> token name>> = ] [ entries node-member? not ] } 1&&
    ] [ f ] if* [ stack pop drop ] [
        0 :> count!
        t :> continue?!
        [ count 8 < continue? and ] [
            count 1 + count!
            document token adoption-pass continue?!
        ] while
    ] if ;

! Forms inside templates do not change the document's form pointer.
: parsing-template? ( document -- ? ) template-insertion-modes>> empty? not ;

: form-start-ignored? ( document -- ? )
    { [ form-element-pointer>> ] [ parsing-template? not ] } 1&& ;

:: insert-form ( document element -- )
    document element insert-element
    document parsing-template? [ document element >>form-element-pointer drop ] unless ;

:: start-body-form ( document element -- )
    document form-start-ignored? [ "unexpected-form-start-tag" report-parse-error ] [
        document close-paragraph
        document element insert-form
    ] if ;

:: end-body-form ( document token -- )
    document parsing-template? [
        document "form" scope-boundaries element-in-scope? [
            document "" generate-implied-end-tags
            document "form" current-element-named? [ "unexpected-form-end-tag" report-parse-error ] unless
            document token close-element
        ] [ "unexpected-form-end-tag" report-parse-error ] if
    ] [
        document form-element-pointer>> :> form
        document f >>form-element-pointer drop
        form [ document form node-in-scope? ] [ f ] if [
            document "" generate-implied-end-tags
            document open-elements>> last form eq? [ "unexpected-form-end-tag" report-parse-error ] unless
            form token >>end-tag drop
            form document open-elements>> remove-node
        ] [ "unexpected-form-end-tag" report-parse-error ] if
    ] if ;

:: start-body-element ( document element -- )
    element name>> "image" = [ element "img" >>name drop ] when
    element name>> :> name
    document element update-frameset-for-element
    name "button" = document "button" scope-boundaries element-in-scope? and [
        document "" generate-implied-end-tags
        document <end-tag> "button" >>name close-element
    ] when
    name "table" = document quirks-mode?>> not and [ document close-paragraph ] when
    name block-elements member? name heading-elements member? or
    name { "pre" "listing" "hr" "xmp" "plaintext" } member? or [ document close-paragraph ] when
    name { "li" "dd" "dt" } member? [
        document name close-list-item
        name { "dd" "dt" } member? [
            document name "dd" = [ "dt" ] [ "dd" ] if close-list-item
        ] when
        document close-paragraph
    ] when
    name heading-elements member? [
        document open-elements>> ?last [ name>> heading-elements member? ] [ f ] if* [
            document open-elements>> pop drop
        ] when
    ] when
    name { "option" "optgroup" } member? [
        document "option" current-element-named? [
            document open-elements>> pop drop
        ] when
        name "optgroup" = [
            document "optgroup" current-element-named? [
                document open-elements>> pop drop
            ] when
        ] when
    ] when
    name { "rb" "rp" "rt" "rtc" } member? [ document "" generate-implied-end-tags ] when
    document element prepare-formatting-start
    name { "svg" "math" } member? [
        document element name "svg" = [ svg-namespace ] [ mathml-namespace ] if insert-foreign-element
    ] [ document element insert-element ] if
    name formatting-elements member? [ document element push-formatting ] when
    name { "pre" "listing" "textarea" } member? [ document t >>skip-leading-newline? drop ] when ;

:: end-body-element ( document token -- )
    token name>> :> name
    name {
        { [ dup formatting-elements member? ] [ drop document token adoption-agency ] }
        { [ dup heading-elements member? ] [ drop document token close-heading ] }
        { [ dup "form" = ] [ drop document token end-body-form ] }
        { [ dup "br" = ] [
            drop document <tag> "br" >>name start-body-element
        ] }
        { [ dup "p" = ] [
            drop document "p" scope-boundaries "button" suffix element-in-scope? [
                document "p" implied-element
            ] unless
            document close-paragraph
        ] }
        [
            drop document name scope-boundaries element-in-scope? [
                document name generate-implied-end-tags
                document token close-element
            ] when
        ]
    } cond ;

:: ordinary-body-token ( document obj -- document )
    obj {
        { [ dup doctype? ] [ drop ] }
        { [ dup tag? ] [
            dup name>> {
                { "body" [ document swap merge-body-attributes ] }
                { "html" [ drop ] }
                { "head" [ drop ] }
                { "frame" [ drop ] }
                { "frameset" [ document swap start-body-frameset ] }
                { "form" [ document swap start-body-form ] }
                [ drop document swap start-body-element ]
            } case
        ] }
        { [ dup end-tag? ] [
            dup name>> { "body" "html" } member? [
                document template-insertion-modes>> empty? [
                    document over name>> "body" = [ after-body-mode ] [ after-after-body-mode ] if >>insertion-mode drop
                    document swap mark-end-tag
                ] [ drop ] if
            ] [ document swap end-body-element ] if
        ] }
        { [ dup f = ] [ drop ] }
        [
            dup integer? [ document reconstruct-formatting document over update-frameset-for-character ] when
            document swap append-node
        ]
    } cond
    document ;

CONSTANT: table-context-elements { "table" "caption" "colgroup" "tbody" "thead" "tfoot" "tr" "td" "th" }
CONSTANT: table-section-elements { "tbody" "thead" "tfoot" }
CONSTANT: table-cell-elements { "td" "th" }

: table-context ( document -- name/f )
    dup open-elements>> [ html-element? ] filter [ name>> ] map reverse
    [ dup table-context-elements member? swap "template" = or ] find nip
    dup "template" = [
        drop insertion-mode>> {
            { in-table-mode [ "table" ] }
            { in-table-body-mode [ "tbody" ] }
            { in-row-mode [ "tr" ] }
            { in-column-group-mode [ "colgroup" ] }
            [ drop f ]
        } case
    ] [ nip ] if ;

:: clear-to-table-context ( document names -- )
    document open-elements>> :> stack
    [ stack ?last [ name>> names { "template" "html" } append member? not ] [ f ] if* ] [ stack pop drop ] while ;

:: close-table-element ( document name -- )
    document name { "html" "template" } element-in-scope? [
        document <end-tag> name >>name close-element
    ] when ;

:: flush-table-characters ( document -- )
    document pending-table-characters>> :> characters
    characters empty? [
        characters [ html-space? ] all? not document swap >>fostering-parent? drop
        document fostering-parent?>> [ document reconstruct-formatting ] when
        characters [ document swap append-node ] each
        document f >>fostering-parent? drop
        characters delete-all
    ] unless ;

DEFER: body-token
DEFER: table-token

:: foster-body-token ( document obj -- document )
    document t >>fostering-parent? obj ordinary-body-token
    f >>fostering-parent? ;

:: template-table-start-ignored? ( document obj -- ? )
    document table-context :> context
    document template-insertion-modes>> empty? not
    context { "tr" "tbody" } member? and
    obj name>> { "caption" "col" "colgroup" "tbody" "thead" "tfoot" } member? and
    document context { "html" "template" } element-in-scope? not and ;

:: start-table-form ( document element -- document )
    "form-start-tag-in-table" report-parse-error
    document form-start-ignored? [
        document element insert-form
        document open-elements>> pop drop
    ] unless document ;

: hidden-input? ( element -- ? )
    attributes>> "type" of [ ascii-downcase "hidden" = ] [ f ] if* ;

:: start-table-input ( document element -- document )
    element hidden-input? [
        "hidden-input-in-table" report-parse-error
        document element insert-element document
    ] [ document element foster-body-token ] if ;

:: table-start-tag ( document obj -- document )
    document obj template-table-start-ignored? [ document ] [
        obj name>> {
            { "form" [ document obj start-table-form ] }
            { "input" [ document obj start-table-input ] }
            { "caption" [
                document { "table" } clear-to-table-context
                document obj insert-element document
            ] }
            { "colgroup" [
                document { "table" } clear-to-table-context
                document obj insert-element document
            ] }
            { "col" [
                document table-context "colgroup" = [
                    document { "table" } clear-to-table-context
                    document "colgroup" implied-element
                ] unless
                document obj insert-element document
            ] }
            { "tr" [
                document table-context "tr" = [ document "tr" close-table-element ] when
                document table-context table-section-elements member? [
                    document { "table" } clear-to-table-context
                    document "tbody" implied-element
                ] unless
                document table-section-elements clear-to-table-context
                document obj insert-element document
            ] }
            { "table" [
                document "table" { "html" "template" } element-in-scope? [
                    document "table" close-table-element
                    document obj body-token
                ] [ document ] if
            ] }
            [
                dup table-section-elements member? [
                    drop document { "table" } clear-to-table-context
                    document obj insert-element document
                ] [
                    table-cell-elements member? [
                        document table-context "tr" = [
                            document <tag> "tr" >>name table-start-tag drop
                        ] unless
                        document { "tr" } clear-to-table-context
                        document obj insert-element document
                    ] [
                        obj name>> { "script" "style" "template" } member? [
                            document obj ordinary-body-token
                        ] [ document obj foster-body-token ] if
                    ] if
                ] if
            ]
        } case
    ] if ;

:: table-end-tag ( document obj -- document )
    obj name>> :> name
    name "table" = [
        document "table" close-table-element
    ] [
        name { "tbody" "thead" "tfoot" "tr" "colgroup" } member? [
            document name { "html" "table" "template" } element-in-scope? [
                document name close-table-element
            ] when
        ] [
            name { "body" "caption" "col" "html" "td" "th" } member? [
                document obj foster-body-token drop
            ] unless
        ] if
    ] if document ;

:: table-cell-token ( document obj context -- document )
    obj tag? [ obj name>> { "caption" "col" "colgroup" "tbody" "td" "tfoot" "th" "thead" "tr" } member? ] [ f ] if
    obj end-tag? [ obj name>> { "table" "tbody" "thead" "tfoot" "tr" "td" "th" } member? ] [ f ] if or [
        obj end-tag? [
            document obj name>> { "html" "table" "template" } element-in-scope?
        ] [ t ] if [
            document context generate-implied-end-tags
            document context close-table-element
            document obj body-token
        ] [ document ] if
    ] [ document obj ordinary-body-token ] if ;

:: table-caption-token ( document obj -- document )
    obj tag? [ obj name>> table-context-elements member? ] [ f ] if
    obj end-tag? [ obj name>> { "table" "caption" } member? ] [ f ] if or [
        document "caption" generate-implied-end-tags
        document "caption" close-table-element
        obj "caption" end-tag-named? [
            document
        ] [ document obj body-token ] if
    ] [ document obj ordinary-body-token ] if ;

:: leave-table-colgroup ( document obj -- document )
    document "colgroup" close-table-element
    document "template" current-element-named? [
        document in-table-mode >>insertion-mode drop
        document template-insertion-modes>> pop drop
        in-table-mode document template-insertion-modes>> push
    ] when
    obj "colgroup" end-tag-named? [ document ] [ document obj body-token ] if ;

:: table-colgroup-token ( document obj -- document )
    {
        { [ obj "col" start-tag-named? obj misc-node? or obj html-space? or obj f = or ]
          [ document obj ordinary-body-token ] }
        { [ obj "col" end-tag-named? obj "html" start-tag-named? or
            document "template" current-element-named? or ] [ document ] }
        [ document obj leave-table-colgroup ]
    } cond ;

:: ordinary-table-token ( document obj -- document )
    obj {
        { [ dup tag? ] [ document swap table-start-tag ] }
        { [ dup end-tag? ] [ document swap table-end-tag ] }
        { [ dup misc-node? ] [ document swap ordinary-body-token ] }
        { [ dup doctype? ] [ drop document ] }
        { [ dup f = ] [ drop document ] }
        [ document swap foster-body-token ]
    } cond ;

:: table-token ( document obj -- document )
    document table-context :> context
    {
        { [ context table-cell-elements member? ] [ document obj context table-cell-token ] }
        { [ context "caption" = ] [ document obj table-caption-token ] }
        { [ context "colgroup" = ] [ document obj table-colgroup-token ] }
        [ document obj ordinary-table-token ]
    } cond ;

:: body-token ( document obj -- document )
    document table-context [ document obj table-token ] [
        document template-insertion-modes>> empty? not
        obj tag? [ obj name>> { "caption" "col" "colgroup" "tbody" "td" "tfoot" "th" "thead" "tr" } member? ] [ f ] if and [
            document
        ] [ document obj ordinary-body-token ] if
    ] if ;

:: ignored-early-end-tag? ( document obj -- ? )
    obj end-tag?
    document insertion-mode>> { before-html-mode before-head-mode after-head-mode } member? and
    obj end-tag? [ obj name>> { "head" "body" "html" "br" } member? not ] [ f ] if and ;

CONSTANT: frameset-modes { in-frameset-mode after-frameset-mode after-after-frameset-mode }

:: frameset-token ( document obj -- document )
    document insertion-mode>> :> mode
    obj {
        { [ dup misc-node? ] [
            mode after-after-frameset-mode = [ document tree>> push ] [ document swap append-node ] if
        ] }
        { [ dup html-space? ] [ document swap append-node ] }
        { [ dup tag? ] [
            dup name>> {
                { "noframes" [ document swap insert-element ] }
                { "frameset" [
                    mode in-frameset-mode = [ document swap insert-element ] [ drop ] if
                ] }
                { "frame" [
                    mode in-frameset-mode = [ document swap insert-element ] [ drop ] if
                ] }
                [ 2drop "unexpected-token-in-frameset" report-parse-error ]
            } case
        ] }
        { [ dup end-tag? ] [
            dup name>> {
                { "noframes" [ document swap close-element ] }
                { "frameset" [
                    mode in-frameset-mode = document open-elements>> length 1 > and [
                        document swap close-element
                        document open-elements>> last name>> "frameset" = [
                            document after-frameset-mode >>insertion-mode drop
                        ] unless
                    ] [ drop ] if
                ] }
                { "html" [
                    drop mode after-frameset-mode = [
                        document after-after-frameset-mode >>insertion-mode drop
                    ] when
                ] }
                [ 2drop "unexpected-token-in-frameset" report-parse-error ]
            } case
        ] }
        { [ dup f = ] [ drop ] }
        [ drop "unexpected-token-in-frameset" report-parse-error ]
    } cond document ;

:: initial-token ( document obj -- document )
    {
        { [ obj doctype? ] [ document obj >>tree-doctype before-html-mode >>insertion-mode ] }
        { [ obj misc-node? ] [ document obj append-node document ] }
        { [ obj html-space? ] [ document ] }
        [ document t >>quirks-mode? before-html-mode >>insertion-mode obj tree-insert ]
    } cond ;

:: before-html-token ( document obj -- document )
    {
        { [ obj misc-node? ] [ document obj append-node document ] }
        { [ obj html-space? ] [ document ] }
        { [ obj "html" start-tag-named? ] [
            document obj insert-element document before-head-mode >>insertion-mode
        ] }
        [ document "html" implied-element
          document before-head-mode >>insertion-mode obj tree-insert ]
    } cond ;

:: before-head-token ( document obj -- document )
    {
        { [ obj html-space? ] [ document ] }
        { [ obj misc-node? ] [ document obj append-node document ] }
        { [ obj "head" start-tag-named? ] [
            document obj insert-element
            document obj >>head-element-pointer in-head-mode >>insertion-mode
        ] }
        [ document "head" implied-element
          document dup open-elements>> last >>head-element-pointer
          in-head-mode >>insertion-mode obj tree-insert ]
    } cond ;

:: in-head-token ( document obj -- document )
    obj {
        { [ dup html-space? ] [ document swap append-node document ] }
        { [ dup misc-node? ] [ document swap append-node document ] }
        { [ dup doctype? ] [ drop document ] }
        { [ dup tag? [ dup name>> {
            "base" "basefont" "bgsound" "link" "meta" "title"
            "style" "script" "noscript" "noframes" "template"
        } member? ] [ f ] if ] [
            document swap insert-element document
        ] }
        { [ dup end-tag? [ dup name>> { "head" "body" "html" "br" } member? not ] [ f ] if ] [
            document swap close-element document
        ] }
        { [ dup end-tag? [ dup name>> "head" = ] [ f ] if ] [
            document swap close-element
            document after-head-mode >>insertion-mode
        ] }
        [
            document <end-tag> "head" >>name close-element
            document after-head-mode >>insertion-mode swap tree-insert
        ]
    } cond ;

:: after-head-token ( document obj -- document )
    {
        { [ obj html-space? obj misc-node? or ] [ document obj append-node document ] }
        { [ obj "body" start-tag-named? ] [
            document obj insert-element document in-body-mode >>insertion-mode f >>frameset-ok?
        ] }
        [ document "body" implied-element
          document in-body-mode >>insertion-mode t >>frameset-ok? obj tree-insert ]
    } cond ;

:: after-body-token ( document obj -- document )
    obj misc-node? [
        obj document open-elements>> first children>> push document
    ] [
        obj "html" end-tag-named? [
            document obj mark-end-tag
            document after-after-body-mode >>insertion-mode
        ] [
            obj html-space? obj doctype? or [ document obj body-token ] [
                document in-body-mode >>insertion-mode obj tree-insert
            ] if
        ] if
    ] if ;

:: after-after-body-token ( document obj -- document )
    obj misc-node? [ obj document tree>> push document ] [
        obj html-space? obj doctype? or [ document obj body-token ] [
            document in-body-mode >>insertion-mode obj tree-insert
        ] if
    ] if ;

:: (html-tree-insert) ( document obj -- document )
    document obj ignored-early-end-tag? [ document ] [
        document insertion-mode>> {
            { initial-mode [ document obj initial-token ] }
            { before-html-mode [ document obj before-html-token ] }
            { before-head-mode [ document obj before-head-token ] }
            { in-head-mode [ document obj in-head-token ] }
            { after-head-mode [ document obj after-head-token ] }
            { after-body-mode [ document obj after-body-token ] }
            { after-after-body-mode [ document obj after-after-body-token ] }
            [ drop document obj body-token ]
        } case
    ] if ;

! HTML templates have a separate fragment and a stack of insertion modes.
: html-template? ( element -- ? )
    { [ html-element? ] [ name>> "template" = ] } 1&& ;

:: reset-template-insertion-mode ( document -- )
    document open-elements>> [
        { [ html-element? ]
          [ name>> { "template" "head" "body" "html" "table" "td" "th" "tr" "tbody" "thead" "tfoot" "colgroup" "caption" } member? ]
        } 1&&
    ] find-last nip [ name>> ] [ "html" ] if* {
        { "template" [ document template-insertion-modes>> last ] }
        { "head" [ in-head-mode ] }
        { "html" [ after-head-mode ] }
        [ drop in-body-mode ]
    } case document swap >>insertion-mode drop ;

:: start-template ( document element -- document )
    element V{ } clone >>template-contents drop
    document insertion-mode>> after-head-mode = [
        document head-element-pointer>> document open-elements>> push
        document element insert-element
        document open-elements>> length 2 - document open-elements>> remove-nth! drop
    ] [ document element insert-element ] if
    in-template-mode document template-insertion-modes>> push
    document in-template-mode >>insertion-mode f >>frameset-ok? ;

:: end-template ( document token -- document )
    document open-elements>> [ html-template? ] find-last drop [
        drop document "" generate-implied-end-tags
        document token close-element
        document template-insertion-modes>> pop drop
        document reset-template-insertion-mode
    ] [ "unexpected-template-end-tag" report-parse-error ] if*
    document ;

:: template-token ( document obj -- document )
    obj tag? [
        obj name>> { "base" "basefont" "bgsound" "link" "meta" "noframes" "script" "style" "title" } member? [
            document obj insert-element document
        ] [
            obj name>> {
                { "caption" [ in-table-mode ] }
                { "colgroup" [ in-table-mode ] }
                { "tbody" [ in-table-mode ] }
                { "tfoot" [ in-table-mode ] }
                { "thead" [ in-table-mode ] }
                { "col" [ in-column-group-mode ] }
                { "tr" [ in-table-body-mode ] }
                { "td" [ in-row-mode ] }
                { "th" [ in-row-mode ] }
                [ drop in-body-mode ]
            } case :> mode
            document template-insertion-modes>> pop drop
            mode document template-insertion-modes>> push
            document mode >>insertion-mode obj body-token
        ] if
    ] [
        obj end-tag? [
            obj name>> { "script" "style" "title" "noframes" } member? [
                document obj close-element
            ] [ "unexpected-end-tag-in-template" report-parse-error ] if document
        ] [ document obj ordinary-body-token ] if
    ] if ;

DEFER: html-tree-insert
:: html-tree-insert ( document obj -- document )
    {
        { [ obj "html" start-tag-named?
            document open-elements>> empty? not and ] [
            document template-insertion-modes>> empty? [
                document open-elements>> first obj merge-element-attributes
            ] when document
        ] }
        { [ document insertion-mode>> frameset-modes member? ] [
            document obj frameset-token
        ] }
        { [ obj "frameset" start-tag-named?
            document insertion-mode>> after-head-mode = and ] [
            document obj insert-element document in-frameset-mode >>insertion-mode
        ] }
        { [ obj f = document template-insertion-modes>> empty? not and ] [
            "eof-in-template" report-parse-error
            document <end-tag> "template" >>name end-template drop
            document obj html-tree-insert
        ] }
        { [ document insertion-mode>> { initial-mode before-html-mode before-head-mode } member? ] [
            document obj (html-tree-insert)
        ] }
        { [ obj "template" start-tag-named? ] [
            document obj start-template
        ] }
        { [ obj "template" end-tag-named? ] [
            document obj end-template
        ] }
        { [ document insertion-mode>> in-template-mode = ] [
            document obj template-token
        ] }
        [ document obj (html-tree-insert) ]
    } cond ;

CONSTANT: foreign-breakout-elements {
    "b" "big" "blockquote" "body" "br" "center" "code" "dd" "div" "dl" "dt"
    "em" "embed" "h1" "h2" "h3" "h4" "h5" "h6" "head" "hr" "i" "img" "li"
    "listing" "menu" "meta" "nobr" "ol" "p" "pre" "ruby" "s" "small" "span"
    "strong" "strike" "sub" "sup" "table" "tt" "u" "ul" "var"
}

: foreign-breakout? ( obj -- ? )
    {
        [ { [ tag? ] [ name>> foreign-breakout-elements member? ] } 1&& ]
        [ { [ tag? ] [ name>> "font" = ] [ attributes>> keys { "color" "face" "size" } intersects? ] } 1&& ]
        [ { [ end-tag? ] [ name>> { "br" "p" } member? ] } 1&& ]
    } 1|| ;

:: leave-foreign-content ( document -- )
    document open-elements>> :> stack
    [ stack ?last [
        { [ html-element? ] [ mathml-text-integration-point? ] [ html-integration-point? ] } 1|| not
    ] [ f ] if* ] [ stack pop drop ] while ;

:: foreign-end-tag ( document token -- document )
    document open-elements>> :> stack
    stack length 1 - :> i!
    f :> done!
    [ i 0 > done not and ] [
        i stack nth :> node
        node name>> ascii-downcase token name>> = [
            node token >>end-tag drop
            i stack shorten t done!
        ] [
            i 1 - i!
            i stack nth html-element? [
                document token html-tree-insert drop t done!
            ] when
        ] if
    ] while document ;

:: foreign-tree-insert ( document obj -- document )
    obj foreign-breakout? [
        "unexpected-html-token-in-foreign-content" report-parse-error
        document leave-foreign-content
        document obj html-tree-insert
    ] [
        obj {
            { [ dup tag? ] [
                document swap document open-elements>> last namespace>> insert-foreign-element document
            ] }
            { [ dup end-tag? ] [ document swap foreign-end-tag ] }
            { [ dup doctype? ] [ drop document ] }
            [
                dup integer? [ document over update-frameset-for-character ] when
                document swap append-node document
            ]
        } cond
    ] if ;

:: tree-insert ( document obj -- document )
    document obj foreign-token? [
        document obj foreign-tree-insert
    ] [ document obj html-tree-insert ] if ;

MEMO: load-entities ( -- assoc )
    "vocab:html5/entities.json" utf8 file-contents json> ;

MEMO: longest-entity-name ( -- n )
    load-entities keys [ length ] map-maximum 1 - ;

: push-tag-name ( ch document -- ) tag>> name>> push ;
: push-attribute-name ( ch document -- ) attribute-name>> push ;
: push-attribute-value ( ch document -- ) attribute-value>> push ;
: push-comment-token ( ch document -- ) comment-token>> push ;
: push-all-comment-token ( string document -- ) comment-token>> push-all ;

ERROR: invalid-return-state obj ;
: check-return-state ( obj -- return-state )
    dup word? [ invalid-return-state ] unless ;

: current-attribute ( document -- attribute/f )
    [ attribute-name>> >string f like ]
    [ attribute-value>> >string ] bi
    over [ 2array ] [ 2drop f ] if ;

: push-when ( obj/f seq -- )
    over [ push ] [ 2drop ] if ; inline

: reset-attribute ( document -- )
    SBUF" " clone >>attribute-name
    SBUF" " clone >>attribute-value drop ;

:: push-attribute ( document -- )
    document current-attribute [
        :> attribute
        document tag>> attributes>> :> attributes
        attribute first attributes key? [
            "duplicate-attribute" report-parse-error
        ] [ attribute attributes push ] if
    ] when*
    document reset-attribute ;

: emit-eof ( document -- ) dup flush-table-characters f tree-insert drop ;
:: scripted-noscript? ( element document -- ? )
    element name>> "noscript" = document scripting?>> and ;

:: character-blocks-frameset? ( document -- ? )
    document [
        { [ html-element? ]
          [ { [ name>> { "title" "style" "script" "noframes" "noembed" } member? ]
              [ document scripted-noscript? ] } 1|| ]
        } 1&&
    ] current-element-matches? not ;

:: reconstruct-for-character? ( document -- ? )
    document open-elements>> last :> current
    current html-element? [
        current name>> { "title" "textarea" "style" "script" "xmp" "iframe" "noframes" "noembed" "plaintext" } member? not
        current document scripted-noscript? not and
    ] [ current { [ mathml-text-integration-point? ] [ html-integration-point? ] } 1|| ] if ;

:: character-needs-tree-routing? ( document char -- ? )
    {
        [ document insertion-mode>> frameset-modes member?
          document "noframes" current-element-named? not and ]
        [ document insertion-mode>> in-column-group-mode =
          document "template" current-element-named? and ]
        [ document char foreign-token? ]
    } 0|| ;

:: body-character ( document char -- )
    document insertion-mode>> in-body-mode = document character-blocks-frameset? and [
        document char update-frameset-for-character
    ] when
    {
        { [ document char character-needs-tree-routing? ] [ document char tree-insert drop ] }
        { [ document [ { [ html-element? ] [ name>> table-text-elements member? ] } 1&& ] current-element-matches? ]
          [ char document pending-table-characters>> push ] }
        { [ document open-elements>> ?last [ name>> { "html" "head" } member? ] [ t ] if* ]
          [ document char tree-insert drop ] }
        [ document reconstruct-for-character? [ document reconstruct-formatting ] when
          document char append-node ]
    } cond ;

:: emit-null-character ( document -- )
    document CHAR: \0 foreign-token? [
        "unexpected-null-character" report-parse-error
        document CHAR: replacement-character append-node
    ] when ;

:: emit-char ( char document -- )
    char CHAR: \0 = [ document emit-null-character ] [
        document skip-leading-newline?>> char CHAR: \n = and :> skip?
        document f >>skip-leading-newline? drop
        skip? [ document char body-character ] unless
    ] if ;
: emit-string ( string document -- ) [ emit-char ] curry each ;

: emit-tag ( document -- )
    dup flush-table-characters
    f >>skip-leading-newline?
    {
        [ tag>> [ name>> >string ] [ name<< ] bi ]
        [ push-attribute ]
        [ dup tag>> tree-insert drop ]
        [ f >>tag drop ]
    } cleave ;

: emit-end-tag ( document -- ) emit-tag ;

: emit-comment-token ( document -- )
    dup flush-table-characters
    f >>skip-leading-newline?
    [ dup comment-token>> >string <comment> tree-insert drop ]
    [ SBUF" " clone >>comment-token drop ] bi ;

: emit-doctype ( document -- )
    [ doctype>> [ [ >string ] [ "" ] if* ] change-name drop ]
    [ dup doctype>> tree-insert drop ] bi ;

: reset-temporary-buffer ( document -- ) SBUF" " clone >>temporary-buffer drop ;
: ch>new-temporary-buffer ( ch document -- ) [ 1sbuf ] dip temporary-buffer<< ;
: string>new-temporary-buffer ( string document -- ) [ SBUF" " clone-like ] dip temporary-buffer<< ;
: temporary-buffer-last ( document -- ch/f ) temporary-buffer>> ?last ;
: push-temporary-buffer ( ch document -- ) temporary-buffer>> push ;
: push-all-temporary-buffer ( string document -- ) temporary-buffer>> push-all ;

: flush-temporary-buffer ( document -- )
    [ dup temporary-buffer-attribute? [
        [ temporary-buffer>> ] [ attribute-value>> ] bi push-all
    ] [ [ temporary-buffer>> ] keep [ emit-char ] curry each ] if ]
    [ SBUF" " clone >>temporary-buffer drop ] bi ;

: emit-temporary-buffer-with ( string document -- )
    [ emit-string ] [ nip flush-temporary-buffer ] 2bi ;

! check if matches open tag
: appropriate-end-tag-token? ( document -- ? )
    [ tag>> name>> ] [ open-elements>> ?last ] bi
    [ name>> sequence= ] [ drop f ] if* ;

: ascii-upper-alpha? ( ch -- ? ) [ CHAR: A CHAR: Z between? ] [ f ] if* ; inline
: ascii-lower-alpha? ( ch -- ? ) [ CHAR: a CHAR: z between? ] [ f ] if* ; inline
: ascii-upper-hex-digit? ( ch -- ? ) [ CHAR: A CHAR: F between? ] [ f ] if* ; inline
: ascii-lower-hex-digit? ( ch -- ? ) [ CHAR: a CHAR: f between? ] [ f ] if* ; inline
: ascii-hex-alpha? ( ch -- ? ) { [ ascii-upper-hex-digit? ] [ ascii-lower-hex-digit? ] } 1|| ; inline

: ascii-digit? ( ch/f -- ? ) [ CHAR: 0 CHAR: 9 between? ] [ f ] if* ;
: ascii-alpha? ( ch/f -- ? ) { [ ascii-lower-alpha? ] [ ascii-upper-alpha? ] } 1|| ;
: ascii-alphanumeric? ( ch/f -- ? ) { [ ascii-alpha? ] [ ascii-digit? ] } 1|| ;
: ascii-hex-digit? ( ch/f -- ? ) { [ ascii-digit? ] [ ascii-hex-alpha? ] } 1|| ;

: (return-state) ( document n/f string ch/f -- document n'/f string )
    reach [ f ] change-return-state drop check-return-state
    name>> "(" ")" surround "html5" lookup-word
    execute( document n/f string ch/f -- document n'/f string ) ;

: return-state ( document n/f string -- document n'/f string )
    pick [ f ] change-return-state drop check-return-state
    execute( document n/f string -- document n'/f string ) ;

: tag-data-state ( document n/f string -- document n'/f string )
    pick open-elements>> ?last [ html-element? ] [ t ] if* [
        pick open-elements>> ?last [ name>> ] [ "" ] if* {
            { "noscript" [ pick scripting?>> [ rawtext-state ] [ data-state ] if ] }
            { "title" [ rcdata-state ] }
            { "textarea" [ rcdata-state ] }
            { "style" [ rawtext-state ] }
            { "xmp" [ rawtext-state ] }
            { "iframe" [ rawtext-state ] }
            { "noembed" [ rawtext-state ] }
            { "noframes" [ rawtext-state ] }
            { "script" [ script-data-state ] }
            { "plaintext" [ plaintext-state ] }
            [ drop data-state ]
        } case
    ] [ data-state ] if ;


: (data-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: & = ] [ drop [ \ data-state >>return-state ] 2dip character-reference-state ] }
        { [ dup CHAR: < = ] [ drop tag-open-state ] }
        { [ dup CHAR: \0 = ] [
            "unexpected-null-character" report-parse-error
            reach over foreign-token? [
                drop pick CHAR: replacement-character append-node
            ] [ drop ] if data-state
        ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char data-state ]
    } cond ;

: data-state ( document n/f string -- document n'/f string )
    take-char (data-state) ;


: (rcdata-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: & = ] [ drop [ \ rcdata-state >>return-state ] 2dip character-reference-state ] }
        { [ dup CHAR: < = ] [ drop rcdata-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach emit-char rcdata-state ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char rcdata-state ]
    } cond ;

: rcdata-state ( document n/f string -- document n'/f string )
    take-char (rcdata-state) ;


: (rawtext-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ drop rawtext-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach emit-char rawtext-state ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char rawtext-state ]
    } cond ;

: rawtext-state ( document n/f string -- document n'/f string )
    take-char (rawtext-state) ;


: (script-data-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ drop script-data-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach emit-char script-data-state ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char script-data-state ]
    } cond ;

: script-data-state ( document n/f string -- document n'/f string )
    take-char (script-data-state) ;


: (plaintext-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach emit-char plaintext-state ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char plaintext-state ]
    } cond ;

: plaintext-state ( document n/f string -- document n'/f string )
    take-char (plaintext-state) ;


: (tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-tag (tag-name-state) ] }
        { [ dup CHAR: ! = ] [ drop markup-declaration-open-state ] }
        { [ dup CHAR: / = ] [ drop end-tag-open-state ] }
        { [ dup CHAR: ? = ] [ drop pick reset-temporary-buffer processing-instruction-open-state ] }
        { [ dup f = ] [
            drop "eof-before-tag-name" report-parse-error
            "<" reach emit-string pick emit-eof
        ] }
        [
            "invalid-first-character-of-tag-name" report-parse-error
            [ CHAR: < reach emit-char ] dip (data-state)
        ]
    } cond ;

: tag-open-state ( document n/f string -- document n'/f string )
    take-char (tag-open-state) ;


: (end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (tag-name-state) ] }
        { [ dup CHAR: > = ] [ drop "missing-end-tag-name" report-parse-error data-state ] }
        { [ dup f = ] [
            drop "eof-before-tag-name" report-parse-error
            "</" reach emit-string pick emit-eof
        ] }
        [ "invalid-first-character-of-tag-name" report-parse-error (bogus-comment-state) ]
    } cond ;

: end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (end-tag-open-state) ;


: (tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach push-tag-name tag-name-state ] }
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: / = ] [ drop self-closing-start-tag-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag tag-data-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-tag-name tag-name-state ] }
        { [ dup f = ] [
            drop "eof-in-tag" report-parse-error pick emit-eof
        ] }
        [ reach push-tag-name tag-name-state ]
    } cond ;

: tag-name-state ( document n/f string -- document n'/f string )
    take-char (tag-name-state) ;


: (rcdata-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer rcdata-end-tag-open-state ] }
        [ [ CHAR: < reach emit-char ] dip (rcdata-state) ]
    } cond ;

: rcdata-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (rcdata-less-than-sign-state) ;


: (rcdata-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (rcdata-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (rcdata-state) ]
    } cond ;

: rcdata-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (rcdata-end-tag-open-state) ;


: end-tag-name-delimiter ( document n/f string ch -- document n'/f string )
    {
        { CHAR: > [ pick emit-end-tag data-state ] }
        { CHAR: / [ self-closing-start-tag-state ] }
        [ drop before-attribute-name-state ]
    } case ;

: push-end-tag-letter ( ch document -- )
    [ [ dup ascii-upper-alpha? [ 0x20 + ] when ] dip push-tag-name ] [ push-temporary-buffer ] 2bi ;

: (rcdata-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? [ reach appropriate-end-tag-token? ] [ f ] if ] [
            end-tag-name-delimiter
        ] }
        { [ dup ascii-alpha? ] [ reach push-end-tag-letter rcdata-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (rcdata-state) ]
    } cond ;

: rcdata-end-tag-name-state ( document n/f string -- document n'/f string )
    take-char (rcdata-end-tag-name-state) ;


: (rawtext-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer rawtext-end-tag-open-state ] }
        [ [ CHAR: < reach emit-char ] dip (rawtext-state) ]
    } cond ;

: rawtext-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (rawtext-less-than-sign-state) ;


: (rawtext-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (rawtext-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (rawtext-state) ]
    } cond ;

: rawtext-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (rawtext-end-tag-open-state) ;


: (rawtext-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? [ reach appropriate-end-tag-token? ] [ f ] if ] [
            end-tag-name-delimiter
        ] }
        { [ dup ascii-alpha? ] [ reach push-end-tag-letter rawtext-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (rawtext-state) ]
    } cond ;

: rawtext-end-tag-name-state ( document n/f string -- document n'/f string )
    take-char (rawtext-end-tag-name-state) ;


: (script-data-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer script-data-end-tag-open-state ] }
        { [ dup CHAR: ! = ] [ drop "<!" reach emit-string script-data-escape-start-state ] }
        [ [ CHAR: < reach emit-char ] dip (script-data-state) ]
    } cond ;

: script-data-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (script-data-less-than-sign-state) ;


: (script-data-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (script-data-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (script-data-state) ]
    } cond ;

: script-data-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (script-data-end-tag-open-state) ;


: (script-data-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? [ reach appropriate-end-tag-token? ] [ f ] if ] [
            end-tag-name-delimiter
        ] }
        { [ dup ascii-alpha? ] [ reach push-end-tag-letter script-data-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (script-data-state) ]
    } cond ;

: script-data-end-tag-name-state ( document n/f string -- document n'/f string )
    take-char (script-data-end-tag-name-state) ;


: (script-data-escape-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-escape-start-dash-state ] }
        [ (script-data-state) ]
    } cond ;

: script-data-escape-start-state ( document n/f string -- document n'/f string )
    take-char (script-data-escape-start-state) ;


: (script-data-escape-start-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-escaped-dash-dash-state ] }
        [ (script-data-state) ]
    } cond ;

: script-data-escape-start-dash-state ( document n/f string -- document n'/f string )
    take-char (script-data-escape-start-dash-state) ;


: (script-data-escaped-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-escaped-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach emit-char script-data-escaped-state ] }
        { [ dup f = ] [ drop "eof-in-script-html-comment-like-text" report-parse-error pick emit-eof ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-state) ;


: (script-data-escaped-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach emit-char script-data-escaped-state ] }
        { [ dup f = ] [ drop "eof-in-script-html-comment-like-text" report-parse-error pick emit-eof ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-dash-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-dash-state) ;


: (script-data-escaped-dash-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: > = ] [ reach emit-char script-data-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach emit-char script-data-escaped-state ] }
        { [ dup f = ] [ drop "eof-in-script-html-comment-like-text" report-parse-error pick emit-eof ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-dash-dash-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-dash-dash-state) ;


: (script-data-escaped-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer script-data-escaped-end-tag-open-state ] }
        { [ dup ascii-alpha? ] [ [ pick reset-temporary-buffer CHAR: < reach emit-char ] dip (script-data-double-escape-start-state) ] }
        [ [ CHAR: < reach emit-char ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-less-than-sign-state) ;


: (script-data-escaped-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ [ pick new-end-tag ] dip (script-data-escaped-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-end-tag-open-state) ;


: (script-data-escaped-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? [ reach appropriate-end-tag-token? ] [ f ] if ] [
            end-tag-name-delimiter
        ] }
        { [ dup ascii-alpha? ] [ reach push-end-tag-letter script-data-escaped-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-end-tag-name-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-end-tag-name-state) ;


: (script-data-double-escape-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? ] [
            reach emit-char
            pick temporary-buffer>> "script" sequence=
            [ script-data-double-escaped-state ] [ script-data-escaped-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-temporary-buffer ] [ reach emit-char ] bi script-data-double-escape-start-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-temporary-buffer ] [ reach emit-char ] bi script-data-double-escape-start-state ] } ! todo
        [ (script-data-escaped-state) ]
    } cond ;

: script-data-double-escape-start-state ( document n/f string -- document n'/f string )
    take-char (script-data-double-escape-start-state) ;


: (script-data-double-escaped-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-double-escaped-dash-state ] }
        { [ dup CHAR: < = ] [ reach emit-char script-data-double-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [
            drop "unexpected-null-character" report-parse-error
            CHAR: replacement-character reach emit-char
            script-data-double-escaped-state
        ] }
        { [ dup f = ] [ drop "eof-in-script-html-comment-like-text" report-parse-error pick emit-eof ] }
        [ reach emit-char script-data-double-escaped-state ]
    } cond ;

: script-data-double-escaped-state ( document n/f string -- document n'/f string )
    take-char (script-data-double-escaped-state) ;


: (script-data-double-escaped-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-double-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ reach emit-char script-data-double-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [
            drop "unexpected-null-character" report-parse-error
            CHAR: replacement-character reach emit-char
            script-data-double-escaped-state
        ] }
        { [ dup f = ] [ drop "eof-in-script-html-comment-like-text" report-parse-error pick emit-eof ] }
        [ reach emit-char script-data-double-escaped-state ]
    } cond ;

: script-data-double-escaped-dash-state ( document n/f string -- document n'/f string )
    take-char (script-data-double-escaped-dash-state) ;


: (script-data-double-escaped-dash-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-double-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ reach emit-char script-data-double-escaped-less-than-sign-state ] }
        { [ dup CHAR: > = ] [ reach emit-char script-data-state ] }
        { [ dup CHAR: \0 = ] [
            drop "unexpected-null-character" report-parse-error
            CHAR: replacement-character reach emit-char
            script-data-double-escaped-state
        ] }
        { [ dup f = ] [ drop "eof-in-script-html-comment-like-text" report-parse-error pick emit-eof ] }
        [ reach emit-char script-data-double-escaped-state ]
    } cond ;

: script-data-double-escaped-dash-dash-state ( document n/f string -- document n'/f string )
    take-char (script-data-double-escaped-dash-dash-state) ;


: (script-data-double-escaped-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ reach emit-char pick reset-temporary-buffer script-data-double-escape-end-state ] }
        [ (script-data-double-escaped-state) ]
    } cond ;

: script-data-double-escaped-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (script-data-double-escaped-less-than-sign-state) ;


: (script-data-double-escape-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? ] [
            reach emit-char
            pick temporary-buffer>> "script" sequence=
            [ script-data-escaped-state ] [ script-data-double-escaped-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-temporary-buffer ] [ reach emit-char ] bi script-data-double-escape-end-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-temporary-buffer ] [ reach emit-char ] bi script-data-double-escape-end-state ] } ! todo
        [ (script-data-double-escaped-state) ]
    } cond ;

: script-data-double-escape-end-state ( document n/f string -- document n'/f string )
    take-char (script-data-double-escape-end-state) ;


: (before-attribute-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup "/>" member? ] [ (after-attribute-name-state) ] }
        { [ dup f = ] [ (after-attribute-name-state) ] }
        { [ dup CHAR: = = ] [
            "unexpected-equals-sign-before-attribute-name" report-parse-error
            [ pick push-attribute ] dip reach push-attribute-name attribute-name-state
        ] }
        [ reach push-attribute (attribute-name-state) ]
    } cond ;

: before-attribute-name-state ( document n/f string -- document n'/f string )
    take-char (before-attribute-name-state) ;


: (attribute-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? ] [ (after-attribute-name-state) ] }
        { [ dup f = ] [ (after-attribute-name-state) ] }
        { [ dup CHAR: = = ] [ drop before-attribute-value-state ] }
        { [ dup ascii-upper-alpha? ] [
            0x20 + reach push-attribute-name
            attribute-name-state
        ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-attribute-name attribute-name-state ] }
        { [ dup "\"'<" member? ] [
            "unexpected-character-in-attribute-name" report-parse-error
            reach push-attribute-name attribute-name-state
        ] }
        [ reach push-attribute-name attribute-name-state ]
    } cond ;

: attribute-name-state ( document n/f string -- document n'/f string )
    take-char (attribute-name-state) ;


: (after-attribute-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-attribute-name-state ] }
        { [ dup CHAR: / = ] [ drop self-closing-start-tag-state ] }
        { [ dup CHAR: = = ] [ drop before-attribute-value-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag tag-data-state ] }
        { [ dup f = ] [ drop "eof-in-tag" report-parse-error pick emit-eof ] }
        [ [ pick push-attribute ] dip (attribute-name-state) ]
    } cond ;

: after-attribute-name-state ( document n/f string -- document n'/f string )
    take-char (after-attribute-name-state) ;


: (before-attribute-value-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-value-state ] }
        { [ dup CHAR: " = ] [ drop attribute-value-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop attribute-value-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "missing-attribute-value" report-parse-error pick emit-tag tag-data-state ] }
        [ (attribute-value-unquoted-state) ]
    } cond ;

: before-attribute-value-state ( document n/f string -- document n'/f string )
    take-char (before-attribute-value-state) ;


: (attribute-value-double-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: " = ] [ drop after-attribute-value-quoted-state ] }
        { [ dup CHAR: & = ] [
            drop
            [ \ attribute-value-double-quoted-state >>return-state ] 2dip character-reference-state
        ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-attribute-value attribute-value-double-quoted-state ] }
        { [ dup f = ] [ drop "eof-in-tag" report-parse-error pick emit-eof ] }
        [ reach push-attribute-value attribute-value-double-quoted-state ]
    } cond ;

: attribute-value-double-quoted-state ( document n/f string -- document n'/f string )
    take-char (attribute-value-double-quoted-state) ;


: (attribute-value-single-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ' = ] [ drop after-attribute-value-quoted-state ] }
        { [ dup CHAR: & = ] [
            drop [ \ attribute-value-single-quoted-state >>return-state ] 2dip
            character-reference-state
        ] }
        { [ dup CHAR: \0 = ] [
            drop "unexpected-null-character" report-parse-error
            CHAR: replacement-character reach push-attribute-value attribute-value-single-quoted-state
        ] }
        { [ dup f = ] [ drop "eof-in-tag" report-parse-error pick emit-eof ] }
        [ reach push-attribute-value attribute-value-single-quoted-state ]
    } cond ;

: attribute-value-single-quoted-state ( document n/f string -- document n'/f string )
    take-char (attribute-value-single-quoted-state) ;


: (attribute-value-unquoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: & = ] [
            drop
            [ \ attribute-value-unquoted-state >>return-state ] 2dip character-reference-state
        ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag tag-data-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-attribute-value attribute-value-unquoted-state ] }
        { [ dup "\"'<=`" member? ] [
            "unexpected-character-in-unquoted-attribute-value" report-parse-error
            reach push-attribute-value
            attribute-value-unquoted-state
        ] }
        { [ dup f = ] [ drop "eof-in-tag" report-parse-error pick emit-eof ] }
        [ reach push-attribute-value attribute-value-unquoted-state ]
    } cond ;

: attribute-value-unquoted-state ( document n/f string -- document n'/f string )
    take-char (attribute-value-unquoted-state) ;


: (after-attribute-value-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: / = ] [ drop self-closing-start-tag-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag tag-data-state ] }
        { [ dup f = ] [ drop "eof-in-tag" report-parse-error pick emit-eof ] }
        [ "missing-whitespace-between-attributes" report-parse-error (before-attribute-name-state) ]
    } cond ;

: after-attribute-value-quoted-state ( document n/f string -- document n'/f string )
    take-char (after-attribute-value-quoted-state) ;


: (self-closing-start-tag-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick [ set-self-closing ] [ emit-tag ] bi tag-data-state ] }
        { [ dup f = ] [ drop "eof-in-tag" report-parse-error pick emit-eof ] }
        [ "unexpected-solidus-in-tag" report-parse-error (before-attribute-name-state) ]
    } cond ;

: self-closing-start-tag-state ( document n/f string -- document n'/f string )
    take-char (self-closing-start-tag-state) ;


: (bogus-comment-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-comment-token data-state ] }
        { [ dup f = ] [ drop pick [ emit-comment-token ] [ emit-eof ] bi ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-comment-token bogus-comment-state ] }
        [ reach push-comment-token bogus-comment-state ]
    } cond ;

: bogus-comment-state ( document n/f string -- document n'/f string )
    take-char (bogus-comment-state) ;


:: take-markup? ( n string text -- n' string ? )
    n text length + string length <= [
        n string text take-from?
    ] [ n string f ] if ;

: markup-declaration-open-state ( document n/f string -- document n'/f string )
    {
        { [ "--" take-markup? ] [ comment-start-state ] }
        { [ "DOCTYPE" take-from-insensitive? ] [ pick <doctype> >>doctype drop doctype-state ] }
        { [ "[CDATA[" take-markup? ] [
            pick open-elements>> ?last [ html-element? not ] [ f ] if* [
                cdata-section-state
            ] [
                "cdata-in-html-content" report-parse-error
                "[CDATA[" reach push-all-comment-token bogus-comment-state
            ] if
        ] }
        [
            "incorrectly-opened-comment" report-parse-error bogus-comment-state
        ]
    } cond ;

: (comment-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-start-dash-state ] }
        { [ dup CHAR: > = ] [ drop "abrupt-closing-of-empty-comment" report-parse-error pick emit-comment-token data-state ] }
        [ (comment-state) ]
    } cond ;

: comment-start-state ( document n/f string -- document n'/f string )
    take-char (comment-start-state) ;


: (comment-start-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-state ] }
        { [ dup CHAR: > = ] [ drop "abrupt-closing-of-empty-comment" report-parse-error pick emit-comment-token data-state ] }
        { [ dup f = ] [ drop "eof-in-comment" report-parse-error pick [ emit-comment-token ] [ emit-eof ] bi ] }
        [ [ CHAR: - reach push-comment-token ] dip (comment-state) ]
    } cond ;

: comment-start-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-start-dash-state) ;


: (comment-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ reach push-comment-token comment-less-than-sign-state ] }
        { [ dup CHAR: - = ] [ drop comment-end-dash-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-comment-token comment-state ] }
        { [ dup f = ] [ drop "eof-in-comment" report-parse-error pick [ emit-comment-token ] [ emit-eof ] bi ] }
        [ reach push-comment-token comment-state ]
    } cond ;

: comment-state ( document n/f string -- document n'/f string )
    take-char (comment-state) ;


: (comment-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ! = ] [ reach push-comment-token comment-less-than-sign-bang-state ] }
        { [ dup CHAR: < = ] [ reach push-comment-token comment-less-than-sign-state ] }
        [ (comment-state) ]
    } cond ;

: comment-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-state) ;


: (comment-less-than-sign-bang-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach push-comment-token comment-less-than-sign-bang-dash-state ] }
        [ (comment-state) ]
    } cond ;

: comment-less-than-sign-bang-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-bang-state) ;


: (comment-less-than-sign-bang-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-less-than-sign-bang-dash-dash-state ] }
        [ (comment-end-dash-state) ]
    } cond ;

: comment-less-than-sign-bang-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-bang-dash-state) ;


: (comment-less-than-sign-bang-dash-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ (comment-end-state) ] }
        { [ dup f = ] [ (comment-end-state) ] }
        [ "nested-comment" report-parse-error (comment-end-state) ]
    } cond ;

: comment-less-than-sign-bang-dash-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-bang-dash-dash-state) ;


: (comment-end-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-state ] }
        { [ dup f = ] [ drop "eof-in-comment" report-parse-error pick [ emit-comment-token ] [ emit-eof ] bi ] }
        [ [ CHAR: - reach push-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-end-dash-state) ;


: (comment-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-comment-token data-state ] }
        { [ dup CHAR: ! = ] [ drop comment-end-bang-state ] }
        { [ dup CHAR: - = ] [ reach push-comment-token comment-end-state ] }
        { [ dup f = ] [ drop "eof-in-comment" report-parse-error pick [ emit-comment-token ] [ emit-eof ] bi ] }
        [ [ "--" reach push-all-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-state ( document n/f string -- document n'/f string )
    take-char (comment-end-state) ;


: (comment-end-bang-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop "--!" reach push-all-comment-token comment-end-dash-state ] }
        { [ dup CHAR: > = ] [ drop "incorrectly-closed-comment" report-parse-error pick emit-comment-token data-state ] }
        { [ dup f = ] [ drop "eof-in-comment" report-parse-error pick [ emit-comment-token ] [ emit-eof ] bi ] }
        [ [ "--!" reach push-all-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-bang-state ( document n/f string -- document n'/f string )
    take-char (comment-end-bang-state) ;


: doctype-eof ( document n/f string -- document n/f string )
    "eof-in-doctype" report-parse-error
    pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri ;

: (doctype-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-name-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        [ "missing-whitespace-before-doctype-name" report-parse-error (before-doctype-name-state) ]
    } cond ;

: doctype-state ( document n/f string -- document n'/f string )
    take-char (doctype-state) ;

: (before-doctype-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-name-state ] }
        { [ dup CHAR: > = ] [ drop "missing-doctype-name" report-parse-error pick force-quirks pick emit-doctype data-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach new-doctype-from-ch doctype-name-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach new-doctype-from-ch doctype-name-state ] }
        [ reach new-doctype-from-ch doctype-name-state ]
    } cond ;

: before-doctype-name-state ( document n/f string -- document n'/f string )
    take-char (before-doctype-name-state) ;

: (doctype-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-name-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-doctype-name doctype-name-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach push-doctype-name doctype-name-state ] }
        [ reach push-doctype-name doctype-name-state ]
    } cond ;

: doctype-name-state ( document n/f string -- document n'/f string )
    take-char (doctype-name-state) ;

:: (after-doctype-name-state) ( document n string ch -- document n' string )
    ch {
        { [ dup html-space? ] [ drop document n string after-doctype-name-state ] }
        { [ dup CHAR: > = ] [ drop document emit-doctype document n string data-state ] }
        { [ dup f = ] [ drop document n string doctype-eof ] }
        [
            drop document n 1 - string
            {
                { [ "PUBLIC" take-from-insensitive? ] [ after-doctype-public-keyword-state ] }
                { [ "SYSTEM" take-from-insensitive? ] [ after-doctype-system-keyword-state ] }
                [ "invalid-character-sequence-after-doctype-name" report-parse-error pick force-quirks bogus-doctype-state ]
            } cond
        ]
    } cond ;

: after-doctype-name-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-name-state) ;

: (after-doctype-public-keyword-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-public-identifier-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup CHAR: " = ] [ drop "missing-whitespace-after-doctype-public-keyword" report-parse-error pick initialize-doctype-public-identifier doctype-public-identifier-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop "missing-whitespace-after-doctype-public-keyword" report-parse-error pick initialize-doctype-public-identifier doctype-public-identifier-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "missing-doctype-public-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        [ "missing-quote-before-doctype-public-identifier" report-parse-error [ pick force-quirks ] dip (bogus-doctype-state) ]
    } cond ;

: after-doctype-public-keyword-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-public-keyword-state) ;

: (before-doctype-public-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-public-identifier-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup CHAR: " = ] [ drop pick initialize-doctype-public-identifier doctype-public-identifier-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop pick initialize-doctype-public-identifier doctype-public-identifier-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "missing-doctype-public-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        [ "missing-quote-before-doctype-public-identifier" report-parse-error [ pick force-quirks ] dip (bogus-doctype-state) ]
    } cond ;

: before-doctype-public-identifier-state ( document n/f string -- document n'/f string )
    take-char (before-doctype-public-identifier-state) ;

: (doctype-public-identifier-double-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: " = ] [ drop after-doctype-public-identifier-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-doctype-public-identifier doctype-public-identifier-double-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "abrupt-doctype-public-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        [ reach push-doctype-public-identifier doctype-public-identifier-double-quoted-state ]
    } cond ;

: doctype-public-identifier-double-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-public-identifier-double-quoted-state) ;

: (doctype-public-identifier-single-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ' = ] [ drop after-doctype-public-identifier-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-doctype-public-identifier doctype-public-identifier-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "abrupt-doctype-public-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        [ reach push-doctype-public-identifier doctype-public-identifier-single-quoted-state ]
    } cond ;

: doctype-public-identifier-single-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-public-identifier-single-quoted-state) ;

: (after-doctype-system-keyword-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-system-identifier-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup CHAR: " = ] [ drop "missing-whitespace-after-doctype-system-keyword" report-parse-error pick initialize-doctype-system-identifier doctype-system-identifier-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop "missing-whitespace-after-doctype-system-keyword" report-parse-error pick initialize-doctype-system-identifier doctype-system-identifier-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "missing-doctype-system-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        [ "missing-quote-before-doctype-system-identifier" report-parse-error [ pick force-quirks ] dip (bogus-doctype-state) ]
    } cond ;

: after-doctype-system-keyword-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-system-keyword-state) ;

: (before-doctype-system-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-system-identifier-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup CHAR: " = ] [ drop pick initialize-doctype-system-identifier doctype-system-identifier-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop pick initialize-doctype-system-identifier doctype-system-identifier-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "missing-doctype-system-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        [ "missing-quote-before-doctype-system-identifier" report-parse-error [ pick force-quirks ] dip (bogus-doctype-state) ]
    } cond ;

: before-doctype-system-identifier-state ( document n/f string -- document n'/f string )
    take-char (before-doctype-system-identifier-state) ;

: (doctype-system-identifier-double-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: " = ] [ drop after-doctype-system-identifier-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-doctype-system-identifier doctype-system-identifier-double-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "abrupt-doctype-system-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        [ reach push-doctype-system-identifier doctype-system-identifier-double-quoted-state ]
    } cond ;

: doctype-system-identifier-double-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-system-identifier-double-quoted-state) ;

: (doctype-system-identifier-single-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ' = ] [ drop after-doctype-system-identifier-state ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error CHAR: replacement-character reach push-doctype-system-identifier doctype-system-identifier-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop "abrupt-doctype-system-identifier" report-parse-error pick [ force-quirks ] [ emit-doctype ] bi data-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        [ reach push-doctype-system-identifier doctype-system-identifier-single-quoted-state ]
    } cond ;

: doctype-system-identifier-single-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-system-identifier-single-quoted-state) ;

: (after-doctype-public-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop between-doctype-public-and-system-identifiers-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup CHAR: " = ] [ drop "missing-whitespace-between-doctype-public-and-system-identifiers" report-parse-error pick initialize-doctype-system-identifier doctype-system-identifier-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop "missing-whitespace-between-doctype-public-and-system-identifiers" report-parse-error pick initialize-doctype-system-identifier doctype-system-identifier-single-quoted-state ] }
        [ "missing-quote-before-doctype-system-identifier" report-parse-error [ pick force-quirks ] dip (bogus-doctype-state) ]
    } cond ;

: after-doctype-public-identifier-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-public-identifier-state) ;

: (between-doctype-public-and-system-identifiers-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop between-doctype-public-and-system-identifiers-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        { [ dup CHAR: " = ] [ drop pick initialize-doctype-system-identifier doctype-system-identifier-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop pick initialize-doctype-system-identifier doctype-system-identifier-single-quoted-state ] }
        [ "missing-quote-before-doctype-system-identifier" report-parse-error [ pick force-quirks ] dip (bogus-doctype-state) ]
    } cond ;

: between-doctype-public-and-system-identifiers-state ( document n/f string -- document n'/f string )
    take-char (between-doctype-public-and-system-identifiers-state) ;

: (after-doctype-system-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-system-identifier-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup f = ] [ drop doctype-eof ] }
        [ "unexpected-character-after-doctype-system-identifier" report-parse-error (bogus-doctype-state) ]
    } cond ;

: after-doctype-system-identifier-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-system-identifier-state) ;

: (bogus-doctype-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup f = ] [ drop pick [ emit-doctype ] [ emit-eof ] bi ] }
        { [ dup CHAR: \0 = ] [ drop "unexpected-null-character" report-parse-error bogus-doctype-state ] }
        [ drop bogus-doctype-state ]
    } cond ;

: bogus-doctype-state ( document n/f string -- document n'/f string )
    take-char (bogus-doctype-state) ;

: (cdata-section-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ drop cdata-section-bracket-state ] }
        { [ dup f = ] [ drop "eof-in-cdata" report-parse-error pick emit-eof ] }
        [ reach emit-char cdata-section-state ]
    } cond ;

: cdata-section-state ( document n/f string -- document n'/f string )
    take-char (cdata-section-state) ;


: (cdata-section-bracket-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ drop cdata-section-end-state ] }
        [ [ CHAR: ] reach emit-char ] dip (cdata-section-state) ]
    } cond ;

: cdata-section-bracket-state ( document n/f string -- document n'/f string )
    take-char (cdata-section-bracket-state) ;


: (cdata-section-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ reach emit-char cdata-section-end-state ] }
        { [ dup CHAR: > = ] [ drop data-state ] }
        [ [ "]]" reach emit-string ] dip (cdata-section-state) ]
    } cond ;

: cdata-section-end-state ( document n/f string -- document n'/f string )
    take-char (cdata-section-end-state) ;


! Processing instructions are supported by the current HTML standard.
: temporary-buffer>comment ( document -- )
    dup temporary-buffer>> >string "?" prepend
    SBUF" " clone-like >>comment-token drop ;

: new-processing-instruction ( document -- )
    dup temporary-buffer>> >string
    processing-instruction new swap >>target
    SBUF" " clone >>data >>processing-instruction-token drop ;

: push-processing-instruction-data ( ch document -- )
    processing-instruction-token>> data>> push ;

: emit-processing-instruction ( document -- )
    dup flush-table-characters
    dup processing-instruction-token>> [ >string ] change-data
    tree-insert drop ;

: (processing-instruction-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup { [ ascii-alpha? ] [ CHAR: _ = ] } 1|| ] [ (processing-instruction-target-state) ] }
        { [ dup f = ] [ drop "eof-in-processing-instruction" report-parse-error pick emit-eof ] }
        [
            "invalid-first-character-of-processing-instruction-target" report-parse-error
            [ pick temporary-buffer>comment ] dip (bogus-comment-state)
        ]
    } cond ;

: processing-instruction-open-state ( document n/f string -- document n'/f string )
    take-char (processing-instruction-open-state) ;

: (processing-instruction-target-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s?>" member? ] [
            reach temporary-buffer>> >string >lower { "xml" "xml-stylesheet" } member? [
                "disallowed-processing-instruction-target" report-parse-error
                [ pick temporary-buffer>comment ] dip (bogus-comment-state)
            ] [
                [ pick new-processing-instruction ] dip (after-processing-instruction-target-state)
            ] if
        ] }
        { [ dup { [ ascii-alphanumeric? ] [ "-_" member? ] } 1|| ] [ reach push-temporary-buffer processing-instruction-target-state ] }
        { [ dup f = ] [ drop "eof-in-processing-instruction" report-parse-error pick emit-eof ] }
        [
            "invalid-processing-instruction-target" report-parse-error
            [ pick temporary-buffer>comment ] dip (bogus-comment-state)
        ]
    } cond ;

: processing-instruction-target-state ( document n/f string -- document n'/f string )
    take-char (processing-instruction-target-state) ;

: (after-processing-instruction-target-state) ( document n/f string ch/f -- document n'/f string )
    dup html-space? [ drop after-processing-instruction-target-state ] [
        (processing-instruction-data-state)
    ] if ;

: after-processing-instruction-target-state ( document n/f string -- document n'/f string )
    take-char (after-processing-instruction-target-state) ;

: (processing-instruction-data-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ? = ] [ drop processing-instruction-questionable-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-processing-instruction data-state ] }
        { [ dup f = ] [ drop "eof-in-processing-instruction" report-parse-error pick emit-eof ] }
        [ reach push-processing-instruction-data processing-instruction-data-state ]
    } cond ;

: processing-instruction-data-state ( document n/f string -- document n'/f string )
    take-char (processing-instruction-data-state) ;

: (processing-instruction-questionable-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-processing-instruction data-state ] }
        { [ dup f = ] [ drop "eof-in-processing-instruction" report-parse-error pick emit-eof ] }
        [ [ CHAR: ? reach push-processing-instruction-data ] dip (processing-instruction-data-state) ]
    } cond ;

: processing-instruction-questionable-state ( document n/f string -- document n'/f string )
    take-char (processing-instruction-questionable-state) ;

: (character-reference-state) ( document n/f string ch/f -- document n'/f string )
    [ CHAR: & reach ch>new-temporary-buffer ] dip
    {
        { [ dup ascii-alphanumeric? ] [ (named-character-reference-state) ] }
        { [ dup CHAR: # = ] [ reach push-temporary-buffer numeric-character-reference-state ] }
        [ reach flush-temporary-buffer (return-state) ]
    } cond ;

: character-reference-state ( document n/f string -- document n'/f string )
    take-char (character-reference-state) ;


! Consume the longest named reference, keeping legacy semicolonless
! references literal in attributes when followed by an alphanumeric or '='.
:: (named-character-reference-state) ( document n string ch -- document n' string )
    ch drop
    n 1 - :> start
    f :> match!
    start :> end!
    start 1 + :> i!
    [ i string length <= i start - longest-entity-name <= and ] [
        start i string subseq "&" prepend load-entities at [
            match! i end!
        ] when*
        i 1 + i!
    ] while
    match [
        document temporary-buffer-attribute?
        end 1 - string nth CHAR: ; = not and
        end string ?nth dup [
            dup ascii-alphanumeric? swap CHAR: = = or
        ] [ drop f ] if and [
            document flush-temporary-buffer
            document start string return-state
        ] [
            match "characters" of document string>new-temporary-buffer
            document flush-temporary-buffer
            document end string return-state
        ] if
    ] [
        document flush-temporary-buffer
        document start string return-state
    ] if ;

: named-character-reference-state ( document n/f string -- document n'/f string )
    take-char (named-character-reference-state) ;

: (ambiguous-ampersand-state) ( document n/f string ch/f -- document n'/f string )
    (return-state) ;

: ambiguous-ampersand-state ( document n/f string -- document n'/f string )
    take-char (ambiguous-ampersand-state) ;

: (numeric-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "xX" member? ] [ reach push-temporary-buffer hexadecimal-character-reference-start-state ] }
        [ (decimal-character-reference-start-state) ]
    } cond ;

: numeric-character-reference-state ( document n/f string -- document n'/f string )
    take-char (numeric-character-reference-state) ;


: (hexadecimal-character-reference-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-hex-digit? ] [ (hexadecimal-character-reference-state) ] }
        [ "absence-of-digits-in-numeric-character-reference" report-parse-error reach flush-temporary-buffer (return-state) ]
    } cond ;

: hexadecimal-character-reference-start-state ( document n/f string -- document n'/f string )
    take-char (hexadecimal-character-reference-start-state) ;


: (decimal-character-reference-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ (decimal-character-reference-state) ] }
        [ "absence-of-digits-in-numeric-character-reference" report-parse-error reach flush-temporary-buffer (return-state) ]
    } cond ;

: decimal-character-reference-start-state ( document n/f string -- document n'/f string )
    take-char (decimal-character-reference-start-state) ;


CONSTANT: numeric-reference-replacements H{
    { 0x80 0x20ac } { 0x82 0x201a } { 0x83 0x192 } { 0x84 0x201e }
    { 0x85 0x2026 } { 0x86 0x2020 } { 0x87 0x2021 } { 0x88 0x2c6 }
    { 0x89 0x2030 } { 0x8a 0x160 } { 0x8b 0x2039 } { 0x8c 0x152 }
    { 0x8e 0x17d } { 0x91 0x2018 } { 0x92 0x2019 } { 0x93 0x201c }
    { 0x94 0x201d } { 0x95 0x2022 } { 0x96 0x2013 } { 0x97 0x2014 }
    { 0x98 0x2dc } { 0x99 0x2122 } { 0x9a 0x161 } { 0x9b 0x203a }
    { 0x9c 0x153 } { 0x9e 0x17e } { 0x9f 0x178 }
}

: noncharacter? ( n -- ? )
    { [ 0xfdd0 0xfdef between? ] [ 0xffff bitand 0xfffe >= ] } 1|| ;

: normalize-numeric-reference ( n -- ch )
    {
        { [ dup 0 = ] [ drop "null-character-reference" report-parse-error CHAR: replacement-character ] }
        { [ dup 0x10ffff > ] [ drop "character-reference-outside-unicode-range" report-parse-error CHAR: replacement-character ] }
        { [ dup 0xd800 0xdfff between? ] [ drop "surrogate-character-reference" report-parse-error CHAR: replacement-character ] }
        [
            dup noncharacter? [ "noncharacter-character-reference" report-parse-error ] when
            dup { [ 0x80 0x9f between? ] [ 0x7f = ] [ 0xd = ]
                [ 0x1 0x8 between? ] [ 0xb = ] [ 0xe 0x1f between? ]
            } 1|| [ "control-character-reference" report-parse-error ] when
            dup numeric-reference-replacements at [ nip ] when*
        ]
    } cond ;

: finish-numeric-reference ( document -- )
    dup temporary-buffer>> >string
    dup ";" tail? [ but-last ] [ "missing-semicolon-after-character-reference" report-parse-error ] if
    2 tail dup first "xX" member? [ rest hex> ] [ dec> ] if
    normalize-numeric-reference 1string swap string>new-temporary-buffer ;

: (hexadecimal-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-hex-digit? ] [ reach push-temporary-buffer hexadecimal-character-reference-state ] }
        { [ dup CHAR: ; = ] [
            reach push-temporary-buffer
            pick [ finish-numeric-reference ] [ flush-temporary-buffer ] bi return-state
        ] }
        [ [ pick [ finish-numeric-reference ] [ flush-temporary-buffer ] bi ] dip (return-state) ]
    } cond ;

: hexadecimal-character-reference-state ( document n/f string -- document n'/f string )
    take-char (hexadecimal-character-reference-state) ;

: (decimal-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ reach push-temporary-buffer decimal-character-reference-state ] }
        { [ dup CHAR: ; = ] [
            reach push-temporary-buffer
            pick [ finish-numeric-reference ] [ flush-temporary-buffer ] bi return-state
        ] }
        [ [ pick [ finish-numeric-reference ] [ flush-temporary-buffer ] bi ] dip (return-state) ]
    } cond ;

: decimal-character-reference-state ( document n/f string -- document n'/f string )
    take-char (decimal-character-reference-state) ;

: (numeric-character-reference-end-state) ( document n/f string ch/f -- document n'/f string )
    [ pick [ finish-numeric-reference ] [ flush-temporary-buffer ] bi ] dip (return-state) ;

: numeric-character-reference-end-state ( document n/f string -- document n'/f string )
    pick [ finish-numeric-reference ] [ flush-temporary-buffer ] bi return-state ;

:: parse-html5-with-scripting ( string scripting? -- document )
    <document> scripting? >>scripting? :> document
    document current-html5-document [
        document 0 string "\r\n" "\n" replace "\r" "\n" replace data-state 2drop
    ] with-variable ;

: parse-html5 ( string -- document )
    f parse-html5-with-scripting ;
