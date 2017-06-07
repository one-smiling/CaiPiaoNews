//
//  VRPhotoBrowser.m
//  NewCamera3D
//
//  Created by LuShuai on 2016/11/16.
//  Copyright © 2016年 superd3d. All rights reserved.
//

#import "VRPhotoBrowser.h"
#import "MWPhotoBrowserPrivate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "UIView+toast.h"

@interface VRPhotoBrowser ()
@property(nonatomic, strong) UIView *bottomBar;
@property(nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,assign) NSInteger currentImageIndex;
@end



@implementation VRPhotoBrowser

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isShowAuthor = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Listen progress notifications
    // Listen for MWPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDidFinishLoding:)
                                                 name:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];

    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)imageDidFinishLoding:(NSNotification *)noti {
    if ([self currentVisiableImage]) {
        [self enableBottomsBtn:YES];
    }
}

- (void)enableBottomsBtn:(BOOL)enable {
    for (UIButton *btn in self.bottomBar.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            btn.enabled = enable;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回
- (void)backButtonTouchHandler:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)downLoadImage:(UIButton *)btn {
    UIImage *image = self.currentVisiableImage;
    if (image) {
        
         [self saveImageToAblum:image completion:^(BOOL isSuccess, PHAsset *asset) {
             [self.view toastMessage:isSuccess ? @"图片下载成功" : @"图片下载失败" ];
         }];
        
        
        // 0.判断状态
        /*
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusDenied) {
            [SVProgressHUD showSuccessWithStatus:@"请在设置中打开相册打开访问权限"];
            NSLog(@"用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
        }else if (status == PHAuthorizationStatusRestricted){
            [SVProgressHUD showSuccessWithStatus:@"相册不允许访问"];
            NSLog(@"家长控制,不允许访问");
        }else if (status == PHAuthorizationStatusNotDetermined){
            NSLog(@"用户还没有做出选择");
            [self saveImage:image];
        }else if (status == PHAuthorizationStatusAuthorized){
            NSLog(@"用户允许当前应用访问相册");
            [self saveImage:image];
        }
         */
    }
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    //    return _photos.count;
    return _albumsData.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    //    if (index < _photos.count)
    //        return [_photos objectAtIndex:index];
    //    return nil;
    return [MWPhoto photoWithURL:[NSURL URLWithString:_albumsData[index]]];
    
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    self.currentImageIndex = index;
    if (!self.currentVisiableImage) {
        [self enableBottomsBtn:NO];
    }
    
}



- (UIImage *)currentVisiableImage {
   return  [[self photoAtIndex:_currentImageIndex] underlyingImage];
}

/**
 *  返回相册
 */
- (PHAssetCollection *)collection{
    // 先获得之前创建过的相册
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:appName]) {
            return collection;
        }
    }
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil; // __block修改block外部的变量的值
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:appName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}


/**
 *  返回相册,避免重复创建相册引起不必要的错误
 */
- (void)saveImage:(UIImage *)image{
    /*
     PHAsset : 一个PHAsset对象就代表一个资源文件,比如一张图片
     PHAssetCollection : 一个PHAssetCollection对象就代表一个相册
     */
    
    __block NSString *assetId = nil;
    // 1. 存储图片到"相机胶卷"
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{ // 这个block里保存一些"修改"性质的代码
        // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
        // 返回PHAsset(图片)的字符串标识
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
        assetId = request.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showSuccessWithStatus:error ? error.localizedDescription : @"图片下载成功"];
            });
            return;
        }
        // 2. 获得相册对象
        PHAssetCollection *collection = [self collection];
        // 3. 将“相机胶卷”中的图片添加到新的相册
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            // 根据唯一标示获得相片对象
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            // 添加图片到相册中
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view toastMessage:error ? error.localizedDescription : @"图片下载成功"];
            });
        }];
    }];
}

-(void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL, PHAsset *))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block PHObjectPlaceholder *placeholderAsset=nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *desCollection = [self collection];
            if (!desCollection) completion(NO, nil);
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }
}



-(PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier{
    if(localIdentifier == nil){
        NSLog(@"Cannot get asset from localID because it is nil");
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if(result.count){
        return result[0];
    }
    return nil;
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
