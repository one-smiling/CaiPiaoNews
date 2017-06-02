//
//  NewsImageCell.h
//  CaiPiaoNews
//
//  Created by lushuai on 2017/6/2.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsAuthorTime;
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;

@end
