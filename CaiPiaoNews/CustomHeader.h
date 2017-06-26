//
//  CustomHeader.h
//  CaiPiaoNews
//
//  Created by lushuai on 2017/6/26.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#ifndef CustomHeader_h
#define CustomHeader_h

//#define KNavBarHexColor @"F8C35B"
#define kMainWidth [UIScreen mainScreen].bounds.size.width
#define kMainHeight [UIScreen mainScreen].bounds.size.height
#define TOutDate(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define TWriteDate(obj,key) [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];\

#endif /* CustomHeader_h */
#import "NetworkManager.h"
#import "UIView+toast.h"
