#import "Pikabu.h"

@implementation Pikabu

@synthesize mute=_mute;
@synthesize isMusicPlaying=_isMusicPlaying;
@synthesize headphonePresent=_headphonePresent;
@synthesize sliderRect;
@synthesize volumeView=_volumeView;
@synthesize isDraggable;

-(id) init{
  self = [super initWithFrame: pikabuRectLeft];
  if (self) {
    colors = [PikabuColors retain];
    feedbackGenerator = [[objc_getClass("UIImpactFeedbackGenerator") alloc] initWithStyle: 0];
    [feedbackGenerator prepare];

    _blurView = [[UIVisualEffectView alloc] init];
    _blurView.frame = self.bounds;
    _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blurView.alpha = 0.0;
    _blurView.layer.cornerRadius = pikabuCornerRadius;
    _blurView.layer.shadowColor = [UIColor blackColor].CGColor;
    _blurView.layer.shadowOpacity = 0.3;
    _blurView.layer.shadowRadius = 3.0;
    _blurView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);

    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
      self.backgroundColor = [UIColor clearColor];

      UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
      _blurView.effect = blurEffect;
    } else {
      _blurView.effect = nil;
    }

    self.layer.cornerRadius = pikabuCornerRadius;
    self.layer.masksToBounds = YES;

    self.sliderRect = pikabuSliderRect;

    _volumeView = [[PikabuView alloc] initWithFrame: pikabuVolumeRect];
    _volumeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _imageView = [[PikabuImageView alloc] initWithFrame: pikabuImageRect];

    [self addSubview: _blurView];
    [self addSubview: _imageView];
    [self addSubview: _volumeView];
  }
  return self;
}

-(void) setMute:(BOOL) mute {
  if (_mute != mute) {
    _mute = mute;
    [_imageView setMute: mute];
  }
}

-(void) setIsMusicPlaying:(BOOL) playing {
  if (_isMusicPlaying != playing) {
    _isMusicPlaying = playing;
    [_imageView setMusicPlaying: playing];
  }
}

-(void) setHeadphonePresent:(BOOL) present {
  if (_headphonePresent != present) {
    _headphonePresent = present;
    [_imageView setHeadphonePresent: present];
    if (_headphonePresent) {
      [self animateHeadphoneEntrance];
    } else {
      [_imageView.layer removeAllAnimations];
      [_volumeView.layer removeAllAnimations];
    }
  }
}

- (void) animateHeadphoneEntrance {
  CGAffineTransform scale = CGAffineTransformMakeScale(1.4, 1.4);
  CGAffineTransform translate = CGAffineTransformMakeTranslation(13.0,0.0);

  CGAffineTransform scaleDown = CGAffineTransformMakeScale(1.0, 1.0);
  CGAffineTransform translateBack = CGAffineTransformMakeTranslation(0.0,0.0);
  [UIView animateWithDuration:0.35f animations:^{
      _imageView.transform = CGAffineTransformConcat(translate, scale);
      _volumeView.alpha = 0.0;
  } completion:^(BOOL finished) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [UIView animateWithDuration:0.4f animations:^{
          _imageView.transform = CGAffineTransformConcat(translateBack, scaleDown);
          _volumeView.alpha = 1.0;
      } completion:nil];
    });
  }];
}

-(void) setStyle:(PikabuStyle) style {
  if (currentStyle != style) {
    currentStyle = style;
    [self updateColor];
  }
}

- (CGRect) currentPositionSliderRect {
  if (shouldBeBigger) {
    if (currentPosition == PikabuPositionMiddle)
      return pikabuSliderRectLargeMiddle;
    else
      return pikabuSliderRectLargeOther;
  } else
    return pikabuSliderRect;
}

- (void) updateAll {
  if (needsUpdate) {
    [self updateFrame];
    [self updateColor];
  }
  needsUpdate = NO;
}

- (void) updateColorDark {
  [_volumeView setDark];
  [_imageView setDark];
  [UIView animateWithDuration:0.2f animations:^{
      self.backgroundColor = [[colors objectAtIndex: _lightColor] colorWithAlphaComponent: 0.6];
  } completion:nil];
}

- (void) updateColorLight {
  [_volumeView setLight];
  [_imageView setLight];
  [UIView animateWithDuration:0.2f animations:^{
      self.backgroundColor = [[colors objectAtIndex: _darkColor] colorWithAlphaComponent: 0.6];
  } completion:nil];
}

- (void) updateColor {
  if (backgroundOn) {
    if (!showDarkTintOnly) {
      if (shouldInvertColor) {
        if ([self isDark])[self updateColorLight];
        else [self updateColorDark];
      } else {
        if ([self isDark]) [self updateColorDark];
        else [self updateColorLight];
      }
    } else {
      [self updateColorDark];
    }
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView.effect = blurEffect;
    [UIView animateWithDuration:0.2f animations:^{
        _blurView.alpha = 1.0;
    } completion:nil];
  } else {
    if (!showDarkTintOnly) {
      if ([self isDark]) {
        [_volumeView setDark];
        [_imageView setDark];
      } else {
        [_volumeView setLight];
        [_imageView setLight];
      }
    } else {
      [_volumeView setDark];
      [_imageView setDark];
    }
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.2f animations:^{
        _blurView.alpha = 0.0;
    } completion:nil];
  }
}

- (void) updateFrame {
  self.frame = [self pikabuFrameForPosition: currentPosition];
  PikabuSliderView *slider = [_volumeView slider];
  slider.frame = [self currentPositionSliderRect];
  self.sliderRect = [self currentPositionSliderRect];
  _volumeView.frame = shouldBeBigger ? pikabuVolumeRectLarge : pikabuVolumeRect;
  _imageView.frame = shouldBeBigger ? pikabuImageRectLarge : pikabuImageRect;
}

- (BOOL) isLighterColor {
  return lighterColor;
}

-(void) setLevel:(float) level animated:(BOOL) animated  {
  //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height)
  CGRect og = self.sliderRect;
  og.size.width = og.size.width * level;
  PikabuSliderView *slider = [_volumeView slider];
  if (animated) {
    [UIView animateWithDuration:0.15f animations:^{
        slider.frame = og;
    } completion:nil];
  } else {
    slider.frame = og;
  }
}

- (void) setLighterColor:(BOOL) enabled {
  if (lighterColor != enabled) {
    lighterColor = enabled;
    _volumeView.lighterColor = lighterColor;
    _imageView.lighterColor = lighterColor;
    needsUpdate = YES;
  }
}

- (void) setBackgroundOn:(BOOL) on {
  if (backgroundOn != on) {
    backgroundOn = on;
    needsUpdate = YES;
  }
}

- (void) setPosition:(PikabuPosition) position {
  if (currentPosition != position) {
    currentPosition = position;
    needsUpdate = YES;
  }
}

- (void) setLightColor:(int) color {
  if (_lightColor != color) {
    _lightColor = color;
    _volumeView.lightColor = [colors objectAtIndex: color];
    _imageView.lightColor = [colors objectAtIndex: color];
    needsUpdate = YES;
  }
}

- (void) setDarkColor:(int) color {
  if (_darkColor != color) {
    _darkColor = color;
    _volumeView.darkColor = [colors objectAtIndex: color];
    _imageView.darkColor = [colors objectAtIndex: color];
    needsUpdate = YES;
  }
}

- (void) setLightColorImediate:(int) color {
  if (_lightColor != color) {
    _lightColor = color;
    _volumeView.lightColor = [colors objectAtIndex: color];
    _imageView.lightColor = [colors objectAtIndex: color];
    [self updateColor];
  }
}

- (void) setDarkColorImediate:(int) color {
  if (_darkColor != color) {
    _darkColor = color;
    _volumeView.darkColor = [colors objectAtIndex: color];
    _imageView.darkColor = [colors objectAtIndex: color];
    [self updateColor];
  }
}

- (void) setBackgroundOnImediate:(BOOL) on {
  if (backgroundOn != on) {
    backgroundOn = on;
    [self updateColor];
  }
}

-(void) setShouldBeBigger:(BOOL) bigger {
  if (shouldBeBigger != bigger) {
    shouldBeBigger = bigger;
    needsUpdate = YES;
  }
}

- (void) setShouldInvertColor:(BOOL) should {
  if (shouldInvertColor != should) {
    shouldInvertColor = should;
    needsUpdate = YES;
  }
}

- (void) setShouldInvertColorImediate:(BOOL) should {
  if (shouldInvertColor != should) {
    shouldInvertColor = should;
    [self updateColor];
  }
}

- (void) setShowDarkTintOnly:(BOOL) only {
  if (showDarkTintOnly != only) {
    showDarkTintOnly = only;
    needsUpdate = YES;
  }
}

- (BOOL) isBackgroundOn {
  return backgroundOn;
}

- (BOOL) showDarkTintOnly {
  return showDarkTintOnly;
}

- (PikabuColor) lightColor {
  return _lightColor;
}

- (PikabuColor) darkColor {
  return _darkColor;
}

- (PikabuPosition) currentPosition {
  return currentPosition;
}

- (PikabuStyle) currentStyle {
  return currentStyle;
}

- (CGRect) pikabuFrameForPosition:(PikabuPosition) position {
  switch (position){
    case PikabuPositionLeft:
      if (shouldBeBigger)
        return pikabuRectLeftLarge;
      else
        return pikabuRectLeft;
      break;
    case PikabuPositionRight:
      if (shouldBeBigger)
        return pikabuRectRightLarge;
      else
        return pikabuRectRight;
      break;
    case PikabuPositionMiddle:
      if (shouldBeBigger)
        return pikabuRectMiddleLarge;
      else
        return pikabuRectMiddle;
      break;
    default:
      break;
  }
}

- (void) updatePosition {
  self.frame = [self pikabuFrameForPosition:currentPosition];
}

- (void) panStarted {
  self.sliderRect = pikabuSliderRectLargeMiddle;
  [UIView animateWithDuration:0.2f animations:^{
      self.frame = pikabuRectMiddleLarge;
  } completion:nil];
}

- (void) panEnded {
  self.sliderRect = [self currentPositionSliderRect];
  [UIView animateWithDuration:0.2f animations:^{
      self.frame = [self pikabuFrameForPosition: currentPosition];
  } completion:nil];
}

- (BOOL) isDark {
  return (currentStyle == PikabuStyleDark);
}

- (BOOL) isBigger {
  return shouldBeBigger;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  [self handleTouches:touches];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  [self handleTouches:touches];
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}
-(void)handleTouches:(NSSet<UITouch *> *)touches{
  int numOfTouches = [touches count];
  if (numOfTouches == 1) {
    UITouch *touch = [[touches allObjects] objectAtIndex: 0];
    CGFloat force = touch.force;
    CGFloat percentage = force/touch.maximumPossibleForce;
    if (percentage > 0.4) {
      [feedbackGenerator impactOccurred];
      self.isDraggable = YES;
    }
  }
}

@end
