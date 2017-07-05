//
//  CreatedByXIBViewController.m
//  RSCarouselViewDemo
//
//  Created by WhatsXie on 2017/7/5.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import "CreatedByXIBViewController.h"
#import "RSCarouselView.h"

@interface CreatedByXIBViewController ()
@property (weak, nonatomic) IBOutlet RSCarouselView *carouselByXIB;

@end

@implementation CreatedByXIBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *arr = @[@"http://og1yl0w9z.bkt.clouddn.com/17-7-5/30634366.jpg", //网络图片
                     [UIImage imageNamed:@"page01.png"],                      //本地图片，传image，不能传名称
                     @"http://og1yl0w9z.bkt.clouddn.com/17-7-5/45299326.jpg", //网络gif图片
                     gifImageNamed(@"pageGif01.gif")                          //本地gif使用gifImageNamed(name)函数创建
                     ];
    
    [self setupCarouselByXIBWithArray:arr];
    
}
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
