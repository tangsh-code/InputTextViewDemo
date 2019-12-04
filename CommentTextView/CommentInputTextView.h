//
//  CommentInputTextView.h
//  CommentView
//
//  Created by mac on 2019/12/3.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIMircro.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentInputTextView : UIView

//------ 发送文本 -----//
@property (nonatomic,copy) void (^EndTextViewBlock)(NSString *text);
//------  设置占位符 ------//
- (void)setPlaceholderText:(NSString *)text;

- (void)show;

@end

NS_ASSUME_NONNULL_END
