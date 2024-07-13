#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Pikabu.h"
#import <Foundation/Foundation.h>
#import "SpringBoard/SBMainStatusBarStateProvider.h"
#import "SpringBoard/SBStatusBarManager.h"
#import "SpringBoard/SBStatusBarStateAggregator.h"
#import "define.h"

@interface PikabuController : UIViewController {
    Pikabu *_pikabu;

    SBMainStatusBarStateProvider *provider;
    SBStatusBarStateAggregator *sbsa;
    BOOL isShowing;
    BOOL _isShown;
    BOOL scrubing;

    NSTimer *timer;
    NSString *operatorName;

    PikabuStyle _currentStyle;

    BOOL _wasShowing[35];

    UINotificationFeedbackGenerator *feedbackGenerator;
    BOOL hasTaptic;

    BOOL isBreadcrumbShowing;
    BOOL shouldBeBiggerInMiddle;

    NSArray *colors;

    CGPoint panCoord;

    float multiplier;

    CGRect frameBeforeDragging;
}

@property(nonatomic, retain) Pikabu *pikabu;

+(PikabuController *) sharedController;
-(void) dismissPikabu;
-(void) showPikabuWithVolume:(float) volume;
-(void) showPikabuWithVolume:(float) volume WithInitialDelay:(NSTimeInterval) delay;

-(id) init;
-(BOOL) isShown;

- (void) checkStyle;

-(void) vibrate;
-(void) shakeItBaby;

- (void) updatePikabu;

- (BOOL) shouldReceiveTouchAtWindowPoint:(CGPoint) point;

@end
