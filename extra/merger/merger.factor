USING: accessors arrays file-picker io.directories kernel
math.rectangles models sequences sets ui ui.gadgets
ui.gadgets.buttons ui.gadgets.glass ui.gadgets.labeled
ui.gadgets.labels ui.gadgets.tracks ;
IN: merger

MAIN-WINDOW: merger-window {
        { title "Merging" }
        { pref-dim { 300 220 } }
    }
    vertical <track>
    { "From:" "To:" } f <model> f <model> 2array
    [
        [
            "…" [
                open-file-dialog [
                    first
                    [ <label> 1array >>children drop ]
                    [ swap set-control-value ] 2bi
                ] [ drop ] if*
            ] <border-button> swap >>model swap
            <labeled-gadget> 1 track-add
        ] 2each
    ] keep
    dup first2
    '[
        _ [ value>> ] all? [
            parent>> "processing..." <label> [
                <zero-rect> show-glass
                _ value>> [
                    "." _ value>>
                    [ [ directory-files ] bi@ diff ] keep copy-files-into
                ] with-directory
            ] keep hide-glass
        ] [ drop ] if
    ] "merge" swap <border-button> 0.4 track-add
    >>gadgets ;
