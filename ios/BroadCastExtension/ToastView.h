//
//  ToastView.h
//  VCXiOS_GroupMode
//
//  Created by Jay Kumar on 01/02/19.
//  Copyright © 2019 Daljeet Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastView : UIView
@property (strong, nonatomic) NSString *text;
+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(float)duration;
@end

NS_ASSUME_NONNULL_END
