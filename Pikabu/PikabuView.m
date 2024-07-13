#import "PikabuView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Pikabu.h"

@implementation PikabuView

-(id) initWithFrame:(CGRect) frame{
  self = [super initWithFrame:frame];
  if (self) {
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = true;

    _blurEffectView = [[UIVisualEffectView alloc] init];
    _blurEffectView.frame = self.bounds;
    _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_blurEffectView];

    _slider = [[PikabuSliderView alloc] init];
    [self addSubview:_slider];
    //self.backgroundColor = [UIColor colorWithRed:(150.0/255.0) green:(60.0/255.0) blue:(23.0/255.0) alpha:1];
  }
  return self;
}

- (void) setDark {
  [super setDark];
  [self update];
}

-(void) setLight {
  [super setLight];
  [self update];
}

- (void) update {
  UIColor *newSliderColor = nil;
  UIColor *newColor = nil;
  if (self.isDark) {
    newSliderColor = self.darkColor;
    newColor = [[self darkerColorForColor: self.darkColor] colorWithAlphaComponent:0.3];
  } else {
    if (self.lighterColor) {
      newSliderColor = [self lighterColorForColor: self.lightColor];
      newColor = [self.lightColor colorWithAlphaComponent: 0.3];
    } else {
      newSliderColor = self.lightColor;
      newColor = [[self darkerColorForColor: self.lightColor] colorWithAlphaComponent:0.3];
    }
  }
  if (!UIAccessibilityIsReduceTransparencyEnabled()) {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurEffectView.alpha = 1.0;
    _blurEffectView.effect = blurEffect;
  } else {
    _blurEffectView.effect = nil;
  }
  [UIView animateWithDuration:0.2f animations:^{
      _slider.backgroundColor = newSliderColor;
      self.backgroundColor = newColor;
  } completion:nil];
}

-(PikabuSliderView *) slider {
  return _slider;
}
@end
