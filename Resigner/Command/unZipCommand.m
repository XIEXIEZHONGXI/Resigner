//
//  unZipCommand.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/26.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "unZipCommand.h"
#import "AsyncTask.h"
#import "NEConsole.h"
@implementation unZipCommand
+(void)performiPAPath:(NSString *)path completionHandler:(void (^)(NSString *))handler{
    NSString * targetPath = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, 1, YES)[0];
    NSString * payloadPath = [targetPath stringByAppendingPathComponent:@"Payload"];
    NSLog(@"--%@",payloadPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:payloadPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:payloadPath error:nil];
    }
    
    NSMutableArray * arguments = [NSMutableArray array];
    [arguments addObject:@"-o"];
    [arguments addObject:@"-q"];
    [arguments addObject:path];
    [arguments addObject:@"-d"];
    [arguments addObject:targetPath];
    NSLog(@"unzip Task Params:%@",arguments);
    [NEConsole appendString:[NSString stringWithFormat:@"开始解压:%@",path] color:NSColor.orangeColor];
    [AsyncTask launchPath:@"/usr/bin/unzip" currentDirectoryPath:nil arguments:arguments outputBlock:^(NSString *outString) {
        NSLog(@"unzip outString:%@",outString);
    } errBlock:^(NSString *errString) {
        NSLog(@"unzip errString:%@",errString);
    } onLaunch:^{
        NSLog(@"unzip Launch");
    } onExit:^{
        NSLog(@"unzip Exit");
        [NEConsole appendString:@"解压完毕" color:NSColor.orangeColor];
        NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:payloadPath error:nil];
        for (NSString * file in files) {
            if ([file hasSuffix:@".app"]) {
                handler([payloadPath stringByAppendingPathComponent:file]);
            }
        }
    }];
}
@end
