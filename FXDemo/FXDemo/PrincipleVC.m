//
//  PrincipleVC.m
//  FXDemo
//
//  Created by Felix on 2020/3/14.
//  Copyright © 2020 Felix. All rights reserved.
//

#import "PrincipleVC.h"
#import "FXPerson.h"
#import <objc/runtime.h>

@interface PrincipleVC ()

@property (nonatomic, strong) FXPerson *person;

@end

@implementation PrincipleVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"原理";
    
    self.person = [FXPerson new];
    
    [self printClasses:[FXPerson class]];
    [self printClassAllMethod:[FXPerson class]];
    [self.person addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self.person addObserver:self forKeyPath:@"dataArray" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    [self printClassAllMethod:[FXPerson class]];
    [self printClassAllMethod:NSClassFromString(@"NSKVONotifying_FXPerson")];
//    [self.person addObserver:self forKeyPath:@"nickname" options:(NSKeyValueObservingOptionNew) context:NULL];
}

- (void)dealloc {
    NSLog(@"销毁了");
    [self.person removeObserver:self forKeyPath:@"name"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@", keyPath);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.name = @"name";
    self.person->nickname = @"nickname";
}

- (void)printClasses:(Class)cls {
    // 注册类的总数
    int count = objc_getClassList(NULL, 0);
    // 创建一个数组， 其中包含给定对象
    NSMutableArray *mArray = [NSMutableArray arrayWithObject:cls];
    // 获取所有已注册的类
    Class* classes = (Class*)malloc(sizeof(Class)*count);
    objc_getClassList(classes, count);
    for (int i = 0; i<count; i++) {
        if (cls == class_getSuperclass(classes[i])) {
            [mArray addObject:classes[i]];
        }
    }
    free(classes);
    NSLog(@"classes = %@", mArray);
}

- (void)printClassAllMethod:(Class)cls {
    NSLog(@"*********%@***********",NSStringFromClass(cls));
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        IMP imp = class_getMethodImplementation(cls, sel);
        NSLog(@"%@-%p",NSStringFromSelector(sel),imp);
    }
    free(methodList);
}

@end

