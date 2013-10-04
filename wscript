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

# List of prebuilt libraries to download to create the windows msi.
dlls = [
    ('blas.dll', '', 'ec84cbbecb0573369de8f6e94b576035'),
    ('bzip2.dll', '', '8a4efd59e29792f6400ce2e5c6799bea'),
    ('freetype6.dll', '', 'fe5ec4b2a07d2c20a4cd3aa09ce0c571'),
    ('glut32.dll', '', 'ae1f4dacacb463450dde420c0758666d'),
    ('iconv.dll', '', 'd7cbbedfad7ad68e12bf6ffcc01c3080'),
    ('intl.dll', '', '7b998b00a7c58475df42b10ef230b5b6'),
    ('jpeg62.dll', '', '43e5901bca2aa2efd21531d83f5628aa'),
    ('libasprintf-0.dll', '', '946ca7dae183e3cded6ca9505670340a'),
    ('libatk-1.0-0.dll', '', 'f95d9eefcf85aeca128c218cb23c90e2'),
    ('libcairo-2.dll', '', 'b2bb842451a11585d73b3eb65878ece9'),
    ('libcairo-gobject-2.dll', '', 'd16b292282398324baa2dd0408c9515e'),
    ('libcairo-script-interpreter-2.dll', '', '66eaa1bafa03beed6f1669e769013c25'),
    ('libeay32.dll', '', 'd2173e4ef025da800827ffba70636d06'),
    ('libexpat-1.dll', '', '3091605d9f53431b964351d80fe34ddf'),
    ('libexpat.dll', '', '85c3f3058b8d6d6332b48542957b8419'),
    ('libfontconfig-1.dll', '', '3d2d77ad23b8256c0cf97b36ffd64299'),
    ('libfreetype-6.dll', '', 'c5839d957d29968e579178aa854b8651'),
    ('libgailutil-18.dll', '', 'cf72818a626bb93eaab07f680f31a8dc'),
    ('libgcc_s_1.dll', '', '881bb0989256fec0e79811e76af449f9'),
    ('libgdk-win32-2.0-0.dll', '', '81cadf1413cadba0e3f67b52fd3f3c88'),
    ('libgdk_pixbuf-2.0-0.dll', '', '835daf325a93ca18d78c9a2a292567ca'),
    ('libgdkglext-win32-1.0-0.dll', '', '5f1420859ca7785c676e4ec852f3420f'),
    ('libgettextlib-0-17.dll', '', 'ef2510ac293a4e29c2b246cd458b6fca'),
    ('libgettextpo-0.dll', '', '1b48ba5651abb32b6b926542882e22c1'),
    ('libgettextsrc-0-17.dll', '', '7da6cd30f6a5d0ad749db8c22e67edac'),
    ('libgfortran-3.dll', '', 'd8d94f0272f7d7ab2b69a7df4e0716ad'),
    ('libgio-2.0-0.dll', '', '02a497b2768cda2b47969a0244c9b766'),
    ('libglade-2.0-0.dll', '', '12321a0e28e48530fb660de8eff0dbab'),
    ('libgladeui-1-7.dll', '', '69785194e326e864c76a21b0313a52b6'),
    ('libglib-2.0-0.dll', '', '8cc667edd3415395e21d79c3f83745ab'),
    ('libgmodule-2.0-0.dll', '', '47417c314255bb58b28f77c880a6c810'),
    ('libgobject-2.0-0.dll', '', '9f1f7d75728442258453d7ecec1a3e1a'),
    ('libgthread-2.0-0.dll', '', '86fc9bcaa15f979b0102ec86e2c75737'),
    ('libgtk-win32-2.0-0.dll', '', 'a38ccb75cd90a92afb6ff0cd295bf9e8'),
    ('libgtkglext-win32-1.0-0.dll', '', '4ff420d58e49067419cc8593635492ba'),
    ('libintl-8.dll', '', 'fd27a9a2a0bbbf1f9a1779585da702b1'),
    ('libjpeg-62.dll', '', '9f9eca580a68017026fa64c70a286610'),
    ('libltdl-3.dll', '', 'ffbaeae5c1c8f936332a01704963881b'),
    ('libobjc-2.dll', '', '8ec985516958a2c99f2ca8fa0ae6843d'),
    ('libpango-1.0-0.dll', '', '7fa55d38156d29623ebd1a883b8d0ad4'),
    ('libpangocairo-1.0-0.dll', '', '055c444be08945547b454bf86f6e5d7b'),
    ('libpangoft2-1.0-0.dll', '', '7360002ec4346643320c3ca577e9b9bf'),
    ('libpangowin32-1.0-0.dll', '', '5afe3a001c4cf23bb4341725fc5644c0'),
    ('libpng12-0.dll', '', '906e17e5ab42b7ceb127e72103c12395'),
    ('libpng12.dll', '', '19ce7c5d61434ab553024ef46b2643a5'),
    ('libpng14-14.dll', '', '33948c627ab6be9a5ce94a68878994f9'),
    ('libssp-0.dll', '', '51515b2264de2f8660cc46b7f3ebbc6b'),
    ('libstdc++-6.dll', '', '54a45223d73d6ea6dd5a1828d2b59195'),
    ('libtiff.dll', '', '4ad93cded54c071c9f6410b47c292a4e'),
    ('libudis86.dll', '', 'e7fb66c3f50469160ca992bd4d8b6544'),
    ('libxml2.dll', '', 'e75d9887e0a9a6fbb812b629f8ea0916'),
    ('sqlite3.dll', '', '7fa162fbf7a702b94810dbaec1bdacd7'),
    ('ssleay32.dll', '', 'fa71efc3a246f2f523d611ddc10e7db1'),
    ('zip32z64.dll', '', '10dc180ed4b49ddcd0ea2e61ae62259b'),
    ('zlib1.dll', '', '55c57c4c216ff91c8776ac2df0c5d94a')
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

def configure(ctx):
    ctx.env['MSVC_VERSIONS'] = ['msvc 10.0']
    ctx.load('compiler_c compiler_cxx')
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
    pf = ctx.options.prefix
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

def build(ctx):
    dest_os = ctx.env.DEST_OS
    dest_cpu = ctx.env.DEST_CPU

    image_target = '%s.image' % APPNAME

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
    vm_sources = [path.join('vm', s)
                  for s in common_source + os_sources[dest_os]]
    ctx.objects(includes = '.', source = vm_sources, target = 'OBJS')

    link_libs = os_uses[dest_os] + ['OBJS']
    features = 'cxx cxxprogram'

    if dest_os == 'win32':
        tg1 = ctx.program(
            features = features,
            source = [],
            target = APPNAME,
            use = link_libs,
            linkflags = '/SUBSYSTEM:console',
            name = 'factor-com'
        )
        tg1.env.cxxprogram_PATTERN = '%s.com'
        ctx.add_group()
        ctx.program(
            features = features,
            source = [],
            target = APPNAME,
            use = link_libs,
            linkflags = '/SUBSYSTEM:windows',
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

    # Build shared lib on Windows, static on Linux.
    # This is neede to trick waf into always building the dll after
    # the exe.
    ctx.add_group()
    if dest_os == 'win32':
        func = ctx.shlib
        features = 'cxx cxxshlib'
        linkflags = '/SUBSYSTEM:console'
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

    # Build factor.image using the newly built executable.
    os_family = {'linux' : 'unix', 'win32' : 'windows'}[dest_os]
    source_image = 'boot-images/boot.%s-x86.%s.image' % (os_family, bits)

    # On Windows, boot.image must reside in the projects root dir. Not
    # sure if, or why, it is different on Linux. -resource-path
    # doesn't seem to have much effect.
    boot_image = {'win32' : '../boot.image', 'linux' : 'boot.image'}[dest_os]
    ctx(
        features = 'subst',
        source = source_image,
        target = boot_image,
        is_copy = True
    )

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
        source = [factor_exe, boot_image],
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
            'factor.%s.msi' % VERSION,
            [image_target, '%s.com' % APPNAME]
        )
    pat = '(basis|core|extra)/**/*.(c|factor|pem|png|tiff|TXT|txt)'
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
