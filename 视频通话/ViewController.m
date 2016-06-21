//
//  ViewController.m
//  视频通话
//
//  Created by mutianyou1 on 16/4/11.
//  Copyright © 2016年 mutianyou1. All rights reserved.
//

#import "ViewController.h"
#import "VedioTakeViewController.h"
#import "VedioCommunicateViewController.h"


@interface ViewController (){
    UIButton *_takeVedioButton;
    UIButton *_vedioCommunicate;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频功能";
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = MAINCOLOR;
    [self setUpButton];
    
    
    
}
- (void)setUpButton{
    _takeVedioButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_takeVedioButton setTitle:@"拍摄小视频" forState:UIControlStateNormal];
    [_takeVedioButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    _takeVedioButton.frame = CGRectMake(10, HEIGTH * 0.3,140, 30);
    [self.view addSubview:_takeVedioButton];
    
    
    
    
    _vedioCommunicate = [UIButton buttonWithType:UIButtonTypeSystem];
    [_vedioCommunicate setTitle:@"视频通话" forState:UIControlStateNormal];
    [_vedioCommunicate addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame = _takeVedioButton.frame;
    frame.origin.x = WIDTH - 10 - 140;
    _vedioCommunicate.frame = frame;
    [self.view addSubview:_vedioCommunicate];

}
- (void)clickButton:(UIButton*)button{
    if ([button.titleLabel.text containsString:@"拍摄"]) {
        [self.navigationController pushViewController:[VedioTakeViewController new] animated:YES];
    }else{
        [self.navigationController pushViewController:[VedioCommunicateViewController new] animated:YES];
    
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
