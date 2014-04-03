//
//  UIImageView+PlayGIF.m
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

/**********************************************************************/
#import <Foundation/Foundation.h>
@interface PlayGIFManager : NSObject
@property (nonatomic, strong) CADisplayLink     *displayLink;
@property (nonatomic, strong) NSMutableArray    *gifViewArray;
@property (nonatomic, strong) NSMutableArray    *gifSourceRefArray;
+ (PlayGIFManager *)shared;
- (void)stopGIFView:(UIImageView *)view;
@end
@implementation PlayGIFManager
+ (PlayGIFManager *)shared{
    static PlayGIFManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PlayGIFManager alloc] init];
    });
    return _sharedInstance;
}
- (id)init{
	self = [super init];
	if (self) {
		_gifViewArray = [NSMutableArray array];
        _gifSourceRefArray = [NSMutableArray array];
	}
	return self;
}
- (void)play{
    [_gifViewArray makeObjectsPerformSelector:@selector(play)];
}
- (void)stopDisplayLink{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)stopGIFView:(UIImageView *)view{
    [_gifSourceRefArray removeObjectAtIndex:[_gifViewArray indexOfObject:view]];
    [_gifViewArray removeObject:view];
    if (_gifViewArray.count<1 && !_displayLink) {
        [self stopDisplayLink];
    }
}
@end
/**********************************************************************/

#import "UIImageView+PlayGIF.h"
#import <objc/runtime.h>

static const char * kGifPathKey         = "kGifPathKey";
static const char * kGifDataKey         = "kGifDataKey";
static const char * kIndexKey           = "kIndexKey";
static const char * kFrameCountKey      = "kFrameCountKey";
static const char * kTimestampKey       = "kTimestampKey";

@implementation UIImageView (PlayGIF)
@dynamic gifPath;
@dynamic gifData;
@dynamic index;
@dynamic frameCount;
@dynamic timestamp;

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(removeFromSuperview);
        SEL swizzledSelector = @selector(yfgif_removeFromSuperview);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
-(void)yfgif_removeFromSuperview{
    [self yfgif_removeFromSuperview];
    [self stopGIF];
}

#pragma mark - ASSOCIATION

-(NSString *)gifPath{
    return objc_getAssociatedObject(self, kGifPathKey);
}
- (void)setGifPath:(NSString *)gifPath{
    objc_setAssociatedObject(self, kGifPathKey, gifPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSData *)gifData{
    return objc_getAssociatedObject(self, kGifDataKey);
}
- (void)setGifData:(NSData *)gifData{
    objc_setAssociatedObject(self, kGifDataKey, gifData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSNumber *)index{
    return objc_getAssociatedObject(self, kIndexKey);
}
- (void)setIndex:(NSNumber *)index{
    objc_setAssociatedObject(self, kIndexKey, index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSNumber *)frameCount{
    return objc_getAssociatedObject(self, kFrameCountKey);
}
- (void)setFrameCount:(NSNumber *)frameCount{
    objc_setAssociatedObject(self, kFrameCountKey, frameCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSNumber *)timestamp{
    return objc_getAssociatedObject(self, kTimestampKey);
}
- (void)setTimestamp:(NSNumber *)timestamp{
    objc_setAssociatedObject(self, kTimestampKey, timestamp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - ACTIONS

- (void)startGIF{
    if ([[PlayGIFManager shared].gifViewArray indexOfObject:self] == NSNotFound && (self.gifData || self.gifPath)) {
        CGImageSourceRef gifSourceRef;
        if (self.gifData) {
            gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
        }else{
            gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
        }
        if (!gifSourceRef) {
            return;
        }
        [[PlayGIFManager shared].gifSourceRefArray addObject:(__bridge id)(gifSourceRef)];
        [[PlayGIFManager shared].gifViewArray addObject:self];
        self.frameCount = [NSNumber numberWithInteger:CGImageSourceGetCount(gifSourceRef)];
    }
    if (![PlayGIFManager shared].displayLink) {
        [PlayGIFManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[PlayGIFManager shared] selector:@selector(play)];
        [[PlayGIFManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopGIF{
    [[PlayGIFManager shared] stopGIFView:self];
}

- (void)play{
    float nextFrameDuration = [self frameDurationAtIndex:MIN(self.index.integerValue+1, self.frameCount.integerValue-1)];
    if (self.timestamp.floatValue < nextFrameDuration) {
        self.timestamp = [NSNumber numberWithFloat:self.timestamp.floatValue+[PlayGIFManager shared].displayLink.duration];
        return;
    }
	self.index = [NSNumber numberWithInteger:self.index.integerValue+1];
    self.index = [NSNumber numberWithInteger:self.index.integerValue%self.frameCount.integerValue];
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([PlayGIFManager shared].gifSourceRefArray[[[PlayGIFManager shared].gifViewArray indexOfObject:self]]);
	CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, self.index.integerValue, NULL);
	self.layer.contents = (__bridge id)(imageRef);
    CGImageRelease(imageRef);
    self.timestamp = [NSNumber numberWithFloat:0];
}

- (BOOL)isGIFPlaying{
    if ([[PlayGIFManager shared].gifViewArray indexOfObject:self] == NSNotFound) {
        return NO;
    }else{
        return YES;
    }
}

- (float)frameDurationAtIndex:(size_t)index{
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([PlayGIFManager shared].gifSourceRefArray[[[PlayGIFManager shared].gifViewArray indexOfObject:self]]);
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    CFRelease(dictRef);
    if (unclampedDelayTime.floatValue) {
        return unclampedDelayTime.floatValue;
    }else if (delayTime.floatValue) {
        return delayTime.floatValue;
    }else{
        return 1/24.0;
    }
}

@end
