# Checksums used on Windows to verify integrity of downloaded dlls.
from hashlib import md5
from urllib import urlopen

# List of prebuilt libraries to download to create the windows msi.
dlls = [
    ('blas.dll', '63017771c424146f8ddcee266d7a9446', 'ec84cbbecb0573369de8f6e94b576035'),
    ('bzip2.dll', 'dad3794d8c75a83397d0fd19a606bafd', '8a4efd59e29792f6400ce2e5c6799bea'),
    ('freetype6.dll', 'e7f5fa7772dd00ef6a2299ba27e8eccc', 'fe5ec4b2a07d2c20a4cd3aa09ce0c571'),
    ('glut32.dll', 'f52d9f3211af6c8ca2b48af0f1469990', 'ae1f4dacacb463450dde420c0758666d'),
    ('iconv.dll', '73af5773bf5627fe771bf6809ec839f9', '15aa5d1b23e701b3fc1cae83df7c711d'),
    ('intl.dll', '9f95ece3d2b3909de4d9147c4d93f976', '7b998b00a7c58475df42b10ef230b5b6'),
    ('jpeg62.dll', 'd0025b74aa9f2737979df053419266ca', '43e5901bca2aa2efd21531d83f5628aa'),
    ('libasprintf-0.dll', '9c23583e944c69e01371ac0ca2f1ae94', '946ca7dae183e3cded6ca9505670340a'),
    ('libatk-1.0-0.dll', 'd90e955b171b2d3bcdcdec73c2277eb3', 'f95d9eefcf85aeca128c218cb23c90e2'),
    ('libcairo-2.dll', '816ce24100a0de30cd24852dbaa3dbfb', 'b2bb842451a11585d73b3eb65878ece9'),
    ('libcairo-gobject-2.dll', '7201c9543b880a5222e2d111f3308218', 'd16b292282398324baa2dd0408c9515e'),
    ('libcairo-script-interpreter-2.dll', 'd7117479b419a0a0df88ba93ad527582', '66eaa1bafa03beed6f1669e769013c25'),
    ('libeay32.dll', '6b1246a5acb66b077b3e9c8ee2e6a3df', '65bedd9cbc93420e4e36b7038aa1b012'),
    ('libexpat-1.dll', '49e6a5f7ceb7de50851dc0bf4e75f18c', '3091605d9f53431b964351d80fe34ddf'),
    ('libexpat.dll', '321f5c9074fd3e39a6cfb183be614784', '85c3f3058b8d6d6332b48542957b8419'),
    ('libfontconfig-1.dll', '5974b1a2dc65b37bd01c52478bcdfa07', '3d2d77ad23b8256c0cf97b36ffd64299'),
    ('libfreetype-6.dll', '4e1168e1d4d5256aaa5e41fb2eddad20', 'c5839d957d29968e579178aa854b8651'),
    ('libgailutil-18.dll', '90c2c0393495b1afa1b025984ed7fd95', 'cf72818a626bb93eaab07f680f31a8dc'),
    ('libgcc_s_1.dll', '94240658db48fa94aa19cdbd50e606e0', '881bb0989256fec0e79811e76af449f9'),
    ('libgdk-win32-2.0-0.dll', '7de43b13fbcc022b9184ca70b9668f79', '81cadf1413cadba0e3f67b52fd3f3c88'),
    ('libgdk_pixbuf-2.0-0.dll', 'e99f79c007650cb129bf5e95199a37ff', '835daf325a93ca18d78c9a2a292567ca'),
    ('libgdkglext-win32-1.0-0.dll', '31ae39b0d64178b3154c40bf64ade7de', '5f1420859ca7785c676e4ec852f3420f'),
    ('libgettextlib-0-17.dll', '53331c9cae5becc46de864019fe89a13', 'ef2510ac293a4e29c2b246cd458b6fca'),
    ('libgettextpo-0.dll', '618090352540d7727d47be33dde4afb4', '1b48ba5651abb32b6b926542882e22c1'),
    ('libgettextsrc-0-17.dll', '8a4f70bb51d4ad1b848faf9132672649', '7da6cd30f6a5d0ad749db8c22e67edac'),
    ('libgfortran-3.dll', 'f1030a7683888f83e1e17f642a97ee1e', 'd8d94f0272f7d7ab2b69a7df4e0716ad'),
    ('libgio-2.0-0.dll', 'a0fcd87f3e738d9733dffceca801a371', '02a497b2768cda2b47969a0244c9b766'),
    ('libglade-2.0-0.dll', '9708f8946340212a840beaa5a544418c', '12321a0e28e48530fb660de8eff0dbab'),
    ('libgladeui-1-7.dll', 'bffa8b4ec08467235d9e72742fd022a1', '69785194e326e864c76a21b0313a52b6'),
    ('libglib-2.0-0.dll', '226daf8c1fd88c1a4f89368c7c706457', '8cc667edd3415395e21d79c3f83745ab'),
    ('libgmodule-2.0-0.dll', '0f9bca46f942748d94a55254bc34ed6e', '47417c314255bb58b28f77c880a6c810'),
    ('libgobject-2.0-0.dll', 'e5c9a323f737ad3f66da3c274aa7e164', '9f1f7d75728442258453d7ecec1a3e1a'),
    ('libgthread-2.0-0.dll', '90dd53dc6fc035b9ca1cba49dc1f8eba', '86fc9bcaa15f979b0102ec86e2c75737'),
    ('libgtk-win32-2.0-0.dll', '9ee94b7b2f501502e053845f67f18b2e', 'a38ccb75cd90a92afb6ff0cd295bf9e8'),
    ('libgtkglext-win32-1.0-0.dll', '60ec1aacfcac406c0e4b04943262bf04', '4ff420d58e49067419cc8593635492ba'),
    ('libintl-8.dll', 'a69ec82feb3d17c83a9d714749fcd5ac', 'fd27a9a2a0bbbf1f9a1779585da702b1'),
    ('libjpeg-62.dll', 'e1c71acfa98caf316f93833dd31e9bb4', '9f9eca580a68017026fa64c70a286610'),
    ('libltdl-3.dll', '1911bdcafe96b98e62c0a51fb2bcb542', 'ffbaeae5c1c8f936332a01704963881b'),
    ('libobjc-2.dll', '217d2307f212955e82e64816d3349a08', '8ec985516958a2c99f2ca8fa0ae6843d'),
    ('libpango-1.0-0.dll', 'a8ccc27c4add119a07d51a0b00eb4bb8', '7fa55d38156d29623ebd1a883b8d0ad4'),
    ('libpangocairo-1.0-0.dll', '01c3741991a19b5870559e9ac51880d2', '055c444be08945547b454bf86f6e5d7b'),
    ('libpangoft2-1.0-0.dll', 'ca3b0eca6f4d7b1f79f40e4e698776a2', '7360002ec4346643320c3ca577e9b9bf'),
    ('libpangowin32-1.0-0.dll', 'b60af805bbf5f69b4a1cce78d3dd814a', '5afe3a001c4cf23bb4341725fc5644c0'),
    ('libpng12-0.dll', '440d117c536ae88f540ecfb0e496c869', '906e17e5ab42b7ceb127e72103c12395'),
    ('libpng12.dll', 'f629bc89f410650c1b9df33581d62d09', '19ce7c5d61434ab553024ef46b2643a5'),
    ('libpng14-14.dll', '6354b491e4c262c67126c6bb001e1330', '33948c627ab6be9a5ce94a68878994f9'),
    ('libssp-0.dll', 'b127a3dcfe2caa0b9fb2bd8768d0f576', '51515b2264de2f8660cc46b7f3ebbc6b'),
    ('libstdc++-6.dll', '184fe8081f4bbedf0e25cac175c2e073', '54a45223d73d6ea6dd5a1828d2b59195'),
    ('libtiff.dll', '573d09e62d71cdaa0fa41f6ad62b2f81', '4ad93cded54c071c9f6410b47c292a4e'),
    ('libudis86.dll', 'c67f87d066b2bf1f545ca385bffbfaf6', 'e7fb66c3f50469160ca992bd4d8b6544'),
    ('libxml2.dll', '096d5e5683819f0d3b3f93428597a29c', '059ca11eea704709f024fbccb2c49466'),
    ('pcre.dll', '57cac848fa14ae38f14f9441f8933282', 'ce9a046b8ac744d20015ef93e2d23a47'),
    ('sqlite3.dll', '5405413fff79b8d9c747aa900f60f082', 'e5a07bbb9dcff7e72142f589d7d0234c'),
    ('ssleay32.dll', 'e1f3b02f7670b6f92cf05ac7628297aa', '0131a8cbeb9772bb70c34bfc8406943a'),
    ('libyaml-0-2.dll', '5aa3f060b1858f28b124ade5dce079ed', 'd7b47ae80b9a3a7f2d62a33262a51334'),
    ('zip32z64.dll', 'd389ce96885acb61c4e471b9ee3a8063', '10dc180ed4b49ddcd0ea2e61ae62259b'),
    ('zlib1.dll', '80e41408f6d641dc1c0f5353a0cc8125', '55c57c4c216ff91c8776ac2df0c5d94a')
]

if __name__ == '__main__':
    # Run file to update the checksums to check against.
    url_fmt = 'http://downloads.factorcode.org/dlls/%s%s'
    for name, _, _ in dlls:
        url1 = url_fmt % ('', name)
        chk32 = md5(urlopen(url1).read()).hexdigest()
        url2 = url_fmt % ('64/', name)
        chk64 = md5(urlopen(url2).read()).hexdigest()
        print "('%s', '%s', '%s')," % (name, chk32, chk64)
