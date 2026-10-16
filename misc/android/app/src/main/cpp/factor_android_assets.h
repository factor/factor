#pragma once

#include <android/asset_manager.h>
#include <string>

namespace factor_android {

// Prepare packaged assets in the activity's private data directory. A false
// result means startup must stop; failed file copies are removed.
bool copy_asset(AAssetManager* manager, const std::string& asset,
                const std::string& destination);
bool extract_resources(AAssetManager* manager, const std::string& destination);

}  // namespace factor_android
