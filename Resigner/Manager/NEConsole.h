//
//  NEConsole.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/31.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@interface NEConsole : NSObject
+(void)appendString:(NSString *)txString color:(NSColor *)color;
@end
