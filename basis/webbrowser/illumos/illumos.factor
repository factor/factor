USING: arrays io.launcher kernel present system webbrowser ;
IN: webbrowser.illumos

M: illumos open-item
    present "xdg-open" swap 2array run-detached drop ;
