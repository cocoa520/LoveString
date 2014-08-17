//
//  AppDelegate.m
//  LoveString
//
//  Created by 坪 李 on 14-8-15.
//  Copyright (c) 2014年 Mac4app. All rights reserved.
//

#import "AppDelegate.h"
#import "HexFormatter.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreFoundation/CFString.h>
#import <CoreFoundation/CFStringEncodingExt.h>

static int numberOfShakes = 4;
static float durationOfShake = 0.05f;
static float vigourOfShake = 0.02f;

@implementation AppDelegate

@synthesize window = _window;
@synthesize textField = _textField;
@synthesize ansiField = _ansiField;
@synthesize unicodeField = _unicodeField;
@synthesize uniBigEndField = _uniBigEndField;
@synthesize utf8Field = _utf8Field;
@synthesize utf7Field = _utf7Field;

- (void)dealloc
{
    [_textFields release],_textFields = nil;
    [super dealloc];
}

#pragma mark
#pragma mark Commom
-(void)shakeWindow:(NSWindow *)window {
    NSRect frame = [window frame];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"frame"];
    NSRect rect1 = NSMakeRect(NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame), frame.size.width, frame.size.height);
    NSRect rect2 = NSMakeRect(NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame), frame.size.width, frame.size.height);
    NSArray *arr = [NSArray arrayWithObjects:[NSValue valueWithRect:rect1], [NSValue valueWithRect:rect2], nil];
    [animation setValues:arr];
    [animation setDuration:durationOfShake];
    [animation setRepeatCount:numberOfShakes];
    [window setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frame"]];
    [[window animator] setFrame:frame display:NO];
}

- (NSString*)hexStringForData:(NSData*)data
{
    if (data == nil) {
        return nil;
    }
    
    NSMutableString* hexString = [NSMutableString string];
    
    const unsigned char *p = [data bytes];
    
    for (int i=0; i < [data length]; i++) {
        [hexString appendFormat:@"%02x", *p++];
    }
    return hexString;
}

- (NSData*)dataForHexString:(NSString*)hexString
{
    if (hexString == nil) {
        return nil;
    }
    
    const char* ch = [[hexString lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data = [NSMutableData data];
    while (*ch) {
        char byte = 0;
        if ('0' <= *ch && *ch <= '9') {
            byte = *ch - '0';
        } else if ('a' <= *ch && *ch <= 'f') {
            byte = *ch - 'a' + 10;
        }
        ch++;
        byte = byte << 4;
        if (*ch) {
            if ('0' <= *ch && *ch <= '9') {
                byte += *ch - '0';
            } else if ('a' <= *ch && *ch <= 'f') {
                byte += *ch - 'a' + 10;
            }
            ch++;
        }
        [data appendBytes:&byte length:1];
    }
    return data;
}

#pragma mark
#pragma mark NSApplicationDelegate
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _textFields = [[NSArray arrayWithObjects:_textField,_ansiField,_unicodeField,_uniBigEndField,_utf8Field,_utf7Field, nil] retain];
    for (id temp in _textFields) {
        if (temp == _textField) {
            continue;
        }
        HexFormatter* formatter = (HexFormatter*)[[temp cell] formatter];
        formatter.delegate = self;
    }
}

#pragma mark
#pragma mark NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
    if (!obj) {
        return;
    }
    [self updateField:[obj object]];
}

- (void)updateField:(id)sender{
    NSString* input = [sender stringValue];
    if (sender !=_textField) {
         input = [self hexDataConvert:input tag:[sender tag]];
    }
    for (NSTextField* temp in _textFields) {
        if (temp == sender) {
            continue;
        }
        
        if (sender == _textField) {
            NSString* hexStr = [self hexStringConvert:input tag:[temp tag]];
            [temp setStringValue:hexStr];
        }else {
            if (temp == _textField) {
                [_textField setStringValue:input];
            }else {
                NSString* hexStr = [self hexStringConvert:input tag:[temp tag]];
                [temp setStringValue:hexStr];
            }
        }
    }
}

#pragma mark
#pragma mark TextInputErrorProtocol
- (void)textInputIsNonValid:(id)sender {
    [self shakeWindow:[self window]];
}

#pragma mark
#pragma mark CodeConvert
- (NSString*)hexStringConvert:(NSString*)input tag:(CodeTag)tag 
            
{
    if ([input length] == 0) {
        return @"";
    }
    
    NSData *hexData = nil;
    switch (tag) {
        case kCodeTagANSI:
            hexData = [input dataUsingEncoding:NSMacOSRomanStringEncoding allowLossyConversion:YES];
            break;
        case kCodeTagUnicode:
            hexData = [input dataUsingEncoding:NSUnicodeStringEncoding allowLossyConversion:YES];
            break;
        case kCodeTagUniBigEnd:
            hexData = [input dataUsingEncoding:NSUTF16BigEndianStringEncoding allowLossyConversion:YES];
            break;
        case kCodeTagUTF8:
            hexData = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            break;
        case kCodeTagUTF7:
            {
                NSStringEncoding utf7 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF7);
                hexData = [input dataUsingEncoding:utf7 allowLossyConversion:YES];
            }
            break;
        default:
            return @"";
    }
    
    return [self hexStringForData:hexData];
}

- (NSString*)hexDataConvert:(NSString*)hexStr tag:(CodeTag)tag {
    if ([hexStr length] == 0) {
        return @"";
    }
    
    NSData* strData = [self dataForHexString:hexStr];
    
    NSString *text = nil;
    switch (tag) {
        case kCodeTagANSI:
            text = [[NSString alloc] initWithData:strData encoding:NSMacOSRomanStringEncoding];
            break;
        case kCodeTagUnicode:
            text = [[NSString alloc] initWithData:strData encoding:NSUnicodeStringEncoding];
            break;
        case kCodeTagUniBigEnd:
            text = [[NSString alloc] initWithData:strData encoding:NSUTF16BigEndianStringEncoding];
            break;
        case kCodeTagUTF8:
            text = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
            break;
        case kCodeTagUTF7:
        {
            NSStringEncoding utf7 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF7);
            text = [[NSString alloc] initWithData:strData encoding:utf7];
        }
            break;
        default:
            return @"";
    }
    
    if (!text) {
        text = @"";
    }
    return [text autorelease];
}
@end
