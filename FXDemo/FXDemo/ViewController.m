//
//  ViewController.m
//  FXDemo
//
//  Created by Felix on 2020/2/19.
//  Copyright © 2020 Felix. All rights reserved.
//

#import "ViewController.h"
#import "FXViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"主页";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:[FXViewController new] animated:YES];
}

@end
