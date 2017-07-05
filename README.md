# RSCarouselViewDemo

![](https://img.shields.io/badge/platform-iOS-red.svg) ![](https://img.shields.io/badge/language-Objective--C-orange.svg) ![](https://img.shields.io/badge/download-8.9MB-brightgreen.svg
) ![](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg) 

## Introduction 导语
在不少项目中，都会有图片轮播这个功能，现在网上关于图片轮播的框架层出不穷，千奇百怪，笔者根据自己的思路，用两个imageView也实现了图片轮播。

| 表类型 | 1.列表页  | 2.XIB创建  | 3.纯代码创建                               |
| --------------------------- |:---------------------------:|:----------------------------:|:----------------------------:|:----------------------------:|
| 截图 | ![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/40982862.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/53634923.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/17-7-5/60384124.jpg) | 
| 文件名 | 1.Main.storyboard  2.CreatedByXIBViewController  3.CreatedByCodeViewController | 1.Main.storyboard 2.CreatedByXIBViewController  3.CreatedByCodeViewController | 1.Main.storyboard  2.CreatedByXIBViewController  3.CreatedByCodeViewController | 
| 描述 | 通过 storyboard 搭建基本框架 | 通过XIB方式加载视图 | 通过纯代码方式加载视图 | 

|Tables         | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

## Advantage 框架的优势
1.文件少，代码简洁
2.不依赖任何其他第三方库
3.同时支持本地图片/Gif及网络图片/Gif
4.自带图片下载与缓存
5.具备较高自定义性

## Usage 实际使用
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

## 轮播实现步骤
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

使用简单、效率高效、进程安全~~~如果你有更好的建议,希望不吝赐教!
### 你的star是我持续更新的动力!
===

## 联系方式:
* WeChat : WhatsXie
* Email : ReverseScale@iCloud.com
* QQ : 1129998515

