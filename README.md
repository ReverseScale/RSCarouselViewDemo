# RSCarouselViewDemo

![](https://img.shields.io/badge/platform-iOS-red.svg) ![](https://img.shields.io/badge/language-Objective--C-orange.svg) ![](https://img.shields.io/badge/download-8.9MB-brightgreen.svg
) ![](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg) 

[EN](#Requirements) | [中文](#中文说明)

## 🎨 What does the test UI look like?
In many projects, there will be a picture carousel function. Nowadays, the online carousel framework is endless and strange. According to my own ideas, the image rotation is implemented using two imageViews.

|1.List page | 2.XIB creation | 3.Pure code creation |
| ------------- | ------------- | ------------- |
| ![](http://og1yl0w9z.bkt.clouddn.com/18-3-16/40729058.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-16/54066601.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-16/18391498.jpg) |
| Building a basic framework via storyboard | Loading views via XIB | Loading views via pure code |

## 🚀 Advantage 
* 1. Less files, simple code
* 2. Does not rely on any other third party library
* 3. Supports local images/Gifs and network images/Gifs at the same time
* 4. comes with picture download and cache
* 5. Highly customizable

## 🤖 Requirements 
* iOS 7+
* Xcode 8+

## 🛠 Usage
### Created by XIB Created by XIB
```
- (void)setupCarouselByXIBWithArray:(NSArray *)arr {
    /**
     *  Rotation control created by storyboard
     */
    self.carouselByXIB.imageArray = arr;
    
    // Set the color of the paging control indicator
    [self.carouselByXIB setPageColor:[UIColor whiteColor] andCurrentPageColor:[UIColor grayColor]];
    // Set the way to switch pictures
    self.carouselByXIB.changeMode = ChangeModeFade;
    // Sets the position of the paging control, the default is PositionBottomCenter
    self.carouselByXIB.pagePosition = PositionBottomRight;
    // Block image click event with block
    self.carouselByXIB.imageClickBlock = ^(NSInteger index){
        NSLog(@"In the XIB creation state, click on the %ld image", index);
    };
    self.carouselByXIB.time = 3;
}
- (IBAction)startAction:(id)sender {
    [self.carouselByXIB startTimer];
}
- (IBAction)stopAction:(id)sender {
    [self.carouselByXIB stopTimer];
}
```

### Created by Code Created by Pure Code
```
- (void)setupCarouselByCodeWithArray:(NSArray *)arr describeArray:(NSArray *)describeArray {
    /**
     *  Created by code
     */
    self.carouselView = [[RSCarouselView alloc] initWithFrame:CGRectMake(16, 129, [UIScreen mainScreen].bounds.size.width - 32, 145)];
    
    // Setting a placeholder image must be set before setting the image array. If not, the default placeholder image will be set.
    self.carouselView.placeholderImage = [UIImage imageNamed:@"placeholderImage.jpg"];
    
    // Set up an image array and image description text
    self.carouselView.imageArray = arr;
    self.carouselView.describeArray = describeArray;
    
    // Deal with image clicks with a proxy
    self.carouselView.delegate = self;
    
    // Set the dwell time of each picture, the default value is 5s, minimum is 2s
    self.carouselView.time = 2;
    
    // Set the paging control picture, if not set, the system default
    [self.carouselView setPageImage:[UIImage imageNamed:@"other"] andCurrentPageImage:[UIImage imageNamed:@"current"]];
    
    // Sets the position of the paging control, the default is PositionBottomCenter
    self.carouselView.pagePosition = PositionBottomCenter;
    
    /**
     * Modify the appearance of the picture description control, no need to modify the pass nil
      *
      * Parameter 1 font color, default is white
      * Parameter two fonts, the default is 13 fonts
      * Parameter three background color, the default is black translucent
     */
    UIColor *bgColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    UIFont *font = [UIFont systemFontOfSize:15];
    UIColor *textColor = [UIColor grayColor];
    [self.carouselView setDescribeTextColor:textColor font:font bgColor:bgColor];
    
    [self.view addSubview:_carouselView];
}
```

## Theory Carousel Implementation Steps
### Hierarchy
The bottom is a UIView, there is a UIScrollView and UIPageControl, there are two UIImageView scrollView, imageView width = high scrollview height = view width height
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/42630920.jpg)
Assume that the width of the carousel control is x, and we set the contentSize.width of the scrollview to 3x, and let the horizontal offset of the scrollview be x.
```
scrollView.contentSize = CGSizeMake(3x, y);
scrollView.contentOffset = CGPointMake(x, 0);
```
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/47687911.jpg)
Add imageView to center of scrollview content view
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/67719806.jpg)
Next use the proxy method scrollViewDidScroll to listen for the ScrollView scrolling, and define an enumeration variable to record the scroll direction.
```
typedef enum{
  DirecNone,
  DirecLeft,
  DirecRight
} Direction;
@property (nonatomic, assign) Direction direction;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  self.direction = scrollView.contentOffset.x >x? DirecLeft : DirecRight;
}
```
Use KVO to listen for changes in the value of the direction property.
```
[self addObserver:self forKeyPath:@"direction" options:NSKeyValueObservingOptionNew context:nil];
```
To determine the direction of the scroll, when the offset is greater than x, said to the left, then add the otherImageView on the right, the offset is less than x, said to the right, then add the otherImageView on the left.

![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/15531601.jpg)

```
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   // self.currIndex represents the index of the currently displayed image, self.nextIndex represents the index of the image to be displayed
   // _images is an array of pictures
  if(change[NSKeyValueChangeNewKey] == change[NSKeyValueChangeOldKey]) return;
  if ([change[NSKeyValueChangeNewKey] intValue] == DirecRight) {
    self.otherImageView.frame = CGRectMake(0, 0, self.width, self.height);
    self.nextIndex = self.currIndex - 1;
    if (self.nextIndex < 0) self.nextIndex = _images.count – 1;
  } else if ([change[NSKeyValueChangeNewKey] intValue] == DirecLeft){
    self.otherImageView.frame = CGRectMake(CGRectGetMaxX(_currImageView.frame), 0, self.width, self.height);
    self.nextIndex = (self.currIndex + 1) % _images.count;
  }
  self.otherImageView.image = self.images[self.nextIndex];
}
```
The end of the scroll is monitored by the scrollViewDidEndDecelerating proxy method.
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/9374679.jpg)
At this point, the scrollview's offset is 0 or 2x. We again set the scrollview's offset to x by the code, and modify the currImageView's image to the image of the otherImageView.
```
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self pauseScroll];
}

- (void)pauseScroll {
  self.direction = DirecNone;
  // Clear the scroll direction
  //Judged whether it eventually rolled to the right or left
  int index = self.scrollView.contentOffset.x / x;
  if (index == 1) return; // Equal to 1 means no scrolling at the end, return no action
  self.currIndex = self.nextIndex;// The current picture index changes
  self.pageControl.currentPage = self.currIndex;
  self.currImageView.frame = CGRectMake(x, 0, x, y);
  self.currImageView.image = self.otherImageView.image;
  self.scrollView.contentOffset = CGPointMake(x, 0);
}
```
So we still see currImageView, but it shows the next picture, as shown in the figure, it becomes the initial effect.
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/75396773.jpg)

### Automatic scrolling
The carousel function is implemented, and then add a timer to let it scroll automatically, which is quite simple.
```
- (void)startTimer {
   // If there is only one picture, it will return directly without opening the timer
   if (_images.count <= 1) return;
   // If the timer is on, stop and start again
   if (self.timer) [self stopTimer];
   self.timer = [NSTimer timerWithTimeInterval:self.time target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
   [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)nextPage {
    // Animation can change the scrollview's offset to achieve automatic scrolling
  [self.scrollView setContentOffset:CGPointMake(self.width * 2, 0) animated:YES];
}
```
> The setContentOffset:animated: method does not call the scrollViewDidEndDecelerating method of the scrollview after it is executed, but it calls the scrollViewDidEndScrollingAnimation method, so we will call pauseScroll in that method.
```
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  [self pauseScroll];
}
```
### Stop auto scrolling when dragging
When we manually drag the picture, we need to stop the automatic scrolling. At this time, we only need to disable the timer. When the drag is stopped, restart the timer.
```
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self.timer invalidate];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
  [self startTimer];
}
```
### Loading pictures
In actual development, we rarely rotate local pictures. Most of them are obtained by the server. There may be both local pictures and network pictures. How do we load it?
Defining 4 attributes
* NSArray imageArray: exposed in the .h file, the outside world will be loaded to the picture or path array assigned to the property
* NSMutableArray images: an array of images
* NSMutableDictionary imageDic: dictionary used to cache images, key is URL
* NSMutableDictionary operationDic: used to save the download operation dictionary, key for the URL
Determine whether the incoming image or path is from the outside world. If it is a picture, add it directly to the picture array. If it is a path, add a placeholder picture first, and then download the picture according to the path.
```
_images = [NSMutableArray array];
for (int i = 0; i < imageArray.count; i++) {
    if ([imageArray[i] isKindOfClass:[UIImage class]]) {
      [_images addObject:imageArray[i]];// If it is a picture, add it directly to the images
    } else if ([imageArray[i] isKindOfClass:[NSString class]]){
      [_images addObject:[UIImage imageNamed:@"placeholder"]];// If it is a path, add a placeholder image to the images
      [self downloadImages:i];  // Download network picture
    }
  }
```
Download the picture, first take it from the cache, if there is, replace the previous placeholder picture, if not, go to the sandbox, if there is, replace the placeholder picture and add it to the cache, if not, enable asynchronous thread download.
```
- (void)downloadImages:(int)index {
  NSString *key = _imageArray[index];
  // Take a picture from the dictionary cache
  UIImage *image = [self.imageDic objectForKey:key];
  if (image) {
    _images[index] = image;// If the picture exists, replace the previous placeholder picture directly
  }else{
    // There is no picture from the sandbox in the dictionary
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [cache stringByAppendingPathComponent:[key lastPathComponent]];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
      // In the sandbox, replace the placeholder image and add it to the dictionary cache
      image = [UIImage imageWithData:data];
      _images[index] = image;
      [self.imageDic setObject:image forKey:key];
    }else{
       // No dictionary sandbox, download picture
      NSBlockOperation *download = [self.operationDic objectForKey:key];// See if the download operation exists
      if (!download) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        // Create a download operation
        download = [NSBlockOperation blockOperationWithBlock:^{
          NSURL *url = [NSURL URLWithString:key];
          NSData *data = [NSData dataWithContentsOfURL:url];
           if (data) {
           // After the download is complete, replace the placeholder image, save it in the dictionary and write it to the sandbox, and remove the download from the dictionary.
            UIImage *image = [UIImage imageWithData:data];
            [self.imageDic setObject:image forKey:key];
            self.images[index] = image;
            if (_images.count == 1) [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            [data writeToFile:path atomically:YES];
            [self.operationDic removeObjectForKey:key]; 
            }
        }];
        [queue addOperation:download];
        [self.operationDic setObject:download forKey:key];
      }
    }
  }
}
```
### Listen for image clicks
When the picture is clicked, we often need to perform some operations, so we need to monitor the click of the picture, the idea is as follows.

1. Define a block property exposed to the outside void (^imageClickBlock) (NSInteger index)

2. Set currImageView's userInteractionEnabled to YES

3. Add a click gesture to currImageView

4. Call the block in the gesture method and pass in the image index


## ⚖ Protocol
```
MIT License

Copyright (c) 2017 ReverseScale

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

##  😬 Contact:
* WeChat : WhatsXie
* Email : ReverseScale@iCloud.com
* Blog : https://reversescale.github.io

---
# 中文说明

## 🎨 测试 UI 什么样子？
在不少项目中，都会有图片轮播这个功能，现在网上关于图片轮播的框架层出不穷，千奇百怪，笔者根据自己的思路，用两个imageView也实现了图片轮播。

|1.列表页 |2.XIB创建 |3.纯代码创建 |
| ------------- | ------------- | ------------- |
| ![](http://og1yl0w9z.bkt.clouddn.com/18-3-16/40729058.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-16/54066601.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-16/18391498.jpg) |
| 通过 storyboard 搭建基本框架 | 通过XIB方式加载视图 | 通过纯代码方式加载视图 |

##  🚀 框架的优势
* 1.文件少，代码简洁
* 2.不依赖任何其他第三方库
* 3.同时支持本地图片/Gif及网络图片/Gif
* 4.自带图片下载与缓存
* 5.具备较高自定义性

##  🤖 要求
* iOS 7+
* Xcode 8+

##  🛠 安装
### Created by XIB 通过XIB创建
```
- (void)setupCarouselByXIBWithArray:(NSArray *)arr {
    /**
     *  通过storyboard创建的轮播控件
     */
    self.carouselByXIB.imageArray = arr;
    
    //设置分页控件指示器的颜色
    [self.carouselByXIB setPageColor:[UIColor whiteColor] andCurrentPageColor:[UIColor grayColor]];
    //设置图片切换的方式
    self.carouselByXIB.changeMode = ChangeModeFade;
    //设置分页控件的位置，默认为PositionBottomCenter
    self.carouselByXIB.pagePosition = PositionBottomRight;
    //用block处理图片点击事件
    self.carouselByXIB.imageClickBlock = ^(NSInteger index){
        NSLog(@"在XIB创建状态下，点击了第%ld张图片", index);
    };
    self.carouselByXIB.time = 3;
}
- (IBAction)startAction:(id)sender {
    [self.carouselByXIB startTimer];
}
- (IBAction)stopAction:(id)sender {
    [self.carouselByXIB stopTimer];
}
```

### Created by Code 通过纯代码创建
```
- (void)setupCarouselByCodeWithArray:(NSArray *)arr describeArray:(NSArray *)describeArray {
    /**
     *  通过代码创建
     */
    self.carouselView = [[RSCarouselView alloc] initWithFrame:CGRectMake(16, 129, [UIScreen mainScreen].bounds.size.width - 32, 145)];
    
    //设置占位图片,须在设置图片数组之前设置,不设置则为默认占位图
    self.carouselView.placeholderImage = [UIImage imageNamed:@"placeholderImage.jpg"];
    
    //设置图片数组及图片描述文字
    self.carouselView.imageArray = arr;
    self.carouselView.describeArray = describeArray;
    
    //用代理处理图片点击
    self.carouselView.delegate = self;
    
    //设置每张图片的停留时间，默认值为5s，最少为2s
    self.carouselView.time = 2;
    
    //设置分页控件的图片,不设置则为系统默认
    [self.carouselView setPageImage:[UIImage imageNamed:@"other"] andCurrentPageImage:[UIImage imageNamed:@"current"]];
    
    //设置分页控件的位置，默认为PositionBottomCenter
    self.carouselView.pagePosition = PositionBottomCenter;
    
    /**
     *  修改图片描述控件的外观，不需要修改的传nil
     *
     *  参数一 字体颜色，默认为白色
     *  参数二 字体，默认为13号字体
     *  参数三 背景颜色，默认为黑色半透明
     */
    UIColor *bgColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    UIFont *font = [UIFont systemFontOfSize:15];
    UIColor *textColor = [UIColor grayColor];
    [self.carouselView setDescribeTextColor:textColor font:font bgColor:bgColor];
    
    [self.view addSubview:_carouselView];
}
```

## Theory 轮播实现步骤
### 层级结构
最底层是一个UIView，上面有一个UIScrollView以及UIPageControl，scrollView上有两个UIImageView，imageView宽高 = scrollview宽高 = view宽高
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/42630920.jpg)
假设轮播控件的宽度为x高度为y，我们设置scrollview的contentSize.width为3x，并让scrollview的水平偏移量为x，既显示最中间内容
```
scrollView.contentSize = CGSizeMake(3x, y);
scrollView.contentOffset = CGPointMake(x, 0);
```
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/47687911.jpg)
将imageView添加到scrollview内容视图的中间位置
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/67719806.jpg)
接下来使用代理方法scrollViewDidScroll来监听scrollview的滚动，定义一个枚举变量来记录滚动的方向
```
typedef enum{
  DirecNone,
  DirecLeft,
  DirecRight
} Direction;
@property (nonatomic, assign) Direction direction;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  self.direction = scrollView.contentOffset.x >x? DirecLeft : DirecRight;
}
```
使用KVO来监听direction属性值的改变
```
[self addObserver:self forKeyPath:@"direction" options:NSKeyValueObservingOptionNew context:nil];
```
判断滚动的方向，当偏移量大于x，表示左移，则将otherImageView加在右边，偏移量小于x，表示右移，则将otherImageView加在左边

![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/15531601.jpg)

```
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   //self.currIndex表示当前显示图片的索引，self.nextIndex表示将要显示图片的索引
  //_images为图片数组
  if(change[NSKeyValueChangeNewKey] == change[NSKeyValueChangeOldKey]) return;
  if ([change[NSKeyValueChangeNewKey] intValue] == DirecRight) {
    self.otherImageView.frame = CGRectMake(0, 0, self.width, self.height);
    self.nextIndex = self.currIndex - 1;
    if (self.nextIndex < 0) self.nextIndex = _images.count – 1;
  } else if ([change[NSKeyValueChangeNewKey] intValue] == DirecLeft){
    self.otherImageView.frame = CGRectMake(CGRectGetMaxX(_currImageView.frame), 0, self.width, self.height);
    self.nextIndex = (self.currIndex + 1) % _images.count;
  }
  self.otherImageView.image = self.images[self.nextIndex];
}
```
通过代理方法scrollViewDidEndDecelerating来监听滚动结束，结束后，会变成以下两种情况
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/9374679.jpg)
此时，scrollview的偏移量为0或者2x，我们通过代码再次将scrollview的偏移量设置为x，并将currImageView的图片修改为otherImageView的图片
```
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self pauseScroll];
}

- (void)pauseScroll {
  self.direction = DirecNone;//清空滚动方向
    //判断最终是滚到了右边还是左边
  int index = self.scrollView.contentOffset.x / x;
  if (index == 1) return; //等于1表示最后没有滚动，返回不做任何操作
  self.currIndex = self.nextIndex;//当前图片索引改变
  self.pageControl.currentPage = self.currIndex;
  self.currImageView.frame = CGRectMake(x, 0, x, y);
  self.currImageView.image = self.otherImageView.image;
  self.scrollView.contentOffset = CGPointMake(x, 0);
}
```
那么我们看到的还是currImageView，只不过展示的是下一张图片，如图，又变成了最初的效果
![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/75396773.jpg)

### 自动滚动
轮播的功能实现了，接下来添加定时器让它自动滚动，相当简单
```
- (void)startTimer {
   //如果只有一张图片，则直接返回，不开启定时器
   if (_images.count <= 1) return;
   //如果定时器已开启，先停止再重新开启
   if (self.timer) [self stopTimer];
   self.timer = [NSTimer timerWithTimeInterval:self.time target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
   [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)nextPage {
    //动画改变scrollview的偏移量就可以实现自动滚动
  [self.scrollView setContentOffset:CGPointMake(self.width * 2, 0) animated:YES];
}
```
> setContentOffset:animated:方法执行完毕后不会调用scrollview的scrollViewDidEndDecelerating方法，但是会调用scrollViewDidEndScrollingAnimation方法，因此我们要在该方法中调用pauseScroll
```
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  [self pauseScroll];
}
```
### 拖拽时停止自动滚动
当我们手动拖拽图片时，需要停止自动滚动，此时我们只需要让定时器失效就行了，当停止拖拽时，重新启动定时器
```
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self.timer invalidate];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
  [self startTimer];
}
```
### 加载图片
实际开发中，我们很少会轮播本地图片，大部分都是服务器获取的，也有可能既有本地图片，也有网络图片，那要如何来加载呢？
定义4个属性
* NSArray imageArray：暴露在.h文件中，外界将要加载的图片或路径数组赋值给该属性
* NSMutableArray images：用来存放图片的数组
* NSMutableDictionary imageDic：用来缓存图片的字典，key为URL
* NSMutableDictionary operationDic：用来保存下载操作的字典，key为URL
判断外界传入的是图片还是路径，如果是图片，直接加入图片数组中，如果是路径，先添加一个占位图片，然后根据路径去下载图片
```
_images = [NSMutableArray array];
for (int i = 0; i < imageArray.count; i++) {
    if ([imageArray[i] isKindOfClass:[UIImage class]]) {
      [_images addObject:imageArray[i]];//如果是图片，直接添加到images中
    } else if ([imageArray[i] isKindOfClass:[NSString class]]){
      [_images addObject:[UIImage imageNamed:@"placeholder"]];//如果是路径，添加一个占位图片到images中
      [self downloadImages:i];  //下载网络图片
    }
  }
```
下载图片，先从缓存中取，如果有，则替换之前的占位图片，如果没有，去沙盒中取，如果有，替换占位图片，并添加到缓存中，如果没有，开启异步线程下载
```
- (void)downloadImages:(int)index {
  NSString *key = _imageArray[index];
  //从字典缓存中取图片
  UIImage *image = [self.imageDic objectForKey:key];
  if (image) {
    _images[index] = image;//如果图片存在，则直接替换之前的占位图片
  }else{
    //字典中没有从沙盒中取图片
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [cache stringByAppendingPathComponent:[key lastPathComponent]];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
             //沙盒中有，替换占位图片，并加入字典缓存中
      image = [UIImage imageWithData:data];
      _images[index] = image;
      [self.imageDic setObject:image forKey:key];
    }else{
       //字典沙盒都没有，下载图片
      NSBlockOperation *download = [self.operationDic objectForKey:key];//查看下载操作是否存在
      if (!download) {//不存在
        //创建一个队列，默认为并发队列
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        //创建一个下载操作
        download = [NSBlockOperation blockOperationWithBlock:^{
          NSURL *url = [NSURL URLWithString:key];
          NSData *data = [NSData dataWithContentsOfURL:url];
           if (data) {
                        //下载完成后，替换占位图片，存入字典并写入沙盒，将下载操作从字典中移除掉
            UIImage *image = [UIImage imageWithData:data];
            [self.imageDic setObject:image forKey:key];
            self.images[index] = image;
                        //如果只有一张图片，需要在主线程主动去修改currImageView的值
            if (_images.count == 1) [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            [data writeToFile:path atomically:YES];
            [self.operationDic removeObjectForKey:key]; 
            }
        }];
        [queue addOperation:download];
        [self.operationDic setObject:download forKey:key];//将下载操作加入字典
      }
    }
  }
}
```
### 监听图片点击
当图片被点击的时候，我们往往需要执行某些操作，因此需要监听图片的点击，思路如下

1.定义一个block属性暴露给外界void(^imageClickBlock)(NSInteger index)

2.设置currImageView的userInteractionEnabled为YES

3.给currImageView添加一个点击的手势

4.在手势方法里调用block，并传入图片索引

## ⚖ 协议

```
MIT License

Copyright (c) 2017 ReverseScale

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


## 😬 联系方式:
* 微信 : WhatsXie
* 邮箱 : ReverseScale@iCloud.com
* 博客 : https://reversescale.github.io
