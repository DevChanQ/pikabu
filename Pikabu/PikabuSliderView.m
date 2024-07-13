#import "PikabuSliderView.h"

@implementation PikabuSliderView

-(id) init {
  self = [super initWithFrame: pikabuSliderRect];
  if (self) {
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = true;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.backgroundColor = [UIColor colorWithRed:(254.0/255.0) green:(213.0/255.0) blue:(60.0/255.0) alpha:1];
  }
  return self;
}

@end
