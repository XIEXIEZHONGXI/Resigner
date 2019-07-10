//
//  zipCommand.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "zipCommand.h"
#import "NEModel.h"
#import "AsyncTask.h"
#import "NEConsole.h"
@implementation zipCommand
+(void)performWithDisplayName:(NSString *)displayName mobileprovisionType:(NSString *)mobileprovisionType completeHandler:(void (^)(void))handler{
    NSString * IPAPath = [[NEModel sharedInstance].appPath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.ipa",displayName,mobileprovisionType]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:IPAPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:IPAPath error:nil];
    }
    
    NSMutableArray * arguments = [NSMutableArray array];
    [arguments addObject:@"-qry"];
    [arguments addObject:IPAPath];
    [arguments addObject:@"Payload"];
    NSLog(@"zip Launch Params : %@",arguments);
    [NEConsole appendString:[NSString stringWithFormat:@"压缩IPA:%@",IPAPath] color:NSColor.orangeColor];
    [AsyncTask launchPath:@"/usr/bin/zip" currentDirectoryPath:IPAPath.stringByDeletingLastPathComponent arguments:arguments outputBlock:^(NSString *outString) {
        NSLog(@"outString : %@",outString);
        [NEConsole appendString:outString color:NSColor.orangeColor];
    } errBlock:^(NSString *errString) {
        NSLog(@"errString : %@",errString);
        [NEConsole appendString:errString color:NSColor.redColor];
    } onLaunch:^{
        NSLog(@"Launch");
    } onExit:^{
        NSLog(@"Exit");
        [NEConsole appendString:@"重签名完毕" color:NSColor.orangeColor];
        handler();
    }];
}
@end
