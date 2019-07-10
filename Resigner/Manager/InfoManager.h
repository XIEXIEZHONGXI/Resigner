//
//  InfoManager.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoManager : NSObject
+(void)setInfoPlistWithDisplayName:(NSString *)displayName bundleIdentifier:(NSString *)bundleIdentifier version:(NSString *)version build:(NSString *)build;
@end
