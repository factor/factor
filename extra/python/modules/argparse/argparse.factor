USING: python.syntax ;
IN: python.modules.argparse

PY-FROM: argparse => ArgumentParser ( -- self ) ;
PY-METHODS: ArgumentParser =>
    add_argument ( self name ** -- )
    format_help ( self -- str ) ;
