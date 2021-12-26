//
//  SampleHandler.m
//  BroadCastExtension
//
//  Created by jaykumar on 15/12/21.
//


#import "SampleHandler.h"
#import "VCXShareScreen.h"

@interface SampleHandler ()

@property(nonatomic,strong)VCXShareScreen *screenShare;

@end

@implementation SampleHandler

-(instancetype)init{
    self = [super init];
    if(self){
        self.screenShare = [[VCXShareScreen alloc]init];
    }
    return self;
}
- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedBroadCast:) name:@"Disconnect" object:nil];
}
- (void)beginRequestWithExtensionContext:(nonnull NSExtensionContext *)context {
    [super beginRequestWithExtensionContext:context];
    [self.screenShare joinRoom];
}
- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [self.screenShare stopScreenShare];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            [self.screenShare processBufferScreen:sampleBuffer];
            // Handle video sample buffer
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}
-(void)finishedBroadCast:(NSNotification *)notification{
    //finishBroadcastGracefully(self);
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    NSError *error = [NSError errorWithDomain:@"BroadcastUploadExtension" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Finished"}];
        [self finishBroadcastWithError:error];
        #pragma clang diagnostic pop
}

@end
