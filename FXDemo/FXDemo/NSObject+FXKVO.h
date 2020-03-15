//
//  NSObject+FXKVO.h
//  FXDemo
//
//  Created by Felix on 2020/3/15.
//  Copyright © 2020 Felix. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FXKVOBlock)(id observer,NSString *keyPath,id oldValue,id newValue);

@interface NSObject (FXKVO)

- (void)fx_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(FXKVOBlock)block;

@end

NS_ASSUME_NONNULL_END
