/*
 *   File Version: 3.1    05/23/2013
 *   File Version: 3.0
 *  
 *	Copyright David Book, buzztouch.com
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are 
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the 
 *	following disclaimer. 
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list 
 *	of conditions and the following disclaimer in the documentation and/or other materials 
 *	provided with the distribution. 
 *
 *	Neither the name of David Book, or buzztouch.com nor the names of its contributors 
 *	may be used to endorse or promote products derived from this software without specific 
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 *	OF SUCH DAMAGE. 
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>
#import "iAd/ADBannerView.h"
#import "JSON.h"
#import "revmobsampleapp_appDelegate.h"
#import "BT_strings.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "BT_viewUtilities.h"
#import "BT_viewController.h"


@implementation BT_viewController
@synthesize progressView, screenData;
@synthesize adView, adBannerView, adBannerViewIsVisible;
@synthesize hasStatusBar, hasNavBar, hasToolBar;




//initWithScreenData
-(id)initWithScreenData:(BT_item *)theScreenData{
	if((self = [super init])){
		[BT_debugger showIt:self theMessage:@"INIT"];

		//set screen data
		[self setScreenData:theScreenData];
        
		
	}
	 return self;
}



//show progress
-(void)showProgress{
	[BT_debugger showIt:self theMessage:@"showProgress"];
	
	//show progress view if not showing
	if(progressView == nil){
		progressView = [BT_viewUtilities getProgressView:@""];
		[self.view addSubview:progressView];
	}	
	
}

//hide progress
-(void)hideProgress{
	[BT_debugger showIt:self theMessage:@"hideProgress"];
	
	//remove progress view if already showing
	if(progressView != nil){
		[progressView removeFromSuperview];
		progressView = nil;
	}

}

//left button
-(void)navLeftTap{
	[BT_debugger showIt:self theMessage:@"navLeftTap"];
    
    //child apps are handled different...
    revmobsampleapp_appDelegate *appDelegate = (revmobsampleapp_appDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate.rootApp isChildApp]){
        [BT_viewControllerManager closeChildApp];
    }else{
        //handle "left" transition
        [BT_viewControllerManager handleLeftButton:screenData];
    }
	
}

//right button
-(void)navRightTap{
	[BT_debugger showIt:self theMessage:@"navRightTap"];
	
	//handle "right" transition
	[BT_viewControllerManager handleRightButton:screenData];
	
}

//show audio controls
-(void)showAudioControls{
	[BT_debugger showIt:self theMessage:@"showAudioControls"];
	
	//appDelegate
	revmobsampleapp_appDelegate *appDelegate = (revmobsampleapp_appDelegate *)[[UIApplication sharedApplication] delegate];	
	[appDelegate showAudioControls];

}

//show alert
-(void)showAlert:(NSString *)theTitle theMessage:(NSString *)theMessage alertTag:(int)alertTag{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:theTitle message:theMessage delegate:self
	cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
	[alertView setTag:alertTag];
	[alertView show];
	[alertView release];
}

//"OK" clicks on UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"alertView:clickedButtonAtIndex: %i", buttonIndex]];
	
	//handles OK click after emailing an image from BT_screen_imageEmail
	if([alertView tag] == 99){
		[self.navigationController popViewControllerAnimated:YES];
	}

	//handles OK click after sharing from BT_screen_shareFacebook or BT_screen_shareTwitter
	if([alertView tag] == 199){
		[self navLeftTap];
	}
	
}


////////////////////////////////////////////
//iAd Methods

//createAdBannerView
-(void)createAdBannerView{
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if(classAdBannerView != nil){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"createiAdBannerView: %@", @""]];
		
        //create a view to hold the adBannerView...
        self.adView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		[self.adView setFrame:[BT_viewUtilities frameForAdView:self theScreenData:screenData]];
        [self.adView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin)];
		[self.adView setBackgroundColor:[UIColor clearColor]];
        [self.adView setTag:94];
        
        //create an adBannerView...
		self.adBannerView = [[[ADBannerView alloc] initWithFrame:CGRectZero] autorelease];
        [self.adBannerView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin)];

        [self.adBannerView setDelegate:self];
		[self.adBannerView setTag:955];
        
        //add adBannerView to view...
		[self.adView addSubview:self.adBannerView];
        [self.view addSubview:adView];
		[self.view bringSubviewToFront:adView];        
    }
}

//resizeAdView...
-(void)resizeAdView{
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if(classAdBannerView != nil){

        /*
         
            The adBannerView should resize to the device's width on rotation automatically. 
            This method is called when the device rotates so you can customize the adBannerViews
            position if desired. Uncomment the ADBannerView on the next line to get a reference to it.
        */
        
        //ad baner is inside adView...
        //ADBannerView *tmpBannerView = (ADBannerView *)[self.view viewWithTag:955];
        
    }
    
}


//showHideAdView
-(void)showHideAdView{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"showHideAdView: %@", @""]];
	if(adBannerView != nil){   
        [UIView beginAnimations:@"positioniAdView" context:nil];
		[UIView setAnimationDuration:1.5];
        if(adBannerViewIsVisible){
            [self.adView setAlpha:1.0];
        }else{
			[self.adView setAlpha:.0];
       }
	   [UIView commitAnimations];
    }   
}

//banner view did load...
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"iAd bannerViewDidLoadAd%@", @""]];
    if(!adBannerViewIsVisible) {                
        adBannerViewIsVisible = YES;
        [self showHideAdView];
    }
}
 
//banner view failed to get add
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"iAd didFailToReceiveAdWithError: %@", [error localizedDescription]]];
	if (adBannerViewIsVisible){        
        adBannerViewIsVisible = NO;
        [self showHideAdView];
    }
}

//canBecomeFirstResponder (support shake gesutures)...
-(BOOL)canBecomeFirstResponder{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"canBecomeFirstResponder in BT_viewController BASE CLASS%@", @""]];
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"viewDidAppear in BT_viewController BASE CLASS%@", @""]];
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"viewWillDisappear in BT_viewController BASE CLASS%@", @""]];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}


//motionEnded (detect shake gesture)...
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(event.type == UIEventSubtypeMotionShake){
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"motionEnded in BT_viewController BASE CLASS%@", @""]];
        
        //appDelegate...
        revmobsampleapp_appDelegate *appDelegate = (revmobsampleapp_appDelegate *)[[UIApplication sharedApplication] delegate];
        
		//get possible loadScreenWithItemIdOnShake of the screen to load
		NSString *loadScreenWithItemIdOnShake = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"loadScreenWithItemIdOnShake" defaultValue:@""];
			
		//get possible loadScreenWithNicknameOnShake of the screen to load
		NSString *loadScreenWithNicknameOnShake = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"loadScreenWithNicknameOnShake" defaultValue:@""];
        
		//check for loadScreenWithItemIdOnShake THEN loadScreenWithNicknameOnShake THEN loadScreenOnShakeObject
		BT_item *screenObjectToLoad = nil;
		if([loadScreenWithItemIdOnShake length] > 1){
			screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenWithItemIdOnShake];
		}else{
			if([loadScreenWithNicknameOnShake length] > 1){
				screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenWithNicknameOnShake];
			}else{
				if([self.screenData.jsonVars objectForKey:@"loadScreenOnShakeObject"]){
					screenObjectToLoad = [[BT_item alloc] init];
					[screenObjectToLoad setItemId:[[self.screenData.jsonVars objectForKey:@"loadScreenOnShakeObject"] objectForKey:@"itemId"]];
					[screenObjectToLoad setItemNickname:[[self.screenData.jsonVars objectForKey:@"loadScreenOnShakeObject"] objectForKey:@"itemNickname"]];
					[screenObjectToLoad setItemType:[[self.screenData.jsonVars objectForKey:@"loadScreenOnShakeObject"] objectForKey:@"itemType"]];
					[screenObjectToLoad setJsonVars:[self.screenData.jsonVars objectForKey:@"loadScreenOnShakeObject"]];
				}
			}
		}
        
 		//load next screen if it's not nil
		if(screenObjectToLoad != nil){
			[BT_viewControllerManager handleTapToLoadScreen:[self screenData] theMenuItemData:nil theScreenData:screenObjectToLoad];
		}
        
        
    }
}

//mailComposeController sheet canceled / closed
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[BT_debugger showIt:self theMessage:@"mailComposeController:didFinishComposingMail"];
    [self dismissViewControllerAnimated:YES completion:nil];
	
	//delegate.
	revmobsampleapp_appDelegate *appDelegate = (revmobsampleapp_appDelegate *)[[UIApplication sharedApplication] delegate];
	
	//if this is an iPad AND our "currentScreenData" is BT_screen_imageEmail
	if([appDelegate.rootApp.rootDevice isIPad]){
		if([[appDelegate.rootApp.currentScreenData.jsonVars objectForKey:@"itemType"] isEqualToString:@"BT_screen_imageEmail"]){
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"emailImageDone", "Re-load this screen to re-start the process or to send another message") delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
		}
		
	}//is iPad
    
}


//messageComposeViewController (SMS) Compose sheet canceled / closed
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	[BT_debugger showIt:self theMessage:@"messageComposeViewController:didFinishComposingSMS"];
    [self dismissViewControllerAnimated:YES completion:nil];
	
}



//should rotate
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"shouldAutorotateToInterfaceOrientation %@", @""]];
	
	//allow / dissallow rotations
	BOOL canRotate = TRUE;
	
	//appDelegate
	revmobsampleapp_appDelegate *appDelegate = (revmobsampleapp_appDelegate *)[[UIApplication sharedApplication] delegate];
	if([appDelegate.rootApp.rootDevice isIPad]){
		canRotate = TRUE;
	}else{
		//should we prevent rotations on small devices?
		if([appDelegate.rootApp.jsonVars objectForKey:@"allowRotation"]){
			if([[appDelegate.rootApp.jsonVars objectForKey:@"allowRotation"] isEqualToString:@"largeDevicesOnly"]){
				canRotate = FALSE;
			}
		}
	}
	
	//can it rotate?
	if(canRotate){
		return YES;
	}else{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	
	//we should not get here
	return YES;
	
}

//will rotate
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"willRotateToInterfaceOrientation %@", @""]];
	
	//delegate
	revmobsampleapp_appDelegate *appDelegate = (revmobsampleapp_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	//some screens need to reload...
	UIViewController *theViewController;
	int selectedTab = 0;
	if([appDelegate.rootApp.tabs count] > 0){
		selectedTab = [appDelegate.rootApp.rootTabBarController selectedIndex];
		theViewController = [[appDelegate.rootApp.rootTabBarController.viewControllers objectAtIndex:selectedTab] visibleViewController];
	}else{
		theViewController = [appDelegate.rootApp.rootNavController visibleViewController];
	}
    
    //if this view controller has a property named "rotating" set it to true...
    if ([theViewController respondsToSelector:NSSelectorFromString(@"setIsRotating")]) {
        SEL s = NSSelectorFromString(@"setIsRotating");
        [theViewController performSelector:s];
    }
    
    
    
}


//did rotate
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didRotateFromInterfaceOrientation %@", @""]];
	
	//delegate
	revmobsampleapp_appDelegate *appDelegate = (revmobsampleapp_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	UIViewController *theViewController;
	int selectedTab = 0;
	if([appDelegate.rootApp.tabs count] > 0){
		selectedTab = [appDelegate.rootApp.rootTabBarController selectedIndex];
		theViewController = [[appDelegate.rootApp.rootTabBarController.viewControllers objectAtIndex:selectedTab] visibleViewController];
    }else{
		theViewController = [appDelegate.rootApp.rootNavController visibleViewController];
	}
    
    //if this view controller has a property named "rotating" set it to false...
    if([theViewController respondsToSelector:NSSelectorFromString(@"setNotRotating")]) {
        SEL s = NSSelectorFromString(@"setNotRotating");
        [theViewController performSelector:s];
    }
    
    
	//some screens need to re-build their layout...If a plugin has a method called
    //"layoutScreen" we trigger it everytime the device rotates. The plugin author can
    //create this method in the UIViewController (layoutScreen) if they need something to
    //happen after rotation occurs.
    
    //if this view controller has a "layoutScreen" method, trigger it...
    if([theViewController respondsToSelector:@selector(layoutScreen)]){
        SEL s = NSSelectorFromString(@"layoutScreen");
        [theViewController performSelector:s];
    }
    
    //resize possible ad view...
    if([theViewController respondsToSelector:@selector(resizeAdView)]){
        SEL s = NSSelectorFromString(@"resizeAdView");
        [theViewController performSelector:s];
    }
    
}




//dealloc
- (void)dealloc {
    [super dealloc];
}

@end







