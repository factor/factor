! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs base64 byte-arrays combinators
combinators.extras hash-sets kernel linked-assocs math
math.parser regexp sequences strings yaml.ffi ;
IN: yaml.conversion

! !!!!!!!!!!!!!!
! tag resolution
! http://www.yaml.org/spec/1.2/spec.html
! 10.3. Core Schema
: resolve-null? ( str -- ? )     R/ null|Null|NULL|~/ matches? ;
: resolve-empty? ( str -- ? )    R/ / matches? ;
: resolve-bool? ( str -- ? )     R/ true|True|TRUE|false|False|FALSE/ matches? ;
: resolve-int10? ( str -- ? )    R/ [-+]?[0-9]+/ matches? ;
: resolve-int8? ( str -- ? )     R/ 0o[0-7]+/ matches? ;
: resolve-int16? ( str -- ? )    R/ 0x[0-9a-fA-F]+/ matches? ;
: resolve-number? ( str -- ? )   R/ [-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?/ matches? ;
: resolve-infinity? ( str -- ? ) R/ [-+]?(\.inf|\.Inf|\.INF)/ matches? ;
: resolve-nan? ( str -- ? )      R/ \.nan|\.NaN|\.NAN/ matches? ;

: resolve-plain-scalar ( str -- tag )
    {
        { [ resolve-null? ] [ YAML_NULL_TAG ] }
        { [ resolve-empty? ] [ YAML_NULL_TAG ] }
        { [ resolve-bool? ] [ YAML_BOOL_TAG ] }
        { [ resolve-int10? ] [ YAML_INT_TAG ] }
        { [ resolve-int8? ] [ YAML_INT_TAG ] }
        { [ resolve-int16? ] [ YAML_INT_TAG ] }
        { [ resolve-number? ] [ YAML_FLOAT_TAG ] }
        { [ resolve-infinity? ] [ YAML_FLOAT_TAG ] }
        { [ resolve-nan? ] [ YAML_FLOAT_TAG ] }
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
: construct-bool ( str -- ? )     R/ true|True|TRUE/ matches? ;
: construct-int ( str -- n )     string>number ;
: construct-infinity ( str -- -inf/+inf )
    first CHAR: - =
    [ -1/0. ] [ 1/0. ] if ;
: construct-float ( str -- x )
    {
        { [ dup resolve-infinity? ] [ construct-infinity ] }
        { [ dup resolve-nan? ] [ drop 1/0. ] }
        [ string>number ]
    } cond ;

CONSTANT:  YAML_BINARY_TAG "tag:yaml.org,2002:binary"

: construct-scalar ( scalar-event -- scalar )
    [ value>> ] [ resolve-scalar ] bi {
        { YAML_NULL_TAG  [ drop f ] }
        { YAML_BOOL_TAG  [ construct-bool ] }
        { YAML_INT_TAG   [ construct-int ] }
        { YAML_FLOAT_TAG [ construct-float ] }
        { YAML_BINARY_TAG [ base64> ] }
        { YAML_STR_TAG   [ ] }
    } case ;

CONSTANT: YAML_OMAP_TAG  "tag:yaml.org,2002:omap"
CONSTANT: YAML_PAIRS_TAG "tag:yaml.org,2002:pairs"
: construct-pairs ( obj -- obj' ) [ >alist first ] map ;
: construct-omap ( obj -- obj' ) <linked-hash> [ assoc-union! ] reduce ;
: construct-sequence ( obj prev-event -- obj' )
    tag>> {
        { YAML_OMAP_TAG [ construct-omap ] }
        { YAML_PAIRS_TAG [ construct-pairs ] }
        [ drop ]
    } case ;

CONSTANT: YAML_SET_TAG   "tag:yaml.org,2002:set"
: construct-set ( obj -- obj' ) keys >hash-set ;
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

M: byte-array represent-scalar ( obj -- str ) >base64 >string ;
M: byte-array yaml-tag ( obj -- tag ) drop YAML_BINARY_TAG ;
