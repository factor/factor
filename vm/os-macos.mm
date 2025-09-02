#import <Cocoa/Cocoa.h>

#include <mach/mach_time.h>
#include <sys/utsname.h>
#include <unistd.h>
#include <stdio.h>

#include "master.hpp"

namespace factor {

void factor_vm::c_to_factor_toplevel(cell quot) { c_to_factor(quot); }

// Darwin 9 is 10.5, Darwin 10 is 10.6
// http://en.wikipedia.org/wiki/Darwin_(operating_system)#Release_history
void early_init(void) {
  struct utsname u;
  int n;
  uname(&u);
  {
    // Parse major Darwin version without locale pitfalls
    char* endp = nullptr;
    long val = std::strtol(u.release, &endp, 10);
    n = (val > 0 && endp != u.release) ? static_cast<int>(val) : 0;
  }
  if (n < 9) {
    std::cout << "Factor requires macOS 10.5 or later.\n";
    exit(1);
  }
}

// You must free() this yourself.
const char* vm_executable_path(void) {
  return safe_strdup([[[NSBundle mainBundle] executablePath] UTF8String]);
}

const char* default_image_path(void) {
  NSBundle* bundle = [NSBundle mainBundle];
  NSString* path = [bundle bundlePath];
  NSString* executablePath = [[bundle executablePath] stringByResolvingSymlinksInPath];
  NSString* executable = [executablePath lastPathComponent];
  NSString* image = [executable stringByAppendingString:@".image"];

  NSString* returnVal;

  if ([path hasSuffix:@".app"] || [path hasSuffix:@".app/"]) {
    NSFileManager* mgr = [NSFileManager defaultManager];
    NSString* root = [path stringByDeletingLastPathComponent];
    NSString* resources = [path stringByAppendingPathComponent:@"Contents/Resources"];

    NSString* imageInBundle = [resources stringByAppendingPathComponent:image];
    NSString* imageAlongBundle = [root stringByAppendingPathComponent:image];

    returnVal = ([mgr fileExistsAtPath:imageInBundle] ? imageInBundle
                                                      : imageAlongBundle);
  } else if ([executablePath hasSuffix:@".app/Contents/MacOS/factor"]) {
    returnVal = executablePath;
    returnVal = [returnVal stringByDeletingLastPathComponent];
    returnVal = [returnVal stringByDeletingLastPathComponent];
    returnVal = [returnVal stringByDeletingLastPathComponent];
    returnVal = [returnVal stringByDeletingLastPathComponent];
    returnVal = [returnVal stringByAppendingPathComponent:image];

  } else {
    returnVal = [path stringByAppendingPathComponent:image];
  }

  return [returnVal UTF8String];
}

void factor_vm::init_signals(void) {
  unix_init_signals();
  mach_initialize();
}

// Amateurs at Apple: implement this function, properly!
Protocol* objc_getProtocol(char* name) {
  if (strcmp(name, "NSTextInput") == 0)
    return @protocol(NSTextInput);
  else
    return nil;
}

uint64_t nano_count() {
  uint64_t time = mach_absolute_time();

  static uint64_t scaling_factor = 0;
  if (!scaling_factor) {
    mach_timebase_info_data_t info;
    kern_return_t ret = mach_timebase_info(&info);
    if (ret != 0)
      fatal_error("mach_timebase_info failed", ret);
    scaling_factor = info.numer / info.denom;
  }

  return time * scaling_factor;
}

}
