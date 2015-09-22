//
//  AboutUsController.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AboutUsController.h"


@interface AboutUsController ()<UIWebViewDelegate>
{
    UIWebView *_aWebview;
    NSString *_phone;
}

@end

@implementation AboutUsController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"关于我们";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
//    NSURL *url =[NSURL URLWithString:ABOUT_US_URL];
//    
//    NSURLRequest *request =[NSURLRequest requestWithURL:url];
//    
//    _aWebview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
//    _aWebview.delegate=self;
//    [_aWebview loadRequest:request];
//    _aWebview.scalesPageToFit = YES;
//    [self.view addSubview:_aWebview];
//    _aWebview.dataDetectorTypes = UIDataDetectorTypeNone;
    
    NSArray *titles = @[@"客服电话",@"联系邮箱",@"万聚鲜城"];
    NSArray *contents = @[@"4000-626-010",@"zhangleiorc@163.com",@"万聚鲜城-互联网生鲜体验品牌。我们致力于用我们为之骄傲的环球海底珍鲜加上我们最极致的体验式服务为您开启全新的生鲜消费方式,让您感受不一样的生鲜品牌时代。"];
    
    for (int i = 0 ; i < titles.count; i ++) {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, i * (30 + 45), DEVICE_WIDTH - 20, 30) title:titles[i] font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [self.view addSubview:label];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, DEVICE_WIDTH, 45)];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, label.bottom, DEVICE_WIDTH - 20, 45) title:contents[i] font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
        [self.view addSubview:label2];
        
        if (i == 0) {
           
            _phone = contents[0];//电话
            [label2 addTaget:self action:@selector(clickToPhone:) tag:0];

        }
        
        if (i == 2) {
            label2.height = 90;
            label2.numberOfLines = 0;
            label2.lineBreakMode = NSLineBreakByCharWrapping;
            CGFloat aHeight = [LTools heightForText:contents[i] width:DEVICE_WIDTH - 20 font:12];
            label2.height = aHeight + 20;
            view.height = label2.height;
        }
    }
    
}

/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_phone];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        NSString *phone = _phone;
        
        if (phone) {
            
            NSString *phoneNum = phone;
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
        }
    }
}

- (void)dealloc
{
    NSLog(@"--%s--",__FUNCTION__);
    
    [_aWebview stopLoading];
    _aWebview.delegate = nil;
    _aWebview = nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [MBProgressHUD showHUDAddedTo:webView animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"erro %@",error);
    
    NSLog(@"data 为空 connectionError %@",error);
    
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
    
    NSString *errInfo = @"网络有问题,请检查网络";
    //    switch (error.code) {
    //        case NSURLErrorNotConnectedToInternet:
    //
    //            errInfo = @"无网络连接";
    //            break;
    //        case NSURLErrorTimedOut:
    //
    //            errInfo = @"网络连接超时";
    //            break;
    //        default:
    //            break;
    //    }
    
    //    [LTools showMBProgressWithText:errInfo addToView:webView];
    
    if (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut) {
        
        [self addReloadButtonWithTarget:self action:@selector(reloadData:) info:errInfo];
        
    }
    
}

- (void)reloadData:(UIButton *)sender
{
    NSURL *url =[NSURL URLWithString:ABOUT_US_URL];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    [_aWebview loadRequest:request];
    
    [_aWebview reload];
    
    [sender removeFromSuperview];
    sender = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
