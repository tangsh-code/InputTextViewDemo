//
//  CommentInputTextView.m
//  CommentView
//
//  Created by mac on 2019/12/3.
//  Copyright © 2019 mac. All rights reserved.
//

#import "CommentInputTextView.h"

#define UIColorRGB(x,y,z) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1.0]
#define MaxTextViewHeight 72 //限制文字输入的高度

static const CGFloat InputViewHeight = 49;
static const CGFloat LeftDistance = 16;
static const CGFloat TopDistance = 8;
static const CGFloat ButtonWidth = 60;
static const CGFloat ButtonHeight = 32;

@interface CommentInputTextView () <UITextViewDelegate, UIScrollViewDelegate>
{
    NSString * placeholderText;
    BOOL statusTextView;
    BOOL isAdd;//适配X以上地图界面
}
@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) UILabel * placeholderLabel;
@property (nonatomic, strong) UIButton * sendButton;

@end

@implementation CommentInputTextView

- (void)dealloc
{
    //移除键盘通知监听者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (UIView *)backgroundView
{
    if (nil == _backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT - Height_Bottom - InputViewHeight, kSCREEN_WIDTH, Height_Bottom + InputViewHeight)];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backgroundView];
    }
    
    return _backgroundView;
}

- (UITextView *)textView
{
    if (nil == _textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.delegate = self;
        _textView.layer.cornerRadius = 5;
        _textView.backgroundColor = UIColorRGB(245, 245, 245);
    }
    
    return _textView;
}

- (UILabel *)placeholderLabel
{
    if (nil == _placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.frame = CGRectMake(21, 15, 200, 20);
        _placeholderLabel.textColor = UIColorRGB(153, 153, 153);
        _placeholderLabel.font = [UIFont systemFontOfSize:15];
        _placeholderLabel.textAlignment = NSTextAlignmentLeft;
        _placeholderLabel.text = placeholderText;
    }
    
    return _placeholderLabel;
}

- (UIButton *)sendButton
{
    if (nil == _sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setBackgroundColor:UIColorRGB(255, 86, 98)];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.layer.cornerRadius = ButtonHeight/2;
    }
    
    return _sendButton;
}

- (void)sendButtonAction:(UIButton *)sender
{
    [self.textView endEditing:YES];
    if (self.EndTextViewBlock) {
        self.EndTextViewBlock(self.textView.text);
    }
    //---- 发送成功之后清空 ------//
    self.textView.text = nil;
    self.placeholderLabel.text = placeholderText;
    [self dismiss];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"init");
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBgView];
        [self setupInputView];
        [self addKeyboardNotification];
    }
    
    return self;
}

- (void)tapGestureAction
{
    [self dismiss];
}

- (void)setupBgView
{
    UIView * bgView = [[UIView alloc] initWithFrame:self.bounds];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    [bgView addGestureRecognizer:tap];
    [self addSubview:bgView];
}

- (void)setupInputView
{
    CGFloat dis = LeftDistance*2 + ButtonWidth + TopDistance;
    self.textView.frame = CGRectMake(LeftDistance, TopDistance, CGRectGetWidth(self.backgroundView.frame) - dis, CGRectGetHeight(self.backgroundView.frame) - TopDistance*2 - Height_Bottom);
    [self.backgroundView addSubview:_textView];

    placeholderText = @"请输入";
    [self.backgroundView addSubview:self.placeholderLabel];
    
    self.sendButton.frame = CGRectMake(CGRectGetWidth(self.backgroundView.frame) - ButtonWidth - LeftDistance, CGRectGetHeight(self.backgroundView.frame) - (TopDistance + ButtonHeight + Height_Bottom), ButtonWidth, ButtonHeight);
   [self.backgroundView addSubview:self.sendButton];
}

- (void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark ----
- (void)setPlaceholderText:(NSString *)text{
    placeholderText = text;
    self.placeholderLabel.text = placeholderText;
}

- (void)show
{
    [self.textView becomeFirstResponder];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)dismiss
{
    [self.textView resignFirstResponder];
    [self removeFromSuperview];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度和动态时间
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];//获取键盘弹出动画时间值
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    CGFloat height = keyboardRect.size.height;
    CGRect rect;
    if (self.textView.text.length == 0) {
        rect = CGRectMake(0, kSCREEN_HEIGHT - InputViewHeight - height, kSCREEN_WIDTH, InputViewHeight);
    } else {
        CGFloat bHeight = self.backgroundView.frame.size.height;
        if (isAdd) {
            bHeight -= Height_Bottom;
            isAdd = NO;
        }
        rect = CGRectMake(0, kSCREEN_HEIGHT - bHeight - height, kSCREEN_WIDTH, bHeight);
    }
    [UIView animateWithDuration:animationDuration animations:^{
        self.backgroundView.frame = rect;
    }];
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    //获取键盘的高度和动态时间
    NSDictionary *userInfo = [aNotification userInfo];
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];//获取键盘弹出动画时间值
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    CGRect rect;
    if (self.textView.text.length == 0) {
        rect = CGRectMake(0, CGRectGetHeight(self.frame) - Height_Bottom - InputViewHeight, kSCREEN_WIDTH, InputViewHeight + Height_Bottom);
    } else {
        CGFloat height = self.backgroundView.frame.size.height + Height_Bottom;
        isAdd = YES;
        rect = CGRectMake(0, CGRectGetHeight(self.frame) - height, kSCREEN_WIDTH, height);
    }
    [UIView animateWithDuration:animationDuration animations:^{
        self.backgroundView.frame = rect;
    }];
}

#pragma mark --- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    // 设置占位符
    if (textView.text.length == 0) {
        self.placeholderLabel.text = placeholderText;
    } else {
        self.placeholderLabel.text = @"";
    }
    
    //---- 计算高度 ---- //
    CGFloat dis = LeftDistance*2 + ButtonWidth + TopDistance;
    CGSize size = CGSizeMake(kSCREEN_WIDTH - dis - 10, CGFLOAT_MAX);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName, nil];
    CGFloat curheight = [textView.text boundingRectWithSize:size
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:dic
                                                    context:nil].size.height;
    CGFloat y = CGRectGetMaxY(self.backgroundView.frame);
    if (curheight < 17.9004) {
        statusTextView = NO;
        self.backgroundView.frame = CGRectMake(0, y - InputViewHeight, kSCREEN_WIDTH, InputViewHeight);
        [self resetControlFrame];
    } else if (curheight < MaxTextViewHeight){
        statusTextView = NO;
        self.backgroundView.frame = CGRectMake(0, y - textView.contentSize.height - TopDistance*2, kSCREEN_WIDTH, textView.contentSize.height + TopDistance*2);
        [self resetControlFrame];
    } else {
        statusTextView = YES;
    }
}

// 重置控件布局
- (void)resetControlFrame
{
    // 输入框
    CGRect textFrame = self.textView.frame;
    textFrame.size.height = CGRectGetHeight(self.backgroundView.frame) - TopDistance*2;
    self.textView.frame = textFrame;
    // 按钮
    CGRect buttonFrame = self.sendButton.frame;
    buttonFrame.origin.y = CGRectGetHeight(self.backgroundView.frame) - TopDistance - ButtonHeight;
    self.sendButton.frame = buttonFrame;
}

#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (statusTextView == NO) {
        scrollView.contentOffset = CGPointMake(0, 0);
    } else {
        
    }
}

@end
