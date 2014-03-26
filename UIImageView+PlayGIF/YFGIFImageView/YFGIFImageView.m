//
//  YFGIFImageView.m
//  UIImageView+PlayGIF
//
//  Created by Yang Fei on 14-3-26.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

/**********************************************************************/
#import <Foundation/Foundation.h>
#import "YFGIFImageView.h"
@interface YFPlayGIFManager : NSObject
@property (nonatomic, strong) CADisplayLink     *displayLink;
@property (nonatomic, strong) NSMutableArray    *gifViewArray;
+ (YFPlayGIFManager *)shared;
- (void)stopGIFView:(YFGIFImageView *)view;
@end
@implementation YFPlayGIFManager
+ (YFPlayGIFManager *)shared{
    static YFPlayGIFManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[YFPlayGIFManager alloc] init];
    });
    return _sharedInstance;
}
- (id)init{
	self = [super init];
	if (self) {
		_gifViewArray = [[NSMutableArray alloc] init];
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
- (void)stopGIFView:(YFGIFImageView *)view{
    [_gifViewArray removeObject:view];
    if (_gifViewArray.count<1 && !_displayLink) {
        [self stopDisplayLink];
    }
}
@end
/**********************************************************************/

#import "YFGIFImageView.h"

@interface YFGIFImageView(){
    size_t              _index;
    size_t              _frameCount;
    CGImageSourceRef    _gifSourceRef;
    float               _timestamp;
}
@end

@implementation YFGIFImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startGIF{
    if ([[YFPlayGIFManager shared].gifViewArray indexOfObject:self] == NSNotFound) {
        if ((self.gifData || self.gifPath)) {
            CGImageSourceRef gifSourceRef;
            if (self.gifData) {
                gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
            }else{
                gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
            }
            if (!gifSourceRef) {
                return;
            }
            [[YFPlayGIFManager shared].gifViewArray addObject:self];
            _gifSourceRef = gifSourceRef;
            _frameCount = CGImageSourceGetCount(gifSourceRef);
        }
    }
    if (![YFPlayGIFManager shared].displayLink) {
        [YFPlayGIFManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[YFPlayGIFManager shared] selector:@selector(play)];
        [[YFPlayGIFManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopGIF{
    if (_gifSourceRef) {
        CFRelease(_gifSourceRef);
        _gifSourceRef = nil;
    }
    [[YFPlayGIFManager shared] stopGIFView:self];
}

- (void)play{
    float nextFrameDuration = [self frameDurationAtIndex:MIN(_index+1, _frameCount-1)];
    if (_timestamp < nextFrameDuration) {
        _timestamp += [YFPlayGIFManager shared].displayLink.duration;
        return;
    }
	_index ++;
	_index = _index%_frameCount;
	CGImageRef ref = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
	self.layer.contents = (__bridge id)(ref);
    CGImageRelease(ref);
    _timestamp = 0;
}

- (BOOL)isGIFPlaying{
    return _gifSourceRef?YES:NO;
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
