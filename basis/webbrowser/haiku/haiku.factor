! See https://factorcode.org/license.txt for BSD license.
USING: arrays io.launcher kernel present system webbrowser ;
IN: webbrowser.haiku

M: haiku open-item
    present "open" swap 2array run-detached drop ;
