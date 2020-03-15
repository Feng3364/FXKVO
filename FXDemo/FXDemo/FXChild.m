//
//  FXChild.m
//  FXDemo
//
//  Created by Felix on 2020/3/14.
//  Copyright © 2020 Felix. All rights reserved.
//

#import "FXChild.h"

@implementation FXChild

@synthesize name = _name;

static FXChild* _instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"name"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

//- (void)setName:(NSString *)name {
//    [self willChangeValueForKey:@"name"];
//    _name= name;
//    [self didChangeValueForKey:@"name"];
//}

@end
