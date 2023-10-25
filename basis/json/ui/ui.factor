USING: json kernel strings ui.clipboards ui.operations ;
IN: json.ui

: copy-json ( obj -- )
    >json >clipboard ;

[ string? not ] \ copy-json H{ } define-operation
