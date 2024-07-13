#import <UIKit/UIKit.h>
#import "define.h"

@interface PikabuBaseView : UIView {
  PikabuStyle style;

  BOOL _mute;
  BOOL _isMusicPlaying;
  BOOL _headphonePresent;
}

@property(nonatomic) BOOL mute;
@property(nonatomic, retain) UIColor *lightColor;
@property(nonatomic, retain) UIColor *darkColor;
@property(nonatomic) BOOL isDark;
@property(nonatomic) BOOL lighterColor;

-(void) setDark;
-(void) setLight;
-(void) update;
-(UIColor *)lighterColorForColor:(UIColor *)c;
-(UIColor *)darkerColorForColor:(UIColor *)c;

@end
