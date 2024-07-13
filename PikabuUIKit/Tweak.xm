#import <UIKit/UIKit.h>
#import <UIKit/UIStatusBarForegroundView.h>
#import <AVFoundation/AVFoundation.h>
#import "define.h"

#define ENABLED ([preferences objectForKey: PREFS_ENABLED_KEY] ? [[preferences objectForKey: PREFS_ENABLED_KEY] boolValue] : DEFAULT_ENABLED)
#define POSITION ([preferences objectForKey: PREFS_POSITION_KEY] ? [[preferences objectForKey: PREFS_POSITION_KEY] integerValue] : DEFAULT_POSITION)
#define VIBRATE ([preferences objectForKey: PREFS_VIBRATE_KEY] ? [[preferences objectForKey: PREFS_VIBRATE_KEY] boolValue] : DEFAULT_VIBRATE)

static VolumeControlObserver *observer = nil;

static NSDictionary *preferences = nil;

static BOOL isStatusBarPartlyHidden = NO;

%group UIKit

%hook UIApplication

%new
- (void) toggleLeftSideOfStatusBar {
	UIStatusBar *sb_modern = MSHookIvar<UIStatusBar *>(self, "_statusBar");
	UIStatusBar *sb = MSHookIvar<UIStatusBar *>(sb_modern, "_statusBar");
	UIStatusBarForegroundView *foreground = MSHookIvar<UIStatusBarForegroundView *>(sb, "_foregroundView");
	UIView *view = [[foreground subviews] objectAtIndex: 0];
	if (!isStatusBarPartlyHidden) {
		isStatusBarPartlyHidden = YES;
		[UIView animateWithDuration:0.2f animations:^{
			view.alpha = 0.0f;
			view.transform = CGAffineTransformMakeScale(0.9, 0.9);
		} completion: nil];
	} else {
		isStatusBarPartlyHidden = NO;
		[UIView animateWithDuration:0.2f animations:^{
			view.alpha = 1.0f;
			view.transform = CGAffineTransformMakeScale(1.0, 1.0);
		} completion: nil];
	}
}

%new
- (void) toggleRightSideOfStatusBar {
	UIStatusBar *sb_modern = MSHookIvar<UIStatusBar *>(self, "_statusBar");
	UIStatusBar *sb = MSHookIvar<UIStatusBar *>(sb_modern, "_statusBar");
	UIStatusBarForegroundView *foreground = MSHookIvar<UIStatusBarForegroundView *>(sb, "_foregroundView");
	UIView *view = [[foreground subviews] objectAtIndex: 2];
	if (!isStatusBarPartlyHidden) {
		isStatusBarPartlyHidden = YES;
		[UIView animateWithDuration:0.2f animations:^{
			view.alpha = 0.0f;
			view.transform = CGAffineTransformMakeScale(0.9, 0.9);
		} completion: nil];
	} else {
		isStatusBarPartlyHidden = NO;
		[UIView animateWithDuration:0.2f animations:^{
			view.alpha = 1.0f;
			view.transform = CGAffineTransformMakeScale(1.0, 1.0);
		} completion: nil];
	}
}

%new
- (void) toggleStatusBar {

	if (POSITION == PikabuPositionLeft)
		[self toggleLeftSideOfStatusBar];
	else if (POSITION == PikabuPositionRight)
		[self toggleRightSideOfStatusBar];
}

%end

%end

static void reloadPreferences() {

	if (preferences) {
		[preferences release];
		preferences = nil;
	}

	NSArray *keyList = [(NSArray *)CFPreferencesCopyKeyList((CFStringRef)APPID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
	preferences = (NSDictionary *)CFPreferencesCopyMultiple((CFArrayRef)keyList, (CFStringRef)APPID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

	if (!preferences || preferences.count == 0) {
		preferences = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.jeffrey.pikabu.plist"]];
	}

	if (!preferences || preferences.count == 0) {
		preferences = [DEFAULT_PREFS retain];
	}
}

static inline void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	reloadPreferences();
}

%ctor {
  reloadPreferences();

  %init(UIKit);

  if (!NSClassFromString(@"SpringBoard"))
    observer = [[[VolumeControlObserver alloc] init] retain];

  CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(center, NULL, &prefsChanged, (CFStringRef)@"com.jeffrey.pikabu/prefsChanged", NULL, 0);
}
