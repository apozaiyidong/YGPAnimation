

#import <UIKit/UIKit.h>

typedef NSInteger YProgressHUDViewType;

@interface YGPProgressHUD : UIView
+ (instancetype)shareView;

//加载HUD
+ (void)showDefaultAnimationWithStatus:(NSString*)status; //默认类型

+ (void)showLoadCircleAnimationWithStatus:(NSString*)str; //圈圈转

+ (void)showWithErrorWithStr:(NSString*)str;

+ (void)showWithSuccessWithStr:(NSString*)str;

+ (void)dismiss;

// 进度条
+ (void)showProgressWithProgress:(float)progress;

////顶部提示
//+ (void)showNoticeWithStr:(NSString*)str;
//
//+ (void)showNoticeWithStr:(NSString*)str forBackgroundColor:(UIColor*)backgroundColor;

@end

//*************************************
//               制作动画
//*************************************

typedef void(^YAnimationFinish)();

@interface YAnimationView : UIView

@property (copy)YAnimationFinish animationFinish;

+ (instancetype) shareView;

- (void)showYProgressView:(UIView*)view
          forAnimationKey:(NSString*)key
                isDismiss:(BOOL)isDismiss
          animationFinish:(YAnimationFinish)animationFinish;

- (void)setYProgressHUDAnimationType:(YProgressHUDViewType)type;

+ (void)dismissYProgressView:(UIView*)view forAnimationKey:(NSString*)key;

@end