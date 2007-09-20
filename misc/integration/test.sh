EXE=$1
CPU=$2
TARGET=$3
LOAD_P=$4
TEST_P=$5
BENCHMARK_P=$6
MAKE_FLAGS=$7
BOOT_FLAGS=$8
VARIANT=$9

PREFIX=misc/integration/results-$CPU$VARIANT

mkdir -p $PREFIX

VM_LOG=$PREFIX/vm.log
BOOT_LOG=$PREFIX/boot.log
LOAD_LOG=$PREFIX/load.log
TEST_LOG=$PREFIX/test.log
BENCHMARK_LOG=$PREFIX/benchmark.log

echo "Output files:"
echo "VM compilation:  $VM_LOG"
echo "Bootstrap:       $BOOT_LOG"
echo "Load everything: $LOAD_LOG"
echo "Unit tests:      $TEST_LOG"
echo "Benchmarks:      $BENCHMARK_LOG"

IMAGE=factor.image

echo
echo
echo

echo "Compiling VM"
${MAKE-make} clean $TARGET $MAKE_FLAGS >$VM_LOG </dev/null

if [ "$?" -ne 0 ]; then
	echo "VM compile failed"
	exit 1
fi

echo "Bootstrap"
rm -f $IMAGE

$EXE -i=boot.$CPU.image \
	-no-user-init \
	$BOOT_FLAGS \
	-output-image=$IMAGE >$BOOT_LOG </dev/null

if [ ! -e "factor.image" ]; then
	echo "Bootstrap failed"
	exit 1
fi

# Load all modules; run tests
if [ "$LOAD_P" = "yes" ]; then
	echo "Testing loading of all modules"

	echo "USE: tools.browser load-everything USE: memory save USE: system 123 exit" \
		>/tmp/factor-$$

	$EXE -i=$IMAGE \
		/tmp/factor-$$ \
		-run=none \
		>$LOAD_LOG </dev/null

	if [ "$?" -ne 123 ]; then
		echo "Load-everything failed"
		exit 1
	fi

	# Check for parser notes
	grep "automatically using" $LOAD_LOG

	if [ "$?" -eq 0 ]; then
		echo "Missing USE: declarations"
		# exit 1
	fi
fi

# Run unit tests
if [ "$TEST_P" = "yes" ]; then
	echo "Running all unit tests"

	$EXE -i=$IMAGE "-e=test-all" -run=none >$TEST_LOG </dev/null
fi

# Run benchmarks
if [ "$BENCHMARK_P" = "yes" ]; then
	echo "Running all benchmarks"

	$EXE -i=$IMAGE "-run=benchmark" >$BENCHMARK_LOG </dev/null
fi
