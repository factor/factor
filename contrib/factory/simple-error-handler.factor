IN: simple-error-handler USING: compiler alien xlib ;
LIBRARY: simple-error-handler
"simple-error-handler" "simple-error-handler.so" "cdecl" add-library
FUNCTION: void SetSimpleErrorHandler ( ) ;
\ SetSimpleErrorHandler compile
