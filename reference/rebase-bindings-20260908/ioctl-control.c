#include <errno.h>
#include <linux/input.h>
#include <stdio.h>
#include <sys/ioctl.h>
int main(void) {
    unsigned char bits[4] = {0};
    struct input_mask mask = {.type=0,.codes_size=4,.codes_ptr=(unsigned long)bits};
    struct input_absinfo abs = {0};
    const unsigned long requests[] = {EVIOCGMASK, EVIOCSABS(0), EVIOCRMFF};
    void *args[] = {&mask, &abs, (void *)7};
    for (unsigned i=0; i<3; i++) {
        errno=0; int result=ioctl(-1, requests[i], args[i]);
        printf("ioctl(%#lx): result=%d errno=%d\n",requests[i],result,errno);
        if (result != -1) return 1;
    }
    return 0;
}
