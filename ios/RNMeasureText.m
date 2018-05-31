#if __has_include(<React/RCTConvert.h>)
#import <React/RCTConvert.h>
#elif __has_include("RCTConvert.h")
#import "RCTConvert.h"
#else
#import "React/RCTConvert.h"   // Required when used as a Pod in a Swift project
#endif

#import "RNMeasureText.h"

@implementation RNMeasureText

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(measure:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    UIFont *font = nil;

    if ([options objectForKey:@"texts"] == nil) {
      reject(@"invalid_texts", @"missing required texts property", nil);
      return;
    }
    if ([options objectForKey:@"fontSize"] == nil) {
      reject(@"invalid_fontSize", @"missing required fontSize property", nil);
      return;
    }
    CGFloat fontSize = [RCTConvert CGFloat:options[@"fontSize"]];
    
    if([options objectForKey:@"fontFamily"] == nil){
      font = [UIFont systemFontOfSize: fontSize];
    } else {
      font = [UIFont fontWithName:options[@"fontFamily"] size:fontSize];
    }

    NSArray *texts = [RCTConvert NSArray:options[@"texts"]];

    NSMutableArray* results = [[NSMutableArray alloc] init];

    for (NSString* text in texts) {
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:text];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize: CGSizeMake(FLT_MAX, FLT_MAX)];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];

        [textStorage addAttribute:NSFontAttributeName value:font
                            range:NSMakeRange(0, [textStorage length])];
        [textContainer setLineFragmentPadding:0.0];
        (void) [layoutManager glyphRangeForTextContainer:textContainer];
        CGRect resultRect = [layoutManager usedRectForTextContainer:textContainer];

        [results addObject:@{
          @"width":[NSNumber numberWithFloat:resultRect.size.width],
          @"height":[NSNumber numberWithFloat:resultRect.size.height]
        }];
    }
    resolve(results);
}

@end
