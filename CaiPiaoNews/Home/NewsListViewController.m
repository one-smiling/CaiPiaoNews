//
//  NewsListViewController.m
//  CaiPiaoNews
//
//  Created by lushuai on 2017/6/2.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import "NewsListViewController.h"
#import "ViewController.h"
#import "EditViewController.h"

extern NSString * const kCategoryChangeNotification;

@interface NewsListViewController ()
@property (assign,nonatomic) BOOL isReload;
@end

@implementation NewsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCategories) name:kCategoryChangeNotification object:nil];
    self.isProgressiveIndicator = YES;
    // Do any additional setup after loading the view.
    
    [self.buttonBarView setBackgroundColor:[UIColor clearColor]];
    [self.buttonBarView.selectedBar setBackgroundColor:[UIColor orangeColor]];
    [self.buttonBarView removeFromSuperview];
    [self.navigationController.navigationBar addSubview:self.buttonBarView];
    
    self.changeCurrentIndexProgressiveBlock = ^void(XLButtonBarViewCell *oldCell, XLButtonBarViewCell *newCell, CGFloat progressPercentage, BOOL changeCurrentIndex, BOOL animated){
        if (changeCurrentIndex) {
            [oldCell.label setTextColor:[UIColor colorWithWhite:0 alpha:0.6]];
            [newCell.label setTextColor:[UIColor blackColor]];
            
            if (animated) {
                [UIView animateWithDuration:0.1
                                 animations:^(){
                                     newCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                     oldCell.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                 }
                                 completion:nil];
            }
            else{
                newCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
                oldCell.transform = CGAffineTransformMakeScale(0.8, 0.8);
            }
        }
    };

    // Do any additional setup after loading the view.
}

- (void)reloadCategories {
    [super reloadPagerTabStripView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar addSubview:self.buttonBarView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = YES;
    [self.buttonBarView removeFromSuperview];
}
#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    // create child view controllers that will be managed by XLPagerTabStripViewController
    NSArray *viewControllerTitles = [EditViewController selectionCategoryList];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSString *title in viewControllerTitles) {
        ViewController* child = [[ViewController alloc] init];
        child.keyWord = title;
        [viewControllers addObject:child];
    }
    return [NSArray arrayWithArray:viewControllers];
    
    
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
