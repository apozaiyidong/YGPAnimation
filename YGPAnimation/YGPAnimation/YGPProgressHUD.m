

#import "YGPProgressHUD.h"
#define SCREEN_WIDTH_YPROGRESS  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT_YPROGRESS [UIScreen mainScreen].bounds.size.height
#define SET_COLOS_YPROGRESS(R,G,B) [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:1.0]
#define HEXCOLOR_YGP(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]

NS_ENUM(YProgressHUDViewType){
    
    YProgressHUDViewDefaultType,
    YProgressHUDViewErrorType,
    YProgressHUDViewSuccessType,
    YProgressHUDViewLoadCircleType,
    YProgressHUDViewProgressType,
    YProgressHUDViewNoticeType,
    
};

static NSString *const YProgressHUDShowAnimation   = @"YProgressHUDShowAnimation";
static const CGFloat YProgressHUDUndefinedProgress = -1;
static const CGFloat YProgressHUDProgressFinish    = 1.f;
static const CGFloat YProgressHUDProgressTextSize  = 22.f;

static inline CGFloat TitleSize (){
    return 15.f;
}


@interface YGPProgressHUD()
@property (strong,nonatomic)UIView          *hudView;
@property (assign,nonatomic)BOOL             isShow;
@property (strong,nonatomic)UILabel         *noticeLabel;
@property (strong,nonatomic)YAnimationView  *animationView;
@property (assign,nonatomic)YProgressHUDViewType hudType;

@end

@implementation YGPProgressHUD

+ (instancetype)shareView{
    
    static YGPProgressHUD * _progressHUD = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _progressHUD = [[YGPProgressHUD alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _progressHUD.backgroundColor = [UIColor clearColor];
        
    });
    
    return _progressHUD;
}

//加载HUD
+ (void)showDefaultAnimationWithStatus:(NSString *)status{
    [[self shareView]showWithStatus:status
                         forHUDType:YProgressHUDViewDefaultType
                           progress:YProgressHUDUndefinedProgress];
}

+ (void)showWithErrorWithStr:(NSString *)str{
    [[self shareView] showWithStatus:str
                          forHUDType:YProgressHUDViewErrorType
                            progress:YProgressHUDUndefinedProgress];
    [[self shareView] dismissWithIsDelay:YES];
}

+ (void)showWithSuccessWithStr:(NSString *)str{
    [[self shareView] showWithStatus:str
                          forHUDType:YProgressHUDViewSuccessType
                            progress:YProgressHUDUndefinedProgress];
    [[self shareView] dismissWithIsDelay:YES];
}

+ (void)showLoadCircleAnimationWithStatus:(NSString *)str{
    
    [[self shareView]showWithStatus:str
                         forHUDType:YProgressHUDViewLoadCircleType
                           progress:YProgressHUDUndefinedProgress];
}

+ (void)dismiss{
    [[self shareView]dismissWithIsDelay:NO];
}

// 进度条
+ (void)showProgressWithProgress:(float)progress{
//    if (progress > YProgressHUDProgressFinish) {
//        return;
//    }
    [[self shareView]showWithStatus:nil
                         forHUDType:YProgressHUDViewProgressType
                           progress:progress];
}

//顶部提示
+ (void)showNoticeWithStr:(NSString *)str{
    [YGPProgressHUD showNoticeWithStr:str forBackgroundColor:nil];
}

+ (void)showNoticeWithStr:(NSString *)str forBackgroundColor:(UIColor *)backgroundColor{
    
    [[self shareView]showWithStatus:str
                         forHUDType:YProgressHUDViewNoticeType
                           progress:YProgressHUDUndefinedProgress];
}

#pragma mark

- (void)dismissWithIsDelay:(BOOL)isDelay{
    
    __weak   typeof(self) weakSelf       = self;
    __strong typeof(weakSelf) strongSelf = weakSelf;

    float delay = isDelay == YES ? 1.5f : 0.f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [strongSelf.animationView showYProgressView:strongSelf.hudView forAnimationKey:YProgressHUDShowAnimation isDismiss:YES animationFinish:^{
            
            [strongSelf.hudView       removeFromSuperview];
            [strongSelf.noticeLabel   removeFromSuperview];
            [strongSelf.animationView removeFromSuperview];
            [strongSelf               removeFromSuperview];
            
            strongSelf.noticeLabel    = nil;
            strongSelf.hudView        = nil;
            strongSelf.animationView  = nil;
            
        }];
    });
}

- (void)showWithStatus:(NSString *)string forHUDType:(NSInteger)hudType progress:(float)progress{
    
    if (!_hudView) {
        NSEnumerator * windows = [[UIApplication sharedApplication].windows reverseObjectEnumerator];
        for (UIWindow * window in windows) {
            
            BOOL windowIsVisible    = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal  = window.windowLevel == UIWindowLevelNormal;
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                
                [window addSubview:self];
                [self.superview bringSubviewToFront:self];
                
                break;
            }
        }
    }
    
    if (YProgressHUDViewProgressType == hudType) {
        [self setProgressHUDWithProgress:progress];
    }else if(YProgressHUDViewNoticeType == hudType){
        [self setNoticeViewWithStr:string];
    }else{
        _hudType = hudType;
        [self setLoadHUDWithStr:string];
    }
}

- (void)setNoticeViewWithStr:(NSString*)str{
    
    if (self.hudView){
        [self.hudView removeFromSuperview];
        self.hudView = nil;
    }
    
    if (self.animationView){
        [self.animationView removeFromSuperview];
        self.animationView = nil;
    }
}

- (void)setProgressHUDWithProgress:(float)progress{
    
    if (progress > YProgressHUDProgressFinish) {

        [self dismissWithIsDelay:NO];
        return;
    }

    if (_hudType != YProgressHUDViewProgressType) {
        if (self.hudView) {
            [self.hudView removeFromSuperview];
            self.hudView = nil;
        }
        
        if (self.animationView) {
            [self.animationView removeFromSuperview];
            self.animationView = nil;
        }
    }
    _hudType = YProgressHUDViewProgressType;
    
    CGRect frame;
    frame.size.width  = 80;
    frame.size.height = 80;
    frame.origin      = CGPointMake(SCREEN_WIDTH_YPROGRESS/2 - CGRectGetWidth(frame)/2,
                               SCREEN_HEIGHT_YPROGRESS/2 - CGRectGetHeight(frame)/2);
    
    [self.hudView setFrame:frame];
    self.hudView.layer.cornerRadius = frame.size.width/2;
    
    frame.size.width  = 60;
    frame.size.height = 60;
    frame.origin      = CGPointMake(CGRectGetWidth(_hudView.frame)/2 - CGRectGetWidth(frame)/2,
                               CGRectGetHeight(_hudView.frame)/2 - CGRectGetHeight(frame)/2);
    
    [self.noticeLabel setFrame:frame];
    self.noticeLabel.text                = [NSString stringWithFormat:@"%.f",progress * 100.f];
    self.noticeLabel.layer.cornerRadius  = 60/2;
    self.noticeLabel.layer.masksToBounds = YES;
    
    self.noticeLabel.font = [UIFont fontWithName:_noticeLabel.font.fontName
                                            size:YProgressHUDProgressTextSize];
    
    [self addSubview:self.hudView];
    [self.hudView addSubview:self.noticeLabel];
    
    self.hudView.backgroundColor     = [UIColor clearColor];
    self.noticeLabel.backgroundColor = [UIColor whiteColor];
    self.hudView.layer.borderColor   = [UIColor clearColor].CGColor;
 
    CGPoint pathCenter  = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:pathCenter
                                                         radius:frame.size.width/2+2.5
                                                     startAngle:0
                                                       endAngle:(M_PI * 2.f)*progress
                                                      clockwise:YES];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path           = path.CGPath;
    shapeLayer.strokeColor    = SET_COLOS_YPROGRESS(160, 160, 160).CGColor;
    shapeLayer.fillColor      = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth      = 5.0f;
    
    
    UIBezierPath * path2 = [UIBezierPath bezierPathWithArcCenter:pathCenter
                                                          radius:frame.size.width/2+2.5
                                                      startAngle:0
                                                        endAngle:M_PI * 2.f
                                                       clockwise:YES];
    CAShapeLayer * shapeLayer2 = [CAShapeLayer layer];
    
    shapeLayer2.path           = path2.CGPath;
    shapeLayer2.strokeColor    = SET_COLOS_YPROGRESS(210, 210, 210).CGColor;
    shapeLayer2.fillColor      = [UIColor clearColor].CGColor;
    shapeLayer2.lineWidth      = 5.0f;

    [self.hudView.layer addSublayer:shapeLayer2];
    [self.hudView.layer addSublayer:shapeLayer];

}

- (void)setLoadHUDWithStr:(NSString*)string{
    
    
    if (self.hudView) {
        [self.hudView removeFromSuperview];
        self.hudView = nil;
    }
    
    if (self.animationView) {
        [self.animationView removeFromSuperview];
        self.animationView = nil;
    }
    
    [self.animationView setYProgressHUDAnimationType:_hudType];
    
    CGSize strSize        = [self stringSizeWithStr:string];
    self.noticeLabel.text = string;
    CGFloat hudW          = strSize.width*1.5f;
    CGFloat hudH          = (strSize.height*1.3)+CGRectGetHeight(self.animationView.frame);
    hudH                  = hudH < 90  ? 90  : hudH;
    hudW                  = hudW < 110 ? 110 : hudW;
    CGFloat hudView_X     = SCREEN_WIDTH_YPROGRESS/2  - hudW/2;
    CGFloat hudView_Y     = SCREEN_HEIGHT_YPROGRESS/2 - hudH/2;
    
    [self.hudView setFrame:CGRectMake(hudView_X,
                                      hudView_Y,
                                      hudW,hudH)];
    
    [self         addSubview:self.hudView];
    [self.hudView addSubview:self.noticeLabel];
    [self.hudView addSubview:self.animationView];
    
    self.animationView.center = CGPointMake(hudW/2,
                                            string.length <=0 ? hudH/2 : hudH/3);
    
    [self.noticeLabel setFrame:CGRectMake(hudW/2 - strSize.width/2 ,
                                          CGRectGetHeight(self.hudView.frame) - (strSize.height*1.7),
                                          strSize.width,
                                          strSize.height)];
    
    
    [self.animationView showYProgressView:_hudView forAnimationKey:YProgressHUDShowAnimation isDismiss:NO animationFinish:^{
        
    }];
    
}

- (YAnimationView*)animationView{
    
    if (!_animationView) {
        _animationView = [YAnimationView shareView];
    }
    
    return _animationView;
}

-(CGSize)stringSizeWithStr:(NSString*)str
{
    NSDictionary * attribute =@{NSFontAttributeName:self.noticeLabel.font};
    
    return   [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH_YPROGRESS/2.f, SCREEN_WIDTH_YPROGRESS/2)
                               options:
              NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|
              NSStringDrawingUsesFontLeading
                            attributes:
              attribute
                               context:
              nil].size;
    
}

- (UIView*)hudView{
    
    if (!_hudView) {
        self.hudView = ({
            
            UIView * view = [[UIView alloc]initWithFrame:CGRectZero];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.cornerRadius = 10.f;
            view.layer.masksToBounds = YES;
            view.layer.borderColor = SET_COLOS_YPROGRESS(210, 210, 210).CGColor;
            view.layer.borderWidth = 2.0f;
            view;
            
        });
    }
    return _hudView;
}

- (UILabel*)noticeLabel{
    
    if (!_noticeLabel) {
        _noticeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _noticeLabel.numberOfLines = 0;
        _noticeLabel.textAlignment = NSTextAlignmentCenter;
        _noticeLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _noticeLabel.font = [UIFont fontWithName:_noticeLabel.font.fontName
                                            size:TitleSize()];
    }
    
    return _noticeLabel;
    
}
@end

static CGFloat const DEFAULT_HUD_WIDTH  = 80;
static CGFloat const DEFAULT_HUD_HEIGHT = 30;
static CGFloat const ERROR_HUD_HEIGHT   = 50;

@interface YAnimationView()

@end
@implementation YAnimationView

+ (instancetype) shareView{
    
    
    YAnimationView * animationView = [[YAnimationView alloc]initWithFrame:CGRectMake(0,
                                                                                     0,
                                                                                     DEFAULT_HUD_WIDTH,
                                                                                     DEFAULT_HUD_HEIGHT)];
    return animationView;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)setYProgressHUDAnimationType:(YProgressHUDViewType)type{
    
    switch (type) {
        case YProgressHUDViewDefaultType:
            [self showDefaultAnimation];
            break;
        case YProgressHUDViewErrorType:
            [self showErrorAnimationWithIsError:YES];
            break;
        case YProgressHUDViewLoadCircleType:
            [self showLoadCircleAnimation];
            break;
        case YProgressHUDViewSuccessType:
            [self showErrorAnimationWithIsError:NO];
            break;
        default:
            break;
    }
    
}

#pragma mark YProgressView YProgressHUDViewLoadCircleType

- (void)showLoadCircleAnimation{

    CGRect frame = self.frame;
    frame.size.height = 50;
    frame.size.width = 50;
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = frame.size.height/2;
    CGRect bezierFrame;
    bezierFrame.size   = CGSizeMake(CGRectGetHeight(self.frame)/1.5,
                                    CGRectGetHeight(self.frame)/1.5);
    
    bezierFrame.origin = CGPointMake(CGRectGetHeight(self.frame)/2
                                     - CGRectGetHeight(bezierFrame)/2,
                                     CGRectGetHeight(self.frame)/2
                                     - CGRectGetHeight(bezierFrame)/2);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:bezierFrame];
    CAShapeLayer * _shapeLayer;
    _shapeLayer             = [CAShapeLayer layer];
    _shapeLayer.fillColor   = [UIColor clearColor].CGColor;
    _shapeLayer.strokeColor = SET_COLOS_YPROGRESS(180, 180, 180).CGColor;
    _shapeLayer.strokeStart = 0.f;
    _shapeLayer.strokeEnd   = 0.f;
    _shapeLayer.lineWidth   = 2.f;
    _shapeLayer.path        = path.CGPath;
    [self.layer addSublayer:_shapeLayer];
    
    
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = @0.f;
    rotation.toValue   = @(2*M_PI);
    rotation.duration = 2.f;
    rotation.repeatCount = MAXFLOAT;
    [self.layer addAnimation:rotation forKey:@""];
    
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

    [_shapeLayer addAnimation:group forKey:@""];

}

#pragma mark YProgressView YProgressHUDViewDefaultType

- (void)showDefaultAnimation{
    
    CGFloat gap = 8;
    CGFloat view_w = 15.f;
    NSArray * delays = @[@0.0,@0.3,@0.6];
    
    for (int i = 0; i<3; i++) {
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(i*view_w+gap,
                                                                CGRectGetHeight(self.frame)/2-view_w/2,
                                                                view_w,
                                                                view_w)];
        
        view.backgroundColor     = SET_COLOS_YPROGRESS(180, 180, 180);
        view.layer.cornerRadius  = CGRectGetHeight(view.frame)/2;
        view.layer.masksToBounds = YES;
        
        [self addSubview:view];
        [self animation:view delay:[delays[i] floatValue]];
        
        gap+=10;
    }
}

- (void)animation:(UIView*)view delay:(float) delay{
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.beginTime   = delay+CACurrentMediaTime();
    animation.duration    = 1.2;
    animation.repeatCount = MAXFLOAT;
    animation.fromValue   = @1.7;
    animation.toValue     = @0.9;
    
    [view.layer addAnimation:animation forKey:@""];
    
}

#pragma mark YProgressView YProgressHUDViewErrorType
- (void)showErrorAnimationWithIsError:(BOOL)isError{
    
    CGRect frame = self.frame;
    frame.size.height = ERROR_HUD_HEIGHT;
    self.frame = frame;
    
    UIBezierPath * path = [UIBezierPath bezierPath];

    if (isError) {
        
        CGFloat from_x = CGRectGetWidth(self.frame)/3;
        CGFloat from_y = CGRectGetHeight(self.frame)/3;
        [path moveToPoint:CGPointMake(from_x, from_y)];
        
        from_x = CGRectGetWidth(self.frame)/1.5;
        from_y = CGRectGetHeight(self.frame)/1.2f;
        [path addLineToPoint:CGPointMake(from_x, from_y)];
        
        from_x = CGRectGetWidth(self.frame)/1.5;
        from_y = CGRectGetHeight(self.frame)/3;
        [path moveToPoint:CGPointMake(from_x, from_y)];
        
        from_x = CGRectGetWidth(self.frame)/3;
        from_y = CGRectGetHeight(self.frame)/1.2;
        [path addLineToPoint:CGPointMake(from_x, from_y)];
        
    }else{
        
        CGFloat from_x = CGRectGetWidth(self.frame)/5;
        CGFloat from_y = CGRectGetHeight(self.frame)/2;
        
        [path moveToPoint:CGPointMake(from_x, from_y)];
        
        from_x = CGRectGetWidth(self.frame)/2.5;
        from_y = CGRectGetHeight(self.frame)/1.2f;
        [path addLineToPoint:CGPointMake(from_x, from_y)];
        
        from_x = CGRectGetWidth(self.frame)/1.2;
        from_y = CGRectGetHeight(self.frame)/4.f;
        [path addLineToPoint:CGPointMake(from_x, from_y)];

    }
    
    
    CAShapeLayer * shapeLayer  = [CAShapeLayer layer];
    shapeLayer.fillColor       = [UIColor clearColor].CGColor;
    shapeLayer.backgroundColor = [UIColor redColor].CGColor;
    shapeLayer.strokeColor     = SET_COLOS_YPROGRESS(180, 180, 180).CGColor;
    shapeLayer.strokeStart     = 0.f;
    shapeLayer.strokeEnd       = 0.f;
    shapeLayer.lineWidth       = 3.f;
    shapeLayer.path            = path.CGPath;
    
    CABasicAnimation * animation  = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    
    animation.fromValue = @0.f;
    animation.toValue   = @1.0f;
    animation.duration  = 0.5f;
    
    [shapeLayer addAnimation:animation forKey:@""];
    
    shapeLayer.strokeEnd = 1.f;
    
    [self.layer addSublayer:shapeLayer];
}

#pragma mark YProgressView 出现动画

- (void)showYProgressView:(UIView*)view forAnimationKey:(NSString*)key isDismiss:(BOOL)isDismiss animationFinish:(YAnimationFinish)animationFinish{
    
    _animationFinish = animationFinish;
    
    if (!isDismiss) {
        [YAnimationView dismissYProgressView:view forAnimationKey:key];
    }
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate    = self;
    animation.duration    = 0.2f;
    animation.fromValue   = isDismiss == YES ? @1.f : @0.f;
    animation.toValue     = isDismiss == YES ? @0.f : @1.f;
    
    [view.layer addAnimation:animation forKey:key];
    
}

+ (void)dismissYProgressView:(UIView*)view forAnimationKey:(NSString*)key{
    [view.layer removeAnimationForKey:key];
}

#pragma mark YAnimationView Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (_animationFinish) {
        _animationFinish();
    }
}











@end
