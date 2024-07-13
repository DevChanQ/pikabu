#import <Preferences/Preferences.h>
#import <Foundation/Foundation.h>
#import "define.h"

@interface PikabuColorListController : PSListItemsController {

}

@property(nonatomic, retain) NSArray *colors;

@end

@implementation PikabuColorListController

@synthesize colors;

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)arg2 {
  if (!self.colors)
    self.colors = PikabuColors;

 UITableViewCell *cell = [super tableView:table cellForRowAtIndexPath: arg2];
 cell.imageView.image = [self imageWithColor: [self.colors objectAtIndex: arg2.row]];
 cell.imageView.contentMode = UIViewContentModeScaleAspectFill;

 return cell;
}

- (UIImage *) imageWithColor:(UIColor *) color {
  CGSize size = CGSizeMake(30,30);
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);

  [color set];
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path addArcWithCenter:CGPointMake(size.width/2,size.width/2) radius:size.width/2 startAngle:0 endAngle:2 * M_PI clockwise:YES];

  [path fill];

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

@end
