//
//  WXBubbleComponent.m
//  Pods
//
//  Created by weixing.jwx on 17/9/26.
//
//

#import "WXBubbleComponent.h"
#import "WXBubbleView.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import <WeexSDK/WXUtility.h>
#import "WXBubbleAnimation.h"

@implementation WXBubbleComponent
{
    NSArray     *_positions;
    NSArray     *_nails;
    NSUInteger  _rowNum;
}

WX_PlUGIN_EXPORT_COMPONENT(bubble,WXBubbleComponent)

WX_EXPORT_METHOD(@selector(registerSwipeCallback:finished:))
WX_EXPORT_METHOD(@selector(replaceBubble:position:))


/**
 *  @abstract Initializes a new component using the specified  properties.
 *
 *  @param ref          the identity string of component
 *  @param type         component type
 *  @param styles       component's styles
 *  @param attributes   component's attributes
 *  @param events       component's events
 *  @param weexInstance the weexInstance with which the component associated
 *
 *  @return A WXComponent instance.
 */
- (instancetype)initWithRef:(NSString *)ref
                       type:(NSString*)type
                     styles:(nullable NSDictionary *)styles
                 attributes:(nullable NSDictionary *)attributes
                     events:(nullable NSArray *)events
               weexInstance:(WXSDKInstance *)weexInstance{
    
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        
//        NSString *jsonString = attributes[@"positions"];
//        _positions = [WXUtility objectFromJSON:jsonString];
//        jsonString = attributes[@"nails"];
//        _nails = [WXUtility objectFromJSON:jsonString];
        
        _positions = attributes[@"positions"];
        _nails = attributes[@"nails"];
        
        _rowNum = [attributes[@"rows"] integerValue];
    }
    return self;
}

- (UIView *)loadView
{
    return [[WXBubbleView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    WXBubbleView *bubbleView = self.view;
    if( [bubbleView isKindOfClass:[WXBubbleView class]] ){
        [bubbleView configPosition:_positions withNail:_nails withRow:_rowNum];
    }
}

//scale Frame
- (CGRect)scaleFrame:(CGRect)originFrame byScale:(CGFloat)scale
{
    CGFloat posScale = (1 - scale) * 0.5;
    CGRect scaleFrame = CGRectMake(originFrame.origin.x + originFrame.size.width*posScale,
                                   originFrame.origin.y + originFrame.size.height*posScale,
                                   originFrame.size.width * scale,
                                   originFrame.size.height * scale);
    return scaleFrame;
}


- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    WXBubbleView *bubbleView = (WXBubbleView*)self.view;
    if ([bubbleView isKindOfClass:[WXBubbleView class]]) {
        UIView *view = subcomponent.view;
        
        subcomponent.isViewFrameSyncWithCalculated = NO;

        CGRect frame = [bubbleView subViewFrameAtIndex:index];
        if (!CGRectEqualToRect(frame, CGRectZero)){
            //设置为原始尺寸的0.6倍
//            CGFloat scale = 0.0;
            CGRect scaleFrame = [self scaleFrame:frame byScale:0.4];
            view.frame = scaleFrame;
        }
        
        [bubbleView addSubview:view];
        [bubbleView addChildView:view atIndex:index];
        
        NSArray *durationArray = @[@(0), @(0.08), @(0.16)];
        CGFloat duration = [durationArray[rand() % 3] floatValue];
        
        [UIView animateWithDuration:1 delay:duration usingSpringWithDamping:0.4 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
            view.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

- (void)dealloc
{
    _positions = nil;
    _nails = nil;
}

- (void)registerSwipeCallback:(WXCallback)startCallback finished:(WXCallback)finishCallback
{
    WXBubbleView *bubbleView = self.view;
    bubbleView.startCallback = startCallback;
    bubbleView.finishCallback = finishCallback;
}

- (void)replaceBubble:(NSUInteger)bubbleId position:(NSUInteger)position
{
    WXBubbleView *bubbleView = self.view;
    [bubbleView replaceBubble:bubbleId position:position];
}



@end
