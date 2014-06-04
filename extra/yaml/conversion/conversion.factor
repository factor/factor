! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs base64 byte-arrays combinators
combinators.extras hash-sets kernel linked-assocs math
math.parser regexp sequences strings yaml.ffi
calendar calendar.format ;
IN: yaml.conversion

! !!!!!!!!!!!!!!
! tag resolution
! http://www.yaml.org/spec/1.2/spec.html
! 10.3. Core Schema

CONSTANT: re-null R/ null|Null|NULL|~/
CONSTANT: re-empty R/ /
CONSTANT: re-bool R/ true|True|TRUE|false|False|FALSE/
CONSTANT: re-int10 R/ [-+]?[0-9]+/
CONSTANT: re-int8 R/ 0o[0-7]+/
CONSTANT: re-int16 R/ 0x[0-9a-fA-F]+/
CONSTANT: re-number R/ [-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?/
CONSTANT: re-infinity R/ [-+]?\.(inf|Inf|INF)/
CONSTANT: re-nan R/ \.(nan|NaN|NAN)/
CONSTANT: re-timestamp R/ [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]|[0-9][0-9][0-9][0-9]-[0-9][0-9]?-[0-9][0-9]?([Tt]|[ \t]+)[0-9][0-9]?:[0-9][0-9]:[0-9][0-9](\.[0-9]*)?([ \t]*(Z|[-+][0-9][0-9]?(:[0-9][0-9])?))?/

: resolve-plain-scalar ( str -- tag )
    {
        { [ re-null matches? ] [ YAML_NULL_TAG ] }
        { [ re-empty matches? ] [ YAML_NULL_TAG ] }
        { [ re-bool matches? ] [ YAML_BOOL_TAG ] }
        { [ re-int10 matches? ] [ YAML_INT_TAG ] }
        { [ re-int8 matches? ] [ YAML_INT_TAG ] }
        { [ re-int16 matches? ] [ YAML_INT_TAG ] }
        { [ re-number matches? ] [ YAML_FLOAT_TAG ] }
        { [ re-infinity matches? ] [ YAML_FLOAT_TAG ] }
        { [ re-nan matches? ] [ YAML_FLOAT_TAG ] }
        { [ re-timestamp matches? ] [ YAML_TIMESTAMP_TAG ] }
        [ drop YAML_STR_TAG ]
    } cond-case ;

CONSTANT: NON-SPECIFIC-TAG "!"

: resolve-explicit-tag ( tag default-tag -- tag )
    [ drop NON-SPECIFIC-TAG = not ] 2keep ? ;

: resolve-explicit-scalar-tag ( tag -- tag )
    YAML_DEFAULT_SCALAR_TAG resolve-explicit-tag ;

: resolve-explicit-sequence-tag ( tag -- tag )
    YAML_DEFAULT_SEQUENCE_TAG resolve-explicit-tag ;

: resolve-explicit-mapping-tag ( tag -- tag )
    YAML_DEFAULT_MAPPING_TAG resolve-explicit-tag ;

: resolve-scalar ( scalar-event -- tag )
    {
        { [ dup tag>> ] [ tag>> resolve-explicit-scalar-tag ] }
        { [ dup style>> YAML_PLAIN_SCALAR_STYLE = not ] [ drop YAML_STR_TAG ] }
        [ value>> resolve-plain-scalar ]
    } cond ;

! !!!!!!!!!!!!!!
! yaml -> factor

CONSTANT: YAML_BINARY_TAG "tag:yaml.org,2002:binary"
CONSTANT: YAML_OMAP_TAG "tag:yaml.org,2002:omap"
CONSTANT: YAML_PAIRS_TAG "tag:yaml.org,2002:pairs"
CONSTANT: YAML_SET_TAG "tag:yaml.org,2002:set"

: construct-bool ( str -- ? ) R/ true|True|TRUE/ matches? ;

: construct-int ( str -- n ) string>number ;

: construct-infinity ( str -- -inf/+inf )
    first CHAR: - = -1/0. 1/0. ? ;

: construct-float ( str -- x )
    {
        { [ dup re-infinity matches? ] [ construct-infinity ] }
        { [ dup re-nan matches? ] [ drop 1/0. ] }
        [ string>number ]
    } cond ;

! YAML allows
! - multiple whitespaces between date and time
! - multiple whitespaces between time and offset
! - months, days and hours on 1 digit
! preprocess to fix this mess...
: yaml>rfc3339 ( str -- str' )
    R/ -[0-9][^0-9]/ [ [ CHAR: 0 1 ] dip insert-nth ] re-replace-with
    R/ -[0-9][^0-9]/ [ [ CHAR: 0 1 ] dip insert-nth ] re-replace-with
    R/ [^0-9][0-9]:/ [ [ CHAR: 0 1 ] dip insert-nth ] re-replace-with
    R/ [ \t]+/ " " re-replace
    CHAR: : over index cut CHAR: space swap remove append ;

: construct-timestamp ( obj -- obj' )
    dup R/ [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ matches?
    [ ymd>timestamp ] [ yaml>rfc3339 rfc3339>timestamp ] if ;

: construct-scalar ( scalar-event -- scalar )
    [ value>> ] [ resolve-scalar ] bi {
        { YAML_NULL_TAG [ drop f ] }
        { YAML_BOOL_TAG [ construct-bool ] }
        { YAML_INT_TAG [ construct-int ] }
        { YAML_FLOAT_TAG [ construct-float ] }
        { YAML_BINARY_TAG [ base64> ] }
        { YAML_TIMESTAMP_TAG [ construct-timestamp ] }
        { YAML_STR_TAG [ ] }
    } case ;

: construct-pairs ( obj -- obj' )
    [ >alist first ] map ;

: construct-omap ( obj -- obj' )
    <linked-hash> [ assoc-union! ] reduce ;

: construct-sequence ( obj prev-event -- obj' )
    tag>> {
        { YAML_OMAP_TAG [ construct-omap ] }
        { YAML_PAIRS_TAG [ construct-pairs ] }
        [ drop ]
    } case ;

: construct-set ( obj -- obj' )
    keys >hash-set ;

: construct-mapping ( obj prev-event -- obj' )
    tag>> {
        { YAML_SET_TAG [ construct-set ] }
        [ drop ]
    } case ;

! !!!!!!!!!!!!!!
! factor -> yaml
GENERIC: represent-scalar ( obj -- str )
GENERIC: yaml-tag ( obj -- tag )

M: string represent-scalar ( obj -- str ) ;
M: string yaml-tag ( obj -- tag ) drop YAML_STR_TAG ;

M: boolean represent-scalar ( obj -- str ) "true" "false" ? ;
M: boolean yaml-tag ( obj -- tag ) drop YAML_BOOL_TAG ;

M: integer represent-scalar ( obj -- str ) number>string ;
M: integer yaml-tag ( obj -- tag ) drop YAML_INT_TAG ;

M: float represent-scalar ( obj -- str ) number>string ;
M: float yaml-tag ( obj -- tag ) drop YAML_FLOAT_TAG ;

M: byte-array represent-scalar ( obj -- str ) >base64 "" like ;
M: byte-array yaml-tag ( obj -- tag ) drop YAML_BINARY_TAG ;

M: timestamp represent-scalar ( obj -- str ) timestamp>rfc3339 ;
M: timestamp yaml-tag ( obj -- str ) drop YAML_TIMESTAMP_TAG ;
