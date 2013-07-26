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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "iAd/ADBannerView.h"
#import <MessageUI/MessageUI.h>
#import "BT_item.h"

@interface BT_viewController : UIViewController <UIAlertViewDelegate, 
												ADBannerViewDelegate,
                                                UIAccelerometerDelegate,
                                                MFMailComposeViewControllerDelegate,
                                                MFMessageComposeViewControllerDelegate>{
	BT_item *screenData;
	UIView *progressView;
	
	/* iAd Views */
	UIView *adView;
	ADBannerView *adBannerView;
	BOOL adBannerViewIsVisible;
	BOOL hasStatusBar;
	BOOL hasNavBar;
	BOOL hasToolBar;

}

@property (nonatomic, retain) BT_item *screenData;
@property (nonatomic, retain) UIView *progressView;
@property (nonatomic, retain) UIView *adView;
@property (nonatomic, retain) ADBannerView *adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;
@property (nonatomic) BOOL hasStatusBar;
@property (nonatomic) BOOL hasNavBar;
@property (nonatomic) BOOL hasToolBar;

-(id)initWithScreenData:(BT_item *)theScreenData;


-(void)showProgress;
-(void)hideProgress;
-(void)navLeftTap;
-(void)navRightTap;
-(void)showAudioControls;
-(void)showAlert:(NSString *)theTitle theMessage:(NSString *)theMessage alertTag:(int)alertTag;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

//iAd methods...
-(void)createAdBannerView;
-(void)resizeAdView;
-(void)showHideAdView;
-(void)bannerViewDidLoadAd:(ADBannerView *)banner;
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;

//shake capture...
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

//message compose delegate methods...
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;



//rotation methods...
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;





@end









