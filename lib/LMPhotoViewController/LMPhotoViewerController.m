//
// LMPhotoViewerController.m
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
#import "LMPhotoViewerController.h"

@implementation LMPhotoViewerController
@synthesize currentIndex, lmScrollView;

#pragma mark - Private
- (void)setNavigationBarStyle
{
    //見た目を保存
    parentWantsFullScreenLayout = self.wantsFullScreenLayout;
    parentStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    parentNavigationBarStyle = self.navigationController.navigationBar.barStyle;
    parentNavigationBarTranslucent = self.navigationController.navigationBar.translucent;
    
    parentToolBarStyle = self.navigationController.toolbar.barStyle;
    parentToolBarTranslucent = self.navigationController.toolbar.translucent;
    
    NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    NSInteger iOsVersionMajor = [[aOsVersions objectAtIndex:0] intValue];
    if (iOsVersionMajor >= 5) {
        parentNavigationBackground = [[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] retain];
        parentNavigationBarBackgroundColor = [self.navigationController.navigationBar.backgroundColor retain];
    }
    
    parentTintColor = [self.navigationController.navigationBar.tintColor retain]; 
    
    //デフォルトの見た目を設定しておく
    //ツールバー系の透過
    self.wantsFullScreenLayout = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.translucent = YES;
    
    if (iOsVersionMajor >= 5) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.backgroundColor = nil;
    }
    
    [self.navigationController.navigationBar setTintColor:nil];
}

- (void)reverseNavigationStyle
{
    self.wantsFullScreenLayout = parentWantsFullScreenLayout;
    [[UIApplication sharedApplication] setStatusBarStyle:parentStatusBarStyle animated:YES];
    
    self.navigationController.navigationBar.barStyle = parentNavigationBarStyle;
    self.navigationController.navigationBar.translucent = parentNavigationBarTranslucent;
    
    self.navigationController.toolbar.barStyle = parentToolBarStyle;
    self.navigationController.toolbar.translucent = parentToolBarTranslucent;
    
    NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    NSInteger iOsVersionMajor = [[aOsVersions objectAtIndex:0] intValue];
    if (iOsVersionMajor >= 5) {
        [self.navigationController.navigationBar setBackgroundImage:parentNavigationBackground forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.backgroundColor = parentNavigationBarBackgroundColor;
    }
    
    self.navigationController.navigationBar.tintColor = parentTintColor;
}

- (CGRect)scrollRect
{
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(
                              -([self sizeForMargin] / 2.0f)
                              ,0
                              ,appFrame.size.width + [self sizeForMargin]
                              ,appFrame.size.height
                              );
    return frame;
}

- (CGSize)contentSize
{
    return CGSizeMake([self scrollRect].size.width * [self numberOfImages], [self scrollRect].size.height);
}

- (CGPoint)contentOffsetFromIndex:(int)index
{
    return CGPointMake([self scrollRect].size.width * index, 0);
}

- (CGPoint)contentOffsetFromCurrentIndex
{
    return [self contentOffsetFromIndex:self.currentIndex];
}

- (int)indexFromContentOffset:(CGPoint)contentOffset
{
    return contentOffset.x / [self scrollRect].size.width;
}

#pragma mark - Managing LMPhotoScrollViews

- (CGRect)photoScrollViewRectWithIndex:(int)index
{
    CGRect rect = [[UIScreen mainScreen]bounds];
    rect.origin.x = [self sizeForMargin] * index + [self sizeForMargin] / 2.0 + rect.size.width * index;
    return rect;
}

- (void)createPhotoScrollViews
{
    if (lmPhotoScrollViews_ == nil) {
        lmPhotoScrollViews_ = [[NSMutableArray alloc]init];
    }else{
        //あり得ないはず
        return;
    }
    
    CGRect rect = [self scrollRect];
    rect.origin.x = 0;
    for (int i = 0; i < 3; i++) {
        LMPhotoScrollView *lmPhotoScrollView = [[[LMPhotoScrollView alloc]initWithFrame:[self photoScrollViewRectWithIndex:i]]autorelease];
        [lmPhotoScrollViews_ addObject:lmPhotoScrollView];
        [self.lmScrollView addSubview:lmPhotoScrollView];
    }
    currentPhotoScrollView_ = [lmPhotoScrollViews_ objectAtIndex:0];
    nextPhotoScrollView_ = [lmPhotoScrollViews_ objectAtIndex:1];
    prevPhotoScrollView_ = [lmPhotoScrollViews_ objectAtIndex:2];
}

- (void)setupPhotoScrollViews
{
    //current
    currentPhotoScrollView_.frame = [self photoScrollViewRectWithIndex:currentIndex];
    nextPhotoScrollView_.frame = [self photoScrollViewRectWithIndex:currentIndex + 1];
    prevPhotoScrollView_.frame = [self photoScrollViewRectWithIndex:currentIndex - 1];
}

- (void)loadPhotos
{
    [currentPhotoScrollView_ setImage:[self imageForAtIndex:currentIndex]];
    
    if ( currentIndex - 1 < 0 ) {
        [prevPhotoScrollView_ setImage:nil];
    } else {
        [prevPhotoScrollView_ setImage:[self imageForAtIndex:currentIndex - 1]];
    }
    
    if ( currentIndex + 1 < [self numberOfImages] ) {
        [nextPhotoScrollView_ setImage:[self imageForAtIndex:currentIndex + 1]];
    } else {
        [nextPhotoScrollView_ setImage:nil];
    }
}

- (void)reloadPhotoScrollViews
{
    [self setupPhotoScrollViews];
    [self loadPhotos];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        //その他初期化
        self.currentIndex = 0;
        
        navigationHide_ = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageTouchHandler) name:LMImageTouchEvent object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.lmScrollView = nil;
    [lmPhotoScrollViews_ release];
    [parentNavigationBackground release];
    [parentNavigationBarBackgroundColor release];
    [parentTintColor release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavigationBarStyle];
    self.lmScrollView = [[UIScrollView alloc]init];
    self.lmScrollView.frame = [self scrollRect];
    
    self.lmScrollView.delegate = self;
    self.lmScrollView.scrollsToTop = NO;
    self.lmScrollView.showsHorizontalScrollIndicator = NO;
    self.lmScrollView.showsHorizontalScrollIndicator = NO;
    self.lmScrollView.pagingEnabled = YES;
    
    [self.view addSubview:self.lmScrollView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self createPhotoScrollViews];
    [self reloadImage];
    
    [self performSelector:@selector(imageTouchHandler) withObject:nil afterDelay:2.0f];
}

- (void)viewDidUnload
{
    self.lmScrollView = nil;
    [lmPhotoScrollViews_ release];
    lmPhotoScrollViews_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self reverseNavigationStyle];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(imageTouchHandler) object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

#pragma mark - UIScrollViewDelegateMethod
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //return;
    float index = self.lmScrollView.contentOffset.x / [self scrollRect].size.width;
    float delta = index - currentIndex;
    
    if (fabs(delta) >= 1.0f) {
        if (delta > 0) {
            currentIndex += 1;
            // the current page moved to right
            LMPhotoScrollView* tmpView = currentPhotoScrollView_;
            currentPhotoScrollView_ = nextPhotoScrollView_;
            nextPhotoScrollView_ = prevPhotoScrollView_;
            prevPhotoScrollView_ = tmpView;
        } else {
            currentIndex -= 1;
            // the current page moved to left
            LMPhotoScrollView* tmpView = currentPhotoScrollView_;
            currentPhotoScrollView_ = prevPhotoScrollView_;
            prevPhotoScrollView_ = nextPhotoScrollView_;
            nextPhotoScrollView_ = tmpView;
        }
        nextPhotoScrollView_.frame = [self photoScrollViewRectWithIndex:currentIndex + 1];
        prevPhotoScrollView_.frame = [self photoScrollViewRectWithIndex:currentIndex - 1];
        if ( currentIndex - 1 < 0 ) {
            [prevPhotoScrollView_ setImage:nil];
        } else {
            [prevPhotoScrollView_ setImage:[self imageForAtIndex:currentIndex - 1]];
        }
        
        if ( currentIndex + 1 < [self numberOfImages] ) {
            [nextPhotoScrollView_ setImage:[self imageForAtIndex:currentIndex + 1]];
        } else {
            [nextPhotoScrollView_ setImage:nil];
        }
    }
}



#pragma mark - LMPhotoViewerControllerMethod
- (float)sizeForMargin
{
    return 40.0;
}

- (int)numberOfImages
{
    return 0;
}

- (UIImage *)imageForAtIndex:(int)index
{
    return nil;
}

- (void)reloadImage
{
    CGSize contentSize = [self contentSize];
    self.lmScrollView.contentSize = contentSize;
    
    CGPoint offset = [self contentOffsetFromCurrentIndex];
    self.lmScrollView.contentOffset = offset;
    
    [self reloadPhotoScrollViews];
}

- (void)setIndex:(int)index
{     
    self.currentIndex = index;
}

#pragma mark - Handler
- (void)hideNavigation
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        //CGRect rect = self.navigationController.navigationBar.frame;
        //rect.origin.y = -44;
        //self.navigationController.navigationBar.frame = rect;
        self.navigationController.navigationBar.alpha = 0.0f;
    } completion:^(BOOL isFinish){
        
    }];
}

- (void)showNavigation
{    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    //おかしなときがあるからナビゲーションバーの位置を計算し直そう
    CGRect rect =  self.navigationController.navigationBar.frame;
    rect.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.navigationController.navigationBar.frame = rect;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        //CGRect rect = self.navigationController.navigationBar.frame;
        //rect.origin.y = -44;
        //self.navigationController.navigationBar.frame = rect;

        self.navigationController.navigationBar.alpha = 1.0f;
    } completion:^(BOOL isFinish){
        
    }];
}


- (void)imageTouchHandler
{
    navigationHide_ = !navigationHide_;
    if (navigationHide_ == YES) {
        [self hideNavigation];
    }else{
        [self showNavigation];
    }
}

@end