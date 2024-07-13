#import "PikabuBaseView.h"

@implementation PikabuBaseView

@synthesize mute=_mute;
@synthesize lightColor;
@synthesize darkColor;
@synthesize isDark;
@synthesize lighterColor;

- (void) setDark {
  style=PikabuStyleDark;
  self.isDark = YES;
}

- (void) setLight {
  style=PikabuStyleLight;
  self.isDark = NO;
}

-(void) update {
  return;
}

-(UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.3, 1.0)
                               green:MIN(g + 0.3, 1.0)
                                blue:MIN(b + 0.3, 1.0)
                               alpha:a];
    return nil;
}

-(UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

@end
