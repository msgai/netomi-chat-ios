//
//  NCWVoiceSTTAutoActivator.m
//  NetomiVoiceSTTAutoActivator
//
//  Genuine Objective-C `+load` — the standard, link-time-supported mechanism for "run this
//  automatically when linked, no public API required". Swift forbids overriding NSObject's
//  `+load`, and a hand-placed `__DATA,__mod_init_func` entry (an earlier attempt) doesn't
//  reliably survive Release/Archive whole-module optimization (ADRP-relocation-out-of-range
//  linker errors). This tiny Objective-C target exists solely to host a real `+load`.
//

#import <Foundation/Foundation.h>

extern void NetomiVoiceSTT_activateOnLoad(void);

@interface NCWVoiceSTTAutoActivator : NSObject
@end

@implementation NCWVoiceSTTAutoActivator

+ (void)load {
    NetomiVoiceSTT_activateOnLoad();
}

@end
