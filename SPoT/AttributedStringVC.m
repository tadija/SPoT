//
//  AttributedStringVC.m
//  SPoT
//
//  Created by Marko Tadić on 23.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "AttributedStringVC.h"

@interface AttributedStringVC ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation AttributedStringVC

- (void)setText:(NSAttributedString *)text
{
    _text = text;
    self.textView.attributedText = text;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.attributedText = self.text;
}

@end
