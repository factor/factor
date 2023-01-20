! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: io io.encodings.ascii math.parser sequences splitting
kernel assocs io.files combinators math.order math namespaces
arrays sequences.deep accessors alien.c-types alien.data
game.models game.models.util gpu.shaders images game.models.loader
prettyprint specialized-arrays make ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAYS: c:float c:uint ;
IN: game.models.obj

SINGLETON: obj-models
"obj" ascii obj-models register-models-class

<PRIVATE
SYMBOLS: vp vt vn current-model current-material material-dictionary models ;

TUPLE: material
    { name                     initial: f }
    { ambient-reflectivity     initial: { 1.0 1.0 1.0 } }
    { diffuse-reflectivity     initial: { 1.0 1.0 1.0 } }
    { specular-reflectivity    initial: { 1.0 1.0 1.0 } }
    { transmission-filter      initial: { 1.0 1.0 1.0 } }
    { dissolve                 initial: 1.0 }
    { specular-exponent        initial: 10.0 }
    { refraction-index         initial: 1.5 }
    { ambient-map              initial: f }
    { diffuse-map              initial: f }
    { specular-map             initial: f }
    { specular-exponent-map    initial: f }
    { dissolve-map             initial: f }
    { displacement-map         initial: f }
    { bump-map                 initial: f }
    { reflection-map           initial: f } ;

: cm ( -- current-material ) current-material get ; inline
: md ( -- material-dictionary ) material-dictionary get ; inline

: strings>numbers ( strings -- numbers )
    [ string>number ] map ;

: strings>faces ( strings -- faces )
    [ "/" split [ string>number ] map ] map ;

: split-string ( string -- strings )
    " \t\n" split harvest ;

: line>mtl ( line -- )
    " \t\n" split harvest [
        unclip {
            { "newmtl" [ first
                [ material new swap >>name current-material set ]
                [ cm swap md set-at ] bi
            ] }
            { "Ka"       [ 3 head strings>numbers cm ambient-reflectivity<<  ] }
            { "Kd"       [ 3 head strings>numbers cm diffuse-reflectivity<<  ] }
            { "Ks"       [ 3 head strings>numbers cm specular-reflectivity<< ] }
            { "Tf"       [ 3 head strings>numbers cm transmission-filter<<   ] }
            { "d"        [ first string>number cm    dissolve<<              ] }
            { "Ns"       [ first string>number cm    specular-exponent<<     ] }
            { "Ni"       [ first string>number cm    refraction-index<<      ] }
            { "map_Ka"   [ first cm                  ambient-map<<           ] }
            { "map_Kd"   [ first cm                  diffuse-map<<           ] }
            { "map_Ks"   [ first cm                  specular-map<<          ] }
            { "map_Ns"   [ first cm                  specular-exponent-map<< ] }
            { "map_d"    [ first cm                  dissolve-map<<          ] }
            { "map_bump" [ first cm                  bump-map<<              ] }
            { "bump"     [ first cm                  bump-map<<              ] }
            { "disp"     [ first cm                  displacement-map<<      ] }
            { "refl"     [ first cm                  reflection-map<<        ] }
            [ 2drop ]
        } case
    ] unless-empty ;

: read-mtl ( file -- material-dictionary )
    [
        f current-material ,,
        H{ } clone material-dictionary ,,
    ] H{ } make
    [
        ascii file-lines [ line>mtl ] each
        md
    ] with-variables ;

VERTEX-FORMAT: obj-vertex-format
    { "POSITION" float-components 3 f }
    { "TEXCOORD" float-components 2 f }
    { "NORMAL"   float-components 3 f } ;

: triangle>aos ( x -- y )
    dup length {
        { 3 [
            first3
            [ 1 - vp get nth ]
            [ 1 - vt get nth ]
            [ 1 - vn get nth ] tri* 3array flatten
        ] }
        { 2 [
            first2
            [ 1 - vp get nth ]
            [ 1 - vt get nth ] bi* 2array flatten
        ] }
    } case ;

: quad>aos ( x -- y z )
    [ 3 head [ triangle>aos 1array ] map ]
    [
        [ 2 swap nth ]
        [ 3 swap nth ]
        [ 0 swap nth ] tri 3array
        [ triangle>aos 1array ] map
    ] bi ;

: face>aos ( x -- y )
    dup length {
        { 3 [ [ triangle>aos 1array ] map 1array ] }
        { 4 [ quad>aos 2array ] }
    } case ;

: push* ( elt seq -- seq )
    [ push ] keep ;

: push-current-model ( -- )
    current-model get [
        [ dseq>> flatten c:float >c-array ]
        [ iseq>> flatten c:uint >c-array ]
        bi obj-vertex-format current-material get model boa models get push
        V{ } V{ } H{ } <indexed-seq> current-model set
    ] unless-empty ;

: line>obj ( line -- )
    split-string [
        unclip {
            { "mtllib" [ first read-mtl material-dictionary set ] }
            { "v"      [ strings>numbers 3 head vp [ push* ] change ] }
            { "vt"     [ strings>numbers 2 head vt [ push* ] change ] }
            { "vn"     [ strings>numbers 3 head vn [ push* ] change ] }
            { "usemtl" [ push-current-model first md at current-material set ] }
            { "f"      [ strings>faces face>aos [ [ current-model [ push* ] change ] each ] each ] }
            [ 2drop ]
        } case
    ] unless-empty ;

PRIVATE>

M: obj-models stream>models
    drop
    [
        V{ } clone vp ,,
        V{ } clone vt ,,
        V{ } clone vn ,,
        V{ } clone models ,,
        V{ } V{ } H{ } <indexed-seq> current-model ,,
        f current-material ,,
        f material-dictionary ,,
    ] H{ } make
    [
        [ line>obj ] each-stream-line push-current-model
        models get
    ] with-variables ;
