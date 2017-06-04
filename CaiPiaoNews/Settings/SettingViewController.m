//
//  SettingViewController.m
//  CaiPiaoNews
//
//  Created by lushuai on 2017/6/2.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import "SettingViewController.h"
#import <SDWebImage/SDImageCache.h>
#import <Masonry.h>
#import "UIView+toast.h"

@interface SettingViewController ()
@property (nonatomic,strong) NSArray *datas;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = @[@"新闻",@"清除缓存",@"关于我们"];
    [self putBufferClicked];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self putBufferClicked];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)putBufferClicked
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSUInteger size = [SDImageCache sharedImageCache].getSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            _sizeLabel.text = [NSString stringWithFormat:@"%.2fMB",(unsigned long)size / 1024.0 / 1024.0];
        });
        
    });
    //    CGFloat size = [[AppDelegate shared] folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject] + [[AppDelegate shared] folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject] + [[AppDelegate shared] folderSizeAtPath:NSTemporaryDirectory()];
    
}


#pragma mark - Table view data source


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"ZLSCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if (indexPath.row == 0 || [indexPath row] == 2 || indexPath.row == 4) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 1) {
            [cell.contentView addSubview:_sizeLabel];
            [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell.contentView.mas_right).offset(-30);
                make.top.mas_equalTo(cell.contentView.mas_top).offset(5);
                make.height.equalTo(@35);
                make.width.equalTo(@80);
            }];
            [self putBufferClicked];
        }
    }
    
//    cell.textLabel.text = [_dragon_list objectAtIndex:[indexPath row]];
    return cell;

}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        if ([SDImageCache sharedImageCache].getSize == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前暂无缓存清理，您可以先去别处看看。" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            [self.view showLoadingWithMessage:@"清理中..."];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [self.view hideLodingViewWithSuccessMessage:@"清理完成"];
                [self putBufferClicked];
            }];
        }

    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    segue.destinationViewController.hidesBottomBarWhenPushed = YES;
}
- (IBAction)summarySwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.on) forKey:@"kShowSummary"];
        
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
