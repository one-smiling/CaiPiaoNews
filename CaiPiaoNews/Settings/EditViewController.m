//
//  EditViewController.m
//  CaiPiaoNews
//
//  Created by lushuai on 2017/6/7.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import "EditViewController.h"
#import "UIView+toast.h"
static NSString *identifier = @"ZLSCELL";
NSString * const kCategoryChangeNotification = @"kCategoryChangeNotification";

@interface EditViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSArray *allCategory;
@property (strong, nonatomic) NSMutableArray *selectionCategory;
@property (assign ,nonatomic) BOOL isChange;
@end

@implementation EditViewController

+ (NSArray *)selectionCategoryList {
    
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSelectionCategoryList"];
    if (!list) {
        list = @[@"彩票", @"六合彩",@"时时彩",@"足球彩",@"七乐彩",@"七星彩",@"足彩"];
        [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"kSelectionCategoryList"];
    }
    return list;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectionCategory =  [NSMutableArray arrayWithArray:[[self class] selectionCategoryList]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    self.allCategory = @[@"彩票", @"六合彩",@"时时彩",@"足球彩",@"七乐彩",@"七星彩",@"足彩",@"双色球",@"超级大乐透",@"排列3",@"排列5",@"大乐透",@"22选5",@"27选5",@"上海时时乐",@"上海11选5",@"重庆快乐十分",@"快乐扑克3",@"新3D",@"华东15选5",@"东方6+1",@"14场胜负彩",@"任选9场",@"场进球彩"];

    // Do any additional setup after loading the view.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *category = _allCategory[indexPath.row];
    if ([_selectionCategory containsObject:category]) {
        if (_selectionCategory.count > 1) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_selectionCategory removeObject:category];
        } else {
            [self.view toastMessage:@"请至少选择一种彩票"];
        }

    } else {
        [_selectionCategory addObject:category];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [[NSUserDefaults standardUserDefaults] setObject:_selectionCategory forKey:@"kSelectionCategoryList"];
    self.isChange = YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allCategory.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if ([_selectionCategory containsObject:_allCategory[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = _allCategory[indexPath.row];

    
    //    cell.textLabel.text = [_dragon_list objectAtIndex:[indexPath row]];
    return cell;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isChange) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryChangeNotification object:nil];
    }
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
