//
//  WebviewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "WebviewController.h"
#import "UIWebView+AFNetworking.h"
#import "ProductDetailViewController.h"

@interface WebviewController ()<UIWebViewDelegate>

@property(nonatomic,retain)UIWebView *webView;

@end

@implementation WebviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = self.titleString ? self.titleString : @"活动详情";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    self.webView.delegate = self;
    self.webView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];
    
    
    [self.webView loadRequest:request progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"%ld",(unsigned long)(int)bytesWritten);
        
    } success:^NSString *(NSHTTPURLResponse *response, NSString *HTML) {
        
        return HTML;
        
    } failure:^(NSError *error) {
        NSLog(@"erro %@",error);
        [LTools alertText:@"页面访问出现错误" viewController:self];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 事件处理

#pragma mark - UIWebviewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"navigationType %ld",(long)navigationType);
    NSLog(@"request %@",request.URL.relativeString);
    
    NSString *relativeUrl = request.URL.relativeString;
    
    if ([relativeUrl rangeOfString:@"product_id"].length > 0) {
        
        NSArray *arr = [relativeUrl componentsSeparatedByString:@":"];
        if (arr.count > 1) {
            NSString *productId = [arr lastObject];
            ProductDetailViewController *detail = [[ProductDetailViewController alloc]init];
            detail.product_id = productId;
            [self.navigationController pushViewController:detail animated:YES];
            
            return NO;
        }
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}

@end
