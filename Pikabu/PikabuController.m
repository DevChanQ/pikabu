#import "PikabuController.h"
#import <objc/runtime.h>
#import "UIKit/UIApplication+Private.h"
#import "SpringBoard/SBApplication.h"
#import "SpringBoard/SBApplicationInfo.h"
#import "UIKit/UIStatusBarStyleRequest.h"
#import <AudioToolbox/AudioServices.h>
#import "PikabuView.h"

@implementation PikabuController

@synthesize pikabu = _pikabu;

+(PikabuController *) sharedController {
   static PikabuController *sharedInstance = nil;
   if (sharedInstance == nil) {
     sharedInstance = [[PikabuController alloc] init];
   }

   return sharedInstance;
}

-(void) showPikabuWithVolume:(float) volume {
  [self showPikabuWithVolume: volume WithInitialDelay: 1.5];
}

-(void) showPikabuWithVolume:(float) volume WithInitialDelay:(NSTimeInterval) delay {
  [self checkStyle];

  if (!isShowing) {
    [self.pikabu.layer removeAllAnimations];

    // start timer
    // has to be with is showing equals yes
    [self startTimerWithDelay: delay];
    isShowing = YES;
    _isShown = YES;
    [self showPikabuWithAnimation];
  } else {
    [self resetTimerWithDelay: delay];
  }

  [self.pikabu setLevel:volume animated:YES];
}

- (void) showPikabu {
  if (!isShowing) {
    [self.pikabu.layer removeAllAnimations];

    // start timer
    // has to be with is showing equals yes
    [self startTimer];
    isShowing = YES;
    _isShown = YES;
    [self showPikabuWithAnimation];
  } else {
    [self resetTimer];
  }
}

- (void) showPikabuWithAnimation {
  [UIView animateWithDuration:0.3f animations:^{
      self.pikabu.alpha = 1.0f;
  } completion:nil];
}

-(void) startTimer {
  timer = [NSTimer scheduledTimerWithTimeInterval: (1.5) target:self selector:@selector(dismissPikabu) userInfo:nil repeats:NO];
}

-(void) startTimerWithDelay:(NSTimeInterval) delay {
  timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(dismissPikabu) userInfo:nil repeats:NO];
}

-(void) resetTimerWithDelay:(NSTimeInterval) delay {
  if (timer != nil) {
    [timer invalidate];
    timer = nil;
    [self startTimerWithDelay: delay];
  }
}

-(void) resetTimer {
  [self resetTimerWithDelay: 1.5];
}

-(void) hideStatusBar {
  PikabuPosition currentPosition = [self.pikabu currentPosition];
  if (currentPosition == PikabuPositionLeft) {
    [[UIApplication sharedApplication] hideLeft];
  } else if (currentPosition == PikabuPositionMiddle) {
    [[UIApplication sharedApplication] hideMiddle];
  } else if (currentPosition == PikabuPositionRight) {
    [[UIApplication sharedApplication] hideRight];
  }
}

-(void) dismissPikabu {
  isShowing = NO;

  [UIView animateWithDuration:0.3f animations:^{
      [self.pikabu setAlpha:0.0f];
  } completion:^(BOOL finished) {
    if (finished)
      _isShown = NO;
  }];
}

-(void) checkStyle:(UIStatusBarStyle) style {
  if ([self.pikabu showDarkTintOnly]) {
    [self.pikabu setStyle:PikabuStyleDark];
  } else {
    if (style == UIStatusBarStyleDefault) {
      [self.pikabu setStyle:PikabuStyleDark];
    } else if (style == UIStatusBarStyleLightContent) {
      [self.pikabu setStyle:PikabuStyleLight];
    } else if ((long)style == 2) {
      [self.pikabu setStyle:PikabuStyleDark];
    }
  }
}

-(void) checkStyle {
  /*SBApplication *application = [[UIApplication sharedApplication] _accessibilityFrontMostApplication];
  if (application) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", [[application mainScene] uiClientSettings]] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    long long style = [[[application mainScene] uiClientSettings] defaultStatusBarStyle];
    if (style == 2 || style == 1) { // if default Status Bar Style is UIStatusBarStyleOpaqueBlack (Eclipse)
      [self setPikabuStyle:PikabuStyleLight];
    }
  } else {*/

  SBStatusBarManager *manager = [objc_getClass("SBStatusBarManager") sharedInstance];

  UIStatusBarStyleRequest *request = [manager frontMostStatusBarStyleRequest];
  if (request) {
    [self checkStyle:request.legibilityStyle];
  }
}

-(id) init {
  self = [super init];

  if (self) {
    colors = [PikabuColors retain];
    isShowing = NO;
    _isShown = NO;
    isBreadcrumbShowing = NO;

    for (int i = 0;i < 35;i++) {
      _wasShowing[i] = NO;
    }

    timer = nil;
    provider = [objc_getClass("SBMainStatusBarStateProvider") sharedInstance];
    sbsa = [objc_getClass("SBStatusBarStateAggregator") sharedInstance];

    feedbackGenerator = [[objc_getClass("UINotificationFeedbackGenerator") alloc] init];
    [feedbackGenerator prepare];

    hasTaptic = (int)[[UIDevice currentDevice] valueForKey: @"_feedbackSupportLevel"] >= 2 ? YES : NO;

    Pikabu *pikabu = [[Pikabu alloc] init];
    pikabu.alpha = 0.0f;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
    singleTap.numberOfTapsRequired = 1;
    [pikabu addGestureRecognizer:singleTap];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    [pikabu addGestureRecognizer:doubleTap];

    [singleTap requireGestureRecognizerToFail:doubleTap];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.maximumNumberOfTouches = 1;
    pan.minimumNumberOfTouches = 1;
    [pikabu addGestureRecognizer:pan];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPress.minimumPressDuration = 0.5;
    [pikabu addGestureRecognizer:longPress];

    self.pikabu = pikabu;

    [self.view addSubview: self.pikabu];
  }

  return self;
}

- (void) longPressed:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan){
    [self.pikabu setBackgroundOnImediate: ![self.pikabu isBackgroundOn]];
  }
  [[objc_getClass("VolumeControl") sharedVolumeControl] _changeVolumeBy: 0.0];
}

- (void)singleTapped:(UITapGestureRecognizer *)recognizer {
  PikabuColor currentColor;
  PikabuColor nextColor;
  if ([self.pikabu isDark]) {
    currentColor = [self.pikabu darkColor];
    nextColor = currentColor + 1;
    if (nextColor >= colors.count) {
      nextColor = 0;
    }
    [self.pikabu setDarkColorImediate: nextColor];
  } else {
    currentColor = [self.pikabu lightColor];
    nextColor = currentColor + 1;
    if (nextColor >= colors.count) {
      nextColor = 0;
    }
    [self.pikabu setLightColorImediate: nextColor];
  }
  [self writeToSettings];
  [[objc_getClass("VolumeControl") sharedVolumeControl] _changeVolumeBy: 0.0];
}

- (void) doubleTapped:(UITapGestureRecognizer *)recognizer {
  PikabuColor currentColor;
  PikabuColor nextColor;
  if ([self.pikabu isDark]) {
    currentColor = [self.pikabu lightColor];
    nextColor = currentColor + 1;
    if (nextColor >= colors.count) {
      nextColor = 0;
    }
    [self.pikabu setLightColorImediate: nextColor];
  } else {
    currentColor = [self.pikabu darkColor];
    nextColor = currentColor + 1;
    if (nextColor >= colors.count) {
      nextColor = 0;
    }
    [self.pikabu setDarkColorImediate: nextColor];
  }
  [self writeToSettings];
  [[objc_getClass("VolumeControl") sharedVolumeControl] _changeVolumeBy: 0.0];
}

-(void) handlePanGesture:(UIPanGestureRecognizer *)gesture {
  CGPoint translation = [gesture translationInView:self.pikabu];
  //CGPoint velocity = [gesture velocityInView:self.pikabu];
  if (self.pikabu.isDraggable) {
    if(gesture.state == UIGestureRecognizerStateBegan) {
      //frameBeforeDragging = self.pikabu.frame;
      //[self.pikabu panStarted];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
      /*multiplier = pikabuMultiplier / (translation.y / 100);
      multiplier = multiplier <= 0 ? 1.0 : multiplier;
      if(velocity.x > 0)
        [[objc_getClass("VolumeControl") sharedVolumeControl] _changeVolumeBy: 0.005 * multiplier];
      else
        [[objc_getClass("VolumeControl") sharedVolumeControl] _changeVolumeBy: -0.005 * multiplier];*/
      translation = CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
      [gesture.view setCenter:translation];
      [gesture setTranslation:CGPointZero inView:gesture.view];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
      //scrubing = NO;
      //[self.pikabu panEnded];
    }
  }
}

- (void) orientationChanged:(NSNotification *)notification {
  [self.pikabu updatePosition];
}

- (void) handleSwipeRight:(UISwipeGestureRecognizer *)recognizer {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Right" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (void) handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Left" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
  [alert release];
}

-(BOOL) isShown {
  return _isShown;
}

-(void) vibrate {
  [feedbackGenerator notificationOccurred:1];
}

-(void) shakeItBaby {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  [animation setDuration:0.07];
  [animation setRepeatCount:2];
  [animation setAutoreverses:YES];
  [animation setFromValue:[NSValue valueWithCGPoint:
                 CGPointMake([self.pikabu center].x - 3.0f, [self.pikabu center].y)]];
  [animation setToValue:[NSValue valueWithCGPoint:
                 CGPointMake([self.pikabu center].x + 3.0f, [self.pikabu center].y)]];
  [[self.pikabu layer] addAnimation:animation forKey:@"position"];

  if (hasTaptic)
    [feedbackGenerator notificationOccurred:2];
  else
    AudioServicesPlaySystemSound(1520);
}

- (void) writeToSettings {
  NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @"com.jeffrey.pikabu"];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:[NSString stringWithFormat:@"%ld", (long)[self.pikabu lightColor]] forKey:@"light"];
  [settings setObject:[NSString stringWithFormat:@"%ld", (long)[self.pikabu darkColor]] forKey:@"dark"];
	[settings writeToFile:path atomically:NO];
}

-(void) updatePikabu {
  [self.pikabu updateAll];
}

- (BOOL) shouldReceiveTouchAtWindowPoint:(CGPoint) point {
  BOOL shouldReceiveTouch = NO;

  CGPoint pointInLocalCoordinates = [self.view convertPoint:point fromView:nil];
  // Always if it's on the toolbar
  if (CGRectContainsPoint(self.pikabu.frame, pointInLocalCoordinates)) {
    shouldReceiveTouch = YES;
  }
  return shouldReceiveTouch;
}

@end
