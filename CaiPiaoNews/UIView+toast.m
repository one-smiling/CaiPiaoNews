//
//  UIViewController+toast.m
//  ARProject
//
//  Created by Simay on 7/10/15.
//  Copyright (c) 2015 Simay. All rights reserved.
//

#import "UIView+toast.h"
#import <objc/runtime.h>
#import <MBProgressHUD/MBProgressHUD.h>

static char HUDKey;
static const NSTimeInterval kDuration = 1.5;
static const float kDetailTitleFont = 15;
static const float kMargin = 15;


@implementation UIView (toast)
- (MBProgressHUD *)HUDView
{
    MBProgressHUD *HUD = objc_getAssociatedObject(self, &HUDKey);
    if (!HUD)
    {
        HUD = [[MBProgressHUD alloc] initWithView:self];
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:kDetailTitleFont];
        HUD.margin = kMargin;
        objc_setAssociatedObject(self, &HUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return HUD;
}

- (void)toastSuccessMessage:(NSString *)message
{    
    [self toastSuccessMessage:message complete:NULL];
}

- (void)toastSuccessMessage:(NSString *)message complete:(void (^)())complete
{
    UIImage *image = [[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self toastMessage:message title:nil duration:kDuration image:image completion:complete];
}

- (void)toastErrorMessage:(NSString *)message complete:(void (^)())complete
{
    UIImage *image = [[UIImage imageNamed:@"error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self toastMessage:message title:nil duration:kDuration image:image completion:complete];
}

- (void)toastMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.detailsLabelFont = [UIFont systemFontOfSize:15];
    hud.margin = 15.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:NO afterDelay:1.5];
}

- (void)showLoadingWithMessage:(NSString *)message
{

    [self showLoading:YES title:message details:nil image:nil];

}

- (void)showLoadingWithMessage:(NSString *)message delay:(NSTimeInterval)delay
{
    [self addSubview:self.HUDView];
    self.HUDView.labelText = message;
    [self.HUDView show:NO];
    [self.HUDView hide:NO afterDelay:delay];
    
}

- (void)hideLodingView
{
    [self.HUDView hide:NO];
    objc_setAssociatedObject(self, &HUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hideLodingViewWithErrorMessage:(NSString *)message
{
    [self hideLodingViewWithErrorMessage:message complete:NULL];
}

- (void)hideLodingViewWithSuccessMessage:(NSString *)message
{
    [self hideLodingViewWithSuccessMessage:message complete:NULL];
}

- (void)hideLodingViewWithSuccessMessage:(NSString *)message complete:(void (^)())complete
{
    UIImage *image = [[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self hideLodingViewWithTitle:message details:nil image:image duration:kDuration completion:complete];

}

- (void)hideLodingViewWithErrorMessage:(NSString *)message complete:(void (^)())complete{
    UIImage *image = [[UIImage imageNamed:@"error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self hideLodingViewWithTitle:message details:nil image:image duration:kDuration completion:complete];
}

- (void)toastMessage:(NSString *)message
            title:(NSString *)title
            duration:(NSTimeInterval)duration
            image:(UIImage *)image
          completion:(void(^)())completion {
    [self showLoading:NO title:title details:message image:image];
    [self hideLodingViewWithTitle:title details:message image:image duration:kDuration completion:completion];
}


- (void)showLoading:(BOOL)show
              title:(NSString *)title
             details:(NSString *)details
               image:(UIImage *)image {

    if (show) {
        self.HUDView.mode = MBProgressHUDModeIndeterminate;
    }
    else {
        self.HUDView.mode = MBProgressHUDModeText;
    }
    [self addSubview:self.HUDView];
    self.HUDView.labelText = title;
    self.HUDView.detailsLabelText = details;
    [self.HUDView show:NO];
    
}
- (void)hideLodingViewWithTitle:(NSString *)title
                          details:(NSString *)details
                            image:(UIImage *)image
                         duration:(NSTimeInterval)duration
                       completion:(void(^)())completion {
    
    if (image) {
        self.HUDView.mode = MBProgressHUDModeCustomView;
        self.HUDView.customView = [[UIImageView alloc] initWithImage:image];
    }
    self.HUDView.detailsLabelText = details;
    self.HUDView.labelText = title;
    
    [self.HUDView hide:NO afterDelay:duration];
    self.HUDView.completionBlock = ^ {
        if (completion) {
            completion();
        }
        objc_setAssociatedObject(self, &HUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };
}




@end
