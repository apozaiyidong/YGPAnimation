

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//** 展现平移动画，出现方向
typedef NS_ENUM(NSInteger , YAnimationTranslationDirection){
    
    YAnimationTranslationDirectionNone,
    YAnimationTranslationDirectionLeft,  //左
    YAnimationTranslationDirectionRight, //右
};

typedef void(^YAnimatioFinished)();

@interface YGPAnimation : NSObject
@property (copy,nonatomic) YAnimatioFinished animationFinished;

@end

@interface ProgressView : UIView

- (id)initWithFrame:(CGRect)frame forBackgroundColor:(UIColor*)backgroundColor;
- (void)startAnimationWithAnmationKey:(NSString*)animationKey;
- (void)stopProgressAnimation;

@end

////////////////////////
//UIView 拓展 YAnimation
////////////////////////
@interface UIView(YAnimation)

@property (strong,nonatomic)YGPAnimation * animation;
@property (assign,nonatomic)BOOL         isShowAnimation;

/**
 *   UIView 转化进度条动画
 *   @params backgroundColor 加载动画背景颜色
 */
- (void)YAnimationShowLoginLoaderAnimationWithBackgroundColor:(UIColor*)backgroundColor;
- (void)YAnimationStopLoginLoaderAnimation;


/**
 *   警告动画（抖动）
 */
- (void)YAnimationShowWarningAnimation;

/**
 *   视图点击缩放效果
 */
- (void)YAnimationShowClickZoomAnimation;

/**
 *   View 平移出现
 *   @params direction 出现方向
 */
- (void)YAnimationShowTranslationAnimationWithDirection:(YAnimationTranslationDirection)direction;
@end

