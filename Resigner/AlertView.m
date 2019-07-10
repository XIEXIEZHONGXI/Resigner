//
//  AlertView.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/27.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "AlertView.h"
#import "NEConsole.h"
@implementation AlertView
+(void)show:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert * alert = [[NSAlert alloc]init];
        [alert setMessageText:@"提示"];
        [alert setInformativeText:message];
        [alert setAlertStyle:NSAlertStyleCritical];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].windows[0] completionHandler:^(NSModalResponse returnCode) {
            
        }];
    });
    [NEConsole appendString:message color:NSColor.redColor];
}

+(void)show:(NSString *)message buttonTitle:(NSString *)buttomTitle handler:(void(^)(void))handler{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert * alert = [[NSAlert alloc]init];
        [alert setMessageText:@"提示"];
        [alert setInformativeText:message];
        [alert setAlertStyle:NSAlertStyleCritical];
        [alert addButtonWithTitle:buttomTitle];
        [alert addButtonWithTitle:@"取消"];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].windows[0] completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == 1000) {
                handler();
            }
        }];
    });
}
@end
