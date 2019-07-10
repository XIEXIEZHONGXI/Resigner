//
//  mobileprovisionManager.h
//  IPA Resign
//
//  Created by Nelson on 2018/7/27.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString * MPTYPE = @"Type";
static NSString * BUNDLEINDENTIFIER = @"BundleIndentifier";
static NSString * CERTNAME = @"CertName";
static NSString * INFO = @"Info";
@interface mobileprovisionManager : NSObject
+(NSDictionary *)decodeMobileprovision:(NSString *)path;
+(void)replaceMobileprovision:(NSDictionary *)mobileprovision;
@end
