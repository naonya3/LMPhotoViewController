//
// LMPhotoViewerController.h
// PhotoBag
//
// Copyright (c) 2011- Naoto Horiguchi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "LMPhotoScrollView.h"

@interface LMPhotoViewerController : UIViewController<UIScrollViewDelegate>
{
@private
    LMPhotoScrollView *currentPhotoScrollView_;
    LMPhotoScrollView *nextPhotoScrollView_;
    LMPhotoScrollView *prevPhotoScrollView_;
    
    //おせっかい
    int parentNavigationBarStyle;
    int parentNavigationBarTranslucent;
    UIColor *parentNavigationBarBackgroundColor;
    int parentToolBarStyle;
    int parentToolBarTranslucent;
    int parentWantsFullScreenLayout;
    int parentStatusBarStyle;
    UIColor *parentTintColor;
    UIImage *parentNavigationBackground;
    
    NSMutableArray *lmPhotoScrollViews_;
    
    BOOL navigationHide_;
}

@property (nonatomic, retain) UIScrollView *lmScrollView;
@property (nonatomic, assign) int currentIndex;

- (int)numberOfImages;
- (float)sizeForMargin;
- (UIImage *)imageForAtIndex:(int)index;
- (void)reloadImage;
- (void)setIndex:(int)index;
- (void)hideNavigation;
- (void)showNavigation;    

@end
