

#import "ViewController.h"
#import "YGPAnimation.h"
#import "YGPProgressHUD.h"

#import "AnimationViewController.h"
#import "HUDViewController.h"
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
static inline 
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * _content;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _content = @[@"animation",@"hud"];
    
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
        AnimationViewController * a = [[AnimationViewController alloc]init];
        [self.navigationController pushViewController:a animated:YES];
    }else{
        HUDViewController * h = [[HUDViewController alloc]init];
        [self.navigationController pushViewController:h animated:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
