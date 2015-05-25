#import "iCarousel/iCarousel.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

@interface SBDisplayItem : UIView 
@property(readonly, assign, nonatomic) NSString* displayIdentifier;
@end

@interface SBAppSwitcherContainer : UIView
@end


@interface SBAppSwitcherPageViewController : UIViewController
@end

@interface SBAppSwitcherController
- (void)switcherScroller:(id)scroller displayItemWantsToBeRemoved:(SBDisplayItem*)beRemoved;
- (SBAppSwitcherPageViewController *)pageController;
@end

@interface SBAppSwitcherController (SwitchD) <iCarouselDataSource, iCarouselDelegate>
@end

@interface SBAppSwitcherModel
+ (id)sharedInstance;
- (id)snapshot;
@end

@interface SBDisplayLayout
@property(readonly, assign, nonatomic) NSArray* displayItems;
@end

@interface SBAppSwitcherWindowController
@property(readonly, assign, nonatomic) UIWindow* window;
@end

@interface SBUIController 
+ (id)sharedInstanceIfExists;
@end

@interface SBAppSwitcherSnapshotView : UIView
@end


static iCarousel *carousel;
static NSArray *appShotsItems;
%hook SBAppSwitcherController
// load our button into view
- (id)init {
    SBAppSwitcherContainer *view = MSHookIvar<SBAppSwitcherContainer *>(self, "_containerView");
    appShotsItems = [[%c(SBAppSwitcherModel) sharedInstance] snapshot];
    
    carousel = (iCarousel *)view;
    carousel.delegate = self;
    carousel.dataSource = self;
    
    carousel.type = iCarouselTypeCoverFlow2;
    
    [carousel reloadData];
    return %orig;
}
%new
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [appShotsItems count];
}
%new
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    // i don't have experience with AppSwitcher i was trying so i'm not sure if it's write or not ( feel free to send pull request to fix any issue )
    SBUIController *uiController = [%c(SBUIController) sharedInstanceIfExists];
    SBAppSwitcherController *controller = MSHookIvar<SBAppSwitcherController *>(uiController, "_switcherController");
    
    SBAppSwitcherPageViewController *pageViewController = MSHookIvar<id>(controller, "_pageController");
    
    if (view == nil) {
        view = pageViewController.view;
    }
    return view;
}
%new
- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}
%end



/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/
