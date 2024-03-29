//
// IQKeyboardManager.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IQKeyboardManager.h"
#import "IQUIView+Hierarchy.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "IQUIWindow+Hierarchy.h"
#import "IQNSArray+Sort.h"
#import "IQToolbar.h"
#import "IQBarButtonItem.h"
#import "IQKeyboardManagerConstantsInternal.h"

#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITableViewController.h>
#import <UIKit/UITableView.h>
#import <UIKit/UITouch.h>

NSInteger const kIQDoneButtonToolbarTag             =   -1002;
NSInteger const kIQPreviousNextButtonToolbarTag     =   -1005;

void _IQShowLog(NSString *logString);

@interface IQKeyboardManager()<UIGestureRecognizerDelegate>

//  Private helper methods
- (void)adjustFrame;

//  Private function to manipulate RootViewController's frame with animation.
- (void)setRootViewFrame:(CGRect)frame;

//  Keyboard Notification methods
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)keyboardDidHide:(NSNotification*)aNotification;

//  UITextField/UITextView Notification methods
- (void)textFieldViewDidBeginEditing:(NSNotification*)notification;
- (void)textFieldViewDidEndEditing:(NSNotification*)notification;
- (void)textFieldViewDidChange:(NSNotification*)notification;

//  Tap Recognizer
- (void)tapRecognized:(UITapGestureRecognizer*)gesture;

//  Next/Previous/Done methods
-(void)previousAction:(id)segmentedControl;
-(void)nextAction:(id)segmentedControl;
-(void)doneAction:(IQBarButtonItem*)barButton;

//  Adding Removing IQToolbar methods
- (void)addToolbarIfRequired;
- (void)removeToolbarIfRequired;

@end

@implementation IQKeyboardManager
{
	@package
    /*******************************************/

    /*! To save UITextField/UITextView object voa textField/textView notifications. */
    __weak UIView           *_textFieldView;
    
    /*! used with canAdjustTextView boolean. */
    __block CGRect           _textFieldViewIntialFrame;
    
    /*! To save rootViewController.view.frame. */
    CGRect                   _topViewBeginRect;
    
    /*! To save rootViewController */
    __weak  UIViewController *_rootViewController;
    
    /*******************************************/
    
    /*! Variable to save lastScrollView that was scrolled. */
    __weak UIScrollView     *_lastScrollView;
    
    /*! LastScrollView's initial contentInsets. */
    UIEdgeInsets             _startingContentInsets;
    
    /*! LastScrollView's initial contentOffset. */
    CGPoint                  _startingContentOffset;
    
    /*******************************************/
    
    /*! To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    NSNotification          *_kbShowNotification;
    
    /*! To save keyboard size. */
    CGSize                   _kbSize;
    
    /*! To save keyboard animation duration. */
    CGFloat                  _animationDuration;
    
    /*! To mimic the keyboard animation */
    NSInteger                _animationCurve;
    
    /*******************************************/

    /*! TapGesture to resign keyboard on view's touch. */
    UITapGestureRecognizer  *_tapGesture;

    /*******************************************/
    
    struct {
        /*! used with canAdjustTextView to detect a textFieldView frame is changes or not. (Bug ID: #92)*/
        unsigned int isTextFieldViewFrameChanged:1;

        /*! Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
        unsigned int isKeyboardShowing:1;

    } _keyboardManagerFlags;
}

//UIKeyboard handling
@synthesize enable                              =   _enable;
@synthesize keyboardDistanceFromTextField       =   _keyboardDistanceFromTextField;
@synthesize preventShowingBottomBlankSpace      =   _preventShowingBottomBlankSpace;

//Keyboard Appearance handling
@synthesize overrideKeyboardAppearance          =   _overrideKeyboardAppearance;
@synthesize keyboardAppearance                  =   _keyboardAppearance;

//IQToolbar handling
@synthesize enableAutoToolbar                   =   _enableAutoToolbar;
@synthesize toolbarManageBehaviour              =   _toolbarManageBehaviour;
@synthesize shouldToolbarUsesTextFieldTintColor =   _shouldToolbarUsesTextFieldTintColor;
@synthesize shouldShowTextFieldPlaceholder      =   _shouldShowTextFieldPlaceholder;
@synthesize placeholderFont                     =   _placeholderFont;

//TextView handling
@synthesize canAdjustTextView                   =   _canAdjustTextView;

//Resign handling
@synthesize shouldResignOnTouchOutside          =   _shouldResignOnTouchOutside;

//Sound handling
@synthesize shouldPlayInputClicks               =   _shouldPlayInputClicks;

//Animation handling
@synthesize shouldAdoptDefaultKeyboardAnimation =   _shouldAdoptDefaultKeyboardAnimation;


#pragma mark - Initializing functions

/*! Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code) */
+(void)load
{
    [super load];
    
    //Enabling IQKeyboardManager.
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

/*  Singleton Object Initialization. */
-(instancetype)init
{
	if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
			//  Registering for keyboard notification.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

			//  Registering for textField notification.
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
			
			//  Registering for textView notification.
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
			
            //  Registering for orientation changes notification
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
            
            //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
            _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [_tapGesture setDelegate:self];
            
            //  Default settings
			[self setKeyboardDistanceFromTextField:10];
            _animationDuration = 0.25;
            
            //Setting it's initial values
            _enable = NO;
            [self setCanAdjustTextView:NO];
            [self setShouldPlayInputClicks:NO];
            [self setShouldResignOnTouchOutside:NO];
            [self setOverrideKeyboardAppearance:NO];
            [self setShouldToolbarUsesTextFieldTintColor:NO];
            [self setKeyboardAppearance:UIKeyboardAppearanceDefault];
            
            [self setEnableAutoToolbar:YES];
            [self setPreventShowingBottomBlankSpace:YES];
            [self setShouldShowTextFieldPlaceholder:YES];
            [self setShouldAdoptDefaultKeyboardAnimation:YES];
            [self setToolbarManageBehaviour:IQAutoToolbarBySubviews];
        });
    }
    return self;
}

/*  Automatically called from the `+(void)load` method. */
+ (instancetype)sharedManager
{
	//Singleton instance
	static IQKeyboardManager *kbManager;
	
	//Dispatching it once.
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
		//  Initializing keyboard manger.
        kbManager = [[self alloc] init];
    });
	
	//Returning kbManager.
	return kbManager;
}

#pragma mark - Dealloc
-(void)dealloc
{
    //  Disable the keyboard manager.
	[self setEnable:NO];
    
    //Removing notification observers on dealloc.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Property functions
-(void)setEnable:(BOOL)enable
{
	// If not enabled, enable it.
    if (enable == YES && _enable == NO)
    {
		//Setting NO to _enable.
		_enable = enable;
        
		//If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
		if (_kbShowNotification)	[self keyboardWillShow:_kbShowNotification];

        _IQShowLog(IQLocalizedString(@"enabled", nil));
    }
	//If not disable, desable it.
    else if (enable == NO && _enable == YES)
    {
		//Sending a fake notification for keyboardWillHide to retain view's original frame.
		[self keyboardWillHide:nil];
        
		//Setting NO to _enable.
		_enable = enable;
		
        _IQShowLog(IQLocalizedString(@"disabled", nil));
    }
	//If already disabled.
	else if (enable == NO && _enable == NO)
	{
        _IQShowLog(IQLocalizedString(@"already disabled", nil));
	}
	//If already enabled.
	else if (enable == YES && _enable == YES)
	{
        _IQShowLog(IQLocalizedString(@"already enabled", nil));
	}
}

//Is enabled
-(BOOL)isEnabled
{
	return _enable;
}

//	Setting keyboard distance from text field.
-(void)setKeyboardDistanceFromTextField:(CGFloat)keyboardDistanceFromTextField
{
    //Can't be less than zero. Minimum is zero.
	_keyboardDistanceFromTextField = MAX(keyboardDistanceFromTextField, 0);

    _IQShowLog([NSString stringWithFormat:@"keyboardDistanceFromTextField: %.2f",_keyboardDistanceFromTextField]);
}

/*! Enabling/disable gesture on touching. */
-(void)setShouldResignOnTouchOutside:(BOOL)shouldResignOnTouchOutside
{
    _IQShowLog([NSString stringWithFormat:@"shouldResignOnTouchOutside: %@",shouldResignOnTouchOutside?@"Yes":@"No"]);
    
    _shouldResignOnTouchOutside = shouldResignOnTouchOutside;
    [_tapGesture setEnabled:_shouldResignOnTouchOutside];    // (Enhancement ID: #14)
}

/*! return YES. If autoToolbar is enabled. */
-(BOOL)isEnableAutoToolbar
{
    return _enableAutoToolbar;
}

/*! Enable/disable autotoolbar. Adding and removing toolbar if required. */
-(void)setEnableAutoToolbar:(BOOL)enableAutoToolbar
{
    _enableAutoToolbar = enableAutoToolbar;
    
    _IQShowLog([NSString stringWithFormat:@"enableAutoToolbar: %@",enableAutoToolbar?@"Yes":@"No"]);

    if (_enableAutoToolbar == YES)
    {
        [self addToolbarIfRequired];
    }
    else
    {
        [self removeToolbarIfRequired];
    }
}

#pragma mark - Private Methods

/*! Getting keyWindow. */
-(UIWindow *)keyWindow
{
    if (_textFieldView.window)
    {
        return _textFieldView.window;
    }
    else
    {
        static UIWindow *_keyWindow = nil;
        
        /*  (Bug ID: #23, #25, #73)   */
        UIWindow *originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if (originalKeyWindow != nil && _keyWindow != originalKeyWindow)  _keyWindow = originalKeyWindow;
        
        //Return KeyWindow
        return _keyWindow;
    }
}

/*  Helper function to manipulate RootViewController's frame with animation. */
-(void)setRootViewFrame:(CGRect)frame
{
    //  Getting topMost ViewController.
    UIViewController *controller = [_textFieldView topMostController];
    if (controller == nil)  controller = [[self keyWindow] topMostController];
    
    //frame size needs to be adjusted on iOS8 due to orientation API changes.
    if (IQ_IS_IOS8_OR_GREATER)
    {
        frame.size = controller.view.IQ_size;
    }

    //  If can't get rootViewController then printing warning to user.
    if (controller == nil)
        _IQShowLog(IQLocalizedString(@"You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager", nil));
    
    //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        //  Setting it's new frame
        [controller.view setFrame:frame];
        _IQShowLog([NSString stringWithFormat:@"Set %@ frame to : %@",[controller _IQDescription],NSStringFromCGRect(frame)]);
    } completion:NULL];
}

/* Adjusting RootViewController's frame according to device orientation. */
-(void)adjustFrame
{
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
    if (_textFieldView == nil)   return;
    
    _IQShowLog([NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]);

    //  Boolean to know keyboard is showing/hiding
    _keyboardManagerFlags.isKeyboardShowing = YES;
    
    //  Getting KeyWindow object.
    UIWindow *keyWindow = [_textFieldView window];
    if (keyWindow == nil)  keyWindow = [self keyWindow];
    
    //  Getting RootViewController.  (Bug ID: #1, #4)
    UIViewController *rootController = [_textFieldView topMostController];
    if (rootController == nil)  rootController = [keyWindow topMostController];
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
    UIInterfaceOrientation interfaceOrientation = IQ_IS_IOS8_OR_GREATER ? UIInterfaceOrientationPortrait : [rootController interfaceOrientation];
#pragma GCC diagnostic pop

    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:keyWindow];
    //  Getting RootViewRect.
    CGRect rootViewRect = [[rootController view] frame];
    //Getting statusBarFrame
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    CGFloat move = 0;
    //  Move positive = textField is hidden.
    //  Move negative = textField is showing.
	
    //  Calculating move position. Common for both normal and special cases.
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            move = MIN(CGRectGetMinX(textFieldViewRect)-(CGRectGetWidth(statusBarFrame)+5), CGRectGetMaxX(textFieldViewRect)-(keyWindow.IQ_width-_kbSize.width))+50;
            break;
        case UIInterfaceOrientationLandscapeRight:
            move = MIN(keyWindow.IQ_width-CGRectGetMaxX(textFieldViewRect)-(CGRectGetWidth(statusBarFrame)+5), _kbSize.width-CGRectGetMinX(textFieldViewRect))+50;
            break;
        case UIInterfaceOrientationPortrait:
            move = MIN(CGRectGetMinY(textFieldViewRect)-(CGRectGetHeight(statusBarFrame)+5), CGRectGetMaxY(textFieldViewRect)-(keyWindow.IQ_height-_kbSize.height))+50;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            move = MIN(keyWindow.IQ_height-CGRectGetMaxY(textFieldViewRect)-(CGRectGetHeight(statusBarFrame)+5), _kbSize.height-CGRectGetMinY(textFieldViewRect))+50;
            break;
        default:
            break;
    }

    _IQShowLog([NSString stringWithFormat:@"Need to move: %.2f",move]);

    //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
    UIScrollView *superScrollView = [_textFieldView superScrollView];
    
    //If there was a lastScrollView.    //  (Bug ID: #34)
    if (_lastScrollView)
    {
        //If we can't find current superScrollView, then setting lastScrollView to it's original form.
        if (superScrollView == nil)
        {
            _IQShowLog([NSString stringWithFormat:@"Restoring %@ contentInset to : %@ and contentOffset to : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]);

            [_lastScrollView setContentInset:_startingContentInsets];
            [_lastScrollView setContentOffset:_startingContentOffset animated:YES];
            _startingContentInsets = UIEdgeInsetsZero;
            _startingContentOffset = CGPointZero;
            _lastScrollView = nil;
        }
        //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
        else if (superScrollView != _lastScrollView)
        {
            _IQShowLog([NSString stringWithFormat:@"Restoring %@ contentInset to : %@ and contentOffset to : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]);

            [_lastScrollView setContentInset:_startingContentInsets];
            [_lastScrollView setContentOffset:_startingContentOffset animated:YES];
            _lastScrollView = superScrollView;
            _startingContentInsets = superScrollView.contentInset;
            _startingContentOffset = superScrollView.contentOffset;

            _IQShowLog([NSString stringWithFormat:@"Saving New %@ contentInset: %@ and contentOffset : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]);
        }
        //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing
    }
    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
    else if(superScrollView)
    {
        _lastScrollView = superScrollView;
        _startingContentInsets = superScrollView.contentInset;
        _startingContentOffset = superScrollView.contentOffset;

        _IQShowLog([NSString stringWithFormat:@"Saving %@ contentInset: %@ and contentOffset : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]);
    }
    
    //  Special case for ScrollView.
    {
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (_lastScrollView)
        {
            //Saving
            UIView *lastView = _textFieldView;
            UIScrollView *superScrollView = _lastScrollView;

            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView && (move>0?(move > (-superScrollView.contentOffset.y)):superScrollView.contentOffset.y>0) )
            {
                //Getting lastViewRect.
                CGRect lastViewRect = [[lastView superview] convertRect:lastView.frame toView:superScrollView];
                
                //Calculating the expected Y offset from move and scrollView's contentOffset.
                CGFloat shouldOffsetY = superScrollView.contentOffset.y - MIN(superScrollView.contentOffset.y,-move);
                
                //Rearranging the expected Y offset according to the view.
                shouldOffsetY = MIN(shouldOffsetY, lastViewRect.origin.y/*-5*/);   //-5 is for good UI.//Commenting -5 (Bug ID: #69)
                
                //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                move -= (shouldOffsetY-superScrollView.contentOffset.y);
                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    _IQShowLog([NSString stringWithFormat:@"Adjusting %.2f to %@ ContentOffset",(superScrollView.contentOffset.y-shouldOffsetY),[superScrollView _IQDescription]]);
                    _IQShowLog([NSString stringWithFormat:@"Remaining Move: %.2f",move]);

                    superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY);

                } completion:NULL];

                //  Getting next lastView & superScrollView.
                lastView = superScrollView;
                superScrollView = [lastView superScrollView];
            }
            
            //Updating contentInset
            {
                
               CGFloat bottom = 0;
                
                CGRect lastScrollViewRect = [[_lastScrollView superview] convertRect:_lastScrollView.frame toView:keyWindow];

                switch (interfaceOrientation)
                {
                    case UIInterfaceOrientationLandscapeLeft:
                        bottom = _kbSize.width-(keyWindow.IQ_width-CGRectGetMaxX(lastScrollViewRect));
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        bottom = _kbSize.width-CGRectGetMinX(lastScrollViewRect);
                        break;
                    case UIInterfaceOrientationPortrait:
                        bottom = _kbSize.height-(keyWindow.IQ_height-CGRectGetMaxY(lastScrollViewRect));
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        bottom = _kbSize.height-CGRectGetMinY(lastScrollViewRect);
                        break;
                    default:
                        break;
                }

                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                UIEdgeInsets movedInsets = _lastScrollView.contentInset;

                movedInsets.bottom = MAX(_startingContentInsets.bottom, bottom);
//                movedInsets.bottom = MAX(0, (_lastScrollView.contentOffset.y+_lastScrollView.IQ_height)-MAX(_lastScrollView.contentSize.height, _lastScrollView.IQ_height));
                
                _IQShowLog([NSString stringWithFormat:@"%@ old ContentInset : %@",[_lastScrollView _IQDescription], NSStringFromUIEdgeInsets(_lastScrollView.contentInset)]);
                
                _lastScrollView.contentInset = movedInsets;
                
                _IQShowLog([NSString stringWithFormat:@"%@ new ContentInset : %@",[_lastScrollView _IQDescription], NSStringFromUIEdgeInsets(_lastScrollView.contentInset)]);
            }
        }
        //Going ahead. No else if.
    }
    
    //Special case for UITextView(Readjusting the move variable when textView hight is too big to fit on screen).
    //If we have permission to adjust the textView, then let's do it on behalf of user.  (Enhancement ID: #15)
    //Added _isTextFieldViewFrameChanged. (Bug ID: #92)
    if (_canAdjustTextView && [_textFieldView isKindOfClass:[UITextView class]] && _keyboardManagerFlags.isTextFieldViewFrameChanged == NO)
    {
        CGFloat textViewHeight = _textFieldView.IQ_height;
        
        switch (interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                textViewHeight = MIN(textViewHeight, (keyWindow.IQ_width-_kbSize.width-(CGRectGetWidth(statusBarFrame)+5)));
                break;
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                textViewHeight = MIN(textViewHeight, (keyWindow.IQ_height-_kbSize.height-(CGRectGetHeight(statusBarFrame)+5)));
                break;
            default:
                break;
        }
        
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            _IQShowLog([NSString stringWithFormat:@"%@ Old Frame : %@",[_textFieldView _IQDescription], NSStringFromCGRect(_textFieldView.frame)]);

            _textFieldView.IQ_height = textViewHeight;
            _keyboardManagerFlags.isTextFieldViewFrameChanged = YES;

            _IQShowLog([NSString stringWithFormat:@"%@ New Frame : %@",[_textFieldView _IQDescription], NSStringFromCGRect(_textFieldView.frame)]);

        } completion:NULL];
    }
    
    //  Special case for iPad modalPresentationStyle.
    if ([rootController modalPresentationStyle] == UIModalPresentationFormSheet ||
        [rootController modalPresentationStyle] == UIModalPresentationPageSheet)
    {
        _IQShowLog([NSString stringWithFormat:@"Found Special case for Model Presentation Style: %ld",(long)(rootController.modalPresentationStyle)]);

        //  Positive or zero.
        if (move>=0)
        {
            // We should only manipulate y.
            rootViewRect.origin.y -= move;
            
            //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
            if (_preventShowingBottomBlankSpace == YES)
            {
                CGFloat minimumY = 0;
                
                switch (interfaceOrientation)
                {
                    case UIInterfaceOrientationLandscapeLeft:
                    case UIInterfaceOrientationLandscapeRight:
                        minimumY = keyWindow.IQ_width-rootViewRect.size.height-statusBarFrame.size.width-(_kbSize.width-_keyboardDistanceFromTextField);  break;
                    case UIInterfaceOrientationPortrait:
                    case UIInterfaceOrientationPortraitUpsideDown:
                        minimumY = (keyWindow.IQ_height-rootViewRect.size.height-statusBarFrame.size.height)/2-(_kbSize.height-_keyboardDistanceFromTextField);  break;
                    default:    break;
                }
                
                rootViewRect.origin.y = MAX(rootViewRect.origin.y, minimumY);
            }
            
            _IQShowLog(@"Moving Upward");
            //  Setting adjusted rootViewRect
            [self setRootViewFrame:rootViewRect];
        }
        //  Negative
        else
        {
            //  Calculating disturbed distance. Pull Request #3
            CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(_topViewBeginRect);
			
            //  disturbDistance Negative = frame disturbed.
            //  disturbDistance positive = frame not disturbed.
            if(disturbDistance<0)
            {
                // We should only manipulate y.
                rootViewRect.origin.y -= MAX(move, disturbDistance);

                _IQShowLog(@"Moving Downward");
                //  Setting adjusted rootViewRect
                [self setRootViewFrame:rootViewRect];
            }
        }
    }
    //If presentation style is neither UIModalPresentationFormSheet nor UIModalPresentationPageSheet then going ahead.(General case)
    else
    {
        //  Positive or zero.
        if (move>=0)
        {
            switch (interfaceOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= move;  break;
                case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += move;  break;
                case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= move;  break;
                case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += move;  break;
                default:    break;
            }
			
            //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
            if (_preventShowingBottomBlankSpace == YES)
            {
                switch (interfaceOrientation)
                {
                    case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x = MAX(rootViewRect.origin.x, MIN(0,-_kbSize.width+_keyboardDistanceFromTextField));  break;
                    case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x = MIN(rootViewRect.origin.x, +_kbSize.width-_keyboardDistanceFromTextField);  break;
                    case UIInterfaceOrientationPortrait:            rootViewRect.origin.y = MAX(rootViewRect.origin.y, MIN(0, -_kbSize.height+_keyboardDistanceFromTextField));  break;
                    case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y = MIN(rootViewRect.origin.y, +_kbSize.height-_keyboardDistanceFromTextField);  break;
                    default:    break;
                }
            }
            
            _IQShowLog(@"Moving Upward");
            //  Setting adjusted rootViewRect
            [self setRootViewFrame:rootViewRect];
        }
        //  Negative
        else
        {
            CGFloat disturbDistance = 0;
            
            switch (interfaceOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:
                    disturbDistance = CGRectGetMinX(rootViewRect)-CGRectGetMinX(_topViewBeginRect);
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    disturbDistance = CGRectGetMinX(_topViewBeginRect)-CGRectGetMinX(rootViewRect);
                    break;
                case UIInterfaceOrientationPortrait:
                    disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(_topViewBeginRect);
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    disturbDistance = CGRectGetMinY(_topViewBeginRect)-CGRectGetMinY(rootViewRect);
                    break;
                default:
                    break;
            }

            //  disturbDistance Negative = frame disturbed. Pull Request #3
            //  disturbDistance positive = frame not disturbed.
            if(disturbDistance<0)
            {
                switch (interfaceOrientation)
                {
                    case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += MAX(move, disturbDistance);  break;
                    default:    break;
                }
                
                _IQShowLog(@"Moving Downward");
                //  Setting adjusted rootViewRect
                [self setRootViewFrame:rootViewRect];
            }
        }
    }
    
    _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
}

#pragma mark - UIKeyboad Notification methods
/*  UIKeyboardWillShowNotification. */
-(void)keyboardWillShow:(NSNotification*)aNotification
{
    _kbShowNotification = aNotification;
	
	if (_enable == NO)	return;
	
    _IQShowLog([NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]);

    //Due to orientation callback we need to resave it's original frame.    //  (Bug ID: #46)
    //Added _isTextFieldViewFrameChanged check. Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed. (Bug ID: #92)
    if (_keyboardManagerFlags.isTextFieldViewFrameChanged == NO && _textFieldView)
    {
        _textFieldViewIntialFrame = _textFieldView.frame;
        _IQShowLog([NSString stringWithFormat:@"Saving %@ Initial frame :%@",[_textFieldView _IQDescription],NSStringFromCGRect(_textFieldViewIntialFrame)]);
    }
    
    if (CGRectEqualToRect(_topViewBeginRect, CGRectZero))    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        _rootViewController = [_textFieldView topMostController];
        if (_rootViewController == nil)  _rootViewController = [[self keyWindow] topMostController];

        _topViewBeginRect = _rootViewController.view.frame;
        _IQShowLog([NSString stringWithFormat:@"Saving %@ beginning Frame: %@",[_rootViewController _IQDescription] ,NSStringFromCGRect(_topViewBeginRect)]);
    }

    if (_shouldAdoptDefaultKeyboardAnimation)
    {
        //  Getting keyboard animation.
        _animationCurve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];
        _animationCurve = _animationCurve<<16;
    }
    else
    {
        _animationCurve = 0;
    }

    //  Getting keyboard animation duration
    CGFloat duration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Saving animation duration
    if (duration != 0.0)    _animationDuration = duration;
    
    CGSize oldKBSize = _kbSize;
    
    //  Getting UIKeyboardSize.
//    CGRect screenRect = [self keyWindow].bounds;
    CGRect kbFrame = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _kbSize = kbFrame.size;
 
    _IQShowLog([NSString stringWithFormat:@"UIKeyboard Size : %@",NSStringFromCGSize(_kbSize)]);

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
    UIViewController *topMostController = [_textFieldView topMostController];
    if (topMostController == nil)  topMostController = [[self keyWindow] topMostController];

    UIInterfaceOrientation interfaceOrientation = IQ_IS_IOS8_OR_GREATER ? UIInterfaceOrientationPortrait : [topMostController interfaceOrientation];
#pragma GCC diagnostic pop
    
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
//            _kbSize.width = screenRect.size.width - kbFrame.origin.x;
            _kbSize.width += _keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationLandscapeRight:
//            _kbSize.width = screenRect.size.width - kbFrame.origin.x;
            _kbSize.width += _keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationPortrait:
//            _kbSize.height = screenRect.size.height - kbFrame.origin.y;
            _kbSize.height += _keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
//            _kbSize.height = screenRect.size.height - kbFrame.origin.y;
            _kbSize.height += _keyboardDistanceFromTextField;
            break;
        default:
            break;
    }
    
    //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
    if (!CGSizeEqualToSize(_kbSize, oldKBSize))
    {
        //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if (_textFieldView != nil && [[_textFieldView viewController] isKindOfClass:[UITableViewController class]] == NO && [_textFieldView isAlertViewTextField] == NO)
        {
            [self adjustFrame];
        }
    }

    _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
}

/*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    //If it's not a fake notification generated by [self setEnable:NO].
    if (aNotification != nil)	_kbShowNotification = nil;
    
    //If not enabled then do nothing.
    if (_enable == NO)	return;
    
    _IQShowLog([NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]);

    //Commented due to #56. Added all the conditions below to handle UIWebView's textFields.    (Bug ID: #56)
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
//    if (_textFieldView == nil)   return;

    //  Boolean to know keyboard is showing/hiding
    _keyboardManagerFlags.isKeyboardShowing = NO;
    
    //  Getting keyboard animation duration
    CGFloat aDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        //  Setitng keyboard animation duration
        _animationDuration = aDuration;
    }
    
    //Restoring the contentOffset of the lastScrollView
    if (_lastScrollView)
    {
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            _lastScrollView.contentInset = _startingContentInsets;
            _lastScrollView.contentOffset = _startingContentOffset;

            _IQShowLog([NSString stringWithFormat:@"Restoring %@ contentInset to : %@ and contentOffset to : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]);
            
            // TODO: restore scrollView state
            // This is temporary solution. Have to implement the save and restore scrollView state
            UIScrollView *superscrollView = _lastScrollView;
            while ((superscrollView = [superscrollView superScrollView]))
            {
                CGSize contentSize = CGSizeMake(MAX(superscrollView.contentSize.width, superscrollView.IQ_width), MAX(superscrollView.contentSize.height, superscrollView.IQ_height));
                
                CGFloat minimumY = contentSize.height-superscrollView.IQ_height;
                
                if (minimumY<superscrollView.contentOffset.y)
                {
                    superscrollView.contentOffset = CGPointMake(superscrollView.contentOffset.x, minimumY);

                    _IQShowLog([NSString stringWithFormat:@"Restoring %@ contentOffset to : %@",[superscrollView _IQDescription],NSStringFromCGPoint(superscrollView.contentOffset)]);
                }
            }
        } completion:NULL];
    }
    
    //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
    if (!CGRectEqualToRect(_topViewBeginRect, CGRectZero) && _rootViewController)
    {
        //frame size needs to be adjusted on iOS8 due to orientation API changes.
        if (IQ_IS_IOS8_OR_GREATER)
        {
            _topViewBeginRect.size = _rootViewController.view.IQ_size;
        }
        
        //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{

            _IQShowLog([NSString stringWithFormat:@"Restoring %@ frame to : %@",[_rootViewController _IQDescription],NSStringFromCGRect(_topViewBeginRect)]);
            //  Setting it's new frame
            [_rootViewController.view setFrame:_topViewBeginRect];
        } completion:NULL];
        _rootViewController = nil;
    }

    //Reset all values
    _lastScrollView = nil;
    _kbSize = CGSizeZero;
    _startingContentInsets = UIEdgeInsetsZero;
    _startingContentOffset = CGPointZero;
//    topViewBeginRect = CGRectZero;    //Commented due to #82

    _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
}

/*  UIKeyboardDidHideNotification. So topViewBeginRect can be set to CGRectZero. */
- (void)keyboardDidHide:(NSNotification*)aNotification
{
    _IQShowLog([NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]);

    _topViewBeginRect = CGRectZero;

    _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
}

#pragma mark - UITextFieldView Delegate methods
/*!  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    _IQShowLog([NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]);

    //  Getting object
    _textFieldView = notification.object;
    
    if (_overrideKeyboardAppearance == YES) [(UITextField*)_textFieldView setKeyboardAppearance:_keyboardAppearance];
    
    // Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed.
    //Added _isTextFieldViewFrameChanged check. (Bug ID: #92)
    if (_keyboardManagerFlags.isTextFieldViewFrameChanged == NO && _textFieldView)
    {
        _textFieldViewIntialFrame = _textFieldView.frame;
        _IQShowLog([NSString stringWithFormat:@"Saving %@ Initial frame :%@",[_textFieldView _IQDescription],NSStringFromCGRect(_textFieldViewIntialFrame)]);
    }
    
	//If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
	if (_enableAutoToolbar)
    {
        _IQShowLog(@"adding UIToolbars if required");

        //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
        if ([_textFieldView isKindOfClass:[UITextView class]] && _textFieldView.inputAccessoryView == nil)
        {
            [UIView animateWithDuration:0.00001 delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                [self addToolbarIfRequired];
            } completion:^(BOOL finished) {
                
                //  Retaining textFieldView
                UIView *textFieldRetain = _textFieldView;

                [textFieldRetain resignFirstResponder];
                [textFieldRetain becomeFirstResponder];
            }];
        }
        else
        {
            [self addToolbarIfRequired];
        }
    }
    
	if (_enable == NO)
    {
        _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
        return;
    }
    
    [_textFieldView.window addGestureRecognizer:_tapGesture];    //   (Enhancement ID: #14)
    
    if (_keyboardManagerFlags.isKeyboardShowing == NO)    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        _rootViewController = [_textFieldView topMostController];
        if (_rootViewController == nil)  _rootViewController = [[self keyWindow] topMostController];
        
        _topViewBeginRect = _rootViewController.view.frame;

        _IQShowLog([NSString stringWithFormat:@"Saving %@ beginning Frame: %@",[_rootViewController _IQDescription], NSStringFromCGRect(_topViewBeginRect)]);
    }
    
    //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37, #74, #76)
    //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
    if (_textFieldView != nil && [[_textFieldView viewController] isKindOfClass:[UITableViewController class]] == NO && [_textFieldView isAlertViewTextField] == NO)
    {
        //  keyboard is already showing. adjust frame.
        [self adjustFrame];
    }

    _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
}

/*!  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    _IQShowLog([NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]);

    [_textFieldView.window removeGestureRecognizer:_tapGesture]; // (Enhancement ID: #14)
    
    // We check if there's a change in original frame or not.
    if(_keyboardManagerFlags.isTextFieldViewFrameChanged == YES)
    {
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            _keyboardManagerFlags.isTextFieldViewFrameChanged = NO;

            _IQShowLog([NSString stringWithFormat:@"Restoring %@ frame to : %@",[_textFieldView _IQDescription],NSStringFromCGRect(_textFieldViewIntialFrame)]);

            _textFieldView.frame = _textFieldViewIntialFrame;

        } completion:NULL];
    }
    
    //Setting object to nil
    _textFieldView = nil;

    _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
}

/* UITextViewTextDidChangeNotificationBug,  fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string */
-(void)textFieldViewDidChange:(NSNotification*)notification //  (Bug ID: #18)
{
    UITextView *textView = (UITextView *)notification.object;
    
    CGRect line = [textView caretRectForPosition: textView.selectedTextRange.start];
    CGFloat overflow = CGRectGetMaxY(line) - (textView.contentOffset.y + CGRectGetHeight(textView.bounds) - textView.contentInset.bottom - textView.contentInset.top);
    
    //Added overflow conditions (Bug ID: 95)
    if ( overflow > 0  && overflow < FLT_MAX)
    {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            [textView setContentOffset:offset];
        } completion:NULL];
    }
}

#pragma mark - UIInterfaceOrientation Change notification methods
/*!  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
- (void)willChangeStatusBarOrientation:(NSNotification*)aNotification
{
    _IQShowLog([NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]);

    //If textFieldViewInitialRect is saved then restore it.(UITextView case @canAdjustTextView)
    if (_keyboardManagerFlags.isTextFieldViewFrameChanged == YES)
    {
        //Due to orientation callback we need to set it's original position.
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            _keyboardManagerFlags.isTextFieldViewFrameChanged = NO;

            _IQShowLog([NSString stringWithFormat:@"Restoring %@ frame to : %@",[_textFieldView _IQDescription],NSStringFromCGRect(_textFieldViewIntialFrame)]);

            _textFieldView.frame = _textFieldViewIntialFrame;
        } completion:NULL];
    }

    _IQShowLog([NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]);
}

#pragma mark AutoResign methods

/*! Resigning on tap gesture. */
- (void)tapRecognized:(UITapGestureRecognizer*)gesture  // (Enhancement ID: #14)
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [gesture.view endEditing:YES];
    }
}

/*! Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

/*! To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [[touch view] isKindOfClass:[UIControl class]] ? NO : YES;
}

/*! Resigning textField. */
- (void)resignFirstResponder
{
    if (_textFieldView)
    {
        //  Retaining textFieldView
        UIView *textFieldRetain = _textFieldView;

        //Resigning first responder
        BOOL isResignFirstResponder = [_textFieldView resignFirstResponder];
        
        //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
        if (isResignFirstResponder == NO)
        {
            //If it refuses to resign then becoming it first responder again for getting notifications callback.
            [textFieldRetain becomeFirstResponder];
            
            _IQShowLog([NSString stringWithFormat:@"Refuses to Resign first responder: %@",[_textFieldView _IQDescription]]);
        }
    }
}

#pragma mark AutoToolbar methods

/*!	Get all UITextField/UITextView siblings of textFieldView. */
-(NSArray*)responderViews
{
    UIView *tableView = [_textFieldView superTableView];
    if (tableView == nil)   tableView = [_textFieldView superCollectionView];
    
    NSArray *textFields = nil;
    
    //If there is a tableView in view's hierarchy, then fetching all it's subview that responds. No sorting for tableView, it's by subView position.
    if (tableView)  //     //   (Enhancement ID: #22)
    {
        textFields = [tableView deepResponderViews];
    }
    //Otherwise fetching all the siblings
    else
    {
        textFields = [_textFieldView responderSiblings];
        
        //Sorting textFields according to behaviour
        switch (_toolbarManageBehaviour)
        {
                //If autoToolbar behaviour is bySubviews, then returning it.
            case IQAutoToolbarBySubviews:
                return textFields;
                break;
                
                //If autoToolbar behaviour is by tag, then sorting it according to tag property.
            case IQAutoToolbarByTag:
                return [textFields sortedArrayByTag];
                break;
                
                //If autoToolbar behaviour is by tag, then sorting it according to tag property.
            case IQAutoToolbarByPosition:
                return [textFields sortedArrayByPosition];
                break;
        }
    }
    
    return textFields;
}

#pragma mark previous/next/done functionality
/*!	previousAction. */
-(void)previousAction:(id)segmentedControl
{
    //If user wants to play input Click sound.
    if (_shouldPlayInputClicks)
    {
        //Play Input Click Sound.
        [[UIDevice currentDevice] playInputClick];
    }

	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
    if ([textFields containsObject:_textFieldView])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        
        //If it is not first textField. then it's previous object becomeFirstResponder.
        if (index > 0)
        {
            UITextField *nextTextField = textFields[index-1];
            
            //  Retaining textFieldView
            UIView *textFieldRetain = _textFieldView;
            
            BOOL isAcceptAsFirstResponder = [nextTextField becomeFirstResponder];
            
            //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
            if (isAcceptAsFirstResponder == NO)
            {
                //If next field refuses to become first responder then restoring old textField as first responder.
                [textFieldRetain becomeFirstResponder];
                
                _IQShowLog([NSString stringWithFormat:@"Refuses to become first responder: %@",[nextTextField _IQDescription]]);
            }
        }
    }
}

/*!	nextAction. */
-(void)nextAction:(id)segmentedControl
{
    //If user wants to play input Click sound.
    if (_shouldPlayInputClicks)
    {
        //Play Input Click Sound.
        [[UIDevice currentDevice] playInputClick];
    }

	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
    if ([textFields containsObject:_textFieldView])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        
        //If it is not last textField. then it's next object becomeFirstResponder.
        if (index < textFields.count-1)
        {
            UITextField *nextTextField = textFields[index+1];
            
            //  Retaining textFieldView
            UIView *textFieldRetain = _textFieldView;

            BOOL isAcceptAsFirstResponder = [nextTextField becomeFirstResponder];
            
            //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
           if (isAcceptAsFirstResponder == NO)
            {
                //If next field refuses to become first responder then restoring old textField as first responder.
                [textFieldRetain becomeFirstResponder];

                _IQShowLog([NSString stringWithFormat:@"Refuses to become first responder: %@",[nextTextField _IQDescription]]);
            }
        }
    }
}

/*!	doneAction. Resigning current textField. */
-(void)doneAction:(IQBarButtonItem*)barButton
{
    //If user wants to play input Click sound.
    if (_shouldPlayInputClicks)
    {
        //Play Input Click Sound.
        [[UIDevice currentDevice] playInputClick];
    }

    //Resign textFieldView.
    [self resignFirstResponder];
}

/*! Add toolbar if it is required to add on textFields and it's siblings. */
-(void)addToolbarIfRequired
{
	//	Getting all the sibling textFields.
	NSArray *siblings = [self responderViews];
	
	//	If only one object is found, then adding only Done button.
	if (siblings.count==1)
	{
        UIView *textField = [siblings firstObject];
        
        //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
		if (![textField inputAccessoryView] || ([[textField inputAccessoryView] tag] == kIQPreviousNextButtonToolbarTag))
		{
            //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
			[textField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
            textField.inputAccessoryView.tag = kIQDoneButtonToolbarTag; //  (Bug ID: #78)
            
            //Setting toolbar tintColor //  (Enhancement ID: #30)
            if (_shouldToolbarUsesTextFieldTintColor && [textField respondsToSelector:@selector(tintColor)])
                [textField.inputAccessoryView setTintColor:[textField tintColor]];
            
            //Setting toolbar title font.   //  (Enhancement ID: #30)
            if (_shouldShowTextFieldPlaceholder && _placeholderFont && [_placeholderFont isKindOfClass:[UIFont class]])
                [(IQToolbar*)[textField inputAccessoryView] setTitleFont:_placeholderFont];
        }
	}
	else if(siblings.count)
	{
		//	If more than 1 textField is found. then adding previous/next/done buttons on it.
		for (UITextField *textField in siblings)
		{
            //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Done toolbar).
			if (![textField inputAccessoryView] || [[textField inputAccessoryView] tag] == kIQDoneButtonToolbarTag)
			{
                //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
				[textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                textField.inputAccessoryView.tag = kIQPreviousNextButtonToolbarTag; //  (Bug ID: #78)
                
                //Setting toolbar tintColor //  (Enhancement ID: #30)
                if (_shouldToolbarUsesTextFieldTintColor && [textField respondsToSelector:@selector(tintColor)])
                    [textField.inputAccessoryView setTintColor:[textField tintColor]];
                
                //Setting toolbar title font.   //  (Enhancement ID: #30)
                if (_shouldShowTextFieldPlaceholder && _placeholderFont && [_placeholderFont isKindOfClass:[UIFont class]])
                    [(IQToolbar*)[textField inputAccessoryView] setTitleFont:_placeholderFont];
  			}
            
            //If the toolbar is added by IQKeyboardManager then automatically enabling/disabling the previous/next button.
            if (textField.inputAccessoryView.tag == kIQPreviousNextButtonToolbarTag)
            {
                //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                //	If firstTextField, then previous should not be enabled.
                if (siblings[0] == textField)
                {
                    [textField setEnablePrevious:NO next:YES];
                }
                //	If lastTextField then next should not be enaled.
                else if ([siblings lastObject] == textField)
                {
                    [textField setEnablePrevious:YES next:NO];
                }
                else
                {
                    [textField setEnablePrevious:YES next:YES];
                }
            }
		}
	}
}

/*! Remove any toolbar if it is IQToolbar. */
-(void)removeToolbarIfRequired  //  (Bug ID: #18)
{
    //	Getting all the sibling textFields.
	NSArray *siblings = [self responderViews];
    
    for (UITextField *textField in siblings)
    {
        UIView *toolbar = [textField inputAccessoryView];

        //  (Bug ID: #78)
        if ([toolbar isKindOfClass:[IQToolbar class]] && (toolbar.tag == kIQDoneButtonToolbarTag || toolbar.tag == kIQPreviousNextButtonToolbarTag))
        {
            [textField setInputAccessoryView:nil];
        }
    }
}

@end


void _IQShowLog(NSString *logString)
{
#if IQKEYBOARDMANAGER_DEBUG
    NSLog(@"IQKeyboardManager: %@",logString);
#endif
}
