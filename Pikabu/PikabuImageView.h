#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "define.h"
#import "PikabuBaseView.h"

@interface PikabuImageView : PikabuBaseView {
  UIImageView *_imageView;
  UIImage *_blackSound;
  UIImage *_whiteSound;
  UIImage *_blackMute;
  UIImage *_whiteMute;
  UIImage *_blackMusic;
  UIImage *_whiteMusic;
  UIImage *_blackHeadphone;
  UIImage *_whiteHeadphone;
}

-(id) initWithFrame:(CGRect) frame;
- (void) setMute:(BOOL) mute;
- (void) setMusicPlaying: (BOOL) playing;
- (void) setHeadphonePresent: (BOOL) present;

@end
