IN: win32
USING: alien parser namespaces kernel syntax words math io prettyprint ;

SYMBOL: unicode f unicode set

: unicode-exec ( unicode-func ascii-func -- func )
	unicode get [
		drop execute
	] [
		nip execute
	] if ; inline

