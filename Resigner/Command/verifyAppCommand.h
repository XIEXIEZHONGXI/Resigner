//
//  verifyAppCommand.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface verifyAppCommand : NSObject
+(void)performCompleteHandler:(void(^)(void))handler;
@end
