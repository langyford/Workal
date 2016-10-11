//
//  EditYourPostViewController.h
//  ParseStarterProject
//
//  Created by Luke Langford on 17/11/2015.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "YourPostsViewController.h"

@interface EditYourPostViewController : UIViewController<UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate> {
    
    // labels
    IBOutlet UILabel *titleLabel;
    IBOutlet UITextView *descriptionBox;
    IBOutlet UILabel *locationLabel;
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *numberOfDaysLabel;
    IBOutlet UILabel *categoryLabel;
    
    // text fields
    IBOutlet UITextField *titleField;
    IBOutlet UITextField *locationField;
    IBOutlet UITextField *priceField;
    IBOutlet UITextField *numberOfDaysField;
    IBOutlet UITextField *categoryField;
    
    // image stuff
    UIImage *jobImage;
    IBOutlet UIImageView *jobImageView;
    
    // buttons
    IBOutlet UIButton *cameraButton;
    IBOutlet UIButton *locationButton;
    
    // segmented control
    IBOutlet UISegmentedControl *toggle;
    
    // location
    CLLocationManager *locationManager;
    
    bool didUpLocation;
    
}

@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

// job objectId
@property (nonatomic, strong) NSString *objectID;


@end
