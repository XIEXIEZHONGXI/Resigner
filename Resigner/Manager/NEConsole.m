//
//  NEConsole.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/31.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "NEConsole.h"

@implementation NEConsole
+(void)appendString:(NSString *)txString color:(NSColor *)color{
    if ([txString stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSView * view in [NSApplication sharedApplication].keyWindow.contentView.subviews) {
            if ([view isKindOfClass:[NSScrollView class]]) {
                NSScrollView * scrollView = (NSScrollView *)view;
                for (NSView * clipView in scrollView.subviews) {
                    if ([clipView isKindOfClass:[NSClipView class]]) {
                        for (NSView * textView in clipView.subviews) {
                            if ([textView isKindOfClass:[NSTextView class]]) {
                                NSTextView * tx = (NSTextView *)textView;
                                NSAttributedString * attributedString = [[NSAttributedString alloc]initWithString:[txString stringByAppendingString:@"\n\n"] attributes:@{NSForegroundColorAttributeName:color}];
                                [tx.textStorage appendAttributedString:attributedString];
//                                [tx.enclosingScrollView.documentView scrollPoint:NSMakePoint(0, NSMaxY(tx.enclosingScrollView.documentView.frame) - NSHeight(tx.enclosingScrollView.documentView.bounds))];
                            }
                        }
                    }
                }
            }
        }
    });
}
@end
