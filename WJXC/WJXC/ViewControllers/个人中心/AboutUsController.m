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
    
    NSURL *url =[NSURL URLWithString:ABOUT_US_URL];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    _aWebview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _aWebview.delegate=self;
    [_aWebview loadRequest:request];
    _aWebview.scalesPageToFit = YES;
    [self.view addSubview:_aWebview];
    _aWebview.dataDetectorTypes = UIDataDetectorTypeNone;
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
