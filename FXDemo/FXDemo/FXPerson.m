//
//  FXPerson.m
//  FXDemo
//
//  Created by Felix on 2020/3/14.
//  Copyright © 2020 Felix. All rights reserved.
//

#import "FXPerson.h"

@implementation FXPerson

//+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
//    if ([key isEqualToString:@"name"]) {
//        return YES;
//    }
//    return [super automaticallyNotifiesObserversForKey:key];
//}

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"process"]) {
        NSArray *affectingKeys = @[@"total", @"current"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

- (NSString *)process {
    if (self.total == 0) {
        return @"0";
    }
    return [[NSString alloc] initWithFormat:@"%f",1.0f*self.current/self.total];
}

@end
