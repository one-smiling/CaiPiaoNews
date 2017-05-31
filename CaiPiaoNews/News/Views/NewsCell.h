//
//  NewsCell.h
//  CaiPiaoNews
//
//  Created by Simay on 2017/5/28.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsAuthorTime;

@end
