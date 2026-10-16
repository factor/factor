USING: alien.c-types alien.syntax kernel present system webbrowser ;
IN: webbrowser.android

LIBRARY: factor-android

FUNCTION: void factor_android_open_url ( c-string url )

M: android open-item present factor_android_open_url ;
