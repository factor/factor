! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: colors kernel math sequences ;
IN: colors.mix

: linear-gradient ( color1 color2 percent -- color )
    [ 1.0 swap - * ] [ * ] bi-curry swapd
    [ [ >rgba-components drop ] [ tri@ ] bi* ] 2bi@
    [ + ] tri-curry@ tri* 1.0 <rgba> ;

:: sample-linear-gradient ( colors percent -- color )
    colors length :> num-colors
    num-colors 1 - percent * >integer :> left-index
    1.0 num-colors 1 - / :> cell-range
    percent left-index cell-range * - cell-range / :> alpha
    left-index colors nth :> left-color
    left-index 1 + num-colors mod colors nth :> right-color
    left-color right-color alpha linear-gradient ;
