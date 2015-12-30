

#import "YGPAnimation.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define YANIMATION_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define YANIMATION_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static  NSString * const KLoingLoaderAnimation = @"KLoingLoaderAnimation";
static  NSString * const KWarningAnimation     = @"KWarningAnimation";

//加载动画类型
typedef  NS_ENUM(NSInteger ,YAnimationType){
    
    YAnimationLoginLoader,
    YAnimationWarning,
    YAnimationClickZoom,
    YAnimationTranslation,
};

#pragma mark LoginLoaderAnimaton
@interface YGPAnimation()
{
    //原有属性值
    CGFloat       _scale;
    CGFloat       _originalH;
    CGFloat       _originalW;
    CGFloat       _originalCornerRadius;
    UIView       *_originalView;
    UIImage      *_buttonImage;
    UIImage      *_buttonBackgroundImage;
    NSString     *_buttonTitle;
    //
    UIView       *_showAnimationView;
    CAShapeLayer *_shapeLayer;
    UIView       *_maskView;
    UIColor      *_backgroundColor;
    BOOL          _isLoadAnimation;
    
    //进度条with动画
    YGPAnimation   *_animaitonView;
    ProgressView *_progressView;
    
    
}

/////////////////////////////////////////////////////////////////
//** 动画方法
/////////////////////////////////////////////////////////////////

//UIView转化成加载图标
- (void)YAnimationshowLoginLoaderAnimationWithView:(id)view
                                          forColor:(UIColor*)color;

//UIView转化成加载图标(停止)
- (void)YAnimationstopLoginLoaderAnimaiton;

//错误抖动动画
- (void)YAnimationshowWarningAnimationWithView:(id)view
                          forAnimationFinished:(YAnimatioFinished)animationFinished;

//点击缩放效果
- (void)YAnimationShowClickZoomAnimationWithView:(id)view
                            forAnimationFinished:(YAnimatioFinished)animationFinished;

//平移出现
- (void)YAnimationShowTranslationAnimationWithView:(id)view
                                      forDirection:(YAnimationTranslationDirection)direction
                                 AnimationFinished:(YAnimatioFinished)animationFinished;

@end

@implementation YGPAnimation

- (id)init{
    if (self = [super init]) {
        _isLoadAnimation = NO;
    }
    return self;
}
//*******************点击登陆加载动画*****************//

- (void)YAnimationshowLoginLoaderAnimationWithView:(id)view forColor:(UIColor*)color{
    
    [self setLoaderAnimationView:view
                        forColor:color];
}

- (void)startLoginLoaderAnimation{
    
    CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation
                                               animationWithKeyPath:@"cornerRadius"];
    
    cornerRadiusAnimation.duration  = 0.5f;
    
    cornerRadiusAnimation.fromValue = [NSNumber
                                       numberWithInt:_originalCornerRadius];
    
    cornerRadiusAnimation.toValue   = [NSNumber
                                       numberWithInt:_originalCornerRadius*1.2*_scale];
    
    [[_showAnimationView layer] addAnimation:cornerRadiusAnimation
                                      forKey:@""];
    
    [_showAnimationView layer].cornerRadius = _originalCornerRadius*1.2*_scale;
    
    
    [UIView animateWithDuration:0.15f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [_showAnimationView layer].bounds = CGRectMake(0, 0,
                                                       _originalW*1.1,
                                                       _originalH*1.1);
        
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_showAnimationView layer].bounds = CGRectMake(0, 0,
                                                               _originalW*1.2,
                                                               _originalH*1.2);
                
            } completion:^(BOOL finished) {
                
                // 遮罩层
                [self maskLayer];
                [_progressView startAnimationWithAnmationKey:KLoingLoaderAnimation];
            }];
        }
    }];
}

- (void)YAnimationstopLoginLoaderAnimaiton{
    
    
    if (!_isLoadAnimation) {
        return;
    }else{
        
        [_progressView stopProgressAnimation];
        
        _showAnimationView.maskView = nil;
        
        CABasicAnimation * cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        
        cornerRadiusAnimation.fromValue = [NSNumber numberWithFloat:_showAnimationView.layer.cornerRadius];
        cornerRadiusAnimation.toValue   = [NSNumber numberWithFloat:_originalCornerRadius];
        cornerRadiusAnimation.duration  = 0.5f;
        
        [_showAnimationView.layer addAnimation:cornerRadiusAnimation forKey:@""];
        _showAnimationView.layer.cornerRadius = _originalCornerRadius;
        
        
        //缩放
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            _showAnimationView.layer.bounds = CGRectMake(0, 0,
                                                         CGRectGetWidth(_showAnimationView.frame)*1.1,
                                                         CGRectGetHeight(_showAnimationView.frame)*1.1);
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    _showAnimationView.layer.bounds = CGRectMake(0, 0,
                                                                 CGRectGetWidth(_showAnimationView.frame)/1.3,
                                                                 CGRectGetHeight(_showAnimationView.frame)/1.3);
                    
                } completion:^(BOOL finished) {
                    
                    if (finished) {
                        
                        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            
                            _showAnimationView.layer.bounds = CGRectMake(0, 0,_originalW,_originalH);
                            
                        } completion:^(BOOL finished) {
                            if ([_showAnimationView isKindOfClass:[UIButton class]]) {
                                 [(UIButton*)_showAnimationView setBackgroundImage:_buttonBackgroundImage forState:UIControlStateNormal];
                                [(UIButton*)_showAnimationView setImage:_buttonImage forState:UIControlStateNormal];
                                [(UIButton*)_showAnimationView setTitle:_buttonTitle forState:UIControlStateNormal];
                            }
                           
                        }];
                        
                    }
                    
                    
                }];
            }
        }];
        
        _progressView = nil;
        _isLoadAnimation = NO;
    }
    
}
- (void)setLoaderAnimationView:(id)view forColor:(UIColor*)color{
    
    if (_isLoadAnimation) return;
    
    _originalW            = [view frame].size.width;
    _originalH            = [view frame].size.height;
    _scale                = 3.f;
    _showAnimationView    = view;
    _originalCornerRadius = [view layer].cornerRadius;
    _backgroundColor      = color;
    _isLoadAnimation      = YES;
    _showAnimationView.backgroundColor = color;
    
    if ([_showAnimationView isKindOfClass:[UIButton class]]) {
        
        if ([(UIButton*)_showAnimationView titleLabel].text !=nil) {
            _buttonTitle = [(UIButton*)_showAnimationView titleLabel].text;
        }
        if ([[(UIButton*)_showAnimationView imageView] image] !=nil){
            _buttonImage = [[(UIButton*)_showAnimationView imageView] image];
        }
        if ([(UIButton*)_showAnimationView backgroundImageForState:UIControlStateNormal]){
            _buttonBackgroundImage = [(UIButton*)_showAnimationView backgroundImageForState:UIControlStateNormal];
        }
        
        [(UIButton*)_showAnimationView setTitle:@"" forState:UIControlStateNormal];
        [(UIButton*)_showAnimationView setBackgroundImage:nil forState:UIControlStateNormal];
        [(UIButton*)_showAnimationView setImage:nil forState:UIControlStateNormal];
    }
    
    [self startLoginLoaderAnimation];
}

- (void)maskLayer{
    
    CGRect maskFrame;
    CGFloat width  = [_showAnimationView layer].bounds.size.width;
    CGFloat height = [_showAnimationView layer].bounds.size.height;
    
    maskFrame.origin.x = width/2 - height/2;
    maskFrame.origin.y = height/2 - height/2;
    maskFrame.size     = CGSizeMake(height,height);
    
    _maskView = [[UIView alloc]initWithFrame:maskFrame];
    
    _maskView.backgroundColor    = [UIColor whiteColor];
    _maskView.layer.cornerRadius = height/2;
    _showAnimationView.maskView  = _maskView;
    
    [_showAnimationView addSubview:[self progressView]];
    
    
}

- (UIView*)progressView{
    
    if (_progressView == nil) {
        _progressView = [[ProgressView alloc]initWithFrame:_maskView.frame
                                        forBackgroundColor:_backgroundColor];
        
    }
    
    return _progressView;
}


//*******************警告动画*****************//

#pragma mark Warning Animation

- (void)YAnimationshowWarningAnimationWithView:(id)view forAnimationFinished:(YAnimatioFinished)animationFinished{
    
    _animationFinished = animationFinished;
    
    _showAnimationView   = view;
    _scale = 4.f;
    
    CGFloat original_X = _showAnimationView.center.x;
    
    CAKeyframeAnimation * keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    
    keyFrameAnimation.delegate    = self;
    keyFrameAnimation.duration    = 0.1f;
    keyFrameAnimation.values      = @[@(original_X-_scale),@(original_X+_scale)];
    keyFrameAnimation.keyTimes    = @[@0.2f,@0.2f];
    keyFrameAnimation.repeatCount = 3.f;
    
    [_showAnimationView.layer addAnimation:keyFrameAnimation
                                    forKey:KWarningAnimation];
    
}

//*******************按钮点击效果*****************//

- (void)YAnimationShowClickZoomAnimationWithView:(id)view forAnimationFinished:(YAnimatioFinished)animationFinished{
    _showAnimationView = view;
    
    if ([_showAnimationView isKindOfClass:[UIButton class]]) {
        
        [(UIButton*)_showAnimationView addTarget:self
                                          action:@selector(clickZoomAnimation)
                                forControlEvents:UIControlEventTouchUpInside];
    }else{
        
        UITapGestureRecognizer * clickZoomTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickZoomAnimation)];
        [_showAnimationView addGestureRecognizer:clickZoomTap];
    }
    
}

- (void)clickZoomAnimation{
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.05 animations:^{
        
        _showAnimationView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            [UIView animateWithDuration:0.05 animations:^{
                
                _showAnimationView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                
            } completion:^(BOOL finished) {
                
                if (finished) {
                    
                    if (weakSelf.animationFinished) {
                        weakSelf.animationFinished();
                    }
                }
            }];
        }
    }];
    
}

//*******************按钮点击效果*****************//
- (void)YAnimationShowTranslationAnimationWithView:(id)view forDirection:(YAnimationTranslationDirection)direction AnimationFinished:(YAnimatioFinished)animationFinished{
    
    _showAnimationView = view;
    _animationFinished = animationFinished;
    CGFloat from_x = 0.0f;
    CGFloat to_x   = _showAnimationView.center.x;
    
    NSArray * values;
    if (direction == YAnimationTranslationDirectionLeft) {
        
        from_x = - CGRectGetMidX(_showAnimationView.frame)
        + CGRectGetWidth(_showAnimationView.frame);
        
        values =  @[@(from_x),@(to_x+10),@(to_x)];
        
    }else if (direction == YAnimationTranslationDirectionRight){
        
        from_x = (YANIMATION_SCREEN_WIDTH - CGRectGetMaxX(_showAnimationView.frame))
        + CGRectGetMaxX(_showAnimationView.frame);
        
        values =  @[@(from_x),@(to_x-10),@(to_x)];
        
    }
    
    CAKeyframeAnimation * keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    keyframeAnimation.values   = values;
    keyframeAnimation.duration = 0.3f;
    keyframeAnimation.delegate = self;
    [_showAnimationView.layer addAnimation:keyframeAnimation forKey:@""];
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (_animationFinished) {
        _animationFinished();
    }
}

@end

static NSString *const KProgressRotationAnimation = @"KProgressRotationAnimation";
@interface ProgressView()
{
    
    CAShapeLayer *_shapeLayer;
    UIColor      *_progressColor;
    NSString     *_progressLoaderAnimation;
    
}
@end

@implementation ProgressView

- (id)initWithFrame:(CGRect)frame forBackgroundColor:(UIColor*)backgroundColor{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor    = backgroundColor;
        self.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
        
        [self setProgressColorWithColor:backgroundColor];
        [self progressViewWithFrame:frame];
        
        
    }
    return self;
}

- (void)progressViewWithFrame:(CGRect)frame{
    
    CGRect bezierFrame;
    bezierFrame.size   = CGSizeMake(CGRectGetHeight(frame)/1.5,
                                    CGRectGetHeight(frame)/1.5);
    
    bezierFrame.origin = CGPointMake(CGRectGetHeight(frame)/2
                                     - CGRectGetHeight(bezierFrame)/2,
                                     CGRectGetHeight(frame)/2
                                     - CGRectGetHeight(bezierFrame)/2);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:bezierFrame];
    
    _shapeLayer             = [CAShapeLayer layer];
    _shapeLayer.fillColor   = [UIColor clearColor].CGColor;
    _shapeLayer.strokeColor = [self getProgressColor].CGColor;
    _shapeLayer.strokeStart = 0.f;
    _shapeLayer.strokeEnd   = 0.f;
    _shapeLayer.lineWidth   = 2.f;
    _shapeLayer.path        = path.CGPath;
    [self.layer addSublayer:_shapeLayer];
    
}

- (void)setProgressColorWithColor:(UIColor*)color{
    
    if (color == [UIColor whiteColor]) {
        _progressColor = [UIColor grayColor];
    }else{
        _progressColor = [UIColor whiteColor];
    }
}

- (UIColor*)getProgressColor{
    return _progressColor;
}

- (void)startAnimationWithAnmationKey:(NSString*)animationKey{
    
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = @0.f;
    rotation.toValue   = @(2*M_PI);
    rotation.duration = 2.f;
    rotation.repeatCount = MAXFLOAT;
    [self.layer addAnimation:rotation forKey:KProgressRotationAnimation];
    
    CABasicAnimation *pAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    pAnimation.fromValue = @0.f;
    pAnimation.toValue = @0.25;
    pAnimation.duration = 1;
    pAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CABasicAnimation *tAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    tAnimation.fromValue = @0.f;
    tAnimation.toValue = @1.f;
    tAnimation.duration = 1;
    tAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *cAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    cAnimation.beginTime = 1.f;
    cAnimation.fromValue = @0.25f;
    cAnimation.toValue = @1;
    cAnimation.duration = 1;
    cAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CABasicAnimation *xAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    xAnimation.beginTime = 1.f;
    xAnimation.fromValue = @1.f;
    xAnimation.toValue = @1.f;
    xAnimation.duration = 1;
    xAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[pAnimation,tAnimation,cAnimation,xAnimation];
    group.repeatCount = MAXFLOAT;
    group.duration = 1.5;
    
    [_shapeLayer addAnimation:group forKey:animationKey];
    _progressLoaderAnimation = animationKey;
    
}

- (void)stopProgressAnimation{
    
    [self.layer removeAnimationForKey:KProgressRotationAnimation];
    [_shapeLayer removeAnimationForKey:_progressLoaderAnimation];
    [self removeFromSuperview];
}
@end

#pragma mark YAnimation ex UIView

static char YUIViewYAnimation;
static char YisShowAnimation;

@implementation UIView(YAnimation)

@dynamic animation;


- (void)YAnimationShowLoginLoaderAnimationWithBackgroundColor:(UIColor*)backgroundColor
{
    [self initYAnimationWithColor:backgroundColor forYAnimationType:YAnimationLoginLoader direction:YAnimationTranslationDirectionNone];
}

- (void)YAnimationStopLoginLoaderAnimation{
    
    if (self.isShowAnimation) {
        [self.animation YAnimationstopLoginLoaderAnimaiton];
        self.isShowAnimation = NO;
    }
}

- (void)YAnimationShowWarningAnimation{
    [self initYAnimationWithColor:nil forYAnimationType:YAnimationWarning direction:YAnimationTranslationDirectionNone];
}

- (void)YAnimationShowClickZoomAnimation
{
    [self initYAnimationWithColor:nil forYAnimationType:YAnimationClickZoom direction:YAnimationTranslationDirectionNone];
}

- (void)YAnimationShowTranslationAnimationWithDirection:(YAnimationTranslationDirection)direction{
    
    [self initYAnimationWithColor:nil forYAnimationType:YAnimationTranslation direction:direction];
    
}

- (void)initYAnimationWithColor:(UIColor*)Color forYAnimationType:(YAnimationType)YAnimationType direction:(YAnimationTranslationDirection)direction{
    
    
    if (self.isShowAnimation)return;
    
    if (!self.animation) {
        YGPAnimation * animation = [[YGPAnimation alloc]init];
        self.animation         = animation;
        [self startYAnimationWithAnimationType:YAnimationType forColor:Color direction:direction];
    }else{
        [self startYAnimationWithAnimationType:YAnimationType forColor:Color direction:direction];
    }
    self.isShowAnimation   = YES;
}

- (void)startYAnimationWithAnimationType:(YAnimationType)animationType forColor:(UIColor*)Color direction:(YAnimationTranslationDirection)direction{
    
    __weak typeof(self) weakSelf = self;
    
    if (animationType == YAnimationLoginLoader) {
        
        [self.animation YAnimationshowLoginLoaderAnimationWithView:self forColor:Color];
        
    }else if (animationType == YAnimationWarning){
        
        [self.animation YAnimationshowWarningAnimationWithView:self forAnimationFinished:^{
            
            weakSelf.isShowAnimation = NO;
        }];
        
    }else if (animationType == YAnimationClickZoom){
        
        [self.animation YAnimationShowClickZoomAnimationWithView:self forAnimationFinished:^{
            weakSelf.isShowAnimation = NO;
        }];
        
    }else if (animationType == YAnimationTranslation){
        
        [self.animation YAnimationShowTranslationAnimationWithView:self forDirection:direction AnimationFinished:^{
            NSLog(@"完成");
            weakSelf.isShowAnimation = NO;
        }];
    }
}


//******* set get
- (void)setAnimation:(YGPAnimation *)animation{
    
    [self willChangeValueForKey:@"animation"];
    objc_setAssociatedObject(self,
                             &YUIViewYAnimation,
                             animation,
                             OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"animation"];
    
    
}

- (YGPAnimation*)animation{
    return objc_getAssociatedObject(self, &YUIViewYAnimation);
}

- (void)setIsShowAnimation:(BOOL)isShowAnimation{
    [self willChangeValueForKey:@"isShowAnimation"];
    objc_setAssociatedObject(self,
                             &YisShowAnimation,
                             [NSNumber numberWithBool:isShowAnimation],
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"isShowAnimation"];
    
}

-(BOOL)isShowAnimation{
    return [objc_getAssociatedObject(self, &YisShowAnimation) boolValue];
}

@end