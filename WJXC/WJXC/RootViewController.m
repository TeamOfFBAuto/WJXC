//
//  RootViewController.m
//  TestClouth
//
//  Created by lichaowei on 14/12/9.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "ClassViewController.h"
#import "ShoppingCarController.h"
#import "PersonalViewController.h"

@interface RootViewController ()<UITabBarControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{

}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.delegate = self;
    
    [self prepareItems];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"RootViewController viewWillAppear");
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareItems
{
    
    NSArray *classNames = @[@"HomeViewController",@"ClassViewController",@"ShoppingCarController",@"PersonalViewController"];
    NSArray *item_names = @[@"首页",@"分类",@"购物车",@"个人中心"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:classNames.count];
    for (int i = 0; i < classNames.count;i ++) {
            
        NSString *className = classNames[i];
        UIViewController *vc = [[NSClassFromString(className) alloc]init];
        XNavigationController *unvc = [[XNavigationController alloc]initWithRootViewController:vc];
        [items addObject:unvc];
        
    }
    

    self.viewControllers = [NSArray arrayWithArray:items];
    
    NSArray *normalImages = @[@"gfujin_up",@"ttai_up",@"my_up",@"my_up"];
    NSArray *selectedImages = @[@"gfujin_down",@"ttai_down",@"my_down",@"my_down"];
    
    for (int i = 0; i < normalImages.count; i ++) {
        
        UITabBarItem *item = self.tabBar.items[i];
        UIImage *aImage = [UIImage imageNamed:[normalImages objectAtIndex:i]];
        aImage = [aImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.image = aImage;
        
        UIImage *selectImage = [UIImage imageNamed:[selectedImages objectAtIndex:i]];
        selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = selectImage;
        
        item.title = [item_names objectAtIndex:i];

    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"666666"],                                                                                                              NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"dc4b6c"],                                                                                                              NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
}


- (void)pushToViewController:(UIViewController *)viewController
{
    viewController.hidesBottomBarWhenPushed = YES;
    [(UINavigationController *)self.selectedViewController pushViewController:viewController animated:YES];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"--> %d  %@",(int)tabBarController.selectedIndex,viewController);
    
}

@end
