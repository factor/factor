USING: help.markup help.syntax ;
IN: colors.yiq

HELP: yiqa
{ $class-description "The class of YIQ (Y, In-Place, Quadrature) colors with an alpha channel. All slots store values in the interval " { $snippet "[0,1]" } "." } ;

ARTICLE: "colors.yiq" "YIQ colors"
"The " { $vocab-link "colors.yiq" } " vocabulary implements colors specified by their Y, in-place, and quadrature components, together with an alpha channel."
{ $subsections
    yiqa
    <yiqa>
    >yiqa
}
{ $see-also "colors" } ;

ABOUT: "colors.yiq"
