//
//  NEModel.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "NEModel.h"

@implementation NEModel
+(NEModel *)sharedInstance{
    static dispatch_once_t onceToken;
    static NEModel * model;
    dispatch_once(&onceToken, ^{
        model = [[NEModel alloc]init];
    });
    return model;
}
@end
