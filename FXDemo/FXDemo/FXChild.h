//
//  FXChild.h
//  FXDemo
//
//  Created by Felix on 2020/3/14.
//  Copyright © 2020 Felix. All rights reserved.
//

#import "FXPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface FXChild : FXPerson

+ (instancetype)shareInstance;

//@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
