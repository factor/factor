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

def options(ctx):
    ctx.load('compiler_cxx')

def configure(ctx):
    ctx.load('compiler_cxx')
    ctx.check(features='cxx cxxprogram', cflags=['-Wall'])
    env = ctx.env
    dest_cpu = env.DEST_CPU
    dest_os = env.DEST_OS
    bits = {'amd64' : 64, 'i386' : 32, 'x86_64' : 64}[dest_cpu]
    if dest_os == 'win32':
        ctx.check_lib_msvc('shell32')
        env.CXXFLAGS += ['/EHsc', '/O2', '/WX', '/W3']
        if dest_cpu == 'i386':
            env.LINKFLAGS.append('/safesh')
        ctx.load('winres')
        env.WINRCFLAGS.append('/nologo')
        ctx.define('_CRT_SECURE_NO_WARNINGS', None)
    elif dest_os == 'linux':
        # Lib checking
        ctx.check_cxx(lib = 'pthread', uselib_store = 'pthread')
        ctx.check_cxx(lib = 'dl', uselib_store = 'dl')
        ctx.check_cxx(
            function_name = 'clock_gettime',
            header_name = ['sys/time.h','time.h'],
            lib = 'rt', uselib_store = 'rt'
        )
        ctx.check_cfg(atleast_pkgconfig_version='0.0.0')
        ctx.check_cfg(
            package = 'gtk+-2.0',
            uselib_store = 'gtk',
            atleast_version = '2.18.0',
            args = '--cflags --libs',
            mandatory = True
        )
        ctx.check_cfg(
            package = 'gtkglext-1.0',
            uselib_store = 'gtkglext',
            atleast_version = '1.0.0',
            args = '--cflags --libs',
            mandatory = True
        )

        # Standard flags
        env.CXXFLAGS += ['-O3', '-fomit-frame-pointer']
        if bits == 64:
            env.CXXFLAGS += ['-m64']
        env.LINKFLAGS += ['-Wl,--no-as-needed', '-Wl,--export-dynamic']

def build(ctx):
    dest_os = ctx.env.DEST_OS
    dest_cpu = ctx.env.DEST_CPU

    bits = {'amd64' : 64, 'i386' : 32, 'x86_64' : 64}[dest_cpu]
    os_sources = {
        'win32' : [
            'cpu-x86.cpp',
            'main-windows.cpp',
            'mvm-windows.cpp',
            'os-windows.cpp',
            'factor.rc',
            'os-windows-x86.%d.cpp' % bits
            ],
        'linux' : [
            'cpu-x86.cpp',
            'main-unix.cpp',
            'mvm-unix.cpp',
            'os-genunix.cpp',
            'os-linux.cpp',
            'os-unix.cpp'
            ]
        }
    os_uses = {
        'win32' : ['SHELL32'],
        'linux' : ['dl', 'gtk', 'gtkglext', 'pthread', 'rt']
        }
    vm_sources = [join('vm', s) for s in common_source + os_sources[dest_os]]
    ctx.objects(includes = '.', source = vm_sources, target = 'OBJS')

    link_libs = os_uses[dest_os] + ['OBJS']
    features = 'cxx cxxprogram'

    if dest_os == 'win32':
        ctx.program(
            features = features,
            source = [],
            target = APPNAME,
            use = link_libs,
            linkflags = '/SUBSYSTEM:windows'
            )
        # The node name can't be factor.com because it will clash with
        # the previously created factor.exe node.
        target = ctx.path.get_bld().make_node('tmp.com')
        ctx.program(
            features = features,
            source = [],
            target = target,
            use = link_libs,
            linkflags = '/SUBSYSTEM:console'
            )
        ctx(
            rule = 'mv ${SRC} ${TGT}',
            source = 'tmp.com',
            target = 'factor.com'
            )
    elif dest_os == 'linux':
        ctx.program(
            features = features,
            source = [],
            target = APPNAME,
            use = link_libs,
            )
