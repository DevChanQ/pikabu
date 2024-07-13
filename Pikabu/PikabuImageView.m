#import "PikabuImageView.h"
#import "UIColor+Pikabu.h"

@implementation PikabuImageView

-(id) initWithFrame:(CGRect) frame {
  self = [super initWithFrame: frame];
  if (self) {
    NSURL *url = [NSURL URLWithString:soundBlackStr];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    _blackSound = [[UIImage imageWithData:imageData] retain];

    /*NSURL *whiteUrl = [NSURL URLWithString:soundWhiteStr];
    NSData *whiteImageData = [NSData dataWithContentsOfURL:whiteUrl];
    _whiteSound = [[UIImage imageWithData:whiteImageData] retain];*/

    url = [NSURL URLWithString:muteBlackStr];
    imageData = [NSData dataWithContentsOfURL:url];
    _blackMute = [[UIImage imageWithData:imageData] retain];

    /*whiteUrl = [NSURL URLWithString:muteWhiteStr];
    whiteImageData = [NSData dataWithContentsOfURL:whiteUrl];
    _whiteMute = [[UIImage imageWithData:whiteImageData] retain];*/

    url = [NSURL URLWithString:musicBlackStr];
    imageData = [NSData dataWithContentsOfURL:url];
    _blackMusic = [[UIImage imageWithData:imageData] retain];

    /*whiteUrl = [NSURL URLWithString:musicWhiteStr];
    whiteImageData = [NSData dataWithContentsOfURL:whiteUrl];
    _whiteMusic = [[UIImage imageWithData:whiteImageData] retain];*/

    url = [NSURL URLWithString:headphoneBlackStr];
    imageData = [NSData dataWithContentsOfURL:url];
    _blackHeadphone = [[UIImage imageWithData:imageData] retain];

    /*whiteUrl = [NSURL URLWithString:headphoneWhiteStr];
    whiteImageData = [NSData dataWithContentsOfURL:whiteUrl];
    _whiteHeadphone = [[UIImage imageWithData:whiteImageData] retain];*/

    _imageView = [[UIImageView alloc] init];
    _imageView.frame = self.bounds;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:_imageView];
  }
  return self;
}

- (void) setMute:(BOOL) mute {
  _mute = mute;
  [self update];
}

- (void) setMusicPlaying:(BOOL) playing {
  _isMusicPlaying = playing;
  [self update];
}

- (void) setHeadphonePresent: (BOOL) present {
  _headphonePresent = present;
  [self update];
}

- (void) setLight {
  [super setLight];
  [self update];
}

- (void) setDark {
  [super setDark];
  [self update];
}

- (void) update {
  if (_headphonePresent) {
    _imageView.image = _blackHeadphone;
  } else if (_isMusicPlaying) {
    _imageView.image = _blackMusic;
  } else if (_mute) {
    _imageView.image = _blackMute;
  } else {
    _imageView.image = _blackSound;
  }
  UIImage *newImage = nil;

  if (self.isDark) {
    newImage = [self filledImageFrom:_imageView.image withColor:self.darkColor];
  } else {
    if (self.lighterColor)
      newImage = [self filledImageFrom:_imageView.image withColor:[self lighterColorForColor: self.lightColor]];
    else
      newImage = [self filledImageFrom:_imageView.image withColor:self.lightColor];
  }

  [UIView animateWithDuration:0.2f animations:^{
      _imageView.image = newImage;
  } completion:nil];
}

- (void) dealloc {
  [_blackSound release];
  [_whiteSound release];
  [_blackMute release];
  [_whiteMute release];
  [_blackMusic release];
  [_whiteMusic release];
  [super dealloc];
}

- (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color{
  // begin a new image context, to draw our colored image onto with the right scale
  UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);

  // get a reference to that context we created
  CGContextRef context = UIGraphicsGetCurrentContext();

  // set the fill color
  [color setFill];

  // translate/flip the graphics context (for transforming from CG* coords to UI* coords
  CGContextTranslateCTM(context, 0, source.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);

  CGContextSetBlendMode(context, kCGBlendModeColorBurn);
  CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
  CGContextDrawImage(context, rect, source.CGImage);

  CGContextSetBlendMode(context, kCGBlendModeSourceIn);
  CGContextAddRect(context, rect);
  CGContextDrawPath(context,kCGPathFill);

  // generate a new UIImage from the graphics context we drew onto
  UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  //return the color-burned image
  return coloredImg;
}

@end
