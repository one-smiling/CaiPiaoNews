//
//  VRPhotoBrowser.h
//  NewCamera3D
//
//  Created by LuShuai on 2016/11/16.
//  Copyright © 2016年 superd3d. All rights reserved.
//

#import "MWPhotoBrowser.h"


/*
 
 // Create browser
 VRPhotoBrowser *browser = [[VRPhotoBrowser alloc] init];
 browser.delegate = browser;
 browser.albumsData = _albumsData;
 browser.displayActionButton = NO;
 browser.displayNavArrows = NO;
 browser.displaySelectionButtons = NO;
 browser.alwaysShowControls = NO;
 [browser setCurrentPhotoIndex:beginIndex];
 browser.isShowAuthor = ![self.albumName isEqualToString:@"欣赏"];
 [self.navigationController pushViewController:browser animated:YES];
 */

@interface VRPhotoBrowser : MWPhotoBrowser<MWPhotoBrowserDelegate>
@property (nonatomic,strong) NSArray *albumsData;
@property (assign,nonatomic) BOOL isShowAuthor;
@end
