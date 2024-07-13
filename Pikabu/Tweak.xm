#import <UIKit/UIKit.h>
#import <UIKit/UIStatusBarForegroundView.h>
#import <UIKit/UIStatusBar.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/objc-runtime.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <UIKit/UIStatusBarItemView.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

#import "PikabuView.h"
#import "PikabuController.h"
#import "SpringBoard/VolumeControl.h"
#import "SpringBoard/SBStatusBarStateAggregator.h"
#import "SpringBoard/SBAppStatusBarSettingsAssertion.h"
#import "SpringBoard/SBAppStatusBarSettings.h"
#import "SpringBoard/SBHUDView.h"
#import "SpringBoard/SBHUDWindow.h"
#import "SpringBoard/SBHUDController.h"
#import "SpringBoard/SBMainStatusBarStateProvider.h"
#import "SpringBoard/SBStatusBarManager.h"

#define ENABLED ([preferences objectForKey: PREFS_ENABLED_KEY] ? [[preferences objectForKey: PREFS_ENABLED_KEY] boolValue] : DEFAULT_ENABLED)
#define POSITION ([preferences objectForKey: PREFS_POSITION_KEY] ? [[preferences objectForKey: PREFS_POSITION_KEY] integerValue] : DEFAULT_POSITION)
#define VIBRATE ([preferences objectForKey: PREFS_VIBRATE_KEY] ? [[preferences objectForKey: PREFS_VIBRATE_KEY] boolValue] : DEFAULT_VIBRATE)
#define DARK_COLOR ([preferences objectForKey: PREFS_DARK_COLOR] ? [[preferences objectForKey: PREFS_DARK_COLOR] integerValue] : DEFAULT_DARK_COLOR)
#define LIGHT_COLOR ([preferences objectForKey: PREFS_LIGHT_COLOR] ? [[preferences objectForKey: PREFS_LIGHT_COLOR] integerValue] : DEFAULT_LIGHT_COLOR)
#define BACKGROUND ([preferences objectForKey: PREFS_BACKGROUND] ? [[preferences objectForKey: PREFS_BACKGROUND] boolValue] : DEFAULT_BACKGROUND)
#define DELAY ([preferences objectForKey: PREFS_DELAY] ? [[preferences objectForKey: PREFS_DELAY] floatValue] : DEFAULT_DELAY)
#define LIGHTER ([preferences objectForKey: PREFS_LIGHTER] ? [[preferences objectForKey: PREFS_LIGHTER] boolValue] : DEFAULT_LIGHTER)
#define BIGGER ([preferences objectForKey: PREFS_BIGGER] ? [[preferences objectForKey: PREFS_BIGGER] boolValue] : DEFAULT_BIGGER)
#define INVERT_COLOR ([preferences objectForKey: PREFS_INVERTCOLOR] ? [[preferences objectForKey: PREFS_INVERTCOLOR] boolValue] : DEFAULT_INVERTCOLOR)
#define DARKONLY ([preferences objectForKey: PREFS_DARKONLY] ? [[preferences objectForKey: PREFS_DARKONLY] boolValue] : DEFAULT_DARKONLY)

@class AVSystemController;

@interface SpringBoardServer : NSObject

@property(nonatomic, retain) PikabuController *controller;

@end

@implementation SpringBoardServer

@synthesize controller;

+ (void)loadWithController:(PikabuController *) controller {
	[SpringBoardServer sharedInstanceWithController: controller];
}

+ (id)sharedInstanceWithController:(PikabuController *) controller {
	static dispatch_once_t once = 0;
	__strong static SpringBoardServer *sharedInstance = nil;
	dispatch_once(&once, ^{
		sharedInstance = [[SpringBoardServer alloc] init];
		sharedInstance.controller = controller;
	});
	return sharedInstance;
}

- (id)init {
	if ((self = [super init])) {
		// ...
		// Center name must be unique, recommend using application identifier.
		CPDistributedMessagingCenter * messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.jeffrey.pikabu"];
		[messagingCenter runServerOnCurrentThread];

		// Register Messages
		[messagingCenter registerForMessageName:@"applicationIsFullscreen" target:self selector:@selector(handleMessage:)];
		[messagingCenter registerForMessageName:@"applicationIsNotFullscreen" target:self selector:@selector(handleMessage:)];
	}

	return self;
}

- (void)handleMessage:(NSString *)name {
	if ([name isEqualToString: @"applicationIsNotFullscreen"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"application is not fullscreen" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	  [alert show];
	  [alert release];
	} else if ([name isEqualToString: @"applicationIsFullscreen"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"application is fullscreen" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	  [alert show];
	  [alert release];
	}
}
@end

@interface PikabuObserver : NSObject {
	NSTimer *timer;
	BOOL isHidden;
	BOOL activated;
	AVSystemController *controller;
	BOOL isHeadphoneConnected;

	BOOL _isSpringBoard;

	BOOL _isFullscreen;

	UIWindow *coverWindow;

	float _delay;
}

- (id) init;
- (void) deactivate;
- (void) activate;
- (void) setDelay:(float) delay;

@end

@implementation PikabuObserver

- (id) init {
	self = [super init];
	if (self) {
		controller = [objc_getClass("AVSystemController") sharedAVSystemController];

		_isSpringBoard = NSClassFromString(@"SpringBoard") ? YES : NO;
		if (_isSpringBoard) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChangedSpringBoard:) name:@"AVSystemController_EffectiveVolumeDidChangeNotification" object:nil];
		} else {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_EffectiveVolumeDidChangeNotification" object:nil];
		}
		isHidden = NO;
		activated = YES;
		isHeadphoneConnected = [self isHeadsetPluggedIn];
	}
	return self;
}

- (BOOL)isHeadsetPluggedIn {
  AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
  for (AVAudioSessionPortDescription* desc in [route outputs]) {
    if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
      return YES;
  }
  return NO;
}

- (void)volumeChanged:(NSNotification *)notification {
	BOOL headphonePresent = [self isHeadsetPluggedIn];
	if (isHeadphoneConnected != headphonePresent) {
		isHeadphoneConnected = headphonePresent;
		if (!isHeadphoneConnected) {
			if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
				if (!isHidden) {
					[self startInitialTimer];
				} else {
					[self resetTimer];
				}
			}
		} else {
			if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
				if (!isHidden) {
					[self startInitialTimerWithDelay: 4.5];
				} else {
					[self resetTimerWithDelay: 4.5];
				}
			}
		}
	} else {
		if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
			if (!isHidden)
				[self startInitialTimer];
			else
				[self resetTimer];
		}
	}
}

- (void) setDelay:(float) delay {
	_delay = delay;
}

- (void)volumeChangedSpringBoard:(NSNotification *)notification {
	BOOL headphonePresent = [self isHeadsetPluggedIn];
	if (isHeadphoneConnected != headphonePresent) {
		isHeadphoneConnected = headphonePresent;
		if (!isHeadphoneConnected) {
			if (activated) {
				if (!isHidden) {
					[self startInitialTimer];
				} else {
					[self resetTimer];
				}
			}
		} else {
			if (activated) {
				if (!isHidden) {
					[self startInitialTimerWithDelay: 4.5];
				} else {
					[self resetTimerWithDelay: 4.5];
				}
			}
		}
		[[UIApplication sharedApplication] showPikabuWithHeadphonePresent: headphonePresent];
	} else {
		if (activated) {
			if (!isHidden)
				[self startInitialTimer];
			else
				[self resetTimer];
		}
	}
}

- (void) onTimerEnd {
	[[UIApplication sharedApplication] showStatusBar];
	isHidden = NO;
}

-(void) startInitialTimer {
	[self startInitialTimerWithDelay:_delay+0.5];
}

-(void) startInitialTimerWithDelay:(NSTimeInterval) delay {
	isHidden = YES;
	[[UIApplication sharedApplication] hideStatusBar];
	[self startTimerWithDelay: delay];
}

-(void) startTimerWithDelay:(NSTimeInterval) delay {
	timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(onTimerEnd) userInfo:nil repeats:NO];
}

-(void) resetTimerWithDelay:(NSTimeInterval) delay {
	if (timer != nil) {
    [timer invalidate];
    timer = nil;
		[self startTimerWithDelay: delay];
  }
}

-(void) resetTimer {
	[self resetTimerWithDelay: _delay+0.5];
}

- (void) deactivate {
	activated = NO;
}

- (void) activate {
	activated = YES;
}


@end

@protocol NSKeyValueChangeKey;

static PikabuController *controller = nil;
static PikabuObserver *_observer;

static BOOL shouldShake;

static NSInteger bufferedPosition;
static NSInteger bufferedDARK;
static NSInteger bufferedLIGHT;
static int bufferedBackgroundOn;
static BOOL shouldBeLighterColor;
static BOOL shouldBeBigger;
static int shouldInvertColor;
static BOOL showDarkTintOnly;
static float pikabuDelay;

static NSDictionary *preferences = nil;

static BOOL isStatusBarPartlyHidden = NO;

static PikabuPosition lastPosition;

static int count = 0;

//static NSMutableArray *foregroundViews;

/*static NSMutableString* DumpObjcMethods(Class clz) {
  unsigned int methodCount = 0;
  Method *methods = class_copyMethodList(clz, &methodCount);

  NSLog(@"Found %d methods on '%s'\n", methodCount, class_getName(clz));

	NSMutableString *string = [[NSMutableString alloc] init];
  for (unsigned int i = 0; i < methodCount; i++) {
      Method method = methods[i];

	    [string appendString:[NSString stringWithFormat: @"\t'%s' has method named '%s' of encoding '%s'\n", class_getName(clz),
	             sel_getName(method_getName(method)),
	             method_getTypeEncoding(method)]];
  }

  free(methods);

	return string;
}*/

/*static NSMutableString* DumpIVar(Class clz) {
	unsigned int varCount;

	Ivar *vars = class_copyIvarList(clz, &varCount);

	NSMutableString *string = [[NSMutableString alloc] init];

	for (int i = 0; i < varCount; i++) {
	    Ivar var = vars[i];

	    const char* name = ivar_getName(var);
	    const char* typeEncoding = ivar_getTypeEncoding(var);

			[string appendString:[NSString stringWithFormat: @"%s, %s\n", name,typeEncoding]];
	}

	free(vars);

	return string;
}*/

%group SpringBoard

%hook SpringBoard

-(void)frontDisplayDidChange:(id)newDisplay {
  %orig(newDisplay);

  if (newDisplay == nil) {
    //[_observer activate];
  } else if ([newDisplay isKindOfClass:%c(SBApplication)]) {
    //[_observer deactivate];
  }
}

// init
- (void)applicationDidFinishLaunching:(id)application {
	%orig;

	controller = [PikabuController sharedController];

	UIStatusBar *sb_modern = MSHookIvar<UIStatusBar *>(self, "_statusBar");
	if (![NSStringFromClass([sb_modern class]) isEqualToString:@"UIStatusBar_Modern"]) {
		[controller.pikabu setBackgroundOn: YES];
	}
	// 0 : left side of status bar
	// 1 : left side of status bar (now recording and stuff)
	// 2 : right side of status Bar
	// 3 : ??
	// 4 : ??
	// 5 : ??
}

%new
- (void) showPikabuWithHeadphonePresent:(BOOL) present {
	[controller.pikabu setHeadphonePresent: present];
	if (present) {
		[[%c(SBHUDController) sharedHUDController] presentPikabuWithSBHUDView: nil WithDelay: 4.0];
		if (VIBRATE)
			[controller vibrate];
	} else
		[[%c(SBHUDController) sharedHUDController] presentPikabuWithSBHUDView: nil];
}

%end

%hook VolumeControl

-(void) _changeVolumeBy:(float) arg1 {
	if (VIBRATE) {
		count++;
		if (count >= 5 && (([self volume] == 1.0 && arg1 > 0.0) || ([self volume] == 0.0 && arg1 < 0.0))) {
			shouldShake = YES;
			count = 0;
		} else
			shouldShake = NO;
	} else
		shouldShake = NO;

	%orig;
}

%end

%hook SBHUDWindow

-(BOOL) _ignoresHitTest {
	return NO;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event { // to make touches pass through
	PikabuController *viewController = (PikabuController *)(self.rootViewController);
	UIView *result = %orig;
	for (UIView *view in [viewController.view subviews])
		if (CGRectContainsPoint(view.frame, point))
			return result;
	return nil;
}

%end

%hook SBHUDController
- (void)presentHUDView:(SBHUDView *)arg1 autoDismissWithDelay:(double)arg2 {
	if (ENABLED) {
		[self presentPikabuWithSBHUDView: arg1];
	} else {
		%orig;
	}
}

- (void) _createUI {
	%orig;
	UIWindow *hudWindow = MSHookIvar<UIWindow *>(self, "_hudWindow");
	[hudWindow _setSecure:YES];
	hudWindow.backgroundColor = [UIColor clearColor];
	hudWindow.windowLevel = 1048; // above home and apps
	hudWindow.rootViewController = controller;
	hudWindow.opaque = NO;
	hudWindow.hidden = NO;
	hudWindow.userInteractionEnabled = YES;
	hudWindow.clipsToBounds = YES;
	//hudWindow.frame = CGRectMake(0,0, DEVICE_WIDTH, 65);
	//hudWindow.clipsToBounds = NO;
}

%new
- (void) _hideHUDWindow:(id) object {
	UIWindow *hudWindow = MSHookIvar<UIWindow *>(self, "_hudWindow");
	hudWindow.hidden = YES;
	count = 5;
}

%new
- (void) presentPikabuWithSBHUDView:(SBHUDView *) view {
	[self presentPikabuWithSBHUDView: view WithDelay:DELAY];
}

%new
- (void) presentPikabuWithSBHUDView:(SBHUDView *) view WithDelay:(NSTimeInterval) delay {
	//[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideHUDWindow:) object:nil];
	// set everything up if pikabu is not shown
	if (![controller isShown]) {
		[controller.pikabu setShouldBeBigger: shouldBeBigger];
		[controller.pikabu setPosition: bufferedPosition];
		[controller.pikabu setLighterColor: shouldBeLighterColor];
		[controller.pikabu setShowDarkTintOnly: showDarkTintOnly];
	}

	// things that should update even when pikabu is showing
	[controller.pikabu setIsMusicPlaying: [[%c(VolumeControl) sharedVolumeControl] _isMusicPlayingSomewhere]];
	if (bufferedDARK >= 0) {
		[controller.pikabu setDarkColorImediate: bufferedDARK];
		bufferedDARK = -1;
	}
	if (bufferedLIGHT >= 0) {
		[controller.pikabu setLightColorImediate: bufferedLIGHT];
		bufferedLIGHT = -1;
	}
	if (bufferedBackgroundOn >= 0){
		[controller.pikabu setBackgroundOnImediate: bufferedBackgroundOn];
		bufferedBackgroundOn = -1;
	}
	if (shouldInvertColor >= 0) {
		[controller.pikabu setShouldInvertColorImediate: shouldInvertColor];
		shouldInvertColor = -1;
	}

	// show volume hud
	UIWindow *hudWindow = MSHookIvar<UIWindow *>(self, "_hudWindow");
	if (!hudWindow) {
		[self _createUI];
	}
	hudWindow = MSHookIvar<UIWindow *>(self, "_hudWindow");
	hudWindow.hidden = NO;

	// show Pikabu after update
	[controller updatePikabu];
	[controller showPikabuWithVolume:[[%c(VolumeControl) sharedVolumeControl] volume] WithInitialDelay: delay];
	if ([view isKindOfClass:[%c(SBRingerHUDView) class]]) {
		//[controller.pikabu setMute: YES];
		return;
	} else if ([view isKindOfClass: [%c(SBVolumeHUDView) class]]) {
		if (shouldShake) {
			[controller shakeItBaby];
		}
	}
	//[self performSelector:@selector(_hideHUDWindow:) withObject:nil afterDelay:delay+0.5];
}

- (void) reorientHUDIfNeeded:(BOOL) arg1 {
	%orig;
	[controller.pikabu updatePosition];
}

%end

%end

%group Common

%hook UIApplication

%new
- (void) hideLeft {
	if (ENABLED) {
		isStatusBarPartlyHidden = YES;
		UIStatusBar *sb_modern;
		sb_modern = MSHookIvar<UIStatusBar *>(self, "_statusBar");

		if ([NSStringFromClass([sb_modern class]) isEqualToString:@"UIStatusBar_Modern"]) {
			UIStatusBar *sb = MSHookIvar<UIStatusBar *>(sb_modern, "_statusBar");
			UIStatusBarForegroundView *foreground = MSHookIvar<UIStatusBarForegroundView *>(sb, "_foregroundView");
			UIView *view = [[foreground subviews] objectAtIndex: 0];
			UIView *view_two = [[foreground subviews] objectAtIndex: 1];

			[UIView animateWithDuration:0.2f animations:^{
				view.alpha = 0.0f;
				view.transform = CGAffineTransformMakeScale(0.9, 0.9);
			} completion: nil];
			[UIView animateWithDuration:0.2f animations:^{
				view_two.alpha = 0.0f;
				view_two.transform = CGAffineTransformMakeScale(0.9, 0.9);
			} completion: nil];
		}
	}
}

%new
- (void)	showLeft {
	isStatusBarPartlyHidden = NO;
	UIStatusBar *sb_modern = MSHookIvar<UIStatusBar *>(self, "_statusBar");

	if ([NSStringFromClass([sb_modern class]) isEqualToString:@"UIStatusBar_Modern"]) {
		UIStatusBar *sb = MSHookIvar<UIStatusBar *>(sb_modern, "_statusBar");
		UIStatusBarForegroundView *foreground = MSHookIvar<UIStatusBarForegroundView *>(sb, "_foregroundView");
		UIView *view = [[foreground subviews] objectAtIndex: 0];
		UIView *view_two = [[foreground subviews] objectAtIndex: 1];

		[UIView animateWithDuration:0.2f animations:^{
			view.alpha = 1.0f;
			view.transform = CGAffineTransformMakeScale(1.0, 1.0);
		} completion: nil];
		[UIView animateWithDuration:0.2f animations:^{
			view_two.alpha = 1.0f;
			view_two.transform = CGAffineTransformMakeScale(1.0, 1.0);
		} completion: nil];
	}
}

%new
- (void) hideRight {
	if (ENABLED) {
		isStatusBarPartlyHidden = YES;
		UIStatusBar *sb_modern = MSHookIvar<UIStatusBar *>(self, "_statusBar");

		if ([NSStringFromClass([sb_modern class]) isEqualToString:@"UIStatusBar_Modern"]) {
			UIStatusBar *sb = MSHookIvar<UIStatusBar *>(sb_modern, "_statusBar");
			UIStatusBarForegroundView *foreground = MSHookIvar<UIStatusBarForegroundView *>(sb, "_foregroundView");
			UIView *view = [[foreground subviews] objectAtIndex: 2];

			[UIView animateWithDuration:0.2f animations:^{
				view.alpha = 0.0f;
				view.transform = CGAffineTransformMakeScale(0.9, 0.9);
			} completion: nil];
		}
	}
}

%new
- (void) showRight {
	isStatusBarPartlyHidden = NO;
	UIStatusBar *sb_modern = MSHookIvar<UIStatusBar *>(self, "_statusBar");

	if ([NSStringFromClass([sb_modern class]) isEqualToString:@"UIStatusBar_Modern"]) {
		UIStatusBar *sb = MSHookIvar<UIStatusBar *>(sb_modern, "_statusBar");
		UIStatusBarForegroundView *foreground = MSHookIvar<UIStatusBarForegroundView *>(sb, "_foregroundView");
		UIView *view = [[foreground subviews] objectAtIndex: 2];

		[UIView animateWithDuration:0.2f animations:^{
			view.alpha = 1.0f;
			view.transform = CGAffineTransformMakeScale(1.0, 1.0);
		} completion: nil];
	}
}


%new
- (void) hideMiddle {

}

%new
- (void) showMiddle {

}

%new
- (void) hideStatusBar {
	if (![controller.pikabu isBigger]) {
		if (!isStatusBarPartlyHidden) {
			if (POSITION == PikabuPositionLeft) {
				[self hideLeft];
				lastPosition = PikabuPositionLeft;
			} else if (POSITION == PikabuPositionMiddle) {
				[self hideMiddle];
				lastPosition = PikabuPositionMiddle;
			}	else if (POSITION == PikabuPositionRight) {
				[self hideRight];
				lastPosition = PikabuPositionRight;
			}
		}
	}
}

%new
- (void) showStatusBar {
	if (isStatusBarPartlyHidden) {
		if (lastPosition == PikabuPositionLeft)
			[self showLeft];
		else if (lastPosition == PikabuPositionMiddle)
			[self showMiddle];
		else if (lastPosition == PikabuPositionRight)
			[self showRight];
	}
}

%end

%end

static void reloadPreferences() {
	/*if (preferences) {
		[preferences release];
		preferences = nil;
	}

	preferences = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jeffrey.pikabu.plist"] retain];

	if (!preferences || preferences.count == 0) {
		preferences = [DEFAULT_PREFS retain];
	}

	bufferedPosition = POSITION;*/

	if (preferences) {
		[preferences release];
		preferences = nil;
	}
	BOOL isSystem = [NSHomeDirectory() isEqualToString:@"/var/mobile"];
    // Retrieve preferences
  if(isSystem) {
      CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.jeffrey.pikabu"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
      if(keyList) {
          preferences = (NSDictionary *)CFPreferencesCopyMultiple(keyList, CFSTR("com.jeffrey.pikabu"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
          if(!preferences) preferences = [DEFAULT_PREFS retain];
          CFRelease(keyList);
      }
  }
  if (!preferences) {
      preferences = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jeffrey.pikabu.plist"] retain];
  }


	bufferedPosition = POSITION;

	bufferedDARK = DARK_COLOR;
	bufferedLIGHT = LIGHT_COLOR;
	bufferedBackgroundOn = BACKGROUND;

	pikabuDelay = DELAY;
	shouldBeLighterColor = LIGHTER;
	shouldBeBigger = BIGGER;
	shouldInvertColor = INVERT_COLOR;
	showDarkTintOnly = DARKONLY;
}

static inline void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	reloadPreferences();
	[_observer setDelay: DELAY];
	[[objc_getClass("VolumeControl") sharedVolumeControl] _changeVolumeBy: 0.0];
}

static void applicationDidBecomeActive(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (!_observer)
		_observer = [[PikabuObserver alloc] init];

	[_observer setDelay: DELAY];
}

/*static void applicationDidFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.jeffrey.pikabu"];

	// One-way (message only)
	[messagingCenter sendMessageName:@"applicationIsFullscreen" userInfo:nil];
}*/

%ctor {
	@autoreleasepool {
		if (NSClassFromString(@"SpringBoard")) {
			%init(SpringBoard);
			//NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Celestial.framework"];
			//[bundle load];
		}
		%init(Common);

		reloadPreferences();

		// observer for preference changes
		CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
		CFNotificationCenterAddObserver(center, NULL, &prefsChanged, (CFStringRef)@"com.jeffrey.pikabu/prefsChanged", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

		CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL,
			applicationDidBecomeActive,
			(CFStringRef)UIApplicationDidBecomeActiveNotification,
			NULL, CFNotificationSuspensionBehaviorCoalesce);
		/*CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL,
			applicationDidFinishLaunching,
			(CFStringRef)UIApplicationDidFinishLaunchingNotification,
			NULL, CFNotificationSuspensionBehaviorCoalesce);*/
	}
}
