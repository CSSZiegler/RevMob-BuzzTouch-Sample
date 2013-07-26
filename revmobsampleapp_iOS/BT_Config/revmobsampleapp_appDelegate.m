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
#import "BT_downloader.h"
#import "JSON.h"
#import "BT_strings.h"
#import "BT_fileManager.h"
#import "BT_audioPlayer.h"
#import "BT_dates.h"
#import "BT_color.h"
#import "BT_application.h"
#import "BT_viewControllerManager.h"
#import "BT_debugger.h"
#import "BT_background_view.h"
#import "revmobsampleapp_appDelegate.h"

///////////////////////////////////////////////////
// RevMob
#import "SampleAppViewController.h"
#import <RevMobAds/RevMobAds.h>
///////////////////////////////////////////////////

@implementation revmobsampleapp_appDelegate
@synthesize uiIsVisible, window, refreshingView, globalBackgroundView, spinner, configurationFileName, saveAsFileName, modifiedFileName;
@synthesize configData, currentMode, rootApp, downloader, showDebugInfo, isDataValid, audioPlayer;
@synthesize soundEffectNames, soundEffectPlayers, receivedData;

///////////////////////////////////////////////////
// RevMob
@synthesize viewController = _viewController;
///////////////////////////////////////////////////

//didFinishLaunchingWithOptions...
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{    
    
	
	/*
		Debugging Output
		---------------------------------------------------------------------------
		Set showDebugInfo to TRUE to print details to the console.
		To see the console, choose Run > Show Console while the simulator or a connected device
		is running. Nearly every method has output to show you details about how the program
		is executing. It looks like lots of data (it is), but it's very useful for understanding how
		the application is behaving.
	*/
    
	//show debug in output window?
    [self setShowDebugInfo:true];
	
	/*
		Application Configuration File / Data
		---------------------------------------------------------------------------
		One file holds all the configuration data associated with the application. This file must exist
		in the applications bundle (drag it into Xcode if it's not already there). This file is normally
		named BT_config.txt and can be read / edited with a normal text editor. If this configuration data
		uses a dataURL, a remote server will be polled for content changes. Changes will be downloaded and 
		saved locally. Once	this happens, the BT_config.txt file is no longer used and instead the application 
		refers to it's newly downloaded and cached data. In other words, if a dataURL is used then the 
		configuration file in the Xcode project is only referenced so it can find the buzztouchAppId, buzztouchAPIKey,
		and dataURL. After that, it uses the data that was saved from the URL.  
		If no dataURL is provided, the file in the bundle will be read and parsed everytime the app is started.
	*/

    ///////////////////////////////////////////////////
    // RevMob
    [RevMobAds startSessionWithAppID:REVMOB_ID];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[SampleAppViewController alloc] init] autorelease];
    if ([self.window respondsToSelector:@selector(setRootViewController:)]) {
        [self.window setRootViewController:self.viewController];
    } else {
        [self.window addSubview:self.viewController.view];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
	///////////////////////////////////////////////////

//    //use a saved config file name if it exists...
//    NSString *tmpConfigFileName = [BT_strings getPrefString:@"configToUse"];
//    if([tmpConfigFileName length] > 5){
//        [BT_debugger showIt:self theMessage:@"Using a non-default configuration file."];
//        [self setConfigurationFileName:tmpConfigFileName];
//    }else{
//        [BT_debugger showIt:self theMessage:@"Using the default BT_config.txt."];
//        [self setConfigurationFileName:@"BT_config.txt"];
//    }
//
//    //initialize a temporary buzztouch app object to assign to the rootApp property...
//    BT_application *tmpApp = [[BT_application alloc] init];
//    
//    //initialize a temporary window to assign to the window property...
//    UIWindow *tmpWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [self setWindow:tmpWindow];
//    [tmpWindow release];
//
//    //assign the local app property...
//    [self setRootApp:tmpApp];
//    [tmpApp release];
//
//    //make the window active...
//    [self.window makeKeyAndVisible];
//    
//    //init audio player in background thread...
//    [NSThread detachNewThreadSelector: @selector(initAudioPlayer) toTarget:self withObject:nil];
//
//    //load sound effect players in background thread...
//    [NSThread detachNewThreadSelector: @selector(loadSoundEffects) toTarget:self withObject:nil];
//
//    //load the applications data...
//    [self loadAppData];
//    
//    //monitor shake gestures in UIViewControllers...
//    application.applicationSupportsShakeToEdit = YES;
//    
//    //return
//    return TRUE;
}


//didRegisterForRemoteNotificationsWithDeviceToken...
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didRegisterForRemoteNotificationsWithDeviceToken: Device Token: %@", deviceToken]];

    //if we have a token, and a  register it...
    if([deviceToken length] > 1 && [[self.rootApp registerForPushURL] length] > 1){
        
        //clean up token...
        NSString *useToken = [NSString stringWithFormat:@"%@", deviceToken];
        useToken = [useToken stringByReplacingOccurrencesOfString:@"<"withString:@""];
        useToken = [useToken stringByReplacingOccurrencesOfString:@">"withString:@""];
        useToken = [useToken stringByReplacingOccurrencesOfString:@" "withString:@""];
        
        //save it for next time...
        [BT_strings setPrefString:@"lastDeviceToken" valueOfPref:useToken];
        
        //append deviceToken and deviceType to end of URL...
        NSString *useURL = [[self.rootApp registerForPushURL] stringByAppendingString:[NSString stringWithFormat:@"&deviceType=%@", @"ios"]];
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&deviceToken=%@", useToken]];
        
        //append currentMode ("Live" or "Design") to end of URL...
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&currentMode=%@", [self currentMode]]];
        
        //merge environment variables in URL...
        useURL = [BT_strings mergeBTVariablesInString:useURL];
        
        //escape the URL...
        NSString *escapedUrl = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //tell the BT_device to register on the server (the device class makes the URL request)...
        [BT_device registerForPushNotifications:escapedUrl];
        
        
    }

}

//unRegisterForPushNotifications...
-(void)unRegisterForPushNotifications{
    
    //look for last token...
    NSString *deviceToken = [BT_strings getPrefString:@"lastDeviceToken"];
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"unRegisterForPushNotifications Device Token: %@", deviceToken]];

    //if we have a token, and a  register it...
    if([deviceToken length] > 1 && [[self.rootApp registerForPushURL] length] > 1){
        
        //clean up token...
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@"<"withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">"withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" "withString:@""];
        
        //erase last token...
        [BT_strings setPrefString:@"lastDeviceToken" valueOfPref:@""];
    
        //append deviceToken and deviceType and apnCommand to end of URL...
        NSString *useURL = [[self.rootApp registerForPushURL] stringByAppendingString:[NSString stringWithFormat:@"&deviceType=%@", @"ios"]];
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&apnCommand=%@", @"unregisterDevice"]];
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&deviceToken=%@", deviceToken]];
        
        //append currentMode ("Live" or "Design") to end of URL...
        useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&currentMode=%@", [self currentMode]]];
        
        //merge environment variables in URL...
        useURL = [BT_strings mergeBTVariablesInString:useURL];
        
        //escape the URL...
        NSString *escapedUrl = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //tell the BT_device to unRegister on the server (the device class makes the URL request)...
        [BT_device unRegisterForPushNotifications:escapedUrl];
        
    }
    
}

//didFailToRegisterForRemoteNotificationsWithError...
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError: ERROR: %@", error]];

}

//didReceiveRemoteNotification..
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didReceiveRemoteNotification %@", @""]];
    
        //don't do anything if the app is not in the foreground. iOS handles inbound APNS message when app is in the background...
        if(application.applicationState == UIApplicationStateActive){

    
            NSString *alertMsg;
            NSString *badge;
            NSString *sound;
        
            //alert message...
            if([[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != NULL){
                alertMsg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            }
        
            //badge...
            if([[userInfo objectForKey:@"aps"] objectForKey:@"badge"] != NULL){
                badge = [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
            }
        
            //sound...
            if([[userInfo objectForKey:@"aps"] objectForKey:@"sound"] != NULL){
                sound = [[userInfo objectForKey:@"aps"] objectForKey:@"sound"];
            }
        
            //if we have a sound...
            if([sound length] > 1){
                [self performSelector:@selector(playSoundFromPushMessage:) withObject:sound afterDelay:.1];
            }
        
            //show messsage...
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                      message:alertMsg
                                                      delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                      otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            
        }//in foreground...
}

//playSoundFromPushMessage...
-(void)playSoundFromPushMessage:(NSString *)soundEffectFileName{
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"playSoundFromPushMessage: %@", soundEffectFileName]];
    
    NSString *theFileName = soundEffectFileName;
    if([BT_fileManager doesFileExistInBundle:theFileName]){
        NSURL *soundFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], theFileName]];
        NSError *error;
        AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&error];
        if(!error){
            [tmpPlayer setNumberOfLoops:0];
            [tmpPlayer prepareToPlay];
            [tmpPlayer play];
            [tmpPlayer release];
        }else{
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didReceiveRemoteNotification soundEffectPlayer ERROR: %@", [error description]]];
        }
    }

}

/*
		
    loadAppData...
    -----------------------------------------------------------------------------------
    a) If a cached version of the app's configuration data is available, use that (then check for updates)
    b) If no cached version is available, use the data in the bundle (then check for updates)
    c) If no cached version is available, and no dataURL is provided in the bundle config file, use the bundle config data.
	
*/
-(void)loadAppData{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"refreshAppData%@", @""]];	
	
	//set the saveAsFileName and the modified file name (only used if configuration data is pulled from a remote server
	self.saveAsFileName = @"cachedAppConfig.txt";
	self.modifiedFileName = @"appModified.txt";
	self.configData = @"";

    //use a saved config file name if it exists...
    NSString *tmpConfigFileName = [BT_strings getPrefString:@"configToUse"];
    if([tmpConfigFileName length] > 5){
        [BT_debugger showIt:self theMessage:@"Using a non-default configuration file."];
        [self setConfigurationFileName:tmpConfigFileName];
    }else{
        [BT_debugger showIt:self theMessage:@"Using the default BT_config.txt."];
        [self setConfigurationFileName:@"BT_config.txt"];
    }
	
	//get the name of the configuration file
	NSString *bundleFileName = [self configurationFileName]; 
	if([bundleFileName length] < 4){
		[BT_debugger showIt:self theMessage:@"There is no config.txt file configured in revmobsampleapp_appDelegate.m?"];
		bundleFileName = @"thereIsNoFileName.txt";
	}
	
	//check for cached version of configuration data
	if([BT_fileManager doesLocalFileExist:self.saveAsFileName]){
	
		//read the configuration data from the cache...
		self.configData = [BT_fileManager readTextFileFromCacheWithEncoding:self.saveAsFileName encodingFlag:-1];
		
        //determine what "mode" we're in from the bundle data...
        if([BT_fileManager doesFileExistInBundle:bundleFileName]){
			NSString *bundleData = [BT_fileManager readTextFileFromBundleWithEncoding:configurationFileName encodingFlag:-1];
            SBJsonParser *parser = [SBJsonParser new];
            id jsonData = [parser objectWithString:bundleData];
            if(jsonData){
                if([[jsonData objectForKey:@"BT_appConfig"] objectForKey:@"BT_items"]){
                    NSArray *tmpItems = [[jsonData objectForKey:@"BT_appConfig"] objectForKey:@"BT_items"];
                    NSDictionary *thisApp = [tmpItems objectAtIndex:0];
                    if([thisApp objectForKey:@"currentMode"]){
                        [self setCurrentMode:[thisApp objectForKey:@"currentMode"]];
                     }
                }//BT_items
            }//jsonData
        }
        
        //log...        
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Using configuration data from application cache.%@", @""]];
	
        
	}else{
	
		if([BT_fileManager doesFileExistInBundle:bundleFileName]){
	
			//read the configuration data from the proejct bundle
			self.configData = [BT_fileManager readTextFileFromBundleWithEncoding:configurationFileName encodingFlag:-1];
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Using configuration data included in the project bundle.%@", @""]];


			//parse the BT_config.txt file in bundle data. If we don't have a dataURL, 
			//remove the possible cached verion of configuration data so app does not use cached version.
			//This approaches forces the app to use the BT_config.txt file and not the cached data.

			//create dictionary from the JSON string
			SBJsonParser *parser = [SBJsonParser new];
			id jsonData = [parser objectWithString:self.configData];
	   		if(jsonData){
				if([[jsonData objectForKey:@"BT_appConfig"] objectForKey:@"BT_items"]){
					NSArray *tmpItems = [[jsonData objectForKey:@"BT_appConfig"] objectForKey:@"BT_items"];
					NSDictionary *thisApp = [tmpItems objectAtIndex:0];
						if([thisApp objectForKey:@"dataURL"]){
							if([[thisApp objectForKey:@"dataURL"] length] < 1){
								[BT_fileManager deleteFile:saveAsFileName];
							}
                            if([thisApp objectForKey:@"currentMode"]){
                                [self setCurrentMode:[thisApp objectForKey:@"currentMode"]];
                            }
						}else{
							[BT_fileManager deleteFile:saveAsFileName];
						}
				}//BT_items
			}//jsonData


		}
	}

	
	//validate the configruation data
	if([self.configData length] > 5){
		
		if(![self.rootApp validateApplicationData:self.configData]){

			//show message in log, delete bogus data from the cache
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"error parsing application data.%@", @""]];
			[self showAlert:nil theMessage:NSLocalizedString(@"appDataInvalid", "The configuration data for this application is invalid.")];

			//delete bogus data (if it was in the cache)
			[BT_fileManager deleteFile:self.saveAsFileName];
		
		}else{
			
			//configure envrionment
			[self configureEnvironmentUsingAppData:self.configData];

		}
		
	}else{
	
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"could not read application configuration data.%@", @""]];
		[self showAlert:nil theMessage:NSLocalizedString(@"appDataInvalid", "The configuration data for this application is invalid.")];
	
	}
	
}//load data


//configureEnvironmentUsingAppData...
-(void)configureEnvironmentUsingAppData:(NSString *)appData{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"configureEnvironmentUsingAppData%@", @""]];

	//if not audio player was already initialized, we are refreshing... kill it.
	if(self.audioPlayer != nil){
		[self.audioPlayer stopAudio];
		[self.audioPlayer.audioPlayer setCurrentTime:0];
	}
	
    //always hide the status bar (themes or screens may show it)... setStatusBarHidden changed after iOS 3.0 >
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]){
        [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationNone]; 
    } else {
        [[UIApplication sharedApplication ] setStatusBarHidden:TRUE];
    } 
	
	
	//ask the application to parse the configuration data
	if(![self.rootApp parseJSONData:appData]){

		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"error parsing bundle application data: %@", @""]];
		[self showAlert:nil theMessage:NSLocalizedString(@"appParseError", "There was a problem parsing some configuration data. Please make sure that it is well-formed.")];
		
	}else{	

		//remove all previous sub-views (if we are refreshing)
		for (UIView *view in self.window.subviews){
			[view removeFromSuperview];
		}

		//ask the app to build it's inteface
		[self.rootApp buildInterface];
		
        //flag UI as visible...
        [self setUiIsVisible:TRUE];
        
		/*
			Background Logic
			-------------------------
			a) A full size view is always present "underneath" the applications view.
			b) If the global theme uses an image or a color, it will always show, else, it will be transparent
			c) If a screen over-rides the global themes background, it will render "over" the themes background.
			d) The view for the background is identified by a tag so individual screens can modify it.
		*/

		CGRect fullSizeFrame = CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height);
		globalBackgroundView = [[UIView alloc] initWithFrame:fullSizeFrame];
		globalBackgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[globalBackgroundView setBackgroundColor:[UIColor clearColor]];
		[globalBackgroundView setTag:1968]; 
		
		//Create a dummy screen object, needed to init a the background view object
		BT_item *dummyScreen = [[BT_item alloc] init];
		[dummyScreen setItemId:@"unusedInThisContext"];
		[dummyScreen setItemType:@"unusedInThisContext"];
		
		//background view object
		BT_background_view *tmpBackground = [[BT_background_view alloc] initWithScreenData:dummyScreen];
		[tmpBackground setTag:9999];
		[globalBackgroundView addSubview:tmpBackground];
		[dummyScreen release];
		[tmpBackground release];
	
		//add app's navigation controller (or tab controller)
		if([self.rootApp.tabs count] > 0){
			[self.rootApp.rootTabBarController.view addSubview:globalBackgroundView];
			[self.rootApp.rootTabBarController.view sendSubviewToBack:globalBackgroundView];
            
            /* 
                Changed for iOS 6
                iOS 6 requires the app's window to have a rootViewController set. 
             
                Previous code:
                [self.window addSubview:[self.rootApp.rootTabBarController view]];
            */
            [self.window.rootViewController = self.rootApp.rootTabBarController view];
            [self.window bringSubviewToFront:[self.rootApp.rootTabBarController view]];
		
        }else{
			if([self.rootApp.screens count] > 0){
				[self.rootApp.rootNavController.view addSubview:globalBackgroundView];
				[self.rootApp.rootNavController.view sendSubviewToBack:globalBackgroundView];
                
                /*
                 Changed for iOS 6
                 iOS 6 requires the app's window to have a rootViewController set.
                 
                 Previous code:
                 [self.window addSubview:[self.rootApp.rootNavController view]];
                 */
                [self.window.rootViewController = self.rootApp.rootNavController view];
                [self.window bringSubviewToFront:[self.rootApp.rootNavController view]];

			}
		}
		
		//all done, make sure progress is hidden..
		[self hideProgress];
		
		//if we didn't have any screens, show an error
		if([self.rootApp.screens count] < 1){
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"This application does not have any screens to display?%@",@""]];
			[self showAlert:nil theMessage:NSLocalizedString(@"appNoScreensError", @"No screens to display.")];
			
			//remove cached data (it must be bogus)...
			[BT_fileManager deleteFile:self.saveAsFileName];
			
		}
		
		//report to cloud after a slight delay (so UI doesn't get consufed)
		[self performSelector:@selector(reportToCloud) withObject:nil afterDelay:.3];
		
        
        //promptForPushNotifications...
        if([self.rootApp promptForPushNotifications]){
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"promptForPushNotifications %@",@""]];
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        }
		
		
	}//app parsed it's configuration data
}


/*
	downloadAppData...
    This method downloads application configuration data from a remote server.
	The downloader delegate methods at the end of this file handle the results
*/
-(void)downloadAppData{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloadAppData%@", @""]];

	//make sure we have a dataURL
	if([[self.rootApp dataURL] length] > 3){
	
		//show progress
		[self showProgress];
		
		//the dataURL may contain merge fields...
		NSString *tmpURL = [BT_strings mergeBTVariablesInString:[self.rootApp dataURL]];

        
        //if we have a currentMode in the BT_config.txt IN THE PROJECT, append it to the end of the URL...
        if([[self currentMode] length] > 0){
            tmpURL = [tmpURL stringByAppendingString:[NSString stringWithFormat:@"&currentMode=%@", [self currentMode]]];
        }
        
        
		//clean up URL
		NSString *escapedUrl = [tmpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        
		//download data (when it's done it will continue, see downloadFileCompleted at bottom)
		downloader = [[BT_downloader alloc] init];
		[downloader setSaveAsFileName:[self saveAsFileName]];
		[downloader setSaveAsFileType:@"return"];
		[downloader setUrlString:escapedUrl];
		[downloader setDelegate:self];
		[downloader downloadFile];
	
	}

}


//showProgress...
-(void)showProgress{
	[BT_debugger showIt:self theMessage:@"showProgress"];

		//build a semi-transparent overlay view (it's huge so it covers all screen sizes, regardless of rotation)
		self.refreshingView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		self.refreshingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.refreshingView setBackgroundColor:[UIColor blackColor]];
		[self.refreshingView setAlpha:.75];

		//build the spinner
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self.spinner startAnimating];
		[self.spinner setCenter:[self.refreshingView center]];
		[self.refreshingView addSubview:spinner];
		
		//add the view to the window
		[self.window addSubview:refreshingView];
		[self.window bringSubviewToFront:refreshingView];
}

//hideProgress...
-(void)hideProgress{
	[BT_debugger showIt:self theMessage:@"hideProgress"];
	if(refreshingView != nil){
		[refreshingView removeFromSuperview];
		refreshingView = nil;
	}
	if(spinner != nil){
		[spinner removeFromSuperview];
		spinner = nil;
	}
}



//showAlert...
-(void)showAlert:(NSString *)theTitle theMessage:(NSString *)theMessage{
	[self hideProgress];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:theTitle message:theMessage delegate:self
	cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

//getNavigationController...
-(BT_navigationController *)getNavigationController{
    BT_navigationController *theNavController;
    if([self.rootApp.tabs count] > 0){
        theNavController =  (BT_navigationController *)[self.rootApp.rootTabBarController selectedViewController];
    }else{
        theNavController = (BT_navigationController *)[self.rootApp rootNavController];
    }
    return theNavController;
}

//getViewController...
-(BT_viewController *)getViewController{
    return (BT_viewController *)[[self getNavigationController] topViewController];
}



//applicationDidBecomeActive...
- (void)applicationDidBecomeActive:(UIApplication *)application{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationDidBecomeActive%@", @""]];
		
	//make sure we have an app...
	if(self.rootApp != nil){
	
        //if a badge was set using APN, reset it each time the app becomes active...
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        //flag UI as visible...
        [self setUiIsVisible:TRUE];
        
		//report to cloud (not all apps do this)
		[self reportToCloud];
	
		//if we have a location manager, re-set it's "counter" and turn it back on.
		if(self.rootApp.rootLocationManager != nil){
			[self.rootApp.rootLocationManager setUpdateCount:0];
			[self.rootApp.rootLocationManager.locationManager startUpdatingLocation];
		}
		
	}
}

//applicationWillTerminate...
-(void)applicationWillTerminate:(UIApplication *)application{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationWillTerminate%@", @""]];

    //set ui as not visible...
    [self setUiIsVisible:FALSE];
    
}

//applicationWillResignActive...
-(void)applicationWillResignActive:(UIApplication *)application{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationWillResignActive%@", @""]];

    //set ui as not visible...
    [self setUiIsVisible:FALSE];
    
}

//applicationDidEnterBackground...
-(void)applicationDidEnterBackground:(UIApplication *)application{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationDidEnterBackground%@", @""]];

    //set ui as not visible...
    [self setUiIsVisible:FALSE];
    
}

//applicationWillEnterForeground...
-(void)applicationWillEnterForeground:(UIApplication *)application{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"applicationWillEnterForeground%@", @""]];

    //set ui as visible...
    [self setUiIsVisible:TRUE];
    
}



/*
	reportToCloud...
    This method makes a simple http request to a remote server. It's primary purpose is to
	track users, devices, and application updates. Not all users like this - be sure to honor their requests to
	prevent this. Do this by using a settings screen and give them a choice to turn off
	location / device tracking. If a user turns of device tracking, BT_strings does not
	merge location information in URL's.
*/

-(void)reportToCloud{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"reportToCloud%@", @""]];
	
	//app's configuration data must have  a "dataURL" and a "reportToCloudURL"...
	NSString *useURL = @"";
    
	if([[self.rootApp dataURL] length] > 1 && [[self.rootApp reportToCloudURL] length] > 1){
        useURL = [self.rootApp reportToCloudURL];
	}else{
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"not reporting to cloud, no dataURL or reportToCloudURL%@", @""]];
	}
	
	if([useURL length] > 3){
	
        //if we have a currentMode in the BT_config.txt IN THE PROJECT, append it to the end of the URL...
        if([[self currentMode] length] > 0){
            useURL = [useURL stringByAppendingString:[NSString stringWithFormat:@"&currentMode=%@", [self currentMode]]];
        }
        
		//the dataURL may contain merge fields...
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"reporting to cloud at : %@", useURL]];
		NSString *tmpURL = [BT_strings mergeBTVariablesInString:useURL];
		
		//clean-up URL, encode as UTF8
		NSURL *escapedURL = [NSURL URLWithString:[tmpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];	

		//make the http request
		NSMutableURLRequest  *theRequest = [NSMutableURLRequest requestWithURL:escapedURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];	
		[theRequest setHTTPMethod:@"GET"];  
		NSURLConnection *theConnection;
		if((theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self])){
			//prepare to accept data
			receivedData = [[NSMutableData data] retain];
		}else{
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"reportToCloud error? Could not init request%@", @""]];
		}
	}
}

//didReceiveResponse...
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[receivedData setLength:0];	
}

//didReceiveData...
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(data != nil){
		[receivedData appendData:data];
	}
}

//didFailWithError...
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"reportToCloud FAILED with error: %@", [error localizedDescription]]];
	[connection release];
	connection = nil;
}

//connectionDidFinishLoading...
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	[connection release];
	connection = nil;
	
	//save data as "lastModified" file
	NSString *dStringData = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];  
	if([dStringData length] > 3){
	
		//returned data format: {"lastModifiedUTC":"2011-02-22 02:13:25"}
		NSString *lastModified = @"";
		NSString *previousModified = @"";
		
		//parse returned JSON data
		SBJsonParser *parser = [SBJsonParser new];
  		id jsonData = [parser objectWithString:dStringData];
  		if(jsonData){
			if([jsonData objectForKey:@"lastModifiedUTC"]){
				lastModified = [jsonData objectForKey:@"lastModifiedUTC"];
				[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"lastModified (value on server): %@", lastModified]];
			}
		}
		
		//parse previous saved data
		if([BT_fileManager doesLocalFileExist:self.modifiedFileName]){
			NSString *previousData = [BT_fileManager readTextFileFromCacheWithEncoding:self.modifiedFileName encodingFlag:-1];
			SBJsonParser *parser = [SBJsonParser new];
  			id jsonData = [parser objectWithString:previousData];
  			if(jsonData){
				if([jsonData objectForKey:@"lastModifiedUTC"]){
					previousModified = [jsonData objectForKey:@"lastModifiedUTC"];
					[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"previousModified (value on device): %@", previousModified]];
				}
			}
		}
				
		//save a copy of the lastModified text for next time..
		BOOL saved = [BT_fileManager saveTextFileToCacheWithEncoding:dStringData fileName:self.modifiedFileName encodingFlag:-1];
		if(saved){};
			
		//if value are not emtpy, and different....ask user to confirm refresh...
		if([lastModified length] > 3 && [previousModified length] > 3){
			if(![lastModified isEqualToString:previousModified]){
				
				//show alert with confirmation...
				UIAlertView *modifiedAlert = [[UIAlertView alloc] 
					initWithTitle:nil 
					message:NSLocalizedString(@"updatesAvailable", "This app's content has changed, would you like to refresh?") 
					delegate:self 
					cancelButtonTitle:NSLocalizedString(@"no", "NO") 
					otherButtonTitles:NSLocalizedString(@"yes", "YES"), nil];
				[modifiedAlert setTag:12];
				[modifiedAlert show];
				[modifiedAlert release];

			}
		}else{
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@ does not exist in the cache. Not checking for updates.", self.modifiedFileName]];
		
		}
	}
	
	//clean up data
	[dStringData release];
	
}

//clickedButtonAtIndex...
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"alertView clickedButtonAtIndex: %d", buttonIndex]];
	int alertTag = [alertView tag];
	
	// 0 = no, 1 = yes
	if(buttonIndex == 0){
		//do nothing...
	}
	if(buttonIndex == 1 && alertTag == 12){
		//refresh entire app contents
		[self downloadAppData];
	}
	
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//downloader delegate methods. Called when refreshing app data.

//downloadFileStarted...
-(void)downloadFileStarted:(NSString *)message{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloadFileStarted: %@", message]];
}

//downloadFileInProgress...
-(void)downloadFileInProgress:(NSString *)message{
	//[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloadFileInProgress: %@", message]];
}

//downloadFileCompleted...
-(void)downloadFileCompleted:(NSString *)message{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"downloadFileCompleted%@", @""]];
	[self hideProgress];
	
	//message returns from downloader is the application data or an error message
	if([message rangeOfString:@"ERROR-1968" options:NSCaseInsensitiveSearch].location != NSNotFound){
		
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"the download process reported an error?: %@", message]];
		[self showAlert:nil theMessage:NSLocalizedString(@"downloadError", @"There was a problem downloading some data from the internet. If you're not connected to the internet, connect then try again.")];

	}else{
	
		//save the version we just downloaded...
		if([BT_fileManager saveTextFileToCacheWithEncoding:message fileName:[self saveAsFileName] encodingFlag:-1]){
			
			//the data we just got must be valid
			if([self.rootApp validateApplicationData:message]){
					
				//delete previously cached data (this does not remove the config file we just created)
				[BT_fileManager deleteAllLocalData];
			
				//rebuild environment using the data we just got
				[self configureEnvironmentUsingAppData:message];
			
			}else{
				
				[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"error parsing downloaded app config data%@", @""]];
				[self showAlert:nil theMessage:NSLocalizedString(@"appParseError", @"There was a problem parsing the app's configuration data. Please make sure that it is well-formed.")];
			
			}
			
		}else{

			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"error saving downloaded app config data%@", @""]];
			[self showAlert:nil theMessage:NSLocalizedString(@"errorSavingData", @"There was a problem saving some data to the devices cache?")];

		}
		
	}//no error
	
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//tab-bar controller delegate methods (we don't use these if we don't have a tabbed app)

//didSelectViewController...
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"tabBarController selected: %i", [tabBarController selectedIndex]]];

	//play possible sound effect
	if(self.rootApp != nil){
		if([self.rootApp.tabs count] > 0){

			//always hide the audio controls when changing tabs
			[self hideAudioControls];

			//data associated with the tab we just tapped
			BT_item *selectedTabData = [self.rootApp.tabs objectAtIndex:[tabBarController selectedIndex]];
		
			//the screen we are leaving may have an audio file that is
			//configured with "audioStopsOnScreenExit" so we may need to turn it off
			if([[BT_strings getJsonPropertyValue:self.rootApp.currentScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:self.rootApp.currentScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
				[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"stopping sound on screen exit%@", @""]];
				if([[BT_strings getJsonPropertyValue:self.rootApp.currentScreenData.jsonVars nameOfProperty:@"audioStopsOnScreenExit" defaultValue:@"0"] isEqualToString:@"1"]){
					if(self.audioPlayer != nil){
						[self.audioPlayer stopAudio];
					}
				}
			}		
			
			//data associated with the screen we are about to load
			NSString *screenToLoadId = [BT_strings getJsonPropertyValue:selectedTabData.jsonVars nameOfProperty:@"homeScreenItemId" defaultValue:@""];
			BT_item *screenToLoadData = [self.rootApp getScreenDataByItemId:screenToLoadId];
		
			//play possible sound effect attached to this menu item
			if([[BT_strings getJsonPropertyValue:selectedTabData.jsonVars nameOfProperty:@"soundEffectFileName" defaultValue:@""] length] > 3){
				[self playSoundEffect:[BT_strings getJsonPropertyValue:selectedTabData.jsonVars nameOfProperty:@"soundEffectFileName" defaultValue:@""]];
			}
			
			if([[BT_strings getJsonPropertyValue:screenToLoadData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:screenToLoadData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
				
				//start audio in different thread to prevent UI blocking
				[NSThread detachNewThreadSelector: @selector(loadAudioForScreen:) toTarget:self withObject:screenToLoadData];

			}
			
			//remember the screen we are loading in the rootApp
			[self.rootApp setCurrentScreenData:screenToLoadData];
			
		}
	}
	
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//audio player (screen background sound) methods

//initAudioPlayer...
-(void)initAudioPlayer{
	
	//this runs in it's own thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc ] init];
	
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"initAudioPlayer in background thread %@", @""]];
	
		//create the player
		self.audioPlayer = [[BT_audioPlayer alloc] initWithScreenData:nil];
		[self.audioPlayer.view setTag:999];
		
	//release pool
	[pool release];
	
}

//loadAudioForScreen...
-(void)loadAudioForScreen:(BT_item *)theScreenData{

	//this runs in it's own thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"loadAudioForScreen with itemId: %@", [theScreenData itemId]]];
	
	
		//theScreenData must have an "audioFileName" or an "audioFileURL" or ignore this...
    if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""] length] > 3 || [[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""] length] > 3){
	
			//tell audio player to load itself (this can take a moment depending on the size of the audio file)
			//[self.audioPlayer loadAudioForScreen];
			if(self.audioPlayer != nil){
				
				
				//get the file name for the existing audio player...
				NSString *playingAudioFileName = [BT_strings getJsonPropertyValue:self.audioPlayer.screenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""];
				NSString *playingAudioFileURL = [BT_strings getJsonPropertyValue:self.audioPlayer.screenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""];
				if(playingAudioFileName.length < 3 && playingAudioFileURL.length > 3){
					playingAudioFileName = [BT_strings getFileNameFromURL:playingAudioFileURL];
				}
								
				//figure out the next file name if we're using a URL
				NSString *nextAudioFileName = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""];
				NSString *nextAudioFileURL = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""];
				if(nextAudioFileName.length < 3 && nextAudioFileURL.length > 3){
					nextAudioFileName = [BT_strings getFileNameFromURL:nextAudioFileURL];
				}				
				
				//if the audio player already has the same audio track loaded...ignore
				if(![playingAudioFileName isEqualToString:nextAudioFileName]){
				
					[self.audioPlayer stopAudio];
					[self.audioPlayer loadAudioForScreen:theScreenData];
				
				}else{
				
					//the same track is already loaded...make sure it's playing
					[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"audio track already loaded: %@", nextAudioFileName]];
					[self.audioPlayer startAudio];
					
				}
			}
		
		}//audioFileName

	//release pool
	[pool release];

}


//showAudioControls...
-(void)showAudioControls{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"showAudioControls %@", @""]];
	
	//show the audio players view
	if(self.audioPlayer != nil){
		
        //get reference to navigation controller...
        BT_navigationController *theNavController = [self getNavigationController];
		
		//find center of screen for current device orientation
		CGPoint tmpCenter;
		UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
		if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight) {
			tmpCenter = CGPointMake([self.rootApp.rootDevice deviceHeight] / 2, ([self.rootApp.rootDevice deviceWidth] / 2));;
		}else{
			tmpCenter = CGPointMake([self.rootApp.rootDevice deviceWidth] / 2, [self.rootApp.rootDevice deviceHeight] / 2);;
		}
		
		//if the view isn't already on the nav controller..add it. audioPlayer view has tag "999"
		BOOL havePlayerView = FALSE;
		for(UIView *view in theNavController.view.subviews) {
		   	if([view tag] == 999){
				havePlayerView = TRUE;
				break;			
		   	}
		}
		//add the subview to this controller if we don't already have it
		if(!havePlayerView){
			[theNavController.view addSubview:[self.audioPlayer view]];
		}
		
		//bring it to the front
		[theNavController.view bringSubviewToFront:[self.audioPlayer view]];

		//makie it visible
		[self.audioPlayer.view setHidden:FALSE];
		
		//center it
		[self.audioPlayer.view setCenter:tmpCenter];
  		
	}
	
}


//hideAudioControls...
-(void)hideAudioControls{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"hideAudioControls %@", @""]];

	//move the the audio players view off the screen and hide it
	if(self.audioPlayer != nil){
	
        //get reference to navigation controller...
        BT_navigationController *theNavController = [self getNavigationController];
        
		
		//find the audioPlayer's view on the controller. audioPlayer view has tag "999"
		for(UIView *view in theNavController.view.subviews) {
		   	if([view tag] == 999){
				
				//move it, hide it
				[view setCenter:CGPointMake(-500, -500)];
				[view setHidden:TRUE];
				break;			
		   	}
		}

	}

}


///////////////////////////////////////////////////////////////////////
//sound effect methods

/*
 
    loadSoundEffects...
    the sound effects you want to use must be added to your Xcode project
    then added to this soundEffectNames array. See example on line 1110, 1111..
 
*/
-(void)loadSoundEffects{
	//this runs in it's own thread
	NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
	
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"loadSoundEffects SEE appDelegete.m, line 924 %@", @""]];
    
	
	//fill an array of sound effect file names...
	self.soundEffectNames = [[NSMutableArray alloc] init];	
	
    /*
    [self.soundEffectNames addObject:@"basso.mp3"];
	[self.soundEffectNames addObject:@"blow.mp3"];
     */
    
	//setup audio session for sound effects...
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
	[[AVAudioSession sharedInstance] setActive: YES error: nil];

	//fill an array of sound effect player objects to pre-load with each audio track...
	self.soundEffectPlayers = [[NSMutableArray alloc] init];
    
	for(int x = 0; x < [self.soundEffectNames count]; x++){
	
		NSString *theFileName = [self.soundEffectNames objectAtIndex:x];
		if([BT_fileManager doesFileExistInBundle:theFileName]){
			NSURL *soundFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], theFileName]];
			NSError *error;
			AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&error];
			[tmpPlayer setNumberOfLoops:0];
			[tmpPlayer prepareToPlay];
			[tmpPlayer setDelegate:self];
			[self.soundEffectPlayers addObject:tmpPlayer];
			[tmpPlayer release];
		}
		
	}
	
    
	//release pool
	[pool release];
	
}


//playSoundEffect...
-(void)playSoundEffect:(NSString *)theFileName{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"playSoundEffect %@", theFileName]];
	if([theFileName length] > 3){
	
		/*
			play sound effect logic
			a) Check the soundEffectNames array for the file name
			b) if it exists, we already instantiated an audio-player object in the soundEffectPlayers array
			c) Find the index of that player in the array then play it...
	
		*/
		
		if([self.soundEffectNames containsObject:theFileName]){
			int playerIndex = [self.soundEffectNames indexOfObject:theFileName];
			//we already initialized a player for this sound. Find it, play it.
			AVAudioPlayer *tmpPlayer = (AVAudioPlayer *)[self.soundEffectPlayers objectAtIndex:playerIndex];
			if(tmpPlayer){
				[tmpPlayer play];
			}
		}else{
			[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"playSoundInBundle:ERROR. This sound effect is not included in the list of available sounds: %@", theFileName]];
		}
	}
	
}



//supportedInterfaceOrientationsForWindow...
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"supportedInterfaceOrientationsForWindow %@", @""]];
    
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
                NSLog(@"%@", @"SHOULD NOT ROTATE");
                canRotate = FALSE;
			}
		}
	}
    
	//bitwise OR operator...
    NSUInteger mask = 0;
    	
		mask |= UIInterfaceOrientationMaskPortrait;
    	if(canRotate){
        	mask |= UIInterfaceOrientationMaskLandscapeLeft;
        	mask |= UIInterfaceOrientationMaskLandscapeRight;
        	mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    	}
		
	
    return mask;
}



//dealloc...
- (void)dealloc {
	[super dealloc];
	[window release];
	[refreshingView release];
		refreshingView = nil;
	[globalBackgroundView release];
		globalBackgroundView = nil;
	[audioPlayer release];
		audioPlayer = nil;
	[spinner release];
		spinner = nil;
	[configurationFileName release];
		configurationFileName = nil;
	[saveAsFileName release];
		saveAsFileName = nil;
	[modifiedFileName release];
		modifiedFileName = nil;
	[configData release];
		configData = nil;
    [currentMode release];
        currentMode = nil;
	[rootApp release];
		rootApp = nil;
	[downloader	release];
		downloader = nil;
	[audioPlayer release];
		audioPlayer = nil;
	[receivedData release];
		receivedData = nil;
	[super dealloc];
}





@end










