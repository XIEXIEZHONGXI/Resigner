//
//  InfoManager.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "InfoManager.h"
#import "NEModel.h"
#import "AlertView.h"
#import "NEConsole.h"
@implementation InfoManager
+(void)setInfoPlistWithDisplayName:(NSString *)displayName bundleIdentifier:(NSString *)bundleIdentifier version:(NSString *)version build:(NSString *)build{
    NSString * InfoPlistPath = [[NEModel sharedInstance].appPath stringByAppendingPathComponent:@"Info.plist"];
    NSMutableDictionary * infoDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:InfoPlistPath];
    [infoDictionary setValue:displayName forKey:@"CFBundleDisplayName"];
    [infoDictionary setValue:bundleIdentifier forKey:@"CFBundleIdentifier"];
    [infoDictionary setValue:version forKey:@"CFBundleShortVersionString"];
    [infoDictionary setValue:build forKey:@"CFBundleVersion"];
    BOOL isWriteInfoPlist = [infoDictionary writeToFile:InfoPlistPath atomically:YES];
    if (!isWriteInfoPlist) {
        [AlertView show:@"Info.plist文件写入失败"];
    }
    [NEConsole appendString:[NSString stringWithFormat:@"替换Info.plist文件:%@",InfoPlistPath] color:NSColor.orangeColor];
}
@end
