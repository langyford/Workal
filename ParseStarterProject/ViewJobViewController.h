//
//  ViewJobViewController.h
//  ParseStarterProject
//
//  Created by Luke Langford on 17/11/2015.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewJobViewController : UIViewController {
    
    IBOutlet UISegmentedControl *toggle;
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UITextView *descriptionBox;
    IBOutlet UILabel *locationLabel;
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *numberOfDaysLabel;
    IBOutlet UILabel *categoryLabel;
    
    // image stuff
    IBOutlet UIImage *jobImage;
    IBOutlet UIImageView *jobImageView;
    
}

@property (nonatomic, strong) NSString *objectID;

@end
