//
//  FXPerson.h
//  FXDemo
//
//  Created by Felix on 2020/3/14.
//  Copyright © 2020 Felix. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FXPerson : NSObject
{
    @public
    NSString *nickname;
}

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *process;
@property (nonatomic, assign) double current;
@property (nonatomic, assign) double total;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

NS_ASSUME_NONNULL_END
