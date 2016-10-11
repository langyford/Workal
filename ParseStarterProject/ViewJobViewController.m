//
//  ViewJobViewController.m
//  ParseStarterProject
//
//  Created by Luke Langford on 17/11/2015.
//
//

#import "ViewJobViewController.h"

@interface ViewJobViewController ()

@end

@implementation ViewJobViewController
@synthesize objectID;

-(void)getJobDetails {
    
    // load the details for the current job
    PFQuery *query = [PFQuery queryWithClassName:@"Jobs"];
    [query whereKey:@"objectId" equalTo:objectID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *jobObject, NSError *error) {
        
        // set labels text to jobs details
        titleLabel.text = jobObject[@"Title"];
        descriptionBox.text = jobObject[@"Description"];
        priceLabel.text = [NSString stringWithFormat:@"Price: $%@", jobObject[@"Price"]];
        numberOfDaysLabel.text = [NSString stringWithFormat:@"Should take %@ Day(s)", jobObject[@"NumberOfDays"]];
        locationLabel.text = jobObject[@"Location"];
        categoryLabel.text = jobObject[@"Category"];
        
        // load the jobs picture
        [jobObject[@"JobPicture"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            jobImage = [UIImage imageWithData:data];
            jobImageView.image = jobImage;
            
        }];
        
    }];
    
}

// segment control onclick
-(IBAction)toggleAction {
    
    if ([toggle selectedSegmentIndex] == 0) {
        
        // apply button
        
    }
    else if ([toggle selectedSegmentIndex] == 1) {
        
        // IM button
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // load job details
    [self getJobDetails];
    
    // Change the color of the Status Bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:109/255.0 green:76/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:statusBarView];
    
}

// UI Handlers

// Change color of text in status bar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
