//
//  SampleViewController.m
//  LMPhotoViewController
//
//  Created by Horiguchi Naoto on 12/01/26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SampleViewController.h"

@implementation SampleViewController

- (id)init
{
    self = [super init];
    if (self) {
        images_ = [[NSArray alloc]initWithObjects:
                   [UIImage imageNamed:@"image01.png"]
                   ,[UIImage imageNamed:@"image02.png"]
                   ,[UIImage imageNamed:@"image03.png"]
                   , nil];
    }
    return self;
}

- (int)numberOfImages
{
    return [images_ count];
}

- (UIImage *)imageForAtIndex:(int)index
{
    return [images_ objectAtIndex:index];
}

@end
