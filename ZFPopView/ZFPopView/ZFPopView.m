//
//  ZFPopView.m
//  commonTestA
//
//  Created by zhaofeng on 14-3-3.
//  Copyright (c) 2014年 GInspire. All rights reserved.
//

#import "ZFPopView.h"

@interface ZFPopViewStack : NSObject

@property (nonatomic) NSMutableArray *popViews;

+ (ZFPopViewStack *)sharedInstance;

- (void)push:(ZFPopView *)popView;
- (void)pop:(ZFPopView *)popView;

@end

static const CGFloat PopViewWidth = 270.0;
static const CGFloat PopViewContentMargin = 9;
static const CGFloat PopViewVerticalElementSpace = 10;
static const CGFloat PopViewButtonHeight = 44;
static const CGFloat PopViewLineLayerWidth = 0.5;

@interface ZFPopView ()

@property (nonatomic) UIWindow *mainWindow;
@property (nonatomic) UIWindow *popWindow;
@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIView *popView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *contentView;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UITapGestureRecognizer *tap;

@end

@implementation ZFPopView

- (UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.windowLevel == windowLevel) {
            return window;
        }
    }
    return nil;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
        contentView:(UIView *)contentView

{
    self = [super init];
    
    if (self) {
        
        _mainWindow = [self windowWithLevel:UIWindowLevelNormal];
        _popWindow = [self windowWithLevel:UIWindowLevelAlert];
        
        if (!_popWindow) {
            _popWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _popWindow.windowLevel = UIWindowLevelAlert;
            _popWindow.backgroundColor = [UIColor clearColor];
        }
        
        _popWindow.rootViewController = self;
        
        CGRect frame = [self frameForOrientation:self.interfaceOrientation];
        self.view.frame = frame;
        
        _backgroundView = [[UIView alloc] initWithFrame:frame];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        _backgroundView.alpha = 0;
        [self.view addSubview:_backgroundView];
        
        _popView = [[UIView alloc] init];
        _popView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
        _popView.layer.cornerRadius = 8.0;
        _popView.layer.opacity = .95;
        _popView.clipsToBounds = YES;
        [self.view addSubview:_popView];
        
        // Title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PopViewContentMargin,
                                                                PopViewVerticalElementSpace,
                                                                PopViewWidth - PopViewContentMargin*2,
                                                                44)];
        _titleLabel.text = title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.frame = [self adjustLabelFrameHeight:self.titleLabel];
        [_popView addSubview:_titleLabel];
        
        CGFloat messageLabelY = _titleLabel.frame.origin.y + _titleLabel.frame.size.height + PopViewVerticalElementSpace;
        
        // Optional Content View
        if (contentView) {
            _contentView = contentView;
            _contentView.frame = CGRectMake(0,
                                            messageLabelY,
                                            _contentView.frame.size.width,
                                            _contentView.frame.size.height);
            _contentView.center = CGPointMake(PopViewWidth/2, _contentView.center.y);
            [_popView addSubview:_contentView];
            messageLabelY += contentView.frame.size.height + PopViewVerticalElementSpace;
        }
        
        // Message
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(PopViewContentMargin,
                                                                  messageLabelY,
                                                                  PopViewWidth - PopViewContentMargin*2,
                                                                  44)];
        _messageLabel.text = message;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        _messageLabel.frame = [self adjustLabelFrameHeight:self.messageLabel];
        [_popView addSubview:_messageLabel];
        
        _popView.bounds = CGRectMake(0, 0, PopViewWidth, 150);
        
        [self resizeViews];
        
        _popView.center = [self centerWithFrame:frame];
        
        [self setupGestures];

    }
    
    return self;
}

- (CGRect)adjustLabelFrameHeight:(UILabel *)label
{
    CGFloat height;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize size = [label.text sizeWithFont:label.font
                             constrainedToSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        height = size.height;
#pragma clang diagnostic pop
    } else {
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        context.minimumScaleFactor = 1.0;
        CGRect bounds = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:label.font}
                                                 context:context];
        height = bounds.size.height;
    }
    
    return CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, height);
}


- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect frame;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
    } else {
        frame = [UIScreen mainScreen].bounds;
    }
    return frame;
}

- (void)resizeViews
{
    CGFloat totalHeight = 0;
    for (UIView *view in [self.popView subviews]) {
        if ([view class] != [UIButton class]) {
            totalHeight += view.frame.size.height + PopViewVerticalElementSpace;
        }
    }
//    if (self.buttons) {
//        NSUInteger otherButtonsCount = [self.buttons count];
//        totalHeight += AlertViewButtonHeight * (otherButtonsCount > 2 ? otherButtonsCount : 1);
//    }
    totalHeight += PopViewVerticalElementSpace;
    
    self.popView.frame = CGRectMake(self.popView.frame.origin.x,
                                      self.popView.frame.origin.y,
                                      self.popView.frame.size.width,
                                      totalHeight);
}

- (CGPoint)centerWithFrame:(CGRect)frame
{
    return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) - [self statusBarOffset]);
}

- (CGFloat)statusBarOffset
{
    CGFloat statusBarOffset = 0;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        statusBarOffset = 20;
    }
    return statusBarOffset;
}

- (void)setupGestures
{
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.tap setNumberOfTapsRequired:1];
    [self.backgroundView setUserInteractionEnabled:YES];
    [self.backgroundView setMultipleTouchEnabled:NO];
    [self.backgroundView addGestureRecognizer:self.tap];
}

- (void)dismiss:(id)sender
{
    self.visible = NO;
    
    if ([[[ZFPopViewStack sharedInstance] popViews] count] == 1) {
        [self dismissPopAnimation];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [self.mainWindow tintColorDidChange];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            self.popWindow.hidden = YES;
            [self.mainWindow makeKeyAndVisible];
        }];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.popView.alpha = 0;
    } completion:^(BOOL finished) {
        [[ZFPopViewStack sharedInstance] pop:self];
        [self.view removeFromSuperview];
    }];
    
//    if (self.completion) {
//        BOOL cancelled = NO;
//        if (sender == self.cancelButton || sender == self.tap) {
//            cancelled = YES;
//        }
//        NSInteger buttonIndex = -1;
//        if (self.buttons) {
//            NSUInteger index = [self.buttons indexOfObject:sender];
//            if (buttonIndex != NSNotFound) {
//                buttonIndex = index;
//            }
//        }
//        self.completion(cancelled, buttonIndex);
//    }
}

- (void)showPopAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [self.popView.layer addAnimation:animation forKey:@"showPop"];
}

- (void)dismissPopAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = .2;
    
    [self.popView.layer addAnimation:animation forKey:@"dismissPop"];
}

- (void)show
{
    [[ZFPopViewStack sharedInstance] push:self];
}

- (void)showInternal
{
    self.popWindow.hidden = NO;
    [self.popWindow addSubview:self.view];
    [self.popWindow makeKeyAndVisible];
    self.visible = YES;
    [self showBackgroundView];
    [self showPopAnimation];
}

- (void)showBackgroundView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [self.mainWindow tintColorDidChange];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 1;
    }];
}

- (void)hide
{
    [self.view removeFromSuperview];
}



#pragma mark -
#pragma mark Public

+ (instancetype)popWithTitle:(NSString *)title
{
    return [[self class] popWithTitle:title message:nil contentView:nil];
}

+ (instancetype)popWithTitle:(NSString *)title
                     message:(NSString *)message
{
    return [[self class] popWithTitle:title message:message contentView:nil];
}

+ (instancetype)popWithcontentView:(UIView *)view
{
    return [[self class] popWithTitle:nil message:nil contentView:view];
}

+ (instancetype)popWithTitle:(NSString *)title
                     message:(NSString *)message
                 contentView:(UIView *)contentView
{
    ZFPopView *popView = [[ZFPopView alloc] initWithTitle:title message:message contentView:contentView];
    [popView show];
    return popView;
}


@end

@implementation ZFPopViewStack

+ (instancetype)sharedInstance
{
    static ZFPopViewStack *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ZFPopViewStack alloc] init];
        _sharedInstance.popViews = [NSMutableArray array];
    });
    
    return _sharedInstance;
}

- (void)push:(ZFPopView *)popView
{
    [self.popViews addObject:popView];
    [popView showInternal];
    for (ZFPopView *pv in self.popViews) {
        if (pv != popView) {
            [pv hide];
        }
    }
}

- (void)pop:(ZFPopView *)popView
{
    [self.popViews removeObject:popView];
    ZFPopView *last = [self.popViews lastObject];
    if (last) {
        [last showInternal];
    }
}



@end
