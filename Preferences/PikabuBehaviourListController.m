#import "PikabuBehaviourListController.h"
#import "define.h"

@implementation PikabuBehaviourListController

@synthesize colorNames;
@synthesize colorV;

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Behaviour" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.colorNames = PikabuColorNames;
	self.colorV = PikabuColorValues;
}


- (NSString *)colorNameForSpecifier:(PSSpecifier *)spec {
	NSUserDefaults *defaults = [[[NSUserDefaults alloc] init] autorelease];
	[defaults addSuiteNamed:[spec propertyForKey: @"defaults"]];
	NSString *colorName = [defaults stringForKey: [spec propertyForKey: @"key"]];

	return colorName;
}

- (NSArray *)colorTitles {
	NSMutableArray *localizedColors = [[NSMutableArray alloc] initWithCapacity: [self.colorNames count]];
	for (NSString *color in self.colorNames) {
		[localizedColors addObject:NSLocalizedString(color, @"")];
	}

	return localizedColors;
}

- (NSArray *)colorValues {
	return self.colorV;
}

@end
