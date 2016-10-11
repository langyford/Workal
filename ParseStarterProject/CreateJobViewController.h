//
//  CreateJobViewController.h
//  ParseStarterProject
//
//  Created by Luke Langford on 15/10/2015.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "QuartzCore/QuartzCore.h"

#import "HomePageViewController.h"

@interface CreateJobViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate> {
    
    // UI elements
    IBOutlet UITextField *titleField;
    IBOutlet UITextView *descriptionField;
    IBOutlet UITextField *numberOfDaysField;
    IBOutlet UITextField *priceField;
    IBOutlet UITextField *locationField;
    IBOutlet UITextField *categoryField;
    IBOutlet UIImageView *imageView;
    
    IBOutlet UIButton *leftArrow;
    IBOutlet UIButton *rightArrow;
    IBOutlet UIButton *locationButton;
    
    // current location manager
    CLLocationManager *locationManager;
    
}

// loading icon
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

@property (nonatomic) int pageIndicator;

// methods and functions
-(IBAction)takePhoto;
-(IBAction)getLocation;

-(void)createJobWithDetails:(NSMutableArray *)jobDetails;
-(IBAction)createJobOnClick;
-(void)getInfoForJob;


@end
