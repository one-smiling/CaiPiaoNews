//
//  ThreeCell.h
//  DynamicPicture
//
//  Created by TNP on 2017/4/19.
//  Copyright © 2017年 重庆瓦普时代网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryModel.h"
@interface ThreeCell : UITableViewCell

@property(nonatomic,strong)UILabel *title;
@property(nonatomic,strong)UILabel *datas;
@property(nonatomic,strong)UIView *bigV;
@property(nonatomic,strong)CategoryModel *model;
@end
