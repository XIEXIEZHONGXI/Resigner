//
//  otoolCommand.h
//  IPA Resign
//
//  Created by Nelson on 2018/8/9.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface otoolCommand : NSObject
+(void)checkCryptWithAppPath:(NSString *)appPath completeHandler:(void (^)(BOOL crypted))handler;
@end
