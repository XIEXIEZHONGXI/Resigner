//
//  resignAppCommand.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "resignAppCommand.h"
#import "NEModel.h"
#import "AsyncTask.h"
#import "NEConsole.h"
@implementation resignAppCommand
+(void)performCompleteHandler:(void(^)(void))handler{
    NSString * entitlementsPath = [[NEModel sharedInstance].appPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"entitlements.plist"];
    NSMutableArray * arguments = [NSMutableArray array];
    [arguments addObject:@"-fs"];
    [arguments addObject:[NEModel sharedInstance].certName];
    [arguments addObject:@"--no-strict"];
    [arguments addObject:@"--deep"];
    [arguments addObject:[NSString stringWithFormat:@"--entitlements=%@",entitlementsPath]];
//    [arguments addObject:@"--entitlements"];
//    [arguments addObject:entitlementsPath];
    [arguments addObject:[NEModel sharedInstance].appPath];
    NSLog(@"resign app Launch Params:%@",arguments);
    [NEConsole appendString:[NSString stringWithFormat:@"重签名app文件:%@",[NEModel sharedInstance].appPath] color:NSColor.orangeColor];

    [AsyncTask launchPath:@"/usr/bin/codesign" currentDirectoryPath:nil arguments:arguments outputBlock:^(NSString *outString) {
        [NEConsole appendString:[NSString stringWithFormat:@"outString:%@",outString] color:NSColor.purpleColor];
    } errBlock:^(NSString *errString) {
        [NEConsole appendString:[NSString stringWithFormat:@"errString:%@",errString] color:NSColor.redColor];
    } onLaunch:^{
        
    } onExit:^{
        [[NSFileManager defaultManager] removeItemAtPath:entitlementsPath error:nil];
        [NEConsole appendString:@"resign app success" color:NSColor.orangeColor];
        handler();
    }];
    
}
@end
