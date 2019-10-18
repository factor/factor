USING: accessors fuel.listener io.serial.linux io.serial.linux.ffi
kernel libc math.bitwise sequences system ;
IN: fuel.listener.linux

: flush-termios ( termios fileno -- )
    TCSAFLUSH rot tcsetattr io-error ;

: set-raw-flags ( termios -- )
    [ ICANON unmask ECHO unmask ] change-lflag
    cc>> [ 1 VMIN rot set-nth ] [ 0 VTIME rot set-nth ] bi ;

M: linux fuel-pty-setup
    0 get-fd-termios dup set-raw-flags 0 flush-termios ;
