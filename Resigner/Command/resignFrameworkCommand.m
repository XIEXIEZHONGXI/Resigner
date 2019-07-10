//
//  resignFrameworkCommand.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "resignFrameworkCommand.h"
#import "NEModel.h"
#import "AsyncTask.h"
#import "NEConsole.h"
@implementation resignFrameworkCommand
+(void)performCompleteHandler:(void(^)(void))handler{
    NSArray * files = [[NSFileManager defaultManager] subpathsAtPath:[NEModel sharedInstance].appPath];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        for (NSString * file in files) {
            if ([file hasSuffix:@".framework"] || [file hasSuffix:@".dylib"] || [file hasSuffix:@".appex"]) {
                NSString * frameworkPath = [[NEModel sharedInstance].appPath stringByAppendingPathComponent:file];
                if ([frameworkPath hasSuffix:@".appex"]) {
                    NSString * appexInfoPlistPath = [frameworkPath stringByAppendingPathComponent:@"Info.plist"];
                    NSMutableDictionary * appexInfoDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:appexInfoPlistPath];
                    NSString * newAppexBundleIdentifier = [appexInfoDictionary[@"CFBundleIdentifier"] stringByReplacingOccurrencesOfString:[NEModel sharedInstance].oldIPABundleIdentifier withString:[NEModel sharedInstance].nIPABundleIdentifier];
                    [appexInfoDictionary setValue:newAppexBundleIdentifier forKey:@"CFBundleIdentifier"];
                    BOOL write = [appexInfoDictionary writeToFile:appexInfoPlistPath atomically:YES];
                    NSLog(@"appex Info.plist文件修改 : %d",write);
                }
                NSString * signPath = [file hasSuffix:@".dylib"]?frameworkPath:[frameworkPath stringByAppendingPathComponent:@"Info.plist"];
                NSMutableArray * arguments = [NSMutableArray array];
                [arguments addObject:@"--deep"];
                [arguments addObject:@"--force"];
                [arguments addObject:@"--verify"];
                [arguments addObject:@"--verbose"];
                [arguments addObject:@"--sign"];
                [arguments addObject:[NEModel sharedInstance].certName];
                [arguments addObject:signPath];
                [arguments addObject:frameworkPath];
//                NSLog(@"codesign framework Launch Params:%@",arguments);
                [NEConsole appendString:[NSString stringWithFormat:@"重签名framework:%@",frameworkPath] color:NSColor.orangeColor];

                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [AsyncTask launchPath:@"/usr/bin/codesign" currentDirectoryPath:nil arguments:arguments outputBlock:^(NSString *outString) {
                    [NEConsole appendString:[NSString stringWithFormat:@"%@",outString] color:NSColor.purpleColor];
                } errBlock:^(NSString *errString) {
                    [NEConsole appendString:[NSString stringWithFormat:@"%@",errString] color:NSColor.purpleColor];
                } onLaunch:^{
                } onExit:^{
                    [NEConsole appendString:@"codesign framework success" color:NSColor.orangeColor];
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        handler();
    });
    
//    }
    
}
@end
