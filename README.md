UIImageView-PlayGIF
===================
UIImageView category/subclass for playing GIF. Simple, high performance, low memory footprint.

<img src="https://raw.githubusercontent.com/yfme/UIImageView-PlayGIF/master/screenshot2.gif" width="200px" style="width: 200px;" />
<img src="https://raw.githubusercontent.com/yfme/UIImageView-PlayGIF/master/screenshot3.gif" width="200px" style="width: 200px;" />

Installation
===================
```
pod 'UIImageView-PlayGIF', '~> 1.0.1'
```

Usage
===================
```
#import <UIImageView-PlayGIF/UIImageView+PlayGIF.h>
```
or `#import <UIImageView-PlayGIF/YFGIFImageView.h>`

 *  Parameters:
  *      Pass value to one of them:
  *      `- gifData` NSData from a GIF
  *      `- gifPath` local path of a GIF
 *  Methods:
  *      `- startGIF`
  *      `- stopGIF`
  *      `- isGIFPlaying`

===================
```objc
//
//  UIImageView+PlayGIF.h
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@interface UIImageView (PlayGIF)
@property (nonatomic, strong) NSString          *gifPath;
@property (nonatomic, strong) NSData            *gifData;
@property (nonatomic, strong) NSNumber          *index,*frameCount,*timestamp;
- (void)startGIF;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
@end
```
```objc
//
//  YFGIFImageView.h
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-26.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@interface YFGIFImageView : UIImageView
@property (nonatomic, strong) NSString          *gifPath;
@property (nonatomic, strong) NSData            *gifData;
- (void)startGIF;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
@end
```

## License

UIImageView-PlayGIF is available under the MIT license. See the LICENSE file for more info.

