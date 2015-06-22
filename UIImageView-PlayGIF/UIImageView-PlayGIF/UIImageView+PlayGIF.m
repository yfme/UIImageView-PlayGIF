//
//  UIImageView+PlayGIF.m
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import "UIImageView+PlayGIF.h"

/**********************************************************************/

@interface PlayGIFManager : NSObject
@property (nonatomic, strong) CADisplayLink     *displayLink;
@property (nonatomic, strong) NSHashTable       *gifViewHashTable;
@property (nonatomic, strong) NSMapTable        *gifSourceRefMapTable;
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
		_gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        _gifSourceRefMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
	}
	return self;
}
- (void)play{
    for (UIImageView *imageView in _gifViewHashTable) {
        [imageView performSelector:@selector(play)];
    }
}
- (void)stopDisplayLink{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)stopGIFView:(UIImageView *)view{
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:view]);
    if (ref) {
        [_gifSourceRefMapTable removeObjectForKey:view];
        CFRelease(ref);
    }
    [_gifViewHashTable removeObject:view];
    if (_gifViewHashTable.count<1 && !_displayLink) {
        [self stopDisplayLink];
    }
}
@end

/**********************************************************************/

static const char * kGifPathKey         = "kGifPathKey";
static const char * kGifDataKey         = "kGifDataKey";
static const char * kIndexKey           = "kIndexKey";
static const char * kFrameCountKey      = "kFrameCountKey";
static const char * kTimestampKey       = "kTimestampKey";
static const char * kPxSize             = "kPxSize";
static const char * kGifLength          = "kGifLength";
static const char * kIndexDurationKey   = "kIndexDurationKey";

@implementation UIImageView (PlayGIF)
@dynamic gifPath;
@dynamic gifData;
@dynamic index;
@dynamic frameCount;
@dynamic timestamp;
@dynamic indexDurations;

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
    [self stopGIF];
    [self yfgif_removeFromSuperview];
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
-(NSDictionary*)indexDurations{
    return objc_getAssociatedObject(self, kIndexDurationKey);
}
-(void)setIndexDurations:(NSDictionary*)durations{
    objc_setAssociatedObject(self, kIndexDurationKey, durations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - ACTIONS

- (void)startGIF
{
    self.timestamp = 0;
    [self startGIFWithRunLoopMode:NSDefaultRunLoopMode];
}

- (void)startGIFWithRunLoopMode:(NSString * const)runLoopMode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[PlayGIFManager shared].gifViewHashTable containsObject:self] && (self.gifData || self.gifPath)) {
            CGImageSourceRef gifSourceRef;
            if (self.gifData) {
                gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
            }else{
                gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
            }
            if (!gifSourceRef) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PlayGIFManager shared].gifViewHashTable addObject:self];
                [[PlayGIFManager shared].gifSourceRefMapTable setObject:(__bridge id)(gifSourceRef) forKey:self];
                self.frameCount = [NSNumber numberWithInteger:CGImageSourceGetCount(gifSourceRef)];
                CGSize pxSize = [self GIFDimensionalSize];
                objc_setAssociatedObject(self, kPxSize, [NSValue valueWithCGSize:pxSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                objc_setAssociatedObject(self, kGifLength, [self buildIndexAndReturnLength], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            });
        }
    });
    if (![PlayGIFManager shared].displayLink) {
        [PlayGIFManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[PlayGIFManager shared] selector:@selector(play)];
        [[PlayGIFManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:runLoopMode];
    }
}

-(NSNumber*)buildIndexAndReturnLength{
    
    NSMutableDictionary* d = [[NSMutableDictionary alloc] initWithCapacity:[self.frameCount integerValue]];
    float l = 0;
    for(int i = 0; i < [self.frameCount intValue]; i++){
        float durationAtIndex = [self frameDurationAtIndex:i];
        [d setObject:@(durationAtIndex) forKey:@(i)];
        l += durationAtIndex;
    }
    self.indexDurations = d;
    return @(l);
}

-(NSNumber*)gifLength{
    return objc_getAssociatedObject(self, kGifLength);
}

- (void)stopGIF{
    [[PlayGIFManager shared] stopGIFView:self];
}

- (void)play{
    self.timestamp = [NSNumber numberWithFloat:self.timestamp.floatValue+[PlayGIFManager shared].displayLink.duration];
    
    float loopT = fmodf([self.timestamp floatValue], [[self gifLength] floatValue]);
    self.index = @([self indexForDuration:loopT]);
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
	CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, self.index.integerValue, NULL);
    self.layer.contents = (__bridge id)(imageRef);
    CGImageRelease(imageRef);
}

- (int) indexForDuration:(float)duration{
    
    float sum = 0;
    
    for(int i = 0; i < self.frameCount.intValue; i++){
        NSNumber* singleFrameDuration = [self.indexDurations objectForKey:@(i)];
        sum += [singleFrameDuration floatValue];
        
        if(sum >= duration) {
            return i;
        }
    }
    
    return [self.frameCount intValue] - 1;
}

- (BOOL)isGIFPlaying{
    return [[PlayGIFManager shared].gifViewHashTable containsObject:self];
}

- (CGSize) gifPixelSize{
    return [objc_getAssociatedObject(self, kPxSize) CGSizeValue];
}

- (CGImageRef) gifCreateImageForFrameAtIndex:(NSInteger)index{
    if(![self isGIFPlaying]){
        return nil;
    }
    
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    return CGImageSourceCreateImageAtIndex(ref, index, NULL);
}

- (float)gifFrameDurationAtIndex:(size_t)index{
    return [self frameDurationAtIndex:index];
}

- (CGSize)GIFDimensionalSize{
    if(![[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]){
        return CGSizeZero;
    }
    
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, 0, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    
    NSNumber* pixelWidth = (dict[(NSString*)kCGImagePropertyPixelWidth]);
    NSNumber* pixelHeight = (dict[(NSString*)kCGImagePropertyPixelHeight]);
    
    CGSize sizeAsInProperties = CGSizeMake([pixelWidth floatValue], [pixelHeight floatValue]);
    
    CFRelease(dictRef);
    
    return sizeAsInProperties;
}

- (float)frameDurationAtIndex:(size_t)index{
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
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

-(NSArray*)frames{
    
    NSMutableArray* images = [NSMutableArray new];
    
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    
    if(!ref){
        return NULL;
    }
    
    NSInteger cnt = CGImageSourceGetCount(ref);
    for(NSInteger i = 0; i < cnt; i++){
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, i, NULL);
        [images addObject:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
    }
    
    return images;
}

@end
