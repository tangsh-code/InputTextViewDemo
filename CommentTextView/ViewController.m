//
//  ViewController.m
//  CommentTextView
//
//  Created by mac on 2019/12/3.
//  Copyright © 2019 mac. All rights reserved.
//

#import "ViewController.h"
#import "CommentInputTextView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)buttonAction:(id)sender {
    CommentInputTextView * commentInputTextView = [[CommentInputTextView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
    [commentInputTextView setPlaceholderText:@"回复美女"];
    commentInputTextView.EndTextViewBlock = ^(NSString * _Nonnull text) {
        NSLog(@"text === %@", text);
    };
    [commentInputTextView show];
}

@end
