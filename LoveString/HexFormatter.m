//
//  HexFormatter.m
//  LoveString
//
//  Created by 坪 李 on 14-8-16.
//  Copyright (c) 2014年 Mac4app. All rights reserved.
//

#import "HexFormatter.h"

@implementation HexFormatter
@synthesize delegate = _delegate;

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
        *error = @"Not a Hex Character!";
        if ([self.delegate respondsToSelector:@selector(textInputIsNonValid:)]) {
            [self.delegate performSelector:@selector(textInputIsNonValid:) withObject:self];
        }
        return NO;
    }
}
@end
