//
//  HistoryViewController.m
//  DynamicPicture
//
//  Created by TNP on 2017/4/27.
//  Copyright © 2017年 重庆瓦普时代网络科技有限公司. All rights reserved.
//

#import "HistoryViewController.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "ThreeCell.h"
#import "FiveCell.h"
#import "SevenCell.h"
#import "EightCell.h"
#import "CustomHeader.h"


@interface HistoryViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataArray;
    UIButton *addBtn;
}
@end

@implementation HistoryViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (_dataArray.count==0) {
//        [self.tableView.mj_header beginRefreshing];
//    }
    [self.tableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [addBtn removeFromSuperview];
}
-(void)addClick:(UIButton *)sender
{
    NSArray *arr = TOutDate(@"shoucang");
    NSMutableArray *dataA = [[NSMutableArray alloc]init];
    NSDictionary *dic = [_categorys mj_keyValues];
    if (arr.count>0)
    {
        [dataA addObjectsFromArray:arr];
        if (![dataA containsObject:dic])
        {
         [dataA addObject:dic];
        }
    }else
    {
     [dataA addObject:dic];
    }
    TWriteDate(dataA, @"shoucang");
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"成功加入收藏、请到我的收藏中查看管理" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
    [alert show];
}


-(void)headUploadingisHead:(NSInteger)number
{
    if (number ==1)
    {
        [NetworkManager getDetailData:_categorys.n page:20 Success:^(id data) {
            
            // NSLog(@"----------%@",data);
            NSDictionary *dict = data[@"model"];
            NSArray *arr = dict[@"data"];
            _dataArray = [CategoryModel mj_objectArrayWithKeyValuesArray:arr];
            
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [self.tableView.mj_header endRefreshing];
        }];
    }else
    {
        self.nextPage +=20;
        
        [NetworkManager getDetailData:_categorys.n page:self.nextPage Success:^(id data) {
            
            // NSLog(@"----------%@",data);
            NSDictionary *dict = data[@"model"];
            NSArray *arr = dict[@"data"];
            _dataArray = [CategoryModel mj_objectArrayWithKeyValuesArray:arr];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [self.tableView.mj_footer endRefreshing];
        }];
        
    }
    
}
- (void)garbageCode {
    
    UITextField *field = [[UITextField alloc] init];
    NSString *key = nil;
    switch (field.keyboardType) {
        case UIKeyboardTypeDefault:key = @"Default";break;
        case UIKeyboardTypeASCIICapable:key = @"ASCIICapable";break;
        case UIKeyboardTypeNumbersAndPunctuation:key = @"NumbersAndPunctuation";break;
        case UIKeyboardTypeURL:key = @"UR";break;
        case UIKeyboardTypeNumberPad:key = @"NumberPad";break;
        case UIKeyboardTypePhonePad:key = @"PhonePad";break;
        case UIKeyboardTypeEmailAddress:key = @"EmailAddress";break;
        case UIKeyboardTypeDecimalPad:key = @"DecimalPad";break;
        case UIKeyboardTypeTwitter:key = @"Twitter";break;
        case UIKeyboardTypeWebSearch:key = @"Search";break;
        case UIKeyboardTypeASCIICapableNumberPad:key = @"ASCIICapableNumberPad";break;
            
        default:
            break;
    }
    
    field.text = @"      本协议为您与本APP管理者之间所订立的契约，具有合同的法律效力，请您仔细阅读。\n\
    一、 本协议内容、生效、变更\n\
    本协议内容包括协议正文及所有本APP已经发布的或将来可能发布的各类规则。所有规则为本协议不可分割的组成部分，与协议正文具有同等法律效力。如您对协议有任何疑问，应向本APP咨询。您在同意所有协议条款并完成注册程序，才能成为本站的正式用户，您点击“我以阅读并同意本APP用户协议和法律协议”按钮后，本协议即生效，对双方产生约束力。\n\
    只要您使用本APP平台服务，则本协议即对您产生约束，届时您不应以未阅读本协议的内容或者未获得本APP对您问询的解答等理由，主张本协议无效，或要求撤销本协议。您确认：本协议条款是处理双方权利义务的契约，始终有效，法律另有强制性规定或双方另有特别约定的，依其规定。 您承诺接受并遵守本协议的约定。如果您不同意本协议的约定，您应立即停止注册程序或停止使用本APP平台服务。本APP有权根据需要不定期地制订、修改本协议及/或各类规则，并在本APP平台公示，不再另行单独通知用户。变更后的协议和规则一经在网站公布，立即生效。如您不同意相关变更，应当立即停止使用本APP平台服务。您继续使用本APP平台服务的，即表明您接受修订后的协议和规则。\n\
    \n\
    \n\
    \n\
    二、 注册\n\
    注册资格用户须具有法定的相应权利能力和行为能力的自然人、法人或其他组织，能够独立承担法律责任。您完成注册程序或其他本APP平台同意的方式实际使用本平台服务时，即视为您确认自己具备主体资格，能够独立承担法律责任。若因您不具备主体资格，而导致的一切后果，由您及您的监护人自行承担。\n\
    注册资料\n\
    2.1用户应自行诚信向本站提供注册资料，用户同意其提供的注册资料真实、准确、完整、合法有效，用户注册资料如有变动的，应及时更新其注册资料。如果用户提供的注册资料不合法、不真实、不准确、不详尽的，用户需承担因此引起的相应责任及后果，并且本APP保留终止用户使用本平台各项服务的权利。\n\
    2.2用户在本站进行浏览等活动时，涉及用户真实姓名/名称、通信地址、联系电话、电子邮箱等隐私信息的，本站将予以严格保密，除非得到用户的授权或法律另有规定，本站不会向外界披露用户隐私信息。 账户\n\
    3.1您注册成功后，即成为本APP平台的会员，将持有本APP平台唯一编号的账户信息，您可以根据本站规定改变您的密码。\n\
    \n\
    \n\
    3.2您设置的姓名为真实姓名，不得侵犯或涉嫌侵犯他人合法权益。否则，本APP有权终止向您提供服务，注销您的账户。账户注销后，相应的会员名将开放给任意用户注册登记使用。\n\
    3.3您应谨慎合理的保存、使用您的会员名和密码，应对通过您的会员名和密码实施的行为负责。除非有法律规定或司法裁定，且征得本APP的同意，否则，会员名和密码不得以任何方式转让、赠与或继承（与账户相关的财产权益除外）。\n\
    3.4用户不得将在本站注册获得的账户借给他人使用，否则用户应承担由此产生的全部责任，并与实际使用人承担连带责任。\n\
    3.5如果发现任何非法使用等可能危及您的账户安全的情形时，您应当立即以有效方式通知本APP要求暂停相关服务，并向公安机关报案。您理解本APP对您的请求采取行动需要合理时间，本APP对在采取行动前已经产生的后果（包括但不限于您的任何损失）不承担任何责任。\n\
    用户信息的合理使用\n\
    4.1您同意本APP平台拥有通过邮件、短信电话等形式，向在本站注册用户发送信息等告知信息的权利。\n\
    4.2您了解并同意，本APP有权应国家司法、行政等主管部门的要求，向其提供您在本APP平台填写的注册信息和交易记录等必要信息。\n\
    \n\
    如您涉嫌侵犯他人知识产权，则本APP亦有权在初步判断涉嫌侵权行为存在的情况下，向权利人提供您必要的身份信息。\n\
    4.3用户同意本APP有权使用用户的注册信息、用户名、密码等信息，登陆进入用户的注册账户，进行证据保全，包括但不限于公证、见证等。\n\
    免责条款 \n\
    5.1 本平台仅提供信息对接，发生一切纠纷问题皆与本平台无关，请通过仲裁部门维护各自权益。\n\
    ";
    
    
}
+ (void)garbageCode2 {
    UIView *infoView = [[UIView alloc] init];
    infoView.frame = CGRectMake(0 , 50, kMainWidth, 122);
    
    CGFloat labelH = (infoView.frame.size.height - 2) / 3;
    CGFloat labelW = infoView.frame.size.width / 3.5;
    CGFloat label1W = kMainWidth - infoView.frame.size.width / 4 ;
    
    UILabel *website = [[UILabel alloc] init];
    website.font = [UIFont systemFontOfSize:14];
    website.textColor = [UIColor lightGrayColor];
    website.backgroundColor = [UIColor whiteColor];
    website.text = @"    官方网站:";
    website.frame = CGRectMake(0 , 0, labelW, labelH);
    [infoView addSubview:website];
    
    UILabel *website1 = [[UILabel alloc] init];
    website1.font = [UIFont systemFontOfSize:14];
    website1.text = @"http://www.c6.com";
    website1.backgroundColor = [UIColor whiteColor];
    website1.frame = CGRectMake(CGRectGetMaxX(website.frame) , 0, label1W, labelH);
    [infoView addSubview:website1];
    
    UILabel *wechat = [[UILabel alloc] init];
    wechat.font = [UIFont systemFontOfSize:14];
    wechat.textColor = [UIColor lightGrayColor];
    wechat.backgroundColor = [UIColor whiteColor];
    wechat.text = @"    微信公众号:";
    wechat.frame = CGRectMake(0 , CGRectGetMaxY(website.frame) + 1, labelW, labelH);
    [infoView addSubview:wechat];
    
    UILabel *wechat1 = [[UILabel alloc] init];
    wechat1.font = [UIFont systemFontOfSize:14];
    wechat1.text = @"彩6彩票";
    wechat1.backgroundColor = [UIColor whiteColor];
    wechat1.frame = CGRectMake(CGRectGetMaxX(wechat.frame) , CGRectGetMaxY(website1.frame) + 1, label1W, labelH);
    [infoView addSubview:wechat1];
    
    UILabel *contact = [[UILabel alloc] init];
    contact.font = [UIFont systemFontOfSize:14];
    contact.textColor = [UIColor lightGrayColor];
    contact.backgroundColor = [UIColor whiteColor];
    contact.text = @"    联系我们:";
    contact.frame = CGRectMake(0 , CGRectGetMaxY(wechat.frame) + 1, labelW, labelH);
    [infoView addSubview:contact];
    
    UILabel *contact1 = [[UILabel alloc] init];
    contact1.font = [UIFont systemFontOfSize:14];
    contact1.backgroundColor = [UIColor whiteColor];
    contact1.numberOfLines=2;
    contact1.text = @"客服QQ:6964830";
    contact1.frame = CGRectMake(CGRectGetMaxX(contact.frame) , CGRectGetMaxY(wechat1.frame) + 1, kMainWidth-CGRectGetMaxX(contact.frame), labelH);
    [infoView addSubview:contact1];

}
- (void)viewDidLoad
{
    addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(kMainWidth-60, 20, 40, 40);
    [addBtn setTitle:@"收藏" forState:(UIControlStateNormal)];
    [addBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [addBtn addTarget:self action:@selector(addClick:) forControlEvents:(UIControlEventTouchUpInside)];
    addBtn.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:addBtn];
    
    self.nextPage = 20;
    _dataArray = [[NSMutableArray alloc]init];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainWidth, kMainHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[ThreeCell class] forCellReuseIdentifier:@"Three"];
    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.nextPage = 20;
        [weakSelf headUploadingisHead:1];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf headUploadingisHead:0];
    }];
    
    [NetworkManager getDetailData:_categorys.n page:20 Success:^(id data) {
        
        // NSLog(@"----------%@",data);
        NSDictionary *dict = data[@"model"];
        NSArray *arr = dict[@"data"];
        _dataArray = [CategoryModel mj_objectArrayWithKeyValuesArray:arr];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.view toastMessage:@"请检查网络"];
    }];

    
    [[self class] garbageCode2];
    [self garbageCode];

    [super viewDidLoad];
    
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryModel *model = _dataArray[indexPath.row];
    model.isHistory = @"1";
    model.cn = _categorys.cn;
    if ([model.cn isEqualToString:@"福彩3D"] ||[model.cn isEqualToString:@"安徽快3"] ||[model.cn isEqualToString:@"吉林快3"] ||[model.cn isEqualToString:@"湖北快3"] ||[model.cn isEqualToString:@"江苏快3"] ||[model.cn isEqualToString:@"排列三"] )
    {
        
        ThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Three" forIndexPath:indexPath];
        cell.model = model;
        return cell;
        
    }
    else if ([model.cn isEqualToString:@"重庆时时彩"] ||[model.cn isEqualToString:@"广东11选5"] ||[model.cn isEqualToString:@"江西11选5"] ||[model.cn isEqualToString:@"山东11选5"]||[model.cn isEqualToString:@"上海11选5"]||[model.cn isEqualToString:@"排列五"]||[model.cn isEqualToString:@"彩运11选5"])
    {
        static NSString *cellIdentifier = @"Five";
        FiveCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[FiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.model = model;
        return cell;
    }
    else if ([model.cn isEqualToString:@"超级大乐透"] ||[model.cn isEqualToString:@"七星彩"] ||[model.cn isEqualToString:@"双色球"])
    {
        static NSString *cellIdentifier = @"Seven";
        SevenCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[SevenCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.model = model;
        return cell;
    }
    else if ([model.cn isEqualToString:@"七乐彩"] ||[model.cn isEqualToString:@"广东快乐十分"] ||[model.cn isEqualToString:@"重庆快乐十分"])
    {
        static NSString *cellIdentifier = @"Eight";
        EightCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[EightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.model = model;
        return cell;
    }else
    {
        return [UITableViewCell new];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
