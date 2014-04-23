from checksums import dlls
from hashlib import md5
from os import path
from urllib import urlopen
from waflib import Errors, Task

APPNAME = 'factor-lang'
VERSION = '0.97-git'

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

def wix_light(ctx, source, target, extra_files):
    wixobjs = ' '.join(source)
    return ctx(
        rule = 'light -ext WixUIExtension -nologo -out ${TGT} %s' % wixobjs,
        source = source + extra_files,
        target = target
        )

def wix_heat_dir(ctx, group, dirpath, source = None):
    if source is None:
        source = []
    # -sw 5150 suppresses warning about self-registering dlls.
    rule_fmt = ('heat dir %s -sw 5150 -nologo -var var.MySource '
                '-cg %sgroup -gg -dr INSTALLDIR -out ${TGT}')
    return ctx(
        rule = rule_fmt % (dirpath, group),
        source = source,
        target = '%s.wxs' % group
        )

def wix_candle(ctx, group, dirpath):
    return ctx(
        rule = 'candle -nologo -out ${TGT} ${SRC} -dMySource="%s"' % dirpath,
        source = ['%s.wxs' % group],
        target = ['%s.wxsobj' % group]
        )

# This monkey patching enables syncronous output from rule tasks.
# https://groups.google.com/d/msg/waf-users/2uA3DEltTKg/8T4X9I4OeeQJ
def my_exec_command(self, cmd, **kw):
    bld = self.generator.bld
    if not kw.get('cwd'):
        cwd = getattr(bld, 'cwd', bld.variant_dir)
        bld.cwd = kw['cwd'] = cwd

    kw["stdout"] = kw["stderr"] = None
    return bld.exec_command(cmd, **kw)
Task.TaskBase.exec_command = my_exec_command

def options(ctx):
    ctx.load('compiler_c compiler_cxx')
    ctx.add_option(
        '--make-bootstrap-image',
        action = 'store_true',
        default = False,
        help = 'Generate new boot images (requires Factor to be installed)'
    )

def configure(ctx):
    ctx.load('compiler_c compiler_cxx')
    ctx.check(features='cxx cxxprogram', cflags=['-Wall'])
    env = ctx.env
    dest_os = env.DEST_OS
    bits = get_bits(ctx)
    opts = ctx.options

    if opts.make_bootstrap_image:
        ctx.find_program(APPNAME)
    ctx.env.MAKE_BOOTSTRAP_IMAGE = opts.make_bootstrap_image

    cxx = ctx.env.COMPILER_CXX
    if dest_os == 'win32':
        ctx.check_lib_msvc('shell32')
        ctx.load('winres')
        if cxx == 'msvc':
            env.WINRCFLAGS.append('/nologo')
            env.CXXFLAGS += ['/EHsc', '/O2', '/WX', '/W3']
            if bits == 32:
                env.LINKFLAGS.append('/safesh')
        elif cxx == 'g++':
            env.LINKFLAGS.extend(['-static-libgcc', '-static-libstdc++', '-s'])
            env.CXXFLAGS += ['-O2', '-fomit-frame-pointer']
        ctx.define('_CRT_SECURE_NO_WARNINGS', None)
        # WIX checks
        ctx.find_program('candle')
        ctx.find_program('heat')
        ctx.find_program('light')
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

        env.CXXFLAGS += ['-O3', '-fomit-frame-pointer']
        if bits == 64:
            env.CXXFLAGS += ['-m64']
        env.LINKFLAGS += ['-Wl,--no-as-needed', '-Wl,--export-dynamic']
    pf = opts.prefix
    if dest_os == 'win32':
        pf = pf.replace('\\', '\\\\')
    ctx.define('INSTALL_PREFIX', pf)

def download_file(self):
    gen = self.generator
    url = gen.url
    expected_digest = gen.digest
    local_path = self.outputs[0].abspath()
    if path.exists(local_path):
        with open(local_path, 'rb') as f:
            digest = md5(f.read()).hexdigest()
            if digest == expected_digest:
                return
    data = urlopen(url).read()
    digest = md5(data).hexdigest()
    if digest != expected_digest:
        fmt = 'Digest mismatch: File %s has digest %s, expected %s.'
        raise Errors.WafError(fmt % (url, digest, expected_digest))
    with open(local_path, 'wb') as f:
        f.write(data)
    return

def get_bits(ctx):
    types = {'amd64' : 64, 'i386' : 32, 'x86' : 32, 'x86_64' : 64}
    return types[ctx.env.DEST_CPU]

def build_msi(ctx, bits, image_target):
    # Download all dlls needed for the build
    dll_targets = []
    url_fmt = 'http://downloads.factorcode.org/dlls/%s%s'
    for name, digest32, digest64 in dlls:
        digest = digest32 if bits == 32 else digest64
        url = url_fmt % ('' if bits == 32 else '64/', name)
        r = ctx(
            rule = download_file,
            url = url,
            digest = digest,
            target = 'dlls/%s' % name,
            always = True
            )
        dll_targets.append(r.target)

    # Generate wxs fragments of the Factor sources.
    frags = ['core', 'basis', 'extra', 'misc']
    fmt = 'heat dir ../%s -nologo -var var.MySource -cg %sgroup -gg -dr INSTALLDIR -out ${TGT}'
    for root in frags:
        wix_heat_dir(ctx, root, '../%s' % root)
        wix_candle(ctx, root, '../%s' % root)

    # Generate one wxs fragment for all bundled dlls.
    wix_heat_dir(ctx, 'dlls', 'dlls', source = dll_targets)
    wix_candle(ctx, 'dlls', 'dlls')

    # Wix wants the Product/@Version attribute to be all
    # numeric. So if you have a version like 0.97-git, you need to
    # strip out the -git part.
    product_version = VERSION.split('-')[0]
    ctx(
        rule = 'candle -nologo -dProductVersion=%s -dVersion=%s ' \
            '-out ${TGT} ${SRC}' % (product_version, VERSION),
        source = ['factor.wxs'],
        target = ['factor.wxsobj']
        )
    wxsobjs = ['%s.wxsobj' % f for f in ['factor', 'dlls'] + frags]
    wix_light(
        ctx,
        wxsobjs,
        'factor.%dbit.%s.msi' % (bits, VERSION),
        [image_target, '%s.com' % APPNAME]
        )


def build(ctx):
    dest_os = ctx.env.DEST_OS
    image_target = '%s.image' % APPNAME

    bits = get_bits(ctx)
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
    vm_sources = [path.join('vm', s)
                  for s in common_source + os_sources[dest_os]]
    ctx.objects(includes = '.', source = vm_sources, target = 'OBJS')

    link_libs = os_uses[dest_os] + ['OBJS']
    features = 'cxx cxxprogram'

    if dest_os == 'win32':
        cxx = ctx.env.COMPILER_CXX
        subsys_fmt = '/SUBSYSTEM:%s' if cxx == 'msvc' else '-Wl,-subsystem,%s'
        tg1 = ctx.program(
            features = features,
            source = [],
            target = APPNAME,
            use = link_libs,
            linkflags = subsys_fmt % 'console',
            name = 'factor-com'
        )
        tg1.env.cxxprogram_PATTERN = '%s.com'
        ctx.add_group()
        ctx.program(
            features = features,
            source = [],
            target = APPNAME,
            use = link_libs,
            linkflags = subsys_fmt % 'windows',
            name = 'factor-exe'
            )
    elif dest_os == 'linux':
        ctx.program(
            features = features,
            source = [],
            target = APPNAME,
            use = link_libs
        )

    # Common paths
    libdir = '${PREFIX}/lib/factor'
    cwd = ctx.path

    # Build ffi test library. It is used by some unit tests.
    ctx.shlib(
        target = 'factor-ffi-test',
        source = ['vm/ffi_test.c'],
        install_path = libdir
        )

    # Build shared lib on Windows, static on Linux.  This is needed to
    # trick waf into always building the dll after the exe.
    ctx.add_group()
    if dest_os == 'win32':
        func = ctx.shlib
        features = 'cxx cxxshlib'
        linkflags = subsys_fmt % 'console'
    elif dest_os == 'linux':
        func = ctx.stlib
        features = 'cxx cxxstlib'
        linkflags = []
    func(
        features = features,
        target = APPNAME,
        source = [],
        install_path = libdir,
        use = link_libs,
        linkflags = linkflags
    )
    os_family = {'linux' : 'unix', 'win32' : 'windows'}[dest_os]
    boot_image_name = 'boot.%s-x86.%s.image' % (os_family, bits)

    # Since factor-lang needs to be run with the project root
    # directory as cwd, that is where the boot image needs to be
    # placed.
    boot_image_path = '../%s' % boot_image_name

    if ctx.env.MAKE_BOOTSTRAP_IMAGE:
        # Backslashes are misinterpreted by Factor on Windows
        resource_path = cwd.abspath().replace('\\', '/')
        params = [
            '-resource-path=%s' % resource_path,
            '-script',
            '-e="USING: system bootstrap.image vocabs.refresh ; '
            'refresh-all make-my-image"',
        ]
        ctx(
            rule = '"%s" %s' % (ctx.env['FACTOR-LANG'], ' '.join(params)),
            source = [],
            target = boot_image_path
        )
    else:
        source_image = 'boot-images/%s' % boot_image_name
        ctx(
            features = 'subst',
            source = source_image,
            target = boot_image_path,
            is_copy = True
        )

    # Build factor.image using the newly built executable.
    factor_exe = {'linux' : APPNAME, 'win32' : '%s.com' % APPNAME}[dest_os]

    # The first image we build doesn't contain local changes for some
    # reason. Not sure how resource-path works in combination with a
    # boot image on Windows. Seems like the resource-path switch
    # doesn't work in that case.
    old_image = '%s.incomplete.image' % APPNAME
    params = [
        '-i=${SRC[1].abspath()}',
        '-resource-path=%s' % cwd.abspath(),
        '-output-image=%s' % old_image
    ]
    ctx(
        rule = '${SRC[0].abspath()} ' + ' '.join(params),
        source = [factor_exe, boot_image_path],
        target = old_image
    )

    # Image built, but it needs to be updated too.
    params = [
        '-script',
        '-resource-path=..',
        '-i=%s' % old_image,
        '-e="USING: vocabs.loader vocabs.refresh system memory ; '
        'refresh-all \\"%s\\" save-image-and-exit"' % image_target
    ]
    ctx(
        rule = '${SRC[0].abspath()} ' + ' '.join(params),
        source = [factor_exe, old_image],
        target = image_target
    )

    # Installer and installation targets.
    if dest_os == 'win32':
        build_msi(ctx, bits, image_target)

    pat = '(basis|core|extra)/**/*.*'
    glob = cwd.ant_glob(pat)

    ctx.install_files(libdir, glob, cwd = cwd, relative_trick = True)
    ctx.install_files(libdir, 'license.txt', cwd = cwd)

    # Install stuff in misc
    sharedir = '${PREFIX}/share/factor'
    base = cwd.find_dir('misc')
    pat = '(fuel|icons|textadept|vim)/**/*.(el|lua|png|vim)'
    glob = base.ant_glob(pat)
    ctx.install_files(sharedir, glob, cwd = base, relative_trick = True)

    # Install image
    ctx.install_files(libdir, image_target)
    ctx.symlink_as(
        '${PREFIX}/bin/%s' % image_target,
        '../lib/factor/%s' % image_target
    )
