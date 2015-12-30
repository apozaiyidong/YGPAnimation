

#import "HUDViewController.h"
#import "YGPProgressHUD.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface HUDViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * _content;
    float _progress;
    NSTimer * _timer;
    
}
@end

@implementation HUDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _progress = 0;
    _content = @[@"showHUD",@"showHUD",@"showError",@"showSuccess",@"showProgress"];
    
    UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT)
                                                          style:UITableViewStylePlain];
    tableView.delegate   = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _content.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * identifier = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:identifier];
    }
    cell.textLabel.text = _content[indexPath.row];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [YGPProgressHUD showDefaultAnimationWithStatus:@""];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    }else if (indexPath.row == 1){
        [YGPProgressHUD showLoadCircleAnimationWithStatus:@""];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];

    }else if (indexPath.row ==2){
        [YGPProgressHUD showWithErrorWithStr:@""];
    }else if (indexPath.row == 3){
        [YGPProgressHUD showWithSuccessWithStr:@""];
    }else if (indexPath.row == 4){
        [YGPProgressHUD showProgressWithProgress:0.1];
       _timer =  [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(yprogress) userInfo:nil repeats:YES];

    }
    
}
- (void)yprogress{
    _progress+=0.1;
    if (_progress >= 1) {
        [_timer invalidate];
    }
    [YGPProgressHUD showProgressWithProgress:_progress];

}
- (void)dismiss{
    [YGPProgressHUD dismiss];

}

@end
