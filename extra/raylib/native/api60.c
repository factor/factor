/* Headless raylib 6.0 ABI oracle. Build against the real upstream header/library:
 * cc -std=c11 -Wall -Wextra -Werror -fPIC -shared -I$RAYLIB/src api60.c
 *    -L$RAYLIB/src -lraylib -Wl,-rpath,$RAYLIB/src -o libraylib-api60.dylib
 * Add -DRAYLIB_API60_MAIN (and omit -shared) for the independent C controls.
 * The control executable takes a TrueType font filename as its only argument.
 */
#include "raylib.h"
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#if RAYLIB_VERSION_MAJOR != 6 || RAYLIB_VERSION_MINOR != 0
#error This fixture requires the upstream raylib 6.0 header
#endif

size_t raylib_api60_layout(int index)
{
    static const size_t values[] = {
        sizeof(ModelSkeleton), offsetof(ModelSkeleton, boneCount),
        offsetof(ModelSkeleton, bones), offsetof(ModelSkeleton, bindPose),
        sizeof(Model), offsetof(Model, transform), offsetof(Model, meshCount),
        offsetof(Model, materialCount), offsetof(Model, meshes),
        offsetof(Model, materials), offsetof(Model, meshMaterial),
        offsetof(Model, skeleton), offsetof(Model, currentPose),
        offsetof(Model, boneMatrices), sizeof(ModelAnimation),
        offsetof(ModelAnimation, name), offsetof(ModelAnimation, boneCount),
        offsetof(ModelAnimation, keyframeCount), offsetof(ModelAnimation, keyframePoses),
        sizeof(AudioStream), offsetof(AudioStream, buffer),
        offsetof(AudioStream, processor), offsetof(AudioStream, sampleRate),
        offsetof(AudioStream, sampleSize), offsetof(AudioStream, channels)
    };
    return (index >= 0 && (size_t)index < sizeof(values)/sizeof(values[0]))?
        values[index] : (size_t)-1;
}

typedef void (*AnimationProbe)(Model *, ModelAnimation *);

bool raylib_api60_animation_case(AnimationProbe probe)
{
    BoneInfo bone = { .name = "root", .parent = -1 };
    Transform bind = { .rotation = { 0, 0, 0, 1 }, .scale = { 1, 1, 1 } };
    Transform first = bind, second = bind, current = bind;
    first.translation = (Vector3){ 2, 4, 6 };
    second.translation = (Vector3){ 10, 12, 14 };
    Transform *poses[] = { &first, &second };
    Matrix matrix = { 0 };
    Model model = {
        .skeleton = { .boneCount = 1, .bones = &bone, .bindPose = &bind },
        .currentPose = &current, .boneMatrices = &matrix
    };
    ModelAnimation animation = {
        .name = "half-frame", .boneCount = 1, .keyframeCount = 2,
        .keyframePoses = poses
    };
    /* Zero meshes: the real update interpolates bones without any GPU call. */
    probe(&model, &animation);
    return current.translation.x == 6.0f && current.translation.y == 8.0f &&
        current.translation.z == 10.0f && matrix.m12 == 6.0f &&
        matrix.m13 == 8.0f && matrix.m14 == 10.0f;
}

void raylib_api60_audio_case(AudioCallback callback)
{
    /* Exercise unsigned callback conversion without an audio device/buffer. */
    callback(NULL, 0x80000005u);
}

bool raylib_api60_glyphs_valid(const GlyphInfo *glyphs, int count)
{
    return glyphs != NULL && count == 95 && glyphs[0].value == 32 &&
        glyphs[94].value == 126 && glyphs[33].image.data != NULL &&
        glyphs[33].image.width > 0 && glyphs[33].image.height > 0;
}

typedef bool (*FontProbe)(const unsigned char *, int);

bool raylib_api60_font_case(const char *path, FontProbe probe)
{
    if (path == NULL) return false;
    FILE *file = fopen(path, "rb");
    if (file == NULL) return false;
    if (fseek(file, 0, SEEK_END) != 0) { fclose(file); return false; }
    long length = ftell(file);
    if (length <= 4 || length > 0x7fffffffL || fseek(file, 0, SEEK_SET) != 0)
    { fclose(file); return false; }
    unsigned char *data = malloc((size_t)length);
    if (data == NULL) { fclose(file); return false; }
    bool result = fread(data, 1, (size_t)length, file) == (size_t)length;
    fclose(file);
    /* This TTF header starts with NUL and contains non-ASCII bytes later. */
    result = result && data[0] == 0 && probe(data, (int)length);
    free(data);
    return result;
}

static void animation_control(Model *model, ModelAnimation *animation)
{
    UpdateModelAnimation(*model, *animation, 0.5f);
}

static bool font_control(const unsigned char *data, int length)
{
    int count = -1;
    GlyphInfo *glyphs = LoadFontData(data, length, 24, NULL, 0, FONT_DEFAULT, &count);
    bool valid = raylib_api60_glyphs_valid(glyphs, count);
    if (glyphs != NULL) UnloadFontData(glyphs, count);
    return valid;
}

bool raylib_api60_controls(const char *font_path)
{
    return raylib_api60_animation_case(animation_control) &&
        raylib_api60_font_case(font_path, font_control);
}

#ifdef RAYLIB_API60_MAIN
static unsigned int audio_frames;
static void audio_control(void *buffer, unsigned int frames)
{
    (void)buffer;
    audio_frames = frames;
}

int main(int argc, char **argv)
{
    raylib_api60_audio_case(audio_control);
    bool passed = argc == 2 && raylib_api60_controls(argv[1]) &&
        audio_frames == 0x80000005u;
    puts(passed? "raylib 6.0 C controls: PASS" : "raylib 6.0 C controls: FAIL");
    return passed? 0 : 1;
}
#endif
