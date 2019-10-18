CPU=$1

if [ "$CPU" = "x86.32" ]; then
	TARGET="macosx-x86"
elif [ "$CPU" = "ppc" ]; then
	TARGET="macosx-ppc"
	CPU = "macosx-ppc"
else
	echo "Specify a CPU"
	exit 1
fi

EXE=factor

bash misc/integration/test.sh \
	$EXE \
	$CPU \
	$TARGET \
	no \
	no \
	no \
	"X11=1" \
	"-ui-backend=x11" \
	"-x11" || exit 1

echo "Testing deployment"
$EXE "misc/integration/x11-deploy.factor" -run=none </dev/null

EXE=Factor.app/Contents/MacOS/factor

bash misc/integration/test.sh \
	$EXE \
	$CPU \
	$TARGET \
	yes \
	yes \
	yes \
	"" \
	"" \
	""

echo "Testing deployment"
$EXE "misc/integration/macosx-deploy.factor" -run=none </dev/null
