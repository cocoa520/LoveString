//
//  AppDelegate.h
//  LoveString
//
//  Created by 坪 李 on 14-8-15.
//  Copyright (c) 2014年 Mac4app. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyProtocol.h"

enum {
    kCodeTagText = 0,
    kCodeTagANSI = 1,
    kCodeTagUnicode = 2,
    kCodeTagUniBigEnd = 3,
    kCodeTagUTF8 = 4,
    kCodeTagUTF7 = 5
};
typedef NSUInteger CodeTag;

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate,TextInputErrorProtocol> {
    NSTextField *_textField;
    NSTextField *_ansiField;
    NSTextField *_unicodeField;
    NSTextField *_uniBigEndField;
    NSTextField *_utf8Field;
    NSTextField *_utf7Field;
    NSArray* _textFields;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *textField;
@property (assign) IBOutlet NSTextField *ansiField;
@property (assign) IBOutlet NSTextField *unicodeField;
@property (assign) IBOutlet NSTextField *uniBigEndField;
@property (assign) IBOutlet NSTextField *utf8Field;
@property (assign) IBOutlet NSTextField *utf7Field;
@end
