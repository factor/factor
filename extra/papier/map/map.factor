! Copyright (C) 2010 Joe Groff
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien assocs classes.struct combinators
combinators.short-circuit fry gpu.shaders images images.atlas
images.loader io.directories io.encodings.utf8 io.files
io.pathnames json kernel locals math math.matrices.simd
math.vectors.simd sequences sets specialized-arrays strings
typed ;

FROM: alien.c-types => float ;
SPECIALIZED-ARRAYS: float float-4 ;
IN: papier.map

ERROR: bad-papier-version version ;

CONSTANT: papier-map-version 3

: check-papier-version ( hash -- hash )
    "papier" over at dup papier-map-version = [ drop ] [ bad-papier-version ] if ;

TUPLE: slab
    { name maybe{ string } }
    images
    { frame fixnum }
    { center float-4 }
    { size float-4 }
    { orient float-4 }
    { color float-4 }

    { matrix matrix4 }
    { texcoords float-4-array } ;

VERTEX-FORMAT: papier-vertex
    { "vertex"   float-components 3 f }
    { f          float-components 1 f }
    { "texcoord" float-components 2 f }
    { f          float-components 2 f }
    { "color"    float-components 4 f } ;
STRUCT: papier-vertex-struct
    { vertex   float-4 }
    { texcoord float-4 }
    { color    float-4 } ;
SPECIALIZED-ARRAY: papier-vertex-struct

ERROR: bad-matrix-dim matrix ;

: parse-slab ( hash -- name images frame center size orient color )
    {
        [ "name"   swap at [ f ] when-json-null ] 
        [ "images" swap at ]
        [ "frame"  swap at >fixnum ]
        [ "center" swap at 3 0.0 pad-tail 4 1.0 pad-tail >float-4 ]
        [ "size"   swap at                4 1.0 pad-tail >float-4 ]
        [ "orient" swap at                               >float-4 ]
        [ "color"  swap at                               >float-4 ]
    } cleave ;

TYPED: slab-matrix ( slab: slab -- matrix: matrix4 )
    [ center>> translation-matrix4 ]
    [ size>> scale-matrix4 m4. ]
    [ orient>> q>matrix4 m4. ] tri ;

TYPED: update-slab-matrix ( slab: slab -- )
    dup slab-matrix >>matrix drop ;

TYPED: cycle-slab-frame ( slab: slab -- )
    dup images>> length '[ 1 + dup _ < [ drop 0 ] unless ] change-frame drop ;

: <slab> ( -- slab ) slab new ; inline

: set-up-slab ( name images frame center size orient color slab -- slab )
    swap >>color
    swap >>orient
    swap >>size
    swap >>center
    swap >>frame
    swap >>images
    swap >>name
    dup update-slab-matrix ; inline

TYPED: update-slab-for-atlas ( slab: slab images -- )
    [ dup images>> ] dip '[ _ at >float-4 ] float-4-array{ } map-as >>texcoords drop ;

: update-slabs-for-atlas ( slabs images -- )
    '[ _ update-slab-for-atlas ] each ; inline

: parse-papier-map ( hash -- slabs )
    check-papier-version
    "slabs" swap at [ parse-slab <slab> set-up-slab ] map ;

: load-papier-map ( path name -- slabs )
    append-path utf8 file-contents json> parse-papier-map ;

: load-papier-images ( path -- images atlas )
    [
        [ file-extension { "tiff" "png" } member? ] filter [ dup load-image ] H{ } map>assoc
    ] with-directory-files make-atlas-assoc ;

: slabs-by-name ( slabs -- assoc )
    [ name>> ] filter [ [ name>> ] keep ] H{ } map>assoc ; inline
