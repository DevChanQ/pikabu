#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "define.h"
#import "PikabuView.h"
#import "PikabuImageView.h"
#import <objc/runtime.h>

@interface Pikabu : UIView {
  PikabuView *_volumeView;
  PikabuImageView *_imageView;
  UIVisualEffectView *_blurView;
  UIView *shadowView;

  BOOL _mute;
  BOOL _isMusicPlaying;
  BOOL _headphonePresent;
  BOOL backgroundOn;
  BOOL shouldBeBigger;
  BOOL lighterColor;
  BOOL shouldInvertColor;
  BOOL showDarkTintOnly;

  PikabuPosition currentPosition;
  PikabuStyle currentStyle;
  PikabuColor _lightColor;
  PikabuColor _darkColor;

  UIImpactFeedbackGenerator *feedbackGenerator;

  NSArray *colors;

  BOOL needsUpdate;
}

@property(nonatomic) BOOL mute;
@property(nonatomic) BOOL isMusicPlaying;
@property(nonatomic) BOOL headphonePresent;
@property(nonatomic) BOOL isDraggable;
@property(nonatomic) CGRect sliderRect;
@property(nonatomic, retain) UIView *volumeView;

-(id) init;
-(void) setStyle:(PikabuStyle) style;
-(void) setLevel:(float) level animated:(BOOL) animated;
-(void) setMute:(BOOL) mute;
- (void) setDarkColor:(int) color;
- (void) setLightColor:(int) color;
- (void) setLighterColor: (BOOL) enabled;
- (void) setLightColorImediate: (int) color;
- (void) setDarkColorImediate: (int) color;

- (void) setBackgroundOn:(BOOL) on;
- (void) setBackgroundOnImediate: (BOOL) on;
- (void) setPosition:(PikabuPosition) position;
- (void) setShouldBeBigger: (BOOL) bigger;
- (void) setShouldInvertColor:(BOOL) should;
- (void) setShouldInvertColorImediate:(BOOL) should;
- (void) setShowDarkTintOnly:(BOOL) only;

- (BOOL) isBackgroundOn;
- (BOOL) isLighterColor;
- (BOOL) showDarkTintOnly;
- (BOOL) isBigger;

- (void) updateAll;
- (void) updateColor;

- (void) updatePosition;

- (PikabuColor) lightColor;
- (PikabuColor) darkColor;
- (PikabuPosition) currentPosition;
- (PikabuStyle) currentStyle;

- (void) panStarted;
- (void) panEnded;

- (BOOL) isDark;

@end
