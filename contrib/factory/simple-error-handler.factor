USING: compiler alien xlib ; IN: simple-error-handler
LIBRARY: simple-error-handler
"simple-error-handler" "simple-error-handler.so" "cdecl" add-library
FUNCTION: void SetSimpleErrorHandler (  ) ;
\ SetSimpleErrorHandler compile
