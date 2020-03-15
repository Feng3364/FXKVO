//
//  NSObject+FXKVO.m
//  FXDemo
//
//  Created by Felix on 2020/3/15.
//  Copyright © 2020 Felix. All rights reserved.
//

#import "NSObject+FXKVO.h"
#import <objc/message.h>

static NSString *const kFXKVOPrefix = @"FXKVONotifying_";
static NSString *const kFXKVOAssiociateKey = @"kFXKVO_AssiociateKey";

@interface FXKVOInfo : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) FXKVOBlock handleBlock;
@end

@implementation FXKVOInfo

- (instancetype)initWitObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath handleBlock:(FXKVOBlock)block {
    if (self=[super init]) {
        _observer = observer;
        _keyPath  = keyPath;
        _handleBlock = block;
    }
    return self;
}
@end


@implementation NSObject (FXKVO)

#pragma mark - 方法交换

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self FXMethodSwizzlingWithClass:self oriSEL:NSSelectorFromString(@"dealloc") swizzledSEL:@selector(fx_dealloc)];
//    });
//}

- (void)fx_dealloc {
    Class superClass = [self class];
    object_setClass(self, superClass);
    [self fx_dealloc];
}

- (void)FXMethodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL {
    
    if (!cls) NSLog(@"传入的交换类不能为空");
    
    Method oriMethod = class_getInstanceMethod(cls, oriSEL);
    Method swiMethod = class_getInstanceMethod(cls, swizzledSEL);
    
    if (!oriMethod) {
        class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
        method_setImplementation(swiMethod, imp_implementationWithBlock(^(id self, SEL _cmd) {
            NSLog(@"方法未实现");
        }));
    }

    BOOL didAddMethod = class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swiMethod);
    }
}

#pragma mark - 注册观察
- (void)fx_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(FXKVOBlock)block {
    // 判空
    if (keyPath == nil || keyPath.length == 0) return;
    
    // 判断是否有keyPath这个属性————分类中的属性没有setter方法也会返回YES
//    if (![self isContainProperty:keyPath]) return;
    
    // 判断是否有setter方法
    if (![self isContainSetterMethodFromKeyPath:keyPath]) return;
    
    // 判断automaticallyNotifiesObserversForKey方法返回的布尔值
    BOOL isAutomatically = [self fx_performSelectorWithMethodName:@"automaticallyNotifiesObserversForKey:" keyPath:keyPath];
    if (!isAutomatically) return ;
    
    // 动态生成子类
    Class newClass = [self createChildClassWithKeyPath:keyPath];
    // isa指向修改->指向动态子类
    object_setClass(self, newClass);
    
    // 保存信息
    FXKVOInfo *info = [[FXKVOInfo alloc] initWitObserver:observer forKeyPath:keyPath handleBlock:block];
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kFXKVOAssiociateKey));
    if (!mArray) {
        mArray = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(kFXKVOAssiociateKey), mArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [mArray addObject:info];
}

#pragma mark - 判断方法
/// 判断属性是否存在
/// @param keyPath 属性名
- (BOOL)isContainProperty:(NSString *)keyPath {
    unsigned int number;
    objc_property_t *propertiList = class_copyPropertyList([self class], &number);
    for (unsigned int i = 0; i < number; i++) {
        const char *propertyName = property_getName(propertiList[i]);
        NSString *propertyString = [NSString stringWithUTF8String:propertyName];
        
        if ([keyPath isEqualToString:propertyString]) {
            NSLog(@"找到了该属性%@", keyPath);
            return YES;
        }
    }
    free(propertiList);
    NSLog(@"没找到该属性%@", keyPath);
    return NO;
}

/// 判断setter方法
/// @param keyPath 属性名
- (BOOL)isContainSetterMethodFromKeyPath:(NSString *)keyPath {
    Class superClass    = object_getClass(self);
    SEL setterSeletor   = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(superClass, setterSeletor);
    if (!setterMethod) {
        NSLog(@"没找到该属性的setter方法%@", keyPath);
        return NO;
    }
    return YES;
}

/// 动态调用类方法，返回调用方法的返回值
/// @param methodName 方法名
/// @param keyPath 观察属性
- (BOOL)fx_performSelectorWithMethodName:(NSString *)methodName keyPath:(id)keyPath {

    if ([[self class] respondsToSelector:NSSelectorFromString(methodName)]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        BOOL i = [[self class] performSelector:NSSelectorFromString(methodName) withObject:keyPath];
        return i;
#pragma clang diagnostic pop
    }
    return NO;
}

#pragma mark - 创建类
- (Class)createChildClassWithKeyPath:(NSString *)keyPath {
    
    NSString *oldClassName = NSStringFromClass([self class]);
    NSString *newClassName = [NSString stringWithFormat:@"%@%@", kFXKVOPrefix, oldClassName];
    Class newClass = NSClassFromString(newClassName);
    // 防止重复创建生成新类
    if (newClass) return newClass;
    /**
     * 如果内存不存在,创建生成
     * 参数一: 父类
     * 参数二: 新类的名字
     * 参数三: 新类的开辟的额外空间
     */
    // 申请类
    newClass = objc_allocateClassPair([self class], newClassName.UTF8String, 0);
    // 注册类
    objc_registerClassPair(newClass);
    // 添加class : class的指向是FXPerson
    SEL classSEL = NSSelectorFromString(@"class");
    Method classMethod = class_getInstanceMethod([self class], classSEL);
    const char *classTypes = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, classSEL, (IMP)fx_class, classTypes);
    // 添加setter
    SEL setterSEL = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod([self class], setterSEL);
    const char *setterTypes = method_getTypeEncoding(setterMethod);
    class_addMethod(newClass, setterSEL, (IMP)fx_setter, setterTypes);
    // 添加dealloc
//    SEL deallocSEL = NSSelectorFromString(@"dealloc");
//    Method deallocMethod = class_getInstanceMethod([self class], deallocSEL);
//    const char *deallocTypes = method_getTypeEncoding(deallocMethod);
//    class_addMethod(newClass, deallocSEL, (IMP)fx_dealloc, deallocTypes);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self FXMethodSwizzlingWithClass:[self class] oriSEL:NSSelectorFromString(@"dealloc") swizzledSEL:@selector(fx_dealloc)];
    });
    
    return newClass;
}

Class fx_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

static void fx_setter(id self,SEL _cmd,id newValue) {
    NSString *keyPath = getterForSetter(NSStringFromSelector(_cmd));
    id oldValue = [self valueForKey:keyPath];
    
    // 改变父类的值 --- 可以强制类型转换
    void (*lg_msgSendSuper)(void *,SEL , id) = (void *)objc_msgSendSuper;
    struct objc_super superStruct = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self)),
    };
    lg_msgSendSuper(&superStruct,_cmd,newValue);
    
    // 信息数据回调
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kFXKVOAssiociateKey));
    
    for (FXKVOInfo *info in mArray) {
        if ([info.keyPath isEqualToString:keyPath] && info.handleBlock) {
            info.handleBlock(info.observer, keyPath, oldValue, newValue);
        }
    }
}

#pragma mark - 从set方法获取getter方法的名称
static NSString *getterForSetter(NSString *setter) {
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) { return nil;}
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    return  [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
}

#pragma mark - 从get方法获取set方法的名称
static NSString *setterForGetter(NSString *getter) {
    if (getter.length <= 0) { return nil; }
    NSString *firstString = [[getter substringToIndex:1] uppercaseString];
    NSString *leaveString = [getter substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:",firstString,leaveString];
}

@end
