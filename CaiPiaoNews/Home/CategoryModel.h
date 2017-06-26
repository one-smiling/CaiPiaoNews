//
//  CategoryModel.h
//  DynamicPicture
//
//  Created by Kings Yan on 2016/12/23.
//  Copyright © 2016年 重庆瓦普时代网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryModel : NSObject

@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *base_id;
@property (nonatomic, strong) NSString *module;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *recommend;


@property (nonatomic, strong) NSString *code;//开奖号码
@property (nonatomic, strong) NSString *date;//开奖日期
@property (nonatomic, strong) NSString *issue;//期数
@property (nonatomic, strong) NSString *n;//代码
@property (nonatomic, strong) NSString *cn;//名字
@property (nonatomic, strong) NSString *isHistory;//查看历史 详情


@end

@interface MoveModel : NSObject

@property (nonatomic, strong) NSString *award;//杀3对3"
@property (nonatomic, strong) NSString *calc;//"05,17,26"
@property (nonatomic, strong) NSString *hitnum;//"测7对7期"
@property (nonatomic, strong) NSString *username;//"飞行家"


@end
