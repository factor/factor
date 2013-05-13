#import <Cocoa/Cocoa.h>

#include <mach/mach_time.h>
#include <sys/utsname.h>

#include "master.hpp"

namespace factor {

void factor_vm::c_to_factor_toplevel(cell quot) { c_to_factor(quot); }

// Darwin 9 is 10.5, Darwin 10 is 10.6
// http://en.wikipedia.org/wiki/Darwin_(operating_system)#Release_history
void early_init(void) {
  struct utsname u;
  int n;
  uname(&u);
  sscanf(u.release, "%d", &n);
  if (n < 9) {
    std::cout << "Factor requires Mac OS X 10.5 or later.\n";
    exit(1);
  }
}

const char* vm_executable_path(void) {
  return [[[NSBundle mainBundle] executablePath] UTF8String];
}

const char* default_image_path(void) {
  NSBundle* bundle = [NSBundle mainBundle];
  NSString* path = [bundle bundlePath];
  NSString* executable = [[bundle executablePath] lastPathComponent];
  NSString* image = [executable stringByAppendingString:@".image"];

  NSString* returnVal;

  if ([path hasSuffix:@".app"] || [path hasSuffix:@".app/"]) {
    NSFileManager* mgr = [NSFileManager defaultManager];

    NSString* imageInBundle =
        [[path stringByAppendingPathComponent:@"Contents/Resources"]
            stringByAppendingPathComponent:image];
    NSString* imageAlongBundle = [[path stringByDeletingLastPathComponent]
        stringByAppendingPathComponent:image];

    returnVal = ([mgr fileExistsAtPath:imageInBundle] ? imageInBundle
                                                      : imageAlongBundle);
  } else
    returnVal = [path stringByAppendingPathComponent:image];

  return [returnVal UTF8String];
}

void factor_vm::init_signals(void) {
  unix_init_signals();
  mach_initialize();
}

/* Amateurs at Apple: implement this function, properly! */
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
