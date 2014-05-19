//
//  POCEnrollmentResultViewController.m
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 5/1/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import "POCEnrollmentResultViewController.h"

@interface POCEnrollmentResultViewController ()

@end

@implementation POCEnrollmentResultViewController
@synthesize imagePreview;
@synthesize statusLabel;
@synthesize resultImage;
@synthesize enrollmentResult;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imagePreview.image = resultImage;
    statusLabel.text = enrollmentResult;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
