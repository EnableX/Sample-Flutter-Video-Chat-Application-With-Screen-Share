//
//  VCXShareScreen.h
//  BroadCastExtension
//
//  Created by VCX-LP-11 on 18/09/20.
//  Copyright © 2020 Hemrajjhariya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>
#import <Accelerate/Accelerate.h>
NS_ASSUME_NONNULL_BEGIN

@interface VCXShareScreen : NSObject
-(instancetype)init;
-(void)joinRoom;
-(void)stopScreenShare;
-(void)processBufferScreen:(CMSampleBufferRef)bufferImage;

@end

NS_ASSUME_NONNULL_END
