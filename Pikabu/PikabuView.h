#import <UIKit/UIKit.h>
#import "PikabuSliderView.h"
#import "define.h"

@interface PikabuView : PikabuBaseView {
  PikabuSliderView *_slider;
  UIVisualEffectView *_blurEffectView;
}

-(id)initWithFrame:(CGRect) frame;
-(PikabuSliderView *) slider;

@end
