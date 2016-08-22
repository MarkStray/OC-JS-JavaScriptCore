//
//  ViewController.m
//  OC与JS交互之JavaScriptCore
//
//  Created by user on 16/8/18.
//  Copyright © 2016年 rrcc. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化webView
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
    
    //初始化JSContext
    self.jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常捕获信息：%@", exceptionValue);
    };
    
    __block typeof(self) weakSelf = self;
    //JS调用OC方法列表
    self.jsContext[@"showMobile"] = ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showMsg:@"我是下面的小红 手机号是:18870707070"];
        });
    };
    
    self.jsContext[@"showName"] = ^ (NSString *name) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *info = [NSString stringWithFormat:@"你好 %@, 很高兴见到你",name];
            [weakSelf showMsg:info];
        });
    };
    
    void (^_showSendMsg) (NSString *num, NSString *msg) = ^ (NSString *num, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *info = [NSString stringWithFormat:@"这是我的手机号: %@, %@ !!",num,msg];
            [self showMsg:info];
        });
    };
    
    [self.jsContext setObject:_showSendMsg forKeyedSubscript:@"showSendMsg"];
}

- (void)showMsg:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

//OC调用JS方法列表
- (IBAction)btnClick:(UIButton *)sender {
    if (sender.tag == 123) {
        //使用jsContext
        [self.jsContext evaluateScript:@"alertMobile()"];
    }
    
    if (sender.tag == 234) {
        //使用webView
        [self.webView stringByEvaluatingJavaScriptFromString:@"alertName('小红')"];
    }
    
    if (sender.tag == 345) {
        //使用jsValue
        JSValue *jsValue = [self.jsContext objectForKeyedSubscript:@"alertSendMsg"];
        [jsValue callWithArguments:@[@"18870707070",@"周末爬山真是件愉快的事情"]];
    }
    
}

@end
