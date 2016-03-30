//
//  TFPhotoCaptionView.m
//  TFPhotoBrowser
//
//  Created by Melvin on 11/18/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "TFPhotoCaptionView.h"
#import "TFPhoto.h"
#import <pop/POP.h>

@interface TFPhotoCaptionView ()

@property (nonatomic ,strong) UIView *toolBarView;
@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UILabel *contentLabel;
@property (nonatomic ,weak)     id<TFPhoto> photo;
@property (nonatomic) CGSize totalTextSize;
@property (nonatomic) TFPanGestureRecognizerDirection direction;
@property (nonatomic) CGRect initialFirstViewFrame;
@property (nonatomic) CGRect viewFrame;
@property (nonatomic) CGRect contentFrame;

@property (nonatomic) CGRect originalViewFrame;
@property (nonatomic) CGRect originalContentFrame;



@end

const static CGFloat kTopBottomThreshold = 12;
const static CGFloat kLeftRightThreshold = 16;


@implementation TFPhotoCaptionView {
    
    //local touch location
    CGFloat _touchPositionInY;
    CGFloat _touchPositionInX;
    CGFloat _restrictTrueOffset;
}


- (id)initWithPhoto:(id<TFPhoto>)photo {
    self = [super initWithFrame:CGRectZero]; // Random initial frame
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _photo = photo;
        [self setupCaption];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handlePanAction:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}
- (id)initWithPhoto:(id<TFPhoto>)photo width:(CGFloat)width frame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(0, 0, width, 44)]; // Random initial frame
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _photo = photo;
        self.initialFirstViewFrame = frame;
        [self setupCaption];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handlePanAction:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}
- (void)setupCaption {
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    
    
    CGFloat contentTop = kTopBottomThreshold/2;
    _titleLabel.text = @"Melvin Young";
    
    if (_titleLabel.text.length) {
        contentTop = kTopBottomThreshold*1.5 + CGRectGetHeight(_titleLabel.frame);
    }
    
    //content size
    
    NSString *content = @"现在我们试试看中文显示的效果怎么样？我猜会很难看，中文字体太丑陋了，太粗旷了，完全没有美感啊。。。多加一些文字试试看现实的效果是不是👌，是不是能够显示完整的三行文字。";
    //    NSString *content = @"Baked Edds and Chorizo,breakfast of champions! It's hearty.full of protein and super energizing.";
    
    CGSize textSize = [content boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.bounds) - kLeftRightThreshold * 2, 60)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:_contentLabel.font}
                                            context:nil].size;
    _totalTextSize = [content boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.bounds) - kLeftRightThreshold * 2, 4000)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:_contentLabel.font}
                                           context:nil].size;
    _contentLabel.text = content;
    _contentFrame = _contentLabel.frame;
    _contentFrame.size = textSize;
    _contentFrame.origin.y = contentTop;
    _contentLabel.frame = _contentFrame;
    _restrictTrueOffset = self.initialFirstViewFrame.size.height - 180;
    
    
    _originalContentFrame = _contentLabel.frame;
    
}
- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = kTopBottomThreshold*2 + 30  + CGRectGetHeight(_contentLabel.frame);
    _viewFrame = self.frame;
    _viewFrame.size.height = height;
    _originalViewFrame = self.frame;
    return CGSizeMake(CGRectGetWidth(self.bounds), height);
}

- (void)setupCaptionToolBarView:(UIView *)toolBarView {
    
}


#pragma mark - Views

- (UIView *)toolBarView {
    if (!_toolBarView) {
        
    }
    return _toolBarView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftRightThreshold, kTopBottomThreshold,
                                                                CGRectGetWidth(self.bounds) - kLeftRightThreshold * 2, 24)];
        _titleLabel.layer.borderWidth = 1;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor whiteColor];
        
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftRightThreshold, kTopBottomThreshold,
                                                                  CGRectGetWidth(self.bounds) - kLeftRightThreshold * 2, 60)];
        _contentLabel.layer.borderWidth = 1;
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.contentMode = UIViewContentModeLeft;
        
    }
    return _contentLabel;
}

#pragma mark - Private

- (void)growUpSelfView:(CGFloat)padding {
    _viewFrame = self.frame;
    _viewFrame.origin.y -= padding;
    _viewFrame.size.height +=padding;
    
    _contentFrame = _contentLabel.frame;
    _contentFrame.size.height +=padding;
    
    if (_contentFrame.size.height > _totalTextSize.height) {
        _contentFrame.size.height = _totalTextSize.height;
    }
    if (_viewFrame.size.height > self.initialFirstViewFrame.size.height) {
        _viewFrame.size.height = self.initialFirstViewFrame.size.height;
    }
    
    [UIView animateWithDuration:0.09
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.frame=_viewFrame;
                         _contentLabel.frame = _contentFrame;
                     }
                     completion:^(BOOL finished) {
                         [self growUpSelfView:10];
                     }];
}

- (void)handlePanAction:(UIPanGestureRecognizer *)recognizer {
    CGFloat y = [recognizer locationInView:self.superview].y;
    NSLog(@"handlePanAction y:%@",@(y));
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        _direction = TFPanGestureRecognizerDirectionUndefined;
        //storing direction
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        [self detectPanDirection:velocity];
        //Snag the Y position of the touch when panning begins
        _touchPositionInY = [recognizer locationInView:self].y;
        _touchPositionInX = [recognizer locationInView:self].x;
        if(_direction == TFPanGestureRecognizerDirectionDown) {
            
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged) {
        if(_direction == TFPanGestureRecognizerDirectionDown ||
           _direction == TFPanGestureRecognizerDirectionUp) {
            CGFloat trueOffset = y - _touchPositionInY;
            CGFloat xOffset = (y - _touchPositionInY)*0.35;
            
            [self adjustViewOnVerticalPan:trueOffset
                                  xOffset:xOffset
                               recognizer:recognizer];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded){
        
        if(_direction == TFPanGestureRecognizerDirectionDown ||
           _direction == TFPanGestureRecognizerDirectionUp) {
            
            if(recognizer.view.frame.origin.y<0) {
                [self expandViewOnPan];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
            }
            else if(recognizer.view.frame.origin.y>(self.initialFirstViewFrame.size.width/2))
            {
                
                [self minimizeViewOnPan];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
            }
            else if(recognizer.view.frame.origin.y<(self.initialFirstViewFrame.size.width/2))
            {
                [self expandViewOnPan];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
                
            }
        }
    }
}

-(void)detectPanDirection:(CGPoint )velocity {
    BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
    if (isVerticalGesture) {
        if (velocity.y > 0) {
            _direction = TFPanGestureRecognizerDirectionDown;
        } else {
            _direction = TFPanGestureRecognizerDirectionUp;
        }
    }
    else {
        if(velocity.x > 0) {
            _direction = TFPanGestureRecognizerDirectionRight;
        }
        else {
            _direction = TFPanGestureRecognizerDirectionLeft;
        }
    }
}


- (void)minimizeViewOnPan {
    //返回原始位置
    
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    positionAnimation.toValue = [NSValue valueWithCGRect:_originalContentFrame];
    [positionAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
    }];
    POPSpringAnimation *viewAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    viewAnimation.toValue = [NSValue valueWithCGRect:_originalViewFrame];
    [viewAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
    }];
    
    [self pop_addAnimation:viewAnimation forKey:@"viewAnimation"];
    [self.contentLabel pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    
    
}


- (void)expandViewOnPan {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         //调整页面空间frame
                     }
                     completion:^(BOOL finished) {
                     }];
}


- (void)adjustViewOnVerticalPan:(CGFloat)trueOffset xOffset:(CGFloat)xOffset recognizer:(UIPanGestureRecognizer *)recognizer {
    
    NSLog(@"trueOffset:%@ xOffset:%@",@(trueOffset),@(xOffset));
    _viewFrame.size.height = 400-xOffset*0.5;
    
    _viewFrame.origin.y    = trueOffset;
    
    _contentFrame = _contentLabel.frame;
    _contentFrame.size.height += 400-xOffset*0.5;
    
    if (_contentFrame.size.height > _totalTextSize.height) {
        _contentFrame.size.height = _totalTextSize.height;
    }
    
    [UIView animateWithDuration:0.05
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.frame=_viewFrame;
                         self.contentLabel.frame = _contentFrame;
                     }
                     completion:^(BOOL finished) {
                     }];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
}



#pragma mark - Delegates

@end
