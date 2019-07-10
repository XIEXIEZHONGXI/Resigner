//
//  mobileprovisionManager.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/27.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "mobileprovisionManager.h"
#import "AlertView.h"
#import "NEModel.h"
#import "NEConsole.h"
static NSString * devCertSummaryKey = @"devCertSummaryKey";
static NSString * devCertInvalidityDateKey = @"devCertInvalidityDateKey";

@implementation mobileprovisionManager

+(void)replaceMobileprovision:(NSDictionary *)mobileprovision{
    NSDictionary * entitlementsDictionary = mobileprovision[@"Entitlements"];
    NSString * EntitlementsPath = [[NEModel sharedInstance].appPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"entitlements.plist"];
    /* 重签名需要用到的entitlements.plist文件 */
    BOOL isWriteEntitlements = [entitlementsDictionary writeToFile:EntitlementsPath atomically:YES];
    if (!isWriteEntitlements) {
        [AlertView show:[NSString stringWithFormat:@"%@文件写入错误",EntitlementsPath]];
    }
    [NEConsole appendString:[NSString stringWithFormat:@"创建entitlements.plist文件:%@",EntitlementsPath] color:NSColor.orangeColor];
    /* 替换.app中的embedded.mobileprovision文件 */
    NSString * embeddedMobileprovisionPath = [[NEModel sharedInstance].appPath stringByAppendingPathComponent:@"embedded.mobileprovision"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:embeddedMobileprovisionPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:embeddedMobileprovisionPath error:nil];
        [NEConsole appendString:@"删除原有的embedded.mobileprovision文件" color:NSColor.orangeColor];
    }
//    BOOL isWriteMobileprovision = [mobileprovision writeToFile:embeddedMobileprovisionPath atomically:YES];
//    if (!isWriteMobileprovision) {
//        [AlertView show:[NSString stringWithFormat:@"%@文件写入错误",embeddedMobileprovisionPath]];
//    }
//    security cms -D -i BadApp.app/embedded.mobileprovision
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtPath:[NEModel sharedInstance].mobileprovisionPath toPath:embeddedMobileprovisionPath error:&error];
    if (error) {
        [AlertView show:[NSString stringWithFormat:@"拷贝至\"%@\"失败:%@",embeddedMobileprovisionPath,error.localizedDescription]];
    }
    [NEConsole appendString:[NSString stringWithFormat:@"替换embedded.mobileprovision文件:%@",embeddedMobileprovisionPath] color:NSColor.orangeColor];
    
}

+(NSDictionary *)decodeMobileprovision:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    NSString *binaryString = [NSString stringWithContentsOfFile:path encoding:NSISOLatin1StringEncoding error:NULL];
    if (!binaryString) {
        [AlertView show:[NSString stringWithFormat:@"描述文件:%@解析错误",path]];
    }
    NSScanner *scanner = [NSScanner scannerWithString:binaryString];
    BOOL ok = [scanner scanUpToString:@"<plist" intoString:nil];
    if (!ok) { NSLog(@"unable to find beginning of plist");
        //            return UIApplicationReleaseUnknown;
    }
    NSString *plistString;
    ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
    if (!ok) { NSLog(@"unable to find end of plist");
        //            return UIApplicationReleaseUnknown;
    }
    
    plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
    NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
    NSError *error = nil;
    NSDictionary * mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
    if (error) {
        NSLog(@"error parsing extracted plist — %@",error);
        if (mobileProvision) {
            mobileProvision = nil;
        }
        [AlertView show:[NSString stringWithFormat:@"描述文件:%@解析错误",path]];
        return nil;
    }else{
        NSString * certName = [self getCertNameWithData:mobileProvision[@"DeveloperCertificates"][0]];
        NSDictionary * entitlementsDictionary = mobileProvision[@"Entitlements"];
        NSString * applicationidentifier = entitlementsDictionary[@"application-identifier"];
        NSString * bundleIdentifier = [applicationidentifier componentsSeparatedByString:[NSString stringWithFormat:@"%@.",[applicationidentifier componentsSeparatedByString:@"."][0]]][1];
        NSString * mobileprovisionType;
        if ([mobileProvision.allKeys containsObject:@"ProvisionedDevices"]) {
            BOOL getTaskAllow = [entitlementsDictionary[@"get-task-allow"] boolValue];
            mobileprovisionType = getTaskAllow?@"DEV":@"ADHOC";
        }else{
            mobileprovisionType = @"DIS";
        }
        NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:certName forKey:CERTNAME];
        [dictionary setValue:bundleIdentifier forKey:BUNDLEINDENTIFIER];
        [dictionary setValue:mobileprovisionType forKey:MPTYPE];
        [dictionary setValue:mobileProvision forKey:INFO];
        return dictionary.copy;
    }
}
+(NSString *)getCertNameWithData:(NSData *)data{
//    NSData * data = dictionary[@"DeveloperCertificates"][0];
    /* 得到mobileprovision文件DeveloperCertificates键值的数据,包括到期时间和证书名称 */
    NSDictionary * cerInfo = [self parseCertificate:data];
    if ([cerInfo.allKeys containsObject:devCertInvalidityDateKey]) {
        /* 判断证书是否过期 */
        if ([[NSDate date] compare:cerInfo[devCertInvalidityDateKey]] == NSOrderedDescending) {
            [AlertView show:[NSString stringWithFormat:@"%@ 已过期",cerInfo[devCertSummaryKey]]];
            return @"";
        }
    }
    if ([cerInfo.allKeys containsObject:devCertSummaryKey]) {
        return cerInfo[devCertSummaryKey];
    }else{
        [AlertView show:@"mobileprovision文件解析错误"];
    }
    return @"";
}
/* DeveloperCertificates键值获取证书名称和到期日 */
+(NSDictionary*)parseCertificate:(NSData*)data {
    
    NSMutableDictionary *detailsDict;
    SecCertificateRef certificateRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
    if (certificateRef) {
        CFStringRef summaryRef = SecCertificateCopySubjectSummary(certificateRef);
        NSString *summary = (NSString *)CFBridgingRelease(summaryRef);
        if (summary) {
            detailsDict = [NSMutableDictionary dictionaryWithObject:summary forKey:devCertSummaryKey];
            
            CFErrorRef error;
            CFDictionaryRef valuesDict = SecCertificateCopyValues(certificateRef, (__bridge CFArrayRef)@[(__bridge id)kSecOIDInvalidityDate], &error);
            if (valuesDict) {
                CFDictionaryRef invalidityDateDictionaryRef = CFDictionaryGetValue(valuesDict, kSecOIDInvalidityDate);
                if (invalidityDateDictionaryRef) {
                    CFTypeRef invalidityRef = CFDictionaryGetValue(invalidityDateDictionaryRef, kSecPropertyKeyValue);
                    CFRetain(invalidityRef);
                    
                    // NOTE: the invalidity date type of kSecPropertyTypeDate is documented as a CFStringRef in the "Certificate, Key, and Trust Services Reference".
                    // In reality, it's a __NSTaggedDate (presumably a tagged pointer representing an NSDate.) But to sure, we'll check:
                    id invalidity = CFBridgingRelease(invalidityRef);
                    if (invalidity) {
                        if ([invalidity isKindOfClass:[NSDate class]]) {
                            // use the date directly
                            [detailsDict setObject:invalidity forKey:devCertInvalidityDateKey];
                        }
                        else {
                            // parse the date from a string
                            NSString *string = [invalidity description];
                            NSDateFormatter *invalidityDateFormatter = [NSDateFormatter new];
                            [invalidityDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                            NSDate *invalidityDate = [invalidityDateFormatter dateFromString:string];
                            if (invalidityDate) {
                                [detailsDict setObject:invalidityDate forKey:devCertInvalidityDateKey];
                            }
                        }
                    }
                    else {
                        NSLog(@"No invalidity date in '%@' certificate, dictionary = %@", summary, invalidityDateDictionaryRef);
                        [detailsDict setObject:@"No invalidity date" forKey:devCertInvalidityDateKey];
                    }
                }
                else {
                    NSLog(@"No invalidity values in '%@' certificate, dictionary = %@", summary, valuesDict);
                    [detailsDict setObject:@"No invalidity values" forKey:devCertInvalidityDateKey];
                    
                }
                
                CFRelease(valuesDict);
            }
            else {
                NSLog(@"Could not get values in '%@' certificate, error = %@", summary, error);
            }
            
        }
        else {
            NSLog(@"Could not get summary from certificate");
        }
        
        CFRelease(certificateRef);
    }
    return detailsDict;
    
}
@end
