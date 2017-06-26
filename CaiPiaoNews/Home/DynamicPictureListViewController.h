//
//  MainViewController.h
//  DynamicPicture
//
//  Created by Kings Yan on 2016/12/22.
//  Copyright © 2016年 重庆瓦普时代网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CategoryModel.h"
typedef void (^succesBlock)();
typedef NS_ENUM(NSInteger, DPFetchType){
    kFetchTypeNormal = 0,
    kFetchTypeUp,
    kFetchTypeDown
};

@interface DynamicPictureListViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSString *categorys;

@property(nonatomic,copy)succesBlock completeblock;

@property (assign, nonatomic) NSInteger nextPage;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end
