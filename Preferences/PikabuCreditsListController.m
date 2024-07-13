#import <Preferences/Preferences.h>
#import <Foundation/Foundation.h>

@interface PikabuCreditsListController : PSListController

@end

@implementation PikabuCreditsListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Credits" target:self] retain];
	}
	return _specifiers;
}

@end
