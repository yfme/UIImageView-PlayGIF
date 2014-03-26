//
//  UIImageView+PlayGIF.m
//  UIImageView+PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import "UIImageView+PlayGIF.h"
#import <objc/runtime.h>

static const char * kGifPathKey         = "kGifPathKey";
static const char * kGifDataKey         = "kGifDataKey";
static const char * kDisplayLinkKey     = "kDisplayLinkKey";

static size_t               _index;
static size_t               _frameCount;
static CGImageSourceRef     _gifSourceRef;

@implementation UIImageView (PlayGIF)
@dynamic gifPath;
@dynamic gifData;
@dynamic displayLink;

#pragma mark - ASSOCIATION

-(NSString *)gifPath{
    return objc_getAssociatedObject(self, kGifPathKey);
}
- (void)setGifPath:(NSString *)gifPath{
    objc_setAssociatedObject(self, kGifPathKey, gifPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)gifData{
    return objc_getAssociatedObject(self, kGifDataKey);
}
- (void)setGifData:(NSString *)gifData{
    objc_setAssociatedObject(self, kGifDataKey, gifData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CADisplayLink *)displayLink{
    return objc_getAssociatedObject(self, kDisplayLinkKey);
}
- (void)setDisplayLink:(CADisplayLink *)displayLink{
    objc_setAssociatedObject(self, kDisplayLinkKey, displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - ACTIONS

- (void)startGIF{
    if (!self.displayLink && (self.gifData || self.gifPath)) {
        CGImageSourceRef gifSourceRef;
        if (self.gifData) {
            gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
        }else{
            gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
        }
        if (!gifSourceRef) {
            return;
        }
        _gifSourceRef = gifSourceRef;
        _frameCount = CGImageSourceGetCount(gifSourceRef);
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(play)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopGIF{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        CFRelease(_gifSourceRef);
    }
}

- (void)play{
	_index ++;
	_index = _index%_frameCount;
	CGImageRef ref = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
	self.layer.contents = (__bridge id)(ref);
    CGImageRelease(ref);
    self.displayLink.frameInterval = (NSInteger)([self frameDurationAtIndex:_index]/self.displayLink.duration+0.5);
}

- (BOOL)isGIFPlaying{
    return self.displayLink?YES:NO;
}

- (float)frameDurationAtIndex:(size_t)index{
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(_gifSourceRef, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    CFRelease(dictRef);
    if ([unclampedDelayTime floatValue]) {
        return [unclampedDelayTime floatValue];
    }else if ([delayTime floatValue]) {
        return [delayTime floatValue];
    }else{
        return 1/24.0;
    }
}

@end
