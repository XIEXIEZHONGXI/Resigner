//
//  verifyAppCommand.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "verifyAppCommand.h"
#import "NEModel.h"
#import "AsyncTask.h"
#import "NEConsole.h"
@implementation verifyAppCommand
+(void)performCompleteHandler:(void(^)(void))handler{
    NSMutableArray * arguments = [NSMutableArray array];
    [arguments addObject:@"-v"];
    [arguments addObject:[NEModel sharedInstance].appPath];
    NSLog(@"verify app Launch Params : %@",arguments);
    [NEConsole appendString:[NSString stringWithFormat:@"校验app文件有效性:%@",[NEModel sharedInstance].appPath] color:NSColor.orangeColor];

    [AsyncTask launchPath:@"/usr/bin/codesign" currentDirectoryPath:nil arguments:arguments outputBlock:^(NSString *outString) {
        [NEConsole appendString:[NSString stringWithFormat:@"outString:%@",outString] color:NSColor.purpleColor];
    } errBlock:^(NSString *errString) {
        [NEConsole appendString:[NSString stringWithFormat:@"errString:%@",errString] color:NSColor.redColor];
    } onLaunch:^{
        
    } onExit:^{
        [NEConsole appendString:@"verify app success" color:NSColor.orangeColor];
        handler();
    }];
}
@end
