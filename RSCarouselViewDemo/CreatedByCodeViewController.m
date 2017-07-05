
//
//  CreatedByCodeViewController.m
//  RSCarouselViewDemo
//
//  Created by WhatsXie on 2017/7/5.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import "CreatedByCodeViewController.h"
#import "RSCarouselView.h"

@interface CreatedByCodeViewController ()<RSCarouselViewDelegate>
@property (nonatomic, strong) RSCarouselView *carouselView;
@end

@implementation CreatedByCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *arr = @[@"http://og1yl0w9z.bkt.clouddn.com/17-7-5/30634366.jpg", //网络图片
                     [UIImage imageNamed:@"page01.png"],                      //本地图片，传image，不能传名称
                     @"http://og1yl0w9z.bkt.clouddn.com/17-7-5/45299326.jpg", //网络gif图片
                     gifImageNamed(@"pageGif01.gif")                          //本地gif使用gifImageNamed(name)函数创建
                     ];
    
    NSArray *describeArray = @[@"网络图片", @"本地图片", @"网络动态图", @"本地动态图"];
    
    [self setupCarouselByCodeWithArray:arr describeArray:describeArray];
}

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
#pragma mark XRCarouselViewDelegate
- (void)carouselView:(RSCarouselView *)carouselView clickImageAtIndex:(NSInteger)index {
    NSLog(@"在纯代码创建状态下，点击了第%ld张图片", index);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //清除缓存
    [RSCarouselView clearDiskCache];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
