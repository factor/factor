USING: accessors assocs colors.contrast kernel math periodic-table
sequences tools.test ui.gadgets ui.pens ;
IN: periodic-table.tests

! Tile and legend text needs normal-text contrast, regardless of UI theme.
{ t } [
    group-colors values [
        <element-pen> f swap
        [ pen-background ] [ pen-foreground ] 2bi
        contrast-ratio 4.5 >=
    ] all?
] unit-test

! Exercise the actual element constructor, including every categorical color.
{ t } [
    118 <iota> [
        1 + <element> dup interior>>
        [ pen-background ] [ pen-foreground ] 2bi
        contrast-ratio 4.5 >=
    ] all?
] unit-test

! Names must fit within the uniform cell width without entering its border.
{ t } [
    118 <iota> [
        1 + <element>
        [ pref-dim first 10 - ]
        [ children>> first children>> last pref-dim first ] bi
        >=
    ] all?
] unit-test
