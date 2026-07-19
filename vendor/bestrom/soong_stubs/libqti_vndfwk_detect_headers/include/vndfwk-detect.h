// BestROM stub for missing QTI vndfwk-detect headers
#pragma once
#ifdef __cplusplus
extern "C" {
#endif
// Returns 0 = AOSP, 1 = vendor enhanced (stub: always 0)
static inline int isRunningWithVendorEnhancedFramework(void) { return 0; }
static inline int getVendorEnhancedInfo(void) { return 0; }
#ifdef __cplusplus
}
#endif
