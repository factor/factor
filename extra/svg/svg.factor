! (c)2009 Joe Groff, see BSD license

USING: accessors arrays assocs kernel math
math.affine-transforms math.functions math.parser
peg.ebnf sequences sequences.squish splitting strings xml.data
xml.syntax multiline ;

IN: svg

XML-NS: svg-name http://www.w3.org/2000/svg
XML-NS: xlink-name http://www.w3.org/1999/xlink
XML-NS: sodipodi-name http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd
XML-NS: inkscape-name http://www.inkscape.org/namespaces/inkscape

: svg-string>number ( string -- number )
    H{ { CHAR: E CHAR: e } } substitute "e" split1
    [ string>number ] [ [ string>number 10^ ] [ 1 ] if* ] bi* *
    >float ;

EBNF: svg-transform>affine-transform [=[

transforms =
    transform:m comma-wsp+ transforms:n => [[ m n a. ]]
    | transform
transform =
    matrix
    | translate
    | scale
    | rotate
    | skewX
    | skewY
matrix =
    "matrix" wsp* "(" wsp*
       number:xx comma-wsp
       number:xy comma-wsp
       number:yx comma-wsp
       number:yy comma-wsp
       number:ox comma-wsp
       number:oy wsp* ")"
        => [[ { xx xy } { yx yy } { ox oy } <affine-transform> ]]
translate =
    "translate" wsp* "(" wsp* number:tx ( comma-wsp number:ty => [[ ty ]] )?:ty wsp* ")"
        => [[ tx ty 0.0 or 2array <translation> ]]
scale =
    "scale" wsp* "(" wsp* number:sx ( comma-wsp number:sy => [[ sy ]] )?:sy wsp* ")"
        => [[ sx sy sx or <scale> ]]
rotate =
    "rotate" wsp* "(" wsp* number:a ( comma-wsp number:cx comma-wsp number:cy => [[ cx cy 2array ]])?:c wsp* ")"
        => [[ a deg>rad <rotation> c [ center-rotation ] when* ]]
skewX =
    "skewX" wsp* "(" wsp* number:a wsp* ")"
        => [[ { 1.0 0.0 } a deg>rad tan 1.0 2array { 0.0 0.0 } <affine-transform> ]]
skewY =
    "skewY" wsp* "(" wsp* number:a wsp* ")"
        => [[ 1.0 a deg>rad tan 2array { 0.0 1.0 } { 0.0 0.0 } <affine-transform> ]]
number =
    sign? (floating-point-constant | integer-constant) => [[ squish-strings svg-string>number ]]
comma-wsp =
    (wsp+ comma? wsp*) | (comma wsp*)
comma =
    ","
integer-constant =
    digit-sequence
floating-point-constant =
    fractional-constant exponent?
    | digit-sequence exponent
fractional-constant =
    digit-sequence? "." digit-sequence
    | digit-sequence "."
exponent =
    ( "e" | "E" ) sign? digit-sequence
sign =
    "+" => [[ f ]] | "-"
digit-sequence = [0-9]+ => [[ >string ]]
wsp = [ \t\r\n]

transform-list = wsp* transforms?:t wsp*
    => [[ t [ identity-transform ] unless* ]]

]=]

: tag-transform ( tag -- transform )
    "transform" svg-name attr svg-transform>affine-transform ;

TUPLE: moveto p relative? ;
TUPLE: closepath ;
TUPLE: lineto p relative? ;
TUPLE: horizontal-lineto x relative? ;
TUPLE: vertical-lineto y relative? ;
TUPLE: curveto p1 p2 p relative? ;
TUPLE: smooth-curveto p2 p relative? ;
TUPLE: quadratic-bezier-curveto p1 p relative? ;
TUPLE: smooth-quadratic-bezier-curveto p relative? ;
TUPLE: elliptical-arc radii x-axis-rotation large-arc? sweep? p relative? ;

: (set-relative) ( args rel -- args )
    '[ [ _ >>relative? drop ] each ] keep ;

EBNF: svg-path>array [=[

moveto-drawto-command-groups =
    moveto-drawto-command-group:first wsp* moveto-drawto-command-groups:rest
        => [[ first rest append ]]
    | moveto-drawto-command-group
moveto-drawto-command-group =
    moveto:m wsp* drawto-commands?:d => [[ m d append ]]
drawto-commands =
    drawto-command:first wsp* drawto-commands:rest => [[ first rest append ]]
    | drawto-command
drawto-command =
    closepath
    | lineto
    | horizontal-lineto
    | vertical-lineto
    | curveto
    | smooth-curveto
    | quadratic-bezier-curveto
    | smooth-quadratic-bezier-curveto
    | elliptical-arc
moveto =
    ("M" => [[ f ]] | "m" => [[ t ]]):rel wsp* moveto-argument-sequence:args
        => [[ args rel (set-relative) ]]
moveto-argument = coordinate-pair => [[ f moveto boa ]]
moveto-argument-sequence =
    moveto-argument:first comma-wsp? lineto-argument-sequence:rest
        => [[ rest first prefix ]]
    | moveto-argument => [[ 1array ]]
closepath =
    ("Z" | "z") => [[ drop closepath boa 1array ]]
lineto =
    ("L" => [[ f ]] | "l" => [[ t ]]):rel wsp* lineto-argument-sequence:args
        => [[ args rel (set-relative) ]]
lineto-argument = coordinate-pair => [[ f lineto boa ]]
lineto-argument-sequence =
    lineto-argument:first comma-wsp? lineto-argument-sequence:rest
        => [[ rest first prefix ]]
    | lineto-argument => [[ 1array ]]
horizontal-lineto =
    ( "H" => [[ f ]] | "h" => [[ t ]]):rel wsp* horizontal-lineto-argument-sequence:args
        => [[ args rel (set-relative) ]]
horizontal-lineto-argument = coordinate => [[ f horizontal-lineto boa ]]
horizontal-lineto-argument-sequence =
    horizontal-lineto-argument:first comma-wsp? horizontal-lineto-argument-sequence:rest
        => [[ rest first prefix ]]
    | horizontal-lineto-argument => [[ 1array ]]
vertical-lineto =
    ( "V" => [[ f ]] | "v" => [[ t ]]):rel wsp* vertical-lineto-argument-sequence:args
        => [[ args rel (set-relative) ]]
vertical-lineto-argument = coordinate => [[ f vertical-lineto boa ]]
vertical-lineto-argument-sequence =
    vertical-lineto-argument:first comma-wsp? vertical-lineto-argument-sequence:rest
        => [[ rest first prefix ]]
    | vertical-lineto-argument => [[ 1array ]]
curveto =
    ( "C" => [[ f ]] | "c" => [[ t ]]):rel wsp* curveto-argument-sequence:args
        => [[ args rel (set-relative) ]]
curveto-argument-sequence =
    curveto-argument:first comma-wsp? curveto-argument-sequence:rest
        => [[ rest first prefix ]]
    | curveto-argument => [[ 1array ]]
curveto-argument =
    coordinate-pair:pone comma-wsp? coordinate-pair:ptwo comma-wsp? coordinate-pair:p
        => [[ pone ptwo p f curveto boa ]]
smooth-curveto =
    ( "S" => [[ f ]] | "s" => [[ t ]] ):rel wsp* smooth-curveto-argument-sequence:args
        => [[ args rel (set-relative) ]]
smooth-curveto-argument-sequence =
    smooth-curveto-argument:first comma-wsp? smooth-curveto-argument-sequence:rest
        => [[ rest first prefix ]]
    | smooth-curveto-argument => [[ 1array ]]
smooth-curveto-argument =
    coordinate-pair:ptwo comma-wsp? coordinate-pair:p
        => [[ ptwo p f smooth-curveto boa ]]
quadratic-bezier-curveto =
    ( "Q" => [[ f ]] | "q" => [[ t ]] ):rel wsp* quadratic-bezier-curveto-argument-sequence:args
        => [[ args rel (set-relative) ]]
quadratic-bezier-curveto-argument-sequence =
    quadratic-bezier-curveto-argument:first comma-wsp? 
        quadratic-bezier-curveto-argument-sequence:rest
        => [[ rest first prefix ]]
    | quadratic-bezier-curveto-argument => [[ 1array ]]
quadratic-bezier-curveto-argument =
    coordinate-pair:pone comma-wsp? coordinate-pair:p
        => [[ pone p f quadratic-bezier-curveto boa ]]
smooth-quadratic-bezier-curveto =
    ( "T" => [[ f ]] | "t" => [[ t ]] ):rel wsp* smooth-quadratic-bezier-curveto-argument-sequence:args
        => [[ args rel (set-relative) ]]
smooth-quadratic-bezier-curveto-argument-sequence =
    smooth-quadratic-bezier-curveto-argument:first comma-wsp? smooth-quadratic-bezier-curveto-argument-sequence:rest
        => [[ rest first prefix ]]
    | smooth-quadratic-bezier-curveto-argument => [[ 1array ]]
smooth-quadratic-bezier-curveto-argument = coordinate-pair => [[ f smooth-quadratic-bezier-curveto boa ]]
elliptical-arc =
    ( "A" => [[ f ]] | "a" => [[ t ]] ):rel wsp* elliptical-arc-argument-sequence:args
        => [[ args rel (set-relative) ]]
elliptical-arc-argument-sequence =
    elliptical-arc-argument:first comma-wsp? elliptical-arc-argument-sequence:rest
        => [[ rest first prefix ]]
    | elliptical-arc-argument => [[ 1array ]]
elliptical-arc-argument =
    nonnegative-number:radiix comma-wsp? nonnegative-number:radiiy comma-wsp? 
        number:xrot comma-wsp flag:large comma-wsp flag:sweep
        comma-wsp coordinate-pair:p
        => [[ radiix radiiy 2array xrot large sweep p f elliptical-arc boa ]]
coordinate-pair = coordinate:x comma-wsp? coordinate:y => [[ x y 2array ]]
coordinate = number
nonnegative-number = (floating-point-constant | integer-constant) => [[ squish-strings svg-string>number ]]
number = sign? (floating-point-constant | integer-constant) => [[ squish-strings svg-string>number ]]
flag = "0" => [[ f ]] | "1" => [[ t ]]
comma-wsp = (wsp+ comma? wsp*) | (comma wsp*)
comma = ","
integer-constant = digit-sequence
floating-point-constant = fractional-constant exponent?  | digit-sequence exponent
fractional-constant = digit-sequence? "." digit-sequence | digit-sequence "."
exponent = ( "e" | "E" ) sign? digit-sequence
sign = "+" => [[ drop f ]] | "-"
digit-sequence = [0-9]+ => [[ >string ]]
wsp = [ \t\r\n]

svg-path = wsp* moveto-drawto-command-groups?:x wsp* => [[ x ]]

]=]

: tag-d ( tag -- d )
    "d" svg-name attr svg-path>array ;
