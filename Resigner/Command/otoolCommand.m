//
//  otoolCommand.m
//  IPA Resign
//
//  Created by Nelson on 2018/8/9.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "otoolCommand.h"
#import "AsyncTask.h"
@implementation otoolCommand
+(void)checkCryptWithAppPath:(NSString *)appPath completeHandler:(void (^)(BOOL crypted))handler{
    NSDictionary * infoDictionary = [NSDictionary dictionaryWithContentsOfFile:[appPath stringByAppendingPathComponent:@"Info.plist"]];
    NSString * executableFilePath = [appPath stringByAppendingPathComponent:infoDictionary[@"CFBundleExecutable"]];
    NSString * luanchString = [self luanchArguments:@[@"-l",executableFilePath] grepArguments:@[@"-B",@"2",@"crypt"]];
    NSLog(@"check crypt luanch string : %@",luanchString);
    handler([luanchString containsString:@"cryptid 1"]);
}
+(NSString *)luanchArguments:(NSArray *)lArguments grepArguments:(NSArray *)gArguments{
    NSTask *psTask = [[NSTask alloc] init];
    NSTask *grepTask = [[NSTask alloc] init];
    
    [psTask setLaunchPath: @"/usr/bin/otool"];
    [grepTask setLaunchPath: @"/usr/bin/grep"];
    
    [psTask setArguments:lArguments];
    [grepTask setArguments:gArguments];
    
    /* ps ==> grep */
    NSPipe *pipeBetween = [NSPipe pipe];
    [psTask setStandardOutput: pipeBetween];
    [grepTask setStandardInput: pipeBetween];
    
    /* grep ==> me */
    NSPipe *pipeToMe = [NSPipe pipe];
    [grepTask setStandardOutput: pipeToMe];
    
    NSFileHandle *grepOutput = [pipeToMe fileHandleForReading];
    
    [psTask launch];
    [grepTask launch];
    
    NSData *data = [grepOutput readDataToEndOfFile];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}
@end
