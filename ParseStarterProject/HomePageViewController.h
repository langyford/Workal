//
//  HomePageViewController.h
//  ParseStarterProject
//
//  Created by Luke Langford on 12/10/2015.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MapKit/MapKit.h>

#import "ViewJobViewController.h"

@interface HomePageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate> {
    
    // table view data
    NSArray *jobFeedArray;
    NSUInteger *arraySize;
    NSInteger rowNumberPressed;
    
    // job feed
    IBOutlet UITableView *jobFeedTableView;
    
    // map and toggle buttons @ bottom of view
    IBOutlet UISegmentedControl *toggle;
    IBOutlet MKMapView *mapView;
    
}

// loading icon
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

@property () bool reloadBool;

@end
