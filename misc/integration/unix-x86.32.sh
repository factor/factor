bash misc/integration/test.sh \
	./factor \
	x86.32 \
	$1-x86 \
	yes \
	yes \
	yes \
	"" \
	"" \
	"" || exit 1

bash misc/integration/test.sh \
	./factor \
	x86.32 \
	$1-x86 \
	yes \
	yes \
	yes \
	"" \
	"-no-sse2" \
	"-no-sse2"
