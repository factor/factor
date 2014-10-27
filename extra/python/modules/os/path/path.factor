USING: python.syntax ;
IN: python.modules.os.path

PY-FROM: os.path =>
    basename ( x -- x' )
    splitext ( x -- base ext ) ;
