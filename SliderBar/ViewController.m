//
//  ViewController.m
//  SliderBar
//
//  Created by 龙一郎 on 2020/11/29.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *timeArray;

@property (nonatomic, strong)IBOutlet UITableView *dateTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _timeArray = [NSMutableArray array];
    
    for (int i = 0; i < 100; i++) {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *string = [dateFormatter stringFromDate:date];
        [_timeArray addObject: string];
    }
    [self.dateTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    
    UIButton *scrollBar = [UIButton buttonWithType:UIButtonTypeCustom];
    scrollBar.tag = 2333;
    [scrollBar setImage:[UIImage imageNamed:@"scrollbar_n"] forState:UIControlStateNormal];
    [scrollBar setImage:[UIImage imageNamed:@"scrollbar_h"] forState:UIControlStateHighlighted];
    [scrollBar setImage:[UIImage imageNamed:@"scrollbar_h"] forState:UIControlStateSelected];
    scrollBar.userInteractionEnabled = YES;
    
    scrollBar.frame = CGRectMake(self.view.frame.size.width-43, 20, 43, 37);
    [self.view addSubview:scrollBar];
    [scrollBar.layer removeAllAnimations];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [scrollBar addGestureRecognizer:pan];
    
//    self.dateTableView.contentInsetAdjustmentBehavior = NO;
//    if (@available(iOS 11.0, *)) {
//            UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
//    self.edgesForExtendedLayout =UIRectEdgeNone;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.timeArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"resouce";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.timeArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    //NSLog(@"keyPath=%@\nobject=%@\nchange%@\ncontext%@\n",keyPath,object,change,context);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@---%@",NSStringFromCGRect(self.dateTableView.frame),NSStringFromCGRect(self.view.frame));
}

#pragma mark ScrollBar

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

-(void)panAction:(UIPanGestureRecognizer *)gr{
    static CGFloat beganY;
    static CGRect touchBeganRect;
        switch (gr.state) {
        case UIGestureRecognizerStateBegan:
        {
            beganY = [gr locationInView:gr.view.superview].y;
            touchBeganRect = gr.view.frame;
            NSLog(@"UIGestureRecognizerStateBegan---%f",beganY);
        }
        break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat moveY = [gr locationInView:gr.view.superview].y;

            NSLog(@"UIGestureRecognizerStateChange---%f",moveY);

            CGRect newRect = touchBeganRect;
            newRect.origin.y = newRect.origin.y + (moveY - beganY);
            gr.view.frame = newRect;
            
            CGRect scrollBarRect = gr.view.frame;
            CGRect tableViewRect = self.dateTableView.frame;
            CGFloat rangeY = tableViewRect.origin.y + tableViewRect.size.height - scrollBarRect.size.height;

            if (scrollBarRect.origin.y < tableViewRect.origin.y) {
                scrollBarRect.origin.y = tableViewRect.origin.y;
                gr.view.frame = scrollBarRect;
            }else if(scrollBarRect.origin.y > rangeY){
                scrollBarRect.origin.y = rangeY;
                gr.view.frame = scrollBarRect;
            }
            
            float progress = (scrollBarRect.origin.y - tableViewRect.origin.y) / (tableViewRect.size.height - scrollBarRect.size.height);
            //NSLog(@"%f",progress);
            CGFloat offSetY = progress * (self.dateTableView.contentSize.height - tableViewRect.size.height);
            //NSLog(@"%f",offSetY);
            [self.dateTableView setContentOffset:CGPointMake(0, offSetY) animated:NO];
        }
        break;
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"UIGestureRecognizerStateEnded");
        }
        break;
        default:
        break;
    }
}
@end
