//
//  NEModel.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/30.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEModel : NSObject
+(NEModel *)sharedInstance;
@property(nonatomic , copy) NSString * appPath;
@property(nonatomic , copy) NSString * certName;
@property(nonatomic , copy) NSString * oldIPABundleIdentifier;
@property(nonatomic , copy) NSString * nIPABundleIdentifier;
@property(nonatomic , copy) NSString * mobileprovisionPath;
@end
