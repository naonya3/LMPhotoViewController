//
// LMPhotoDetailView.m
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

#import "LMPhotoScrollView.h"

@implementation LMPhotoScrollView

/*
 最小拡大率の算出と保存
 シングルタップ時に通知
 最大拡大率の算出と保存
 最大拡大率を超えた場合の挙動
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (CGRect)zoomRectFromScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    if (scale == 1) {
        scale = 1.0001;
    }
    
    zoomRect.size.height = (self.frame.size.height) / scale;
    zoomRect.size.width = (self.frame.size.width) / scale;
    
    zoomRect.origin.x = (center.x) - ((zoomRect.size.width) / 2.0);
    zoomRect.origin.y = (center.y) - ((zoomRect.size.height) / 2.0);
    
    return zoomRect;
}

- (CGRect)zoomRectAtFit
{
    float scale;

    //長い方を合わせる
    if ( imageView_.frame.size.height <= imageView_.frame.size.width ) {
        //横にあわせる
        scale = self.frame.size.width / imageView_.bounds.size.width;
    } else {
        scale = self.frame.size.height / imageView_.bounds.size.height;
    }
    
    return [self zoomRectFromScale:scale withCenter:CGPointMake(0, 0)];
}

//画像を中央に移動させる
- (void)moveToCenter:(UIImageView *)imageView animated:(BOOL)animated
{
    CGRect fitRect = [self zoomRectAtFit];
    [self zoomToRect:fitRect animated:animated];
    
    //scrollViewの拡大は左上(0,0)を起点にされる為、
    //コンテンツサイズが領域に達していない場合は中央揃えにする為に
    //imageViewのframeに適当な余白をつける必要がある。
    fitZoomScale = self.zoomScale;
    
    CGRect rect = imageView.frame;
    CGRect newRect = rect;

    self.contentSize = self.bounds.size;
    newRect.origin.x = self.frame.size.width / 2 - rect.size.width / 2;
    newRect.origin.y = self.frame.size.height / 2 - rect.size.height / 2;
    
    imageView.frame = newRect;
}

- (void)postTouchNotification
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:LMImageTouchEvent object:nil]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        [self performSelector:@selector(postTouchNotification) withObject:nil afterDelay:0.2f];
    } else if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(postTouchNotification) object:nil];
        
        CGRect zoomRect;
        
        if (fitZoomScale > self.zoomScale || fitZoomScale < self.zoomScale) {
            
            //画面にfitする倍率以外のときダブルタップされたら画面にfitさせる
            [self moveToCenter:imageView_ animated:YES];
        
        }else if (fitZoomScale == self.zoomScale) {
            
            //画面にfitしている状態でダブルタップされるとfitする倍率の2倍の大きさに、タップしたポイントを中心に拡大する
            
            //領域中央に配置する為に空けていたマージンを削除。消さないと、余分にスクロールできてしまう。
            CGRect rect = imageView_.frame;
            rect.origin.x = 0;
            rect.origin.y = 0;
            imageView_.frame = rect;
            
            zoomRect = [self zoomRectFromScale:(fitZoomScale * 2) withCenter:[touch locationInView:imageView_]];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //コンテンツの高さが足りないときはY座標を表示領域の中心に固定
    //もうちょっとブラッシュアップしたい
    if (imageView_.frame.size.height < self.bounds.size.height) {
        CGRect rect = imageView_.frame;
        __block CGRect newRect = rect;
        
        //[UIView animateWithDuration:0.2 animations:^{
            newRect.origin.y = self.frame.size.height / 2 - rect.size.height / 2;
            imageView_.frame = newRect;
        //}];
    }
    
    if (imageView_.frame.size.width < self.bounds.size.width) {
        CGRect rect = imageView_.frame;
        __block CGRect newRect = rect;
        
        //[UIView animateWithDuration:0.2 animations:^{
            newRect.origin.x = self.frame.size.width / 2 - rect.size.width / 2;
            imageView_.frame = newRect;
        //}];
    }
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (scale == fitZoomScale) {
        return;
    }
    
    if (scale < minZoomScale) {
        
        //最小サイズより小さいとき中心に戻す
        
        //[self moveToCenter:imageView_ animated:YES];
        CGRect fitRect = [self zoomRectFromScale:minZoomScale withCenter:CGPointMake(0, 0)];
        [self zoomToRect:fitRect animated:YES];
        
        CGRect rect = imageView_.frame;
        CGRect newRect = rect;
        self.contentSize = self.bounds.size;
        newRect.origin.x = self.frame.size.width / 2 - rect.size.width / 2;
        newRect.origin.y = self.frame.size.height / 2 - rect.size.height / 2;
        
        imageView_.frame = newRect;
        
    } else {
        
        //コンテンツの高さが足りないときは縦方向のコンテンツ幅を変えない
        if (imageView_.frame.size.height < self.bounds.size.height) {
            
            //縦スクロール禁止
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, self.bounds.size.height);
            
            //そして、画面の中央にコンテンツを移動
            [UIView animateWithDuration:0.3f animations:^{
                CGRect rect = imageView_.frame;
                CGRect newRect = rect;
                newRect.origin.y = self.frame.size.height / 2 - rect.size.height / 2;
                imageView_.frame = newRect;
            }];
            
        } else if (imageView_.frame.size.width < self.bounds.size.width) {
            
            //縦スクロール禁止
            scrollView.contentSize = CGSizeMake(self.bounds.size.width, scrollView.contentSize.height);
            
            //そして、画面の中央にコンテンツを移動
            [UIView animateWithDuration:0.3f animations:^{
                CGRect rect = imageView_.frame;
                CGRect newRect = rect;
                newRect.origin.x = self.frame.size.width / 2 - rect.size.width / 2;
                imageView_.frame = newRect;
            }];
        
        } else {
            
            //コンテンツ幅が足りているときはコンテンツの始点を(0,0)に
            CGRect rect = imageView_.frame;
            CGRect newRect = rect;
            
            newRect.origin.x = 0;
            newRect.origin.y = 0;
            
            imageView_.frame = newRect;
        }
    }
}

- (void)setImage:(UIImage *)image
{
    [imageView_ removeFromSuperview];
    [imageView_ release];
    imageView_ = [[UIImageView alloc] initWithImage:image];
    [image_ release];
    image_ = [image retain];
    
    self.delegate = self;    
    [self addSubview:imageView_];
    //self.contentSize = imageView_.bounds.size;
    
    //最小サイズだけはUIScrollViewに任せておくとめんどくさいのでこちらで制御する
    //あり得ない小ささを指定して、事実上無視
    self.minimumZoomScale = 0.0001f;
    self.maximumZoomScale = 10000.0f;//後で決めるけどとりあえず直近で拡大する必要があり
    
    //イメージを中央にそろえる
    [self moveToCenter:imageView_ animated:NO];
    
    //fitする倍率を保存しておく
    //fitZoomScale = self.zoomScale;
    //moveToCenter:animated:内部へ移動。理由はそちらへ

    //最小倍率の決定
    minZoomScale = MIN(
                        (self.bounds.size.height / imageView_.bounds.size.height),
                        (self.bounds.size.width / imageView_.bounds.size.width)
                       );
    
    
    //最大倍率の決定
    maxZoomScale = fitZoomScale * 2.0f;
    self.maximumZoomScale = maxZoomScale;
}

- (void)delay
{

}

- (void)dealloc
{
    [imageView_ release];
    [image_ release];
    [super dealloc];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView_;
}

@end