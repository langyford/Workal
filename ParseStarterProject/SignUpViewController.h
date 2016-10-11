//
//  SignUpViewController.h
//  
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "LoginViewController.h"

@interface SignUpViewController : UIViewController<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate> {
    
    // arrow buttons
    IBOutlet UIButton *leftArrow;
    IBOutlet UIButton *rightArrow;
    
    // text fields on signup view
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *ageField;
    IBOutlet UITextField *nameField;
    
    // Profile Picture
    IBOutlet UIImageView *imageView;
    
    // Location
    CLLocationManager *locationManager;
    IBOutlet UITextField *locationField;
    
}

// Loading Animation
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

@property (nonatomic) int pageIndicator;

// Methods and Functions
-(void)getProfileInfo;
-(IBAction)signupOnClick;
-(IBAction)takePicture;
-(IBAction)getCurrentLocation;
-(void)signUpWithDetailsWithDetails:(NSMutableArray *)profileDetails;

@end
