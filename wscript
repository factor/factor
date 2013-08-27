from os.path import join

APPNAME = 'factor'
VERSION = '0.96'

# List source files
common_source = [
    'aging_collector.cpp',
    'alien.cpp',
    'arrays.cpp',
    'bignum.cpp',
    'byte_arrays.cpp',
    'callbacks.cpp',
    'callstack.cpp',
    'code_blocks.cpp',
    'code_heap.cpp',
    'compaction.cpp',
    'contexts.cpp',
    'data_heap.cpp',
    'data_heap_checker.cpp',
    'debug.cpp',
    'dispatch.cpp',
    'entry_points.cpp',
    'errors.cpp',
    'factor.cpp',
    'free_list.cpp',
    'full_collector.cpp',
    'gc.cpp',
    'gc_info.cpp',
    'image.cpp',
    'inline_cache.cpp',
    'instruction_operands.cpp',
    'io.cpp',
    'jit.cpp',
    'math.cpp',
    'mvm.cpp',
    'nursery_collector.cpp',
    'object_start_map.cpp',
    'objects.cpp',
    'primitives.cpp',
    'quotations.cpp',
    'run.cpp',
    'safepoints.cpp',
    'sampling_profiler.cpp',
    'strings.cpp',
    'to_tenured_collector.cpp',
    'tuples.cpp',
    'utilities.cpp',
    'vm.cpp',
    'words.cpp'
    ]

def options(opt):
    opt.load('compiler_cxx')

def configure(conf):
    conf.load('compiler_cxx')
    conf.check(features='cxx cxxprogram', cflags=['-Wall'])
    env = conf.env
    dest_cpu = env.DEST_CPU
    dest_os = env.DEST_OS
    if dest_os == 'win32':
        conf.check_cxx(lib = 'shell32', uselib_store = 'shell32')
        env.LINKFLAGS.append('/SUBSYSTEM:console')
        env.CXXFLAGS.append('/EHsc')
        if dest_cpu == 'i386':
            env.LINKFLAGS.append('/safesh')
        conf.load('winres')
        env.WINRCFLAGS.append('/nologo')
        conf.define('_CRT_SECURE_NO_WARNINGS', None)
    elif dest_os == 'linux':
        conf.check_cxx(lib = 'pthread', uselib_store = 'pthread')
        conf.check_cxx(lib = 'dl', uselib_store = 'dl')
        conf.check_cxx(
            function_name = 'clock_gettime',
            header_name = ['sys/time.h','time.h'],
            lib = 'rt', uselib_store = 'rt'
        )

def build(bld):
    dest_os = bld.env.DEST_OS
    dest_cpu = bld.env.DEST_CPU
    if dest_os == 'win32':
        bits = {'amd64' : 64, 'i386' : 32}[dest_cpu]
        extra_source = [
            'cpu-x86.cpp',
            'main-windows.cpp',
            'mvm-windows.cpp',
            'os-windows.cpp',
            'factor.rc',
            'os-windows-x86.%d.cpp' % bits
            ]
        use = ['shell32']
    elif dest_os == 'linux':
        extra_source = [
            'cpu-x86.cpp',
            'main-unix.cpp',
            'mvm-unix.cpp',
            'os-genunix.cpp',
            'os-linux.cpp',
            'os-unix.cpp'
            ]
        use = ['dl', 'pthread', 'rt']
    else:
        raise Exception('Platform not implemented: %s' % dest_os)

    bld.program(
        features = 'cxx cxxprogram',
        source = [join('vm', s) for s in common_source + extra_source],
        includes = '.',
        target = 'factor',
        use = use
        )
