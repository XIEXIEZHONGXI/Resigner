//
//  certificateManager.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/27.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "certificateManager.h"
#import "AsyncTask.h"
@implementation certificateManager
+(void)getCertificateInfoCompleteHandler:(void (^)(NSArray *))handler{
    //    security find-identity -v -p codesigning
    NSMutableArray * certificateArray = [NSMutableArray array];
    NSMutableArray * arguments = [NSMutableArray array];
    NSMutableString * securitySyring = [NSMutableString string];
    [arguments addObject:@"find-identity"];
    [arguments addObject:@"-v"];
    [arguments addObject:@"-p"];
    [arguments addObject:@"codesigning"];
    NSLog(@"Security命令行参数:%@",arguments);
    [AsyncTask launchPath:@"/usr/bin/security" currentDirectoryPath:nil arguments:arguments outputBlock:^(NSString *outString) {
        [securitySyring appendString:outString];
        if ([outString containsString:@"valid identities found"]) {
            NSArray * formatString = [securitySyring componentsSeparatedByString:@"\n"];
            for (int i = 0; i < formatString.count; i++) {
                if ([formatString[i] containsString:@"\"iPhone "]) {
                    NSString * cerName = [NSString stringWithFormat:@"iPhone %@)",[[formatString[i] componentsSeparatedByString:@"\"iPhone "][1] componentsSeparatedByString:@")\""][0]];
                    [certificateArray addObject:cerName];
                }
            }
//            NSLog(@"证书数组:%@",certificateArray);
            NSLog(@"本地证书个数:%ld",certificateArray.count);
            handler(certificateArray);
        }
    } errBlock:^(NSString *errString) {
        NSLog(@"Security errString:%@",errString);
    } onLaunch:^{
        NSLog(@"security Launch");
    } onExit:^{
        NSLog(@"security Exit");
    }];
}
@end
