#import <Preferences/Preferences.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "define.h"



@interface PikabuListController: PSListController {

}
@end

@implementation PikabuListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Pikabu" target:self] retain];

	}
	return _specifiers;
}

-(void) twitter {
	NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", @"chan_jeffrey"]];
	if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
		[[UIApplication sharedApplication] openURL:twitterURL];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", @"chan_jeffrey"]]];
	}
}

@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(PSSpecifier *)specifier;
- (CGFloat)preferredHeightForWidth:(CGFloat)width;
@end

@interface PikabuHeaderLabel : UILabel {
	 CGSize glowOffset;
	 UIColor *glowColor;
	 CGFloat glowAmount;

	 CGColorSpaceRef colorSpaceRef;
	 CGColorRef glowColorRef;
}

@end

@implementation PikabuHeaderLabel

- (id) initWithFrame:(CGRect) frame {
	self = [super initWithFrame: frame];
	if (self) {
		glowColor = [UIColor blackColor];
    glowColorRef = CGColorCreate(colorSpaceRef, CGColorGetComponents(glowColor.CGColor));

		glowOffset = CGSizeMake(10.0, 10.0);
    glowAmount = 5.0;
	}
	return self;
}

- (void)drawTextInRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  CGContextSetShadow(context, glowOffset, glowAmount);
  CGContextSetShadowWithColor(context, glowOffset, glowAmount, glowColorRef);

  [super drawTextInRect:rect];

  CGContextRestoreGState(context);
}

@end

@interface PikabuHeaderCell : PSTableCell <PreferencesTableCustomView> {
	UIView *labelContainerView;
	UILabel *_label;

	UIImageView *_headerImg;
}
@end

@implementation PikabuHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
	if (self) {
		/*labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,100)];
		labelContainerView.center = CGPointMake(self.bounds.size.width  / 2,
                                 self.bounds.size.height / 2);

		_label = [[PikabuHeaderLabel alloc] initWithFrame:CGRectMake(0,0,300,100)];
		_label.textColor = [UIColor colorWithRed:(254.0/255.0) green:(213.0/255.0) blue:(60.0/255.0) alpha:1];
		_label.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:36];
		[_label setNumberOfLines: 0];

		[_label setLineBreakMode:UILineBreakModeWordWrap];
		[_label setText:@"Pikabu"];
		[_label setBackgroundColor:[UIColor clearColor]];
		[_label setShadowColor:[UIColor clearColor]];

		[_label setTextAlignment:UITextAlignmentCenter];

		[labelContainerView addSubview: _label];
		[self addSubview:labelContainerView];*/

		_headerImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/bootstrap/Library/PreferenceBundles/PikabuSettings.bundle/PikabuHeader.png"]];
		_headerImg.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width - 50.0, 60.0);
		_headerImg.contentMode = UIViewContentModeScaleAspectFill;

		_headerImg.center = CGPointMake(UIScreen.mainScreen.bounds.size.width/2, 80.0/2);
		[self addSubview:_headerImg];

		[_headerImg release];
	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	// Return a custom cell height.
	return 80.f;
}
@end

@interface PikabuSwitchCell : PSSwitchTableCell

@end

@implementation PikabuSwitchCell

-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier { //init method
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier]; //call the super init method
	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed:(254.0/255.0) green:(213.0/255.0) blue:(60.0/255.0) alpha:1]]; //change the switch color
	}
	return self;
}

@end
