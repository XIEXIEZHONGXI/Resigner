//
//  ViewController.m
//  IPA Resign
//
//  Created by Nelson on 2018/7/25.
//  Copyright © 2018年 Nelson. All rights reserved.
//

#import "ViewController.h"
#import "unZipCommand.h"
#import "FNHUD.h"
#import "certificateManager.h"
#import "mobileprovisionManager.h"
#import "AlertView.h"
#import "NEModel.h"
#import "InfoManager.h"
#import "resignFrameworkCommand.h"
#import "resignAppCommand.h"
#import "verifyAppCommand.h"
#import "zipCommand.h"
#import "NEConsole.h"
#import "otoolCommand.h"
typedef NS_ENUM(NSUInteger, MobileprovisionType){
    USEIPATYPE,
    USENEWTYPE
};
@interface ViewController(){
    NSDictionary * useMobileprovisionDictionary;
}
@property (weak) IBOutlet NSTextField *IPAPathTextField;
@property (weak) IBOutlet NSTextField *displayNameTextField;
@property (weak) IBOutlet NSTextField *BundleIdentifierTextField;
@property (weak) IBOutlet NSTextField *versionTextField;
@property (weak) IBOutlet NSTextField *buildTextField;
@property (weak) IBOutlet NSPopUpButton *certificatePopUpButton;
@property (weak) IBOutlet NSTextField *mobileprovisionPathTextField;
@property (weak) IBOutlet NSButton *mobileprovisionButton;

@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self.certificatePopUpButton removeAllItems];
    self.certificatePopUpButton.enabled = NO;
    [FNHUD showLoading:@"获取keyChain数据..." inView:self.view];
    [certificateManager getCertificateInfoCompleteHandler:^(NSArray *certificates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NEConsole appendString:@"获取证书成功" color:NSColor.orangeColor];
            [FNHUD hide];
            [self.certificatePopUpButton addItemsWithTitles:certificates];
        });
    }];
    
//    [self.textView setString:@"AAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\nAAAA\n"];
    
    
}

- (IBAction)resignAction:(id)sender {
    
    if (![NEModel sharedInstance].appPath) {
        [AlertView show:@"请先选择ipa文件"];
        return;
    }
    
    if ([self.BundleIdentifierTextField.stringValue containsString:@"*"]) {
        [AlertView show:@"请正确配置BundleIdentifier"];
        return;
    }
    if (!useMobileprovisionDictionary) {
        useMobileprovisionDictionary = [mobileprovisionManager decodeMobileprovision:[[NEModel sharedInstance].appPath stringByAppendingPathComponent:@"embedded.mobileprovision"]];
    }
    NSString * certName = useMobileprovisionDictionary[CERTNAME];
    NSDictionary * mobileprovisionDictionary = useMobileprovisionDictionary[INFO];
    NSString * mobileprovisionType = useMobileprovisionDictionary[MPTYPE];
    NSString * mobileprovisionBundleIdentifier = self.BundleIdentifierTextField.stringValue;
    
    [NEModel sharedInstance].certName = certName;
    [NEModel sharedInstance].nIPABundleIdentifier = mobileprovisionBundleIdentifier;
    
    if (![mobileprovisionBundleIdentifier containsString:@"*"] && ![mobileprovisionBundleIdentifier isEqualToString:self.BundleIdentifierTextField.stringValue]) {
        [AlertView show:@"BundleIdentifier与描述文件不匹配~"];
        return;
    }
    if (![self.certificatePopUpButton.itemTitles containsObject:certName]) {
        [AlertView show:[NSString stringWithFormat:@"请导入证书 : %@",certName]];
        return;
    }
    
    [NEConsole appendString:@"重签名参数:" color:NSColor.orangeColor];
    [NEConsole appendString:[NSString stringWithFormat:@"应用名称 : %@",self.displayNameTextField.stringValue] color:NSColor.magentaColor];
    [NEConsole appendString:[NSString stringWithFormat:@"BundleIdentifier : %@",self.BundleIdentifierTextField.stringValue] color:NSColor.magentaColor];
    [NEConsole appendString:[NSString stringWithFormat:@"Version : %@",self.versionTextField.stringValue] color:NSColor.magentaColor];
    [NEConsole appendString:[NSString stringWithFormat:@"Build : %@",self.buildTextField.stringValue] color:NSColor.magentaColor];
    [NEConsole appendString:[NSString stringWithFormat:@"证书名称 : %@",certName] color:NSColor.magentaColor];
    
    [FNHUD showLoading:@"Resign..." inView:self.view];
    
    [mobileprovisionManager replaceMobileprovision:mobileprovisionDictionary];
    
    /* 修改Info.plist文件 */
    [InfoManager setInfoPlistWithDisplayName:self.displayNameTextField.stringValue bundleIdentifier:self.BundleIdentifierTextField.stringValue version:self.versionTextField.stringValue build:self.buildTextField.stringValue];
    
    NSString * displayName = self.displayNameTextField.stringValue;
    
        /* 重签名framework、dylib文件 */
    [resignFrameworkCommand performCompleteHandler:^{
        /* 重签名app文件 */
        [resignAppCommand performCompleteHandler:^{
            /* 验证app文件 */
            [verifyAppCommand performCompleteHandler:^{
                /* 打包ipa文件 */
                [zipCommand performWithDisplayName:displayName mobileprovisionType:mobileprovisionType completeHandler:^{
                    [FNHUD hide];
                    [AlertView show:@"重签名完毕"];
                }];
            }];
        }];
    }];
}

- (IBAction)IPAPathBrowseAction:(id)sender {
    [self.view.window makeFirstResponder:nil];
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanCreateDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setAllowsOtherFileTypes:NO];
    [openDlg setAllowedFileTypes:@[@"ipa"]];
    if ([openDlg runModal] == NSModalResponseOK) {
        NSString * iPAResourcePath = [[openDlg URLs][0] path];
        self.IPAPathTextField.stringValue = iPAResourcePath;
        [FNHUD showLoading:@"解压中..." inView:self.view];
        [unZipCommand performiPAPath:iPAResourcePath completionHandler:^(NSString *appPath) {
            [NEModel sharedInstance].appPath = appPath;
            NSString * codeSignaturePath = [appPath stringByAppendingPathComponent:@"_CodeSignature"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:codeSignaturePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:codeSignaturePath error:nil];
            }
            NSString * infoPlist = [appPath stringByAppendingPathComponent:@"Info.plist"];
            NSDictionary * infoDictionary = [NSDictionary dictionaryWithContentsOfFile:infoPlist];
            NSString * displayName = infoDictionary[@"CFBundleDisplayName"];
            if (!displayName) {
                displayName = infoDictionary[@"CFBundleName"];
            }
            NSString * BundleIdentifier = infoDictionary[@"CFBundleIdentifier"];
            NSString * version = infoDictionary[@"CFBundleShortVersionString"];
            NSString * build = infoDictionary[@"CFBundleVersion"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.displayNameTextField.stringValue = displayName;
                self.BundleIdentifierTextField.stringValue = BundleIdentifier;
                self.versionTextField.stringValue = version;
                self.buildTextField.stringValue = build;
            });
            [NEModel sharedInstance].oldIPABundleIdentifier = BundleIdentifier;
            
            [otoolCommand checkCryptWithAppPath:appPath completeHandler:^(BOOL crypted) {
                [FNHUD hide];
                if (crypted) {
                    [AlertView show:[NSString stringWithFormat:@"%@ 被加密",iPAResourcePath]];
                }
            }];
        }];
    }
}

- (IBAction)mobileprovisionBrowseAction:(id)sender {
    [self.view.window makeFirstResponder:nil];
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanCreateDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setAllowsOtherFileTypes:NO];
    [openDlg setAllowedFileTypes:@[@"mobileprovision"]];
    if ([openDlg runModal] == NSModalResponseOK) {
        NSString * mobileprovisionPath = [[openDlg URLs][0] path];
        self.mobileprovisionPathTextField.stringValue = mobileprovisionPath;
        [NEModel sharedInstance].mobileprovisionPath = mobileprovisionPath;
        self->useMobileprovisionDictionary = [mobileprovisionManager decodeMobileprovision:mobileprovisionPath];
        [self useIPAMobileprovisionAction:nil];
    }
}

- (IBAction)useIPAMobileprovisionAction:(id)sender {
    NSButton * button = (NSButton *)sender;
    self.mobileprovisionPathTextField.enabled = !button.state;
    if (button.state) {
        if ([NEModel sharedInstance].oldIPABundleIdentifier) {
            self.BundleIdentifierTextField.stringValue = [NEModel sharedInstance].oldIPABundleIdentifier;
        }
    }else{
        if (useMobileprovisionDictionary) {
            self.BundleIdentifierTextField.stringValue = useMobileprovisionDictionary[BUNDLEINDENTIFIER];
            [self rollingPopUpButtonWithCertName:useMobileprovisionDictionary[CERTNAME]];
        }
    }
}

-(void)rollingPopUpButtonWithCertName:(NSString *)certName{
    if ([self.certificatePopUpButton.itemTitles containsObject:certName]) {
        [self.certificatePopUpButton selectItemWithTitle:certName];
    }else{
        [AlertView show:[NSString stringWithFormat:@"未导入 %@",certName]];
    }
}

- (IBAction)resetAction:(id)sender {
    [self.IPAPathTextField setStringValue:@""];
    [self.displayNameTextField setStringValue:@""];
    [self.BundleIdentifierTextField setStringValue:@""];
    [self.versionTextField setStringValue:@""];
    [self.buildTextField setStringValue:@""];
    [self.mobileprovisionPathTextField setStringValue:@""];
    useMobileprovisionDictionary = nil;
    [self.textView setString:@""];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
