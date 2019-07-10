//
//  unZipCommand.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/26.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface unZipCommand : NSObject
+(void)performiPAPath:(NSString *)path completionHandler:(void(^)(NSString * appPath))handler;
@end
