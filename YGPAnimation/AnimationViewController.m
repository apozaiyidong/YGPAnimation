

#import "AnimationViewController.h"
#import "YGPAnimation/YGPAnimation.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface AnimationViewController ()
{
//    UIButton * button1;
    UIButton * button1;
    UIButton * button2;
    UIButton * button3;
    UIButton * button4;
    UIButton * button5;
}
@end

@implementation AnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
   
    
    
}

- (void)viewDidAppear:(BOOL)animated{

    button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(70, 100, 80, 80)];
    [button1 setTitle:@"BUTTON" forState:UIControlStateNormal];
    [button1 setBackgroundColor:[UIColor blackColor]];
    button1.layer.cornerRadius = 5.f;
    [self.view addSubview:button1];
    [button1 YAnimationShowTranslationAnimationWithDirection:YAnimationTranslationDirectionLeft];
    
    button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(SCREEN_WIDTH-150, 150, 80, 80)];
    [button2 setTitle:@"VIEW" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor blueColor]];
    button2.layer.cornerRadius = 5.f;
    [self.view addSubview:button2];
    [button2 YAnimationShowTranslationAnimationWithDirection:YAnimationTranslationDirectionRight];
    


    button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setFrame:CGRectMake(SCREEN_WIDTH/2-150/2, SCREEN_HEIGHT/2, 150, 40)];
    [button3 setTitle:@"缩放BUTTON" forState:UIControlStateNormal];
    [button3 setBackgroundColor:[UIColor redColor]];
    button3.layer.cornerRadius = 5.f;
    [self.view addSubview:button3];
    [button3 addTarget:self action:@selector(scaleB) forControlEvents:UIControlEventTouchUpInside];
    [button3 YAnimationShowTranslationAnimationWithDirection:YAnimationTranslationDirectionRight];

    
    button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 setFrame:CGRectMake(SCREEN_WIDTH/2-150/2, CGRectGetMaxY(button3.frame)+20, 150, 40)];
    [button4 setTitle:@"抖动" forState:UIControlStateNormal];
    [button4 setBackgroundColor:[UIColor blueColor]];
    button4.layer.cornerRadius = 5.f;
    [self.view addSubview:button4];
    [button4 addTarget:self action:@selector(error) forControlEvents:UIControlEventTouchUpInside];
    [button4 YAnimationShowTranslationAnimationWithDirection:YAnimationTranslationDirectionRight];
    
    
    button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button5 setFrame:CGRectMake(SCREEN_WIDTH/2-150/2, CGRectGetMaxY(button4.frame)+20, 100, 30)];
    [button5 setTitle:@"点我加载" forState:UIControlStateNormal];
//    [button5 setImage:[UIImage imageNamed:@"http"] forState:UIControlStateNormal];
//    [button5 setBackgroundImage:[UIImage imageNamed:@"http"] forState:UIControlStateNormal];
    [button5 setBackgroundColor:[UIColor blueColor]];
    button5.layer.cornerRadius = 5.f;
    [self.view addSubview:button5];
    [button5 addTarget:self action:@selector(load) forControlEvents:UIControlEventTouchUpInside];
    [button5 YAnimationShowTranslationAnimationWithDirection:YAnimationTranslationDirectionRight];
    
    
}

- (void)scaleB{
    [button3 YAnimationShowClickZoomAnimation];

}

- (void)load{
    [button5 YAnimationShowLoginLoaderAnimationWithBackgroundColor:[UIColor blackColor]];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(stop) userInfo:nil repeats:NO];
}

- (void)stop{

    [button5 YAnimationStopLoginLoaderAnimation];
}
- (void)error{

    [button4 YAnimationShowWarningAnimation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
