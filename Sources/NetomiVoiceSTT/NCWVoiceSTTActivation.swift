//
//  NCWVoiceSTTActivation.swift
//  NetomiVoiceSTT
//
//  Automatically installs the real Azure-backed STT implementation into core as soon as
//  this module is linked into the host app. Host apps do not call anything here — there
//  is deliberately no public API on this module. `NCWSpeechToTextService`/`NCWVoiceConfig`/
//  `NCWVoiceFactory` etc. are reached only through the `@_spi(NetomiVoiceSTT)` boundary
//  that core exposes exclusively to this module.
//
//  Swift forbids overriding NSObject's Objective-C `+load` ("method 'load()' defines
//  Objective-C class method 'load', which is not permitted by Swift"), so this entry point
//  is called from a genuine Objective-C `+load` instead, in the sibling
//  NetomiVoiceSTTAutoActivator target (NCWVoiceSTTAutoActivator.m) — the standard,
//  link-time-supported mechanism for "run this automatically when linked, no public API
//  required". An earlier version placed a Swift global directly into the
//  `__DATA,__mod_init_func` section via `@_section`, which worked in Debug/incremental
//  builds but produced an ADRP-relocation-out-of-range linker error under Release/Archive
//  whole-module optimization — hand-placed custom sections don't reliably survive LTO.

import Foundation
@_spi(NetomiVoiceSTT) import Netomi

@_cdecl("NetomiVoiceSTT_activateOnLoad")
public func NetomiVoiceSTT_activateOnLoad() {
    NCWVoiceFactory.registerSTTProvider { voiceConfig in
        NCWAzureSTTService(voiceConfig: voiceConfig)
    }
}
