//
//  YourProfileViewController.h
//  ParseStarterProject
//
//  Created by Luke Langford on 20/10/2015.
//
//

#import <UIKit/UIKit.h>

#import "CProfile.h"

@interface YourProfileViewController : UIViewController<UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate> {
    
    // UI elements
    
    // labels
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *ageLabel;
    IBOutlet UILabel *emailLabel;
    IBOutlet UILabel *locationLabel;
    IBOutlet UILabel *languageLabel;
    IBOutlet UIImageView *profileImageView;
    
    // text fields
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *ageField;
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *locationField;
    IBOutlet UITextField *languageField;
    
    // buttons
    IBOutlet UIButton *editProfileButton;
    IBOutlet UIButton *saveProfileButton;
    IBOutlet UIButton *discardChanges;
    IBOutlet UIButton *cameraButton;
    IBOutlet UIButton *locationButton;
    IBOutlet UIButton *yourJobsButton;
    
    CLLocationManager *locationManager;
    
    IBOutlet UIImage *profileImage;
    
}

// loading icon
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

@end
