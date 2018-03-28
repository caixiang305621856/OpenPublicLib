//
//  PathMacro.h
//  
//
//  Created by vernepung on 14-5-5.
//  Copyright (c) 2014年 vernepung. All rights reserved.
//


#import <UIKit/UIKit.h>
#ifndef PathMacro_h
#define PathMacro_h

UIKIT_STATIC_INLINE NSString *VPDocumentPath(){return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];}

UIKIT_STATIC_INLINE NSString *VPCachePath(){return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];}

UIKIT_STATIC_INLINE NSString *VPPathAtDocumentWithDirectory(NSString *directoryName){return [VPDocumentPath() stringByAppendingPathComponent:directoryName];}

UIKIT_STATIC_INLINE NSString *VPPathAtCacheWithDirectory(NSString *directoryName){return [VPCachePath() stringByAppendingPathComponent:directoryName];}

UIKIT_STATIC_INLINE NSString *VPPathAtTempWithDirectory(NSString *directoryName){return [NSTemporaryDirectory() stringByAppendingPathComponent:directoryName];}

#endif