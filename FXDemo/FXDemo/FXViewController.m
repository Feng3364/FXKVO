//
//  FXViewController.m
//  FXDemo
//
//  Created by Felix on 2020/3/14.
//  Copyright © 2020 Felix. All rights reserved.
//

#import "FXViewController.h"
#import "PrincipleVC.h"
#import "FXPerson.h"
#import "FXChild.h"
#import "NSObject+FXKVO.h"

static void *PersonNameContext = &PersonNameContext;
static void *ChildNameContext = &ChildNameContext;

@interface FXViewController ()
@property (nonatomic, strong) FXPerson *person;
@property (nonatomic, strong) FXChild *child;
@end

@implementation FXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Push页";
    
    self.person = [FXPerson new];
    self.person.name = @"Felix";
    [self.person fx_addObserver:self forKeyPath:@"name" block:^(id  _Nonnull observer, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"%@", newValue);
    }];
//    [self.person addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:PersonNameContext];
    
//    self.child = [FXChild shareInstance];
//    self.child.name = @"Feng";
//    [self.child fx_addObserver:self forKeyPath:@"name" block:^(id  _Nonnull observer, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
//
//    }];
//    [self.child addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:ChildNameContext];
    
//    self.person.current = 0;
//    self.person.total = 100;
//    [self.person addObserver:self forKeyPath:@"process" options:(NSKeyValueObservingOptionNew) context:NULL];
//
//    self.person.dataArray = @[].mutableCopy;
//    [self.person addObserver:self forKeyPath:@"dataArray" options:(NSKeyValueObservingOptionNew) context:NULL];
}

- (void)dealloc {
//    [self.person removeObserver:self forKeyPath:@"name"];
//    [self.child removeObserver:self forKeyPath:@"name"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"name"]) {
//        NSLog(@"%@", change);
//    }
//    if (context == PersonNameContext) {
//        NSLog(@"%@", change);
//    } else if (context == ChildNameContext) {
//        NSLog(@"%@", change);
//    }
//    if ([keyPath isEqualToString:@"process"]) {
//        NSLog(@"%@", change);
//    }
//    if ([keyPath isEqualToString:@"dataArray"]) {
//        NSLog(@"%@", change);
//    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.name = [NSString stringWithFormat:@"%@+", self.person.name];
//    self.child.name = [NSString stringWithFormat:@"%@+", self.child.name];
//    self.person.current += 10;
//    self.person.total += 10;
//    [[self.person mutableArrayValueForKey:@"dataArray"] addObject:@"Felix"];
    
//    PrincipleVC *vc = [PrincipleVC new];
//    [self.navigationController pushViewController:vc animated:YES];
}

@end
