//
//  RootViewController.m
//  LMPhotoViewController
//
//  Created by Horiguchi Naoto on 12/01/26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "SampleViewController.h"

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)show
{
    SampleViewController *viewController = [[SampleViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
