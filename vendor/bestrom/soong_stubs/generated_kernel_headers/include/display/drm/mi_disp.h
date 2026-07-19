// BestROM stub kernel uapi for UDFPS (prebuilt kernel)
#pragma once
#include <linux/types.h>
#include <linux/ioctl.h>
// Common Xiaomi disp notify event ids (stubs)
enum {
    MI_DISP_EVENT_FOD = 1,
    MI_DISP_EVENT_FPS = 2,
};
struct disp_event_req {
    __u32 base;
    __u32 type;
};
#define MI_DISP_IOCTL_REGISTER_EVENT   _IOW('D', 1, struct disp_event_req)
#define MI_DISP_IOCTL_DEREGISTER_EVENT _IOW('D', 2, struct disp_event_req)
