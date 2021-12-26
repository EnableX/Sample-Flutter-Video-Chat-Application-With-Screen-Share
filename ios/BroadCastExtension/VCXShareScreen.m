//
//  VCXShareScreen.m
//  BroadCastExtension
//
//  Created by VCX-LP-11 on 18/09/20.
//  Copyright © 2020 Hemrajjhariya. All rights reserved.
//

#import "VCXShareScreen.h"
#import <EnxRTCiOS/EnxRTCiOS.h>
#import "VCXServicesClass.h"
#import "ToastView.h"


@interface VCXShareScreen()<EnxBroadCastDelegate>

@property(nonatomic,strong) NSString *roomId;
@property(nonatomic,strong)EnxRoom *remoteRooml;

@end


static int kDownScaledFrameWidth = 540;
static int kDownScaledFrameHeight = 960;

@implementation VCXShareScreen
-(instancetype)init{
    self = [super init];
    if(self){
    }
    return self;
}
# pragma mark - JoinRoomCall
- (void)ConnectToroom{
    VCXServicesClass *service = [[VCXServicesClass alloc]init];
    
    @try {
        NSDictionary *params = @{
                                 @"name": @"Enx Screen Share",
                                 @"role": @"participant",
                                 @"user_ref": @"2236",
                                 @"roomId"  : self.roomId
                                 };
        
        NSLog(@"params %@",params);
        [service fetchCreateToken:params result:^(id result){
            if ([result isKindOfClass:[NSError class]] == NO)
            {
                NSError *error = nil;
                NSDictionary *respinseDict = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error];
                NSLog(@"respinseDict: %@",respinseDict);
                NSString *errors = [respinseDict objectForKey:@"error"];
                if (errors) {
                    //Server Error
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->_remoteRooml = [[EnxRoom alloc]init];
                        [self->_remoteRooml connectWithScreenshare:respinseDict[@"token"] withScreenDelegate:self];
                    });
                }
                
            }
            else
            {
               //Server Not found
               
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception :%@",exception);
    }
}
-(void)joinRoom{
    [[EnxUtilityManager shareInstance] setAppGroupsName:@"group.vcxsample" withUserKey:@"clientID"];
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.vcxsample"];
    self.roomId = [userDefault objectForKey:@"RoomID"];
    //NSString *clientId = [userDefault objectForKey:@"ClientID"];
    
    [self ConnectToroom];
    userDefault = nil;
}
-(void)stopScreenShare{
    if(self.remoteRooml != nil){
        [self.remoteRooml stopScreenShare];
    }
}
-(void)processBufferScreen:(CMSampleBufferRef)bufferImage{
    @autoreleasepool {
    dispatch_sync(dispatch_get_main_queue(), ^{
        CVImageBufferRef pixelBuffer =  CMSampleBufferGetImageBuffer(bufferImage);
            CVPixelBufferRef outPixelBuffer = nil;
            CVPixelBufferLockBaseAddress(pixelBuffer,0);
            OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
            
            if(sourcePixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange){
                
            }
            CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, kDownScaledFrameWidth, kDownScaledFrameHeight, sourcePixelFormat, nil, &outPixelBuffer);
            if(status != kCVReturnSuccess){
                //Failed to create pixel buffer
            }
            CVPixelBufferLockBaseAddress(outPixelBuffer, 0);
            // Prepare source pointers.
            vImage_Buffer sourceImageY = {(void *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0),CVPixelBufferGetHeightOfPlane(pixelBuffer, 0),CVPixelBufferGetWidthOfPlane(pixelBuffer, 0),CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)};
            
            vImage_Buffer sourceImageUV = {(void *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1),CVPixelBufferGetHeightOfPlane(pixelBuffer, 1),CVPixelBufferGetWidthOfPlane(pixelBuffer, 1),CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)};
            
            // Prepare out pointers.
            
            vImage_Buffer outImageY = {(void *)CVPixelBufferGetBaseAddressOfPlane(outPixelBuffer, 0),CVPixelBufferGetHeightOfPlane(outPixelBuffer, 0),CVPixelBufferGetWidthOfPlane(outPixelBuffer, 0),CVPixelBufferGetBytesPerRowOfPlane(outPixelBuffer, 0)};
            
            vImage_Buffer outImageUV = {(void *)CVPixelBufferGetBaseAddressOfPlane(outPixelBuffer, 1),CVPixelBufferGetHeightOfPlane(outPixelBuffer, 1),CVPixelBufferGetWidthOfPlane(outPixelBuffer, 1),CVPixelBufferGetBytesPerRowOfPlane(outPixelBuffer, 1)};
            
            vImage_Error error = vImageScale_Planar8(&sourceImageY, &outImageY, nil, 0);
           
            if(error != kvImageNoError){
                //Failed to down scale luma plane
                return;
            }
            error = vImageScale_CbCr8(&sourceImageUV, &outImageUV, nil, 0);
            if(error != kvImageNoError){
                //Failed to down scale chroma plane
                return;
            }
            CVPixelBufferUnlockBaseAddress(outPixelBuffer, 0);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        int64_t timeStampNs = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(bufferImage)) *1000000000;
        
        if(self.remoteRooml != nil){
            [self.remoteRooml sendVideoBuffer:outPixelBuffer withTimeStamp:timeStampNs];
        }
        
        CVPixelBufferRelease(outPixelBuffer);
    });
    }
}
-(void)broadCastConnected{
    [self.remoteRooml startScreenShare];
}
-(void)failedToConnectWithBroadCast:(NSArray *)reason{
    //Handle Room Failure Error
}
-(void)didStartBroadCast:(NSArray *)data{
    //Handle Strat Screen share
}
-(void)didStoppedBroadCast:(NSArray *)data{
    //Handle Stop Screen share
    [self.remoteRooml disconnect];
}
-(void)didRequestedExitRoom:(NSArray *_Nullable)Data{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Disconnect" object:nil userInfo:nil];
}
-(void)broadCastDisconnected{
    self.remoteRooml = nil;
}
-(void)disconnectedByOwner{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Disconnect" object:nil userInfo:nil];
}
@end
