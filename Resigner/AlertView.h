//
//  AlertView.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/27.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@interface AlertView : NSObject
+(void)show:(NSString *)message;
//+(void)show:(NSString *)message buttonTitle:(NSString *)buttomTitle handler:(void(^)(void))handler;
@end
