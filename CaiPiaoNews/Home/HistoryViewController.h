//
//  HistoryViewController.h
//  DynamicPicture
//
//  Created by TNP on 2017/4/27.
//  Copyright © 2017年 重庆瓦普时代网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryModel.h"
@interface HistoryViewController : UIViewController
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) CategoryModel *categorys;

@property (assign, nonatomic) NSInteger nextPage;
@end
