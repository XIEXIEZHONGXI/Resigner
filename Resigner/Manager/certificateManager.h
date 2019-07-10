//
//  certificateManager.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/27.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface certificateManager : NSObject
+(void)getCertificateInfoCompleteHandler:(void (^)(NSArray * certificates))handler;
@end
