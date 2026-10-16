#pragma once

// The asset API used by the loader, implemented in assets.cpp for host tests.
#include <cstddef>
#include <sys/types.h>

struct AAsset;
struct AAssetManager;
constexpr int AASSET_MODE_STREAMING = 2;

AAsset* AAssetManager_open(AAssetManager*, const char*, int);
int AAsset_read(AAsset*, void*, size_t);
off64_t AAsset_getLength64(AAsset*);
off64_t AAsset_getRemainingLength64(AAsset*);
off64_t AAsset_seek64(AAsset*, off64_t, int);
void AAsset_close(AAsset*);
