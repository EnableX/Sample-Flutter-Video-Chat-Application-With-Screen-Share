//
//  VCXServicesClass.h
//  EnxBroadCast
//
//  Created by jaykumar on 15/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ServiceResult)(id);

@interface VCXServicesClass : NSObject
-(void)fetchCreateToken:(NSDictionary *)options result:(ServiceResult)result;
@end

NS_ASSUME_NONNULL_END
