//
//  ZFPopView.h
//  commonTestA
//
//  Created by zhaofeng on 14-3-3.
//  Copyright (c) 2014年 GInspire. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZFPopViewCompletionBlock)(BOOL cancelled, NSInteger buttonIndex);

@interface ZFPopView : UIViewController

@property (nonatomic, getter = isVisible) BOOL visible;

+ (instancetype)popWithTitle:(NSString *)title;

+ (instancetype)popWithTitle:(NSString *)title
                     message:(NSString *)message;

+ (instancetype)popWithTitle:(NSString *)title
                     message:(NSString *)message
                 contentView:(UIView *)contentView;

+ (instancetype)popWithcontentView:(UIView *)view;



@end
