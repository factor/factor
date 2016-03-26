# Checksums used on Windows to verify integrity of downloaded dlls.
from hashlib import md5
from sys import stdout
try:
    from urllib import urlopen
except ImportError:
    from urllib.request import urlopen
    from urllib.error import HTTPError

# List of prebuilt libraries to download to create the windows msi
# (name, digest32, digest64). If digest is None, then the dll is not
# available for that arch.
dlls = [
    ('blas.dll', '63017771c424146f8ddcee266d7a9446', 'ec84cbbecb0573369de8f6e94b576035'),
    ('bzip2.dll', None, None),
    ('freetype6.dll', 'e7f5fa7772dd00ef6a2299ba27e8eccc', None),
    ('iconv.dll', '73af5773bf5627fe771bf6809ec839f9', '15aa5d1b23e701b3fc1cae83df7c711d'),
    ('intl.dll', '9f95ece3d2b3909de4d9147c4d93f976', None),
    ('jpeg62.dll', None, None),

    ('libasprintf-0.dll', None, None),

    ('libcairo-2.dll', '816ce24100a0de30cd24852dbaa3dbfb', 'b2bb842451a11585d73b3eb65878ece9'),
    ('libcairo-gobject-2.dll', None, 'd16b292282398324baa2dd0408c9515e'),
    ('libcairo-script-interpreter-2.dll', None, '66eaa1bafa03beed6f1669e769013c25'),
    ('libcrypto-37.dll', '71027d5bcbb28f76b22c04e3a1a54282', '4cd4965d6eb16075886c1ebe1e5c491b'),

    ('libexpat-1.dll', None, '3091605d9f53431b964351d80fe34ddf'),
    ('libexpat.dll', None, '85c3f3058b8d6d6332b48542957b8419'),

    ('libfftw3-3.dll', '88ae2d3b7069ab4b823e5cf6cebf7932', '4867d055a37fcbf4fb37b6c8c3e49f4a'),
    ('libfontconfig-1.dll', None, '3d2d77ad23b8256c0cf97b36ffd64299'),
    ('libfreetype-6.dll', None, 'c5839d957d29968e579178aa854b8651'),

    ('libgailutil-18.dll', None, 'cf72818a626bb93eaab07f680f31a8dc'),

    ('libgcc_s_1.dll', None, '881bb0989256fec0e79811e76af449f9'),
    ('libgdbm-3.dll', '091a117e07532c001c8bde151aa84221', '8238c5a3f10c7a3822a48af915348253'),
    ('libgdk-win32-2.0-0.dll', None, '81cadf1413cadba0e3f67b52fd3f3c88'),
    ('libgdk_pixbuf-2.0-0.dll', None, '835daf325a93ca18d78c9a2a292567ca'),
    ('libgdkglext-win32-1.0-0.dll', None, '5f1420859ca7785c676e4ec852f3420f'),
    ('libgettextlib-0-17.dll', None, 'ef2510ac293a4e29c2b246cd458b6fca'),
    ('libgettextpo-0.dll', None, '1b48ba5651abb32b6b926542882e22c1'),
    ('libgettextsrc-0-17.dll', None, '7da6cd30f6a5d0ad749db8c22e67edac'),
    ('libgfortran-3.dll', None, 'd8d94f0272f7d7ab2b69a7df4e0716ad'),
    ('libgio-2.0-0.dll', 'a0fcd87f3e738d9733dffceca801a371', '02a497b2768cda2b47969a0244c9b766'),
    ('libglade-2.0-0.dll', None, '12321a0e28e48530fb660de8eff0dbab'),
    ('libgladeui-1-7.dll', None, '69785194e326e864c76a21b0313a52b6'),
    ('libglib-2.0-0.dll', '226daf8c1fd88c1a4f89368c7c706457', None),
    ('libgmodule-2.0-0.dll', '0f9bca46f942748d94a55254bc34ed6e', None),
    ('libgobject-2.0-0.dll', 'e5c9a323f737ad3f66da3c274aa7e164', '9f1f7d75728442258453d7ecec1a3e1a'),
    ('libgthread-2.0-0.dll', '90dd53dc6fc035b9ca1cba49dc1f8eba', '86fc9bcaa15f979b0102ec86e2c75737'),
    ('libgtk-win32-2.0-0.dll', None, 'a38ccb75cd90a92afb6ff0cd295bf9e8'),
    ('libgtkglext-win32-1.0-0.dll', None, '4ff420d58e49067419cc8593635492ba'),
    ('libintl-8.dll', None, 'fd27a9a2a0bbbf1f9a1779585da702b1'),
    ('libintl.dll', None, None),
    ('libjpeg-62.dll', None, '9f9eca580a68017026fa64c70a286610'),
    ('libltdl-3.dll', None, 'ffbaeae5c1c8f936332a01704963881b'),
    ('libobjc-2.dll', None, '8ec985516958a2c99f2ca8fa0ae6843d'),
    ('libpango-1.0-0.dll', 'a8ccc27c4add119a07d51a0b00eb4bb8', '7fa55d38156d29623ebd1a883b8d0ad4'),
    ('libpangocairo-1.0-0.dll', '01c3741991a19b5870559e9ac51880d2', '055c444be08945547b454bf86f6e5d7b'),
    ('libpangoft2-1.0-0.dll', None, '7360002ec4346643320c3ca577e9b9bf'),
    ('libpangowin32-1.0-0.dll', 'b60af805bbf5f69b4a1cce78d3dd814a', '5afe3a001c4cf23bb4341725fc5644c0'),
    ('libpng12-0.dll', '440d117c536ae88f540ecfb0e496c869', '906e17e5ab42b7ceb127e72103c12395'),
    ('libpng12.dll', None, '19ce7c5d61434ab553024ef46b2643a5'),
    ('libpng14-14.dll', None, '33948c627ab6be9a5ce94a68878994f9'),
    ('libpq.dll', None, '2cd1cb3e4ffaf05d046224b84cea8c97'),
    ('libpython27.dll', '45e9efbe2b2c9b98f4e08ca35e73b5ae', '9c23faac6e19bb86934c198333101b4e'),

    ('libssl-38.dll', '1f969efa4413c2f815144c8c60f6031a', '0409d4408ca6e351f2a7f9983312a7d1'),
    ('libssp-0.dll', None, '51515b2264de2f8660cc46b7f3ebbc6b'),
    ('libstdc++-6.dll', None, '54a45223d73d6ea6dd5a1828d2b59195'),

    ('libtiff.dll', None, '4ad93cded54c071c9f6410b47c292a4e'),
    ('libtiff3.dll', 'cfd09d054747280ed660ef7d79d0d443', None),
    ('libudis86.dll', None, 'e7fb66c3f50469160ca992bd4d8b6544'),
    ('libxml2.dll', 'cce96a8421c6b764e58eb8f13dbe5dd8', '059ca11eea704709f024fbccb2c49466'),
    ('libxslt.dll', '7931188c564aa428fefdf6017bedf39e', '5cd2b89f0de9abe7a96ef0d05a5e5502'),
    ('libyaml-0-2.dll', '5aa3f060b1858f28b124ade5dce079ed', 'd7b47ae80b9a3a7f2d62a33262a51334'),
    ('libzmq.dll', 'b4f44f1fbe1a36440758a47b6e2c46e6', '58797adaee268f600be05ef357cd9711'),
    ('msvcp120.dll', 'fd5cabbe52272bd76007b68186ebaf00', '46060c35f697281bc5e7337aee3722b1'),
    ('msvcr120.dll', '034ccadc1c073e4216e9466b720f9849', '9c861c079dd81762b6c54e37597b7712'),
    ('pcre.dll', '5d6cade5112191346afa3fa66252440a', 'ce9a046b8ac744d20015ef93e2d23a47'),
    ('snappy.dll', 'd5fb0ce7c811af02dcabd22b8a7ff42e', '4ee4bf3eec99ee1867980ceaad0a490e'),
    ('sqlite3.dll', 'ee68b052a08fec0f574f2dae2003df27', 'e5a07bbb9dcff7e72142f589d7d0234c'),
    ('zip32z64.dll', None, '10dc180ed4b49ddcd0ea2e61ae62259b'),
    ('zlib1.dll', '80e41408f6d641dc1c0f5353a0cc8125', '55c57c4c216ff91c8776ac2df0c5d94a'),
]

def data_digest(data):
    # Filter file not found pages.
    return None if len(data) < 512 else md5(data).hexdigest()

def read_url(url):
    try:
        return urlopen(url).read()
    except HTTPError:
        return ''

if __name__ == '__main__':
    # Run file to update the checksums to check against.
    url_fmt = 'http://downloads.factorcode.org/dlls/%s%s'
    for name, _, _ in dlls:
        url1 = url_fmt % ('', name)
        data = read_url(url1)
        chk32 = data_digest(data)
        url2 = url_fmt % ('64/', name)
        data = read_url(url2)
        chk64 = data_digest(data)
        stdout.write("('%s', %r, %r),\n" % (name, chk32, chk64))
