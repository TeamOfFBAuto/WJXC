//
//  TuiKuanViewController.m
//  YiYiProject
//
//  Created by lichaowei on 15/9/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "TuiKuanViewController.h"

@interface TuiKuanViewController ()<UITableViewDataSource,UITableViewDelegate>

{
    UITableView *_tab;
    UITextField *_refund_reason_tf;
}

@end

@implementation TuiKuanViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"申请退款";
    
    
    UIControl *aa = [[UIControl alloc]initWithFrame:self.view.bounds];
    [aa addTaget:self action:@selector(ggshou) tag:0];
    [self.view addSubview:aa];
    
    [self creatTab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MyMethod
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
}


-(void)prepareNetData{
    [_refund_reason_tf resignFirstResponder];
    if ([LTools isEmpty:_refund_reason_tf.text]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写退款原因" addToView:self.view];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{@"authcode":[GMAPI getAuthkey],
                             @"order_id":self.orderId,
                             @"refund_reason":_refund_reason_tf.text};
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_REFUND parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_TUIKUAN_SUCCESS object:nil];
        
        [self performSelector:@selector(goPop) withObject:self afterDelay:2.5];
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];
}

-(void)ggshou{
    
    [_refund_reason_tf resignFirstResponder];
}

-(void)goPop{
    
    if (self.lastVc) { //如果是来自订单详情成功之后需要先pop掉详情
        
        [self.lastVc.navigationController popViewControllerAnimated:NO];
        [self.lastVc.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITabelViewDelegate && UITabelViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIControl *shou = [[UIControl alloc]initWithFrame:cell.contentView.bounds];
    [shou addTarget:self action:@selector(ggshou) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if (indexPath.row == 0) {
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 30)];
        tLabel.userInteractionEnabled = YES;
        [tLabel addTaget:self action:@selector(ggshou) tag:0];
        [cell.contentView addSubview:tLabel];
        
        NSString *aa = @"退款金额  *不可更改";
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:aa];
        
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,4)];
        
        [str addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(133, 134, 135) range:NSMakeRange(4,aa.length - 4)];
        
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 4)];
        
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(4, aa.length - 4)];
        
        tLabel.attributedText = str;
        
        
        UIView *cLabel_backView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(tLabel.frame), tLabel.frame.size.width, 40)];
        cLabel_backView.backgroundColor = RGBCOLOR(238, 239, 240);
        cLabel_backView.layer.cornerRadius = 4;
        [cell.contentView addSubview:cLabel_backView];
        
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, cLabel_backView.frame.size.width - 20, cLabel_backView.frame.size.height)];
        tf.userInteractionEnabled = NO;
        tf.textColor = RGBCOLOR(80, 81, 82);
        tf.font = [UIFont systemFontOfSize:15];
        tf.text = [NSString stringWithFormat:@"%.2f",self.tuiKuanPrice];
        [cLabel_backView addSubview:tf];
        
        
        
        
    }else if (indexPath.row == 1){
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 30)];
        tLabel.userInteractionEnabled = YES;
        [tLabel addTaget:self action:@selector(ggshou) tag:0];
        tLabel.font = [UIFont systemFontOfSize:12];
        tLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:tLabel];
        
//        NSString *aa = @"退款说明 (可选填)";
//
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:aa];
//        
//        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,4)];
//        
//        [str addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(133, 134, 135) range:NSMakeRange(4,aa.length - 4)];
//        
//        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 4)];
//        
//        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(4, aa.length - 4)];
//        
//        tLabel.attributedText = str;
        
        
        NSString *aa = @"退款说明";
        tLabel.text = aa;
        
        
        UIView *cLabel_backView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(tLabel.frame), tLabel.frame.size.width, 40)];
        cLabel_backView.backgroundColor = RGBCOLOR(238, 239, 240);
        cLabel_backView.layer.cornerRadius = 4;
        [cell.contentView addSubview:cLabel_backView];
        
        _refund_reason_tf  = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, cLabel_backView.frame.size.width - 20, cLabel_backView.frame.size.height)];
        _refund_reason_tf.textColor = RGBCOLOR(80, 81, 82);
        _refund_reason_tf.font = [UIFont systemFontOfSize:12];
        _refund_reason_tf.placeholder = @"请输入退款原因";
        [cLabel_backView addSubview:_refund_reason_tf];
        
        
        
    }else if (indexPath.row == 2) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, [LTools fitHeight:40])];
        [btn setTitle:@"提交申请" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.layer.cornerRadius = 4;
        btn.backgroundColor = DEFAULT_TEXTCOLOR;
        [btn addTarget:self action:@selector(prepareNetData) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
    }
    
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}










@end
