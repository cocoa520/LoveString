//
//  MyValueFormatter.m
//  LoveString
//
//  Created by 坪 李 on 14-8-16.
//  Copyright (c) 2014年 Mac4app. All rights reserved.
//

#import "MyValueFormatter.h"

@implementation MyValueFormatter
@synthesize delegate = _delegate;
- (NSString *)stringForObjectValue:(id)anObject{
    if (anObject) {
        NSString* result = anObject;
        if ([anObject hasPrefix:@"fffe"] || [anObject hasPrefix:@"feff"]) {
            result = [anObject stringByReplacingOccurrencesOfString:@"fffe" withString:@""];
        }
        return result;
    }
    return @"";
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error{
    if (string != nil){
        *anObject = string;
        return YES;
    } else {
        NSString *errorString = @"unsupported object class";
        *error = errorString;
        return NO;
    };
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr 
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr 
              originalString:(NSString *)origString 
       originalSelectedRange:(NSRange)origSelRange 
            errorDescription:(NSString **)error {
    NSMutableCharacterSet *hexDigits; 
    NSRange newStuff; 
    NSString *newStuffString; 
    
    hexDigits = [NSCharacterSet decimalDigitCharacterSet]; 
    [hexDigits addCharactersInString:@"abcdefABCDEF"];
    
    newStuff = NSMakeRange(origSelRange.location,proposedSelRangePtr->location- origSelRange.location); 
    newStuffString = [*partialStringPtr substringWithRange: newStuff]; 
    
    if ([newStuffString rangeOfCharacterFromSet: hexDigits 
                                        options: NSLiteralSearch].location != NSNotFound || [newStuffString length] == 0) {
        *error = nil;
        return YES;
    } else {
        if ([self.delegate respondsToSelector:@selector(textInputIsNonValid:)]) {
            [self.delegate performSelector:@selector(textInputIsNonValid:) withObject:self];
        }
        *error = @"Not a Hex Character!";
        return NO;
    }
}
@end
