//
//  AppDelegate.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/25.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [[NSApplication sharedApplication].windows[0] makeKeyAndOrderFront:nil];
    return YES;
}



@end
