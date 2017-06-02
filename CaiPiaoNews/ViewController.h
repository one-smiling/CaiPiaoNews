//
//  ViewController.h
//  CaiPiaoNews
//
//  Created by lushuai on 2017/5/27.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"

@interface ViewController : UIViewController<XLPagerTabStripChildItem>
@property (copy,nonatomic) NSString *keyWord;
@end

