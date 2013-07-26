/*  File Version: 3.0
 *	Copyright, David Book, buzztouch.com
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
package com.revmobsampleapp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

///////////////////////////////////////////////////
// RevMob
import com.revmob.RevMob;
import com.revmob.RevMobTestingMode;
import com.revmob.RevMobUserGender;
///////////////////////////////////////////////////
import com.revmob.RevMobAdsListener;
import com.revmob.ads.banner.RevMobBanner;
import com.revmob.ads.fullscreen.RevMobFullscreen;
import com.revmob.ads.link.RevMobLink;
import com.revmob.ads.popup.RevMobPopup;
import com.revmob.internal.RMLog;

public class BT_activity_root extends Activity{

	//member variables
	public String activityName = "BT_activity_root";
	public AlertDialog myAlert = null;
	public ProgressDialog progressBox = null;
	public BT_progressSpinner progressSpinner = null;
	public String configData = "";
	public boolean needsRefreshed = false;
	
	///////////////////////////////////////////////////
	// RevMob
	private static String REVMOB_APPID = "5106bea78e5bd71500000098";
	
	RevMobAdsListener revmobListener = new RevMobAdsListener() {
		@Override
		public void onRevMobAdReceived() {
			toastOnUiThread("RevMob ad received.");
		}

		@Override
		public void onRevMobAdNotReceived(String message) {
			toastOnUiThread("RevMob ad not received.");
		}

		@Override
		public void onRevMobAdDismiss() {
			toastOnUiThread("Ad dismissed.");
		}

		@Override
		public void onRevMobAdClicked() {
			toastOnUiThread("Ad clicked.");
		}

		@Override
		public void onRevMobAdDisplayed() {
			toastOnUiThread("Ad displayed.");
		}
	};

	RevMob revmob;
	boolean useUIThread = true;
	Activity currentActivity; // for anonymous classes
	RevMobFullscreen fullscreen;
	RevMobBanner banner;
	RevMobPopup popup;
	RevMobLink link;
	
	void updateTestInfo() {
		((Button) this.findViewById(R.id.buttonChangeActivity)).setText("Change to Activity 2");
		String activityStr = getClass().getSimpleName().equals("SampleApp") ? "Activity 1" : "Activity 2";
		String threadStr = useUIThread == true ? "UIThread" : "Another thread";
		String testingModeStr;
		if (revmob.getTestingMode() == RevMobTestingMode.WITH_ADS) {
			testingModeStr = "Test mode with ads";
		} else if (revmob.getTestingMode() == RevMobTestingMode.WITHOUT_ADS) {
			testingModeStr = "Test mode without ads";
		} else {
			testingModeStr = "Test mode disabled";
		}
		((TextView) this.findViewById(R.id.textTestInfo)).setText(activityStr + " / " + threadStr + " / " + testingModeStr);
	}

	// Test functions

	public void changeActivity(View v) {
//		Intent intent = new Intent(currentActivity, SampleApp2.class);
//		startActivity(intent);
	}

	public void changeThread(View v) {
		useUIThread = ! useUIThread;
		updateTestInfo();
	}

	public void testingModeWithAds(View v) {
		revmob.setTestingMode(RevMobTestingMode.WITH_ADS);
		updateTestInfo();
	}

	public void testingModeWithoutAds(View v) {
		revmob.setTestingMode(RevMobTestingMode.WITHOUT_ADS);
		updateTestInfo();
	}

	public void testingModeDisable(View v) {
		revmob.setTestingMode(RevMobTestingMode.DISABLED);
		updateTestInfo();
	}

	public void printEnvironmentInformation(View v) {
		if (useUIThread) {
			revmob.printEnvironmentInformation(currentActivity);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { revmob.printEnvironmentInformation(currentActivity); }});
		}
	}

	public void closeApplication(View v) {
		setResult(0);
		finish();
		System.exit(0);
	}

	// Fullscreen

	public void showFullscreen(View v) {
		if (useUIThread) {
			revmob.showFullscreen(currentActivity);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { revmob.showFullscreen(currentActivity); } });
		}
	}

	public void loadFullscreen(View v) {
		if (useUIThread) {
			fullscreen = revmob.createFullscreen(currentActivity, revmobListener);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { fullscreen = revmob.createFullscreen(currentActivity, revmobListener); } });
		}
	}

	public void showLoadedFullscreen(View v) {
		if (useUIThread) {
			if (fullscreen != null) {
				fullscreen.show();
			}
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { if (fullscreen != null) {
					fullscreen.show();
				} } });
		}
	}

	// Banner

	void showBanner() {
		banner = revmob.createBanner(currentActivity, revmobListener);
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ViewGroup view = (ViewGroup) findViewById(R.id.banner);
				view.addView(banner);
			}
		});
	}

	public void showBanner(final View v) {
		if (useUIThread) {
			showBanner();
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { showBanner(); } });
		}
	}

	public void showBannerCustomSize(View v) {
		RevMobBanner banner = revmob.createBanner(currentActivity);
		ViewGroup view = (ViewGroup) findViewById(R.id.bannerCustomSize);
		view.removeAllViews();
		view.addView(banner);
	}

	// Link

	public void openAdLink(View v) {
		if (useUIThread) {
			revmob.openAdLink(currentActivity, revmobListener);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { revmob.openAdLink(currentActivity, revmobListener); }});
		}
	}

	public void loadAdLink(View v) {
		if (useUIThread) {
			link = revmob.createAdLink(currentActivity, revmobListener);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { link = revmob.createAdLink(currentActivity, revmobListener); }});
		}
	}

	public void openLoadedAdLink(View v) {
		if (useUIThread) {
			if (link != null) {
				link.open();
			}
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { if (link != null) {
					link.open();
				} }});
		}
	}

	// Popup

	public void showPopup(View v) {
		if (useUIThread) {
			revmob.showPopup(currentActivity);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { revmob.showPopup(currentActivity); } });
		}
	}

	public void loadPopup(View v) {
		if (useUIThread) {
			popup = revmob.createPopup(currentActivity, revmobListener);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { popup = revmob.createPopup(currentActivity, revmobListener); } });
		}
	}

	public void showLoadedPopup(View v) {
		if (useUIThread) {
			if (popup != null) {
				popup.show();
			}
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { if (popup != null) {
					popup.show();
				} } });
		}
	}

	// Notification

	public void scheduleNotification(View v) {
		if (useUIThread) {
			revmob.scheduleNotification(currentActivity, R.drawable.revmob, null, revmobListener);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { revmob.scheduleNotification(currentActivity, R.drawable.revmob, null, revmobListener); } });
		}
	}

	public void scheduleCustomNotification(View v) {
		final Calendar cal = Calendar.getInstance();
		cal.add(Calendar.SECOND, 5);
		if (useUIThread) {
			revmob.scheduleNotification(currentActivity, R.drawable.revmob, null, revmobListener, cal);
		} else {
			runOnAnotherThread(new Runnable() { @Override
				public void run() { revmob.scheduleNotification(currentActivity, R.drawable.revmob, null, revmobListener, cal); } });
		}
	}

	// Auxiliar methods

	void runOnAnotherThread(Runnable action) {
		new Thread(action).start();
	}

	void toastOnUiThread(final String message) {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Toast.makeText(currentActivity, message, Toast.LENGTH_SHORT).show();
			}
		});
	}

	void fillUserInfo() {
		revmob.setUserGender(RevMobUserGender.FEMALE);
		revmob.setUserAgeRangeMin(18);
		revmob.setUserAgeRangeMax(25);
		revmob.setUserBirthday(new GregorianCalendar(1990, 11, 12));
		revmob.setUserPage("twitter.com/revmob");
		ArrayList<String> interests = new ArrayList<String>();
		interests.add("mobile");
		interests.add("Android");
		interests.add("apps");
		revmob.setUserInterests(interests);

		LocationManager locationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
		Location gpsLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
		Location netLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);

		if (gpsLocation != null) {
			revmob.setUserLocation(gpsLocation.getLatitude(), gpsLocation.getLongitude(), gpsLocation.getAccuracy());
		}
		else if (netLocation != null) {
			revmob.setUserLocation(netLocation.getLatitude(), netLocation.getLongitude(), netLocation.getAccuracy());
		}
		else {
			RMLog.d("No location data available");
		}
	}
	///////////////////////////////////////////////////

	///////////////////////////////////////////////////
	//activity life-cycle events
	
    //onCreate
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
		BT_debugger.showIt(activityName + ":onCreate");	
		
	    ///////////////////////////////////////////////////
	    // RevMob
		currentActivity = this;
		setContentView(R.layout.main);
		revmob = RevMob.start(currentActivity, REVMOB_APPID);
		fillUserInfo();
		updateTestInfo();
        ///////////////////////////////////////////////////
	    
//		//no title, full screen
//		requestWindowFeature(Window.FEATURE_NO_TITLE);
//		
//		//uncomment the next line to force full screen (no status bar) on launch...
//		//getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
//		
//       /*
//         *****************************************************************************************
//         * app's interface is displayed after this activity loads the app's configuration data. 
//         * The GUI is displayed by the next activity. The next activity is either:
//         * BT_activity_home OR BT_activity_root_tabs (if this layout uses tabs).
//         *****************************************************************************************
//         */
//		
//		//always show progress
// 		showProgress(null, null);
//
//		//create handler object to process after loadAppDataWorkerThread finishes...
//		//loadAppDataHandler = new Handler();
//		
//		//if an activity was started with a payload we are "refreshing" app data...
//		Intent startedFromIntent = getIntent();
//		int isRefreshing = startedFromIntent.getIntExtra("isRefreshing", -1);
//		if(isRefreshing > -1){
//			BT_debugger.showIt(activityName + ":refreshing...");	
//			
//			//flag as needing refreshed...Do not delete any cached data until new configuration data
//			//is downloaded. This ensures we have "something" to show if the connection fails..
//			needsRefreshed = true;
//		
//		}
//		
//        //load app data (creates background thread so UI does not block)
//		this.loadAppData();		
    }//end onCreate
	
	//onStart
	@Override 
	protected void onStart() {
		//BT_debugger.showIt(activityName + ":onStart");	
		super.onStart();
	}
	
    //onResume
    @Override
    public void onResume() {
       super.onResume();
       //BT_debugger.showIt(activityName + ":onResume");	
	   ///////////////////////////////////////////////////
	   // RevMob
       revmob.openNotification(currentActivity);
       ///////////////////////////////////////////////////
    }
    
    //onPause
    @Override
    public void onPause() {
        super.onPause();
        //BT_debugger.showIt(activityName + ":onPause");	
    }
    
    //onStop
	@Override 
	protected void onStop(){
		super.onStop();
        //BT_debugger.showIt(activityName + ":onStop");	
	}	
	
	//onDestroy
    @Override
    public void onDestroy() {
        super.onDestroy();
        //BT_debugger.showIt(activityName + ":onDestroy");	
    }
    
	//end activity life-cycle events
	//////////////////////////////////////////////////////////////////////////

	//show alert message dialogue
	public void showAlert(String theTitle, String theMessage) {
		myAlert = new AlertDialog.Builder(this).create();
		myAlert.setTitle(theTitle);
		myAlert.setMessage(theMessage);
		myAlert.setIcon(R.drawable.icon);
		myAlert.setCancelable(false);
		myAlert.setButton("OK", new DialogInterface.OnClickListener() {
	      public void onClick(DialogInterface dialog, int which) {
	        myAlert.dismiss();
	    } }); 
		try{
			myAlert.show();
		}catch(Exception e){
			
		}
	}	
	
	//show / hide progress (two different types, depending on the message)...
	public void showProgress(String theTitle, String theMessage){
		if(theTitle == null && theMessage == null){
	        progressSpinner = BT_progressSpinner.show(this, null, null, true);
		}else{
			progressBox = ProgressDialog.show(this, theTitle, theMessage, true);
		}
	}
	public void hideProgress(){
		if(progressBox != null){
			progressBox.dismiss();
		}
		if(progressSpinner != null){
			progressSpinner.dismiss();
		}
	}
	
	//transitionToAppHomeScreen (after parsing or confirming updates)...
	public void transitionToAppHomeScreen(){
		BT_debugger.showIt(activityName + ":transitionToAppHomeScreen");
        
		//we must have config data...
		if(configData.length() < 1){
			
			showAlert(getString(R.string.errorTitle), getString(R.string.errorConfigData) + "(3)");
			BT_debugger.showIt(activityName + ":transitionToAppHomeScreen ERROR config data not valid?");
		
		}else{
			
			//get the theme data to find a possible splash screen...
			BT_item theThemeData = revmobsampleapp_appDelegate.rootApp.getRootTheme();
			
			String splashScreenItemId = BT_strings.getJsonPropertyValue(theThemeData.getJsonObject(), "splashScreenItemId", "");
			if(splashScreenItemId.length() > 1){
				BT_debugger.showIt(activityName + ":transitionToAppHomeScreen splash screen with itemId: " + splashScreenItemId);
			
				//get the splash screen object and remember it...
				BT_item tmpScreenData = revmobsampleapp_appDelegate.rootApp.getScreenDataByItemId(splashScreenItemId);
				
				//remember the current screen
				revmobsampleapp_appDelegate.rootApp.setCurrentScreenData(tmpScreenData);
				String theActivityClass = "com.revmobsampleapp." + tmpScreenData.getItemType();

				try{
					
					Intent i = new Intent().setClass(revmobsampleapp_appDelegate.getContext(), Class.forName(theActivityClass));

					i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
					i.putExtra("isSplash", 1);
					startActivity(i);
					
					//finish this activity so it cannot be returned to...
					finish();
					
					//fade in splash screen.
	                overridePendingTransition(R.anim.fadein,R.anim.fadeout);
					
			    }catch(ClassNotFoundException e) {
					BT_debugger.showIt(activityName + ":transitionToAppHomeScreen ERROR loading splash screen for plugin type: " + theActivityClass);
			    }
			    
			}else{
		
				//not using a splash screen...
				
				//tabbed interface or not?
				if(revmobsampleapp_appDelegate.rootApp.getTabs().size() > 0){
					BT_debugger.showIt(activityName + ":transitionToAppHomeScreen tabbed interface (BT_activity_root_tabs).");
				
					try{
						
						Intent i = new Intent(BT_activity_root.this, BT_activity_root_tabs.class);
						i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
						startActivity(i);

						//finish this activity so it cannot be returned to...
						finish();
					
						//fade in splash screen.
						overridePendingTransition(R.anim.fadein,R.anim.fadeout);
						
					}catch(Exception e){
						BT_debugger.showIt(activityName + ":ERROR starting intent for BT_activity_root_tabs.");
					}
					
				}else{ //tabs.size() < 0
					
					BT_debugger.showIt(activityName + ":transitionToAppHomeScreen non-tabbed home screen.");

					//get the splash screen object...
					BT_item tmpScreenData = revmobsampleapp_appDelegate.rootApp.getHomeScreen();
					
					//flag it as the home screen...
					tmpScreenData.setIsHomeScreen(true);
					
					//remember the current screen
					revmobsampleapp_appDelegate.rootApp.setCurrentScreenData(tmpScreenData);
					String theActivityClass = "com.revmobsampleapp." + tmpScreenData.getItemType();
					try{
						
						Intent i = new Intent().setClass(revmobsampleapp_appDelegate.getContext(), Class.forName(theActivityClass));
						//i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
						startActivity(i);
						
						//finish this activity so it cannot be returned to...
						finish();
						
						//fade in splash screen.
		                overridePendingTransition(R.anim.fadein,R.anim.fadeout);

				    }catch(ClassNotFoundException e) {
						BT_debugger.showIt(activityName + ":transitionToAppHomeScreen ERROR loading home screen for plugin type: " + theActivityClass);
				    }
						
				}
			
			}//no splashScreenItemId
					
		}//configData.length > 0		
		
	}//end transitionToAppHomeScreen
	
	//show toast
	public void showToast(String theMessage, String shortOrLong){
		Toast toast = null;
		if(shortOrLong.equalsIgnoreCase("short")){
			toast = Toast.makeText(revmobsampleapp_appDelegate.getContext(), theMessage, Toast.LENGTH_SHORT);
		}else{
			toast = Toast.makeText(revmobsampleapp_appDelegate.getContext(), theMessage, Toast.LENGTH_LONG);
		}
		toast.show();
	}	

	
	//handles messages after refresh thread completes...
	private Handler mHandler = new Handler(){
		@Override
		public void handleMessage(Message msg){
 			
			//hide progress...
 			hideProgress();
 			
 			//config data must be loaded at this point...
			if(configData.length() < 1){
				
				showAlert(getString(R.string.errorTitle), getString(R.string.errorConfigData) + " (2)");
			
			}else{

				//transition to home screen or tabbed interface with multiple home screens...
	   			transitionToAppHomeScreen();
				
			}		
		}
	};
	
	//loadAppData
	public void loadAppData(){
		BT_debugger.showIt(activityName + ":loadAppData");			

		new Thread(){
			
			@Override
			public void run(){
				
		   		//prepare looper...
	    		Looper.prepare();

	    		//update device connection type...
				revmobsampleapp_appDelegate.rootApp.getRootDevice().updateDeviceConnectionType();
				
				//update device size...
				revmobsampleapp_appDelegate.rootApp.getRootDevice().updateDeviceSize();
				
	 			//fill this from cached data, downloaded data, or eclipse data...
				configData = "";
						
				//local vars...
				String configurationFileName = revmobsampleapp_appDelegate.configurationFileName;
				String cachedConfigDataFileName = revmobsampleapp_appDelegate.cachedConfigDataFileName;
				String cachedConfigModifiedFileName = revmobsampleapp_appDelegate.cachedConfigModifiedFileName;
				
				//empty BT_item to hold "currentScreenData" before we use so it always has a value...
				BT_item tmpScreenData = new BT_item();
				tmpScreenData.setItemId("na");
				tmpScreenData.setItemNickname("na");
				tmpScreenData.setItemType("na");
				revmobsampleapp_appDelegate.rootApp.setCurrentScreenData(tmpScreenData);
				

				//fill a variable with the BT_config.txt in Eclipse. The BT_config.txt data is eclipse
				//is ALWAYS looked at, everytime the app loads, regardless of whether or not it's used
				//in the app. We need to look at it to see if it has a dataURL. If no dataURL is used, 
				//but a previous cached version of data is found, remove the cached data.
				
				String eclipseConfigData = "";
				boolean checkForCachedData = true;
				
				try{
					BT_debugger.showIt(activityName + ":loadAppData loading BT_config.txt from /assests folder in Eclipse project...");			
					if(BT_fileManager.doesProjectAssetExist("", configurationFileName)){
						eclipseConfigData = BT_fileManager.readTextFileFromAssets("", configurationFileName);
						BT_debugger.showIt(activityName + ":loadAppData loaded BT_config.txt from /assets folder successfully...");			
					}
				}catch(Exception e){
					BT_debugger.showIt(activityName + ":loadAppData EXCEPTION loading BT_config.txt from the /assets folder " + e.toString());			
				}
				
				//did we find any local data...
				if(eclipseConfigData.length() < 1){
					BT_debugger.showIt(activityName + ":loadAppData ERROR loading BT_config.txt from the /assets folder? Existing app.");			
					
					//tell hander we're done. It's on the main UI thread so it can show alerts...
					//loadAppDataHandler.post(appDataDoneLoading);
					sendMessageToMainThread(0);

				}else{

					//look for dataURL in BT_conifg.txt in the Eclipse project...
					if(revmobsampleapp_appDelegate.rootApp.getDataURLFromAppData(eclipseConfigData).length() < 1){

						//because the configuration data in the project does not use a dataURL we need to remove a
						//possible previously cached version. Unusual for this to happen but possible...
							
						BT_debugger.showIt(activityName + ":loadAppData BT_config.txt file does not use a dataURL for remote updates...");			
						BT_fileManager.deleteFile(cachedConfigDataFileName);
						checkForCachedData = false;
						
						//configData is the data from BT_config.txt in Eclipse...
						configData = eclipseConfigData;
						
		    			BT_debugger.showIt(activityName + ":loadAppData continuing to load with BT_config.txt data in Eclipse project...");	
							
					}else{
						
		    			BT_debugger.showIt(activityName + ":loadAppData BT_config.txt file does use a dataURL for remote updates...");	
						checkForCachedData = true;
						
					}
					
				}//if eclipseConfigData.length() 
				
				//check for cached version of app's config data...
				if(checkForCachedData){
					if(BT_fileManager.doesCachedFileExist(cachedConfigDataFileName)){
						configData = BT_fileManager.readTextFileFromCache(cachedConfigDataFileName);
						BT_debugger.showIt(activityName + ":loadAppData reading " + cachedConfigDataFileName + " from the applications download cache...");
		    			BT_debugger.showIt(activityName + ":loadAppData ignoring BT_config.txt file in Eclipse project...");	
					
					}else{
						
						//configData is the eclipseConfigData data...
						configData = eclipseConfigData;
		    			BT_debugger.showIt(activityName + ":loadAppData " + cachedConfigDataFileName + " does not exist in the cache...");	
					
					}
				}

				//at this point config data is from cache or from BT_config.txt in Eclipse ...
				if(configData.length() > 1){
					
					try{
					
						//validate data loaded from cache...
			    	    if(revmobsampleapp_appDelegate.rootApp.validateApplicationData(configData)){
			    			BT_debugger.showIt(activityName + ": application data appears to be valid JSON...");	

			    			//parse the configuration data found in the bundle or in the cache
			    	    	revmobsampleapp_appDelegate.rootApp.parseAppJSONData(configData);

			    	    }else{
			    			BT_debugger.showIt(activityName + ": application data is not valid JOSN data? You could try to use an online JSON validator. Several good ones exist online. Exiting App.");	
			    	    	configData = "";
			    	    }
						
			    	    //Download new data if we have a dataURL and needsRefreshed = true. needsRefreshed will equal true
			    	    //when the user taps the refreshButton or agrees to download after an alert...The app will NEVER
			    	    //download data from it's dataURL when it first launches.
						String dataURL = revmobsampleapp_appDelegate.rootApp.getDataURL();
						dataURL = BT_strings.mergeBTVariablesInString(dataURL);
						if(dataURL.length() > 5 && needsRefreshed){
						
							//if we have a currentMode, append it to the end of the URL...
							if(revmobsampleapp_appDelegate.rootApp.getCurrentMode().length() > 1){
								dataURL += "&currentMode=" + revmobsampleapp_appDelegate.rootApp.getCurrentMode();
							}					

				 			BT_debugger.showIt(activityName + ":loadAppDataWorkerThread downloading app data from: " + dataURL);
		
				 			//downloader object..
		    			 	BT_downloader objDownloader = new BT_downloader(dataURL);
		    			 	objDownloader.setSaveAsFileName("");
		    			 	String downloadedData = objDownloader.downloadTextData();
		    			 	if(downloadedData.length() > 5){
		    			 		
		      			 		//if it's valid, remove the previously cached version...
		    			 		if(revmobsampleapp_appDelegate.rootApp.validateApplicationData(downloadedData)){
		        	    			    			 		
		    			 			BT_debugger.showIt(activityName + ":loadAppDataWorkerThread downloaded app data appears to be valid.");
		        	    			revmobsampleapp_appDelegate.rootApp.parseAppJSONData(downloadedData);
		        	    			configData = downloadedData;
		 
		        	    			//delete previously cached data EXCEPT the apps "last changed" timestamp file...
		        	    			BT_fileManager.deleteAllCachedData(cachedConfigModifiedFileName);
		        	    			
		        	    			//re-save downloaded configuration data...
		        	    			BT_fileManager.saveTextFileToCache(downloadedData, cachedConfigDataFileName);
		        	    			
		    			 		}else{
		        	    			BT_debugger.showIt(activityName + ":loadAppDataWorkerThread done downloading. Newly downloaded data is NOT valid, not caching. Try a JSON validator?");
		    			 		}
		    			 		
		        			}else{
		        				showAlert(getString(R.string.errorDownloadingData), "long");
		        				BT_debugger.showIt(activityName + ":loadAppDataWorkerThread ERROR (7) downloading data from: " + dataURL);
		    			 	}
		    			 	
		    			 	
						} //downloadAppData
					
					}catch(Exception e){
						BT_debugger.showIt(activityName + ":loadAppData An exception occurred (55). " + e.toString());
						configData = "";
					}
				
				}//if configData 
				
				//send message...
				sendMessageToMainThread(0);
				
			}
			
			//send message....
			private void sendMessageToMainThread(int what){
				Message msg = Message.obtain();
				msg.what = what;
				mHandler.sendMessage(msg);
			}
			
		}.start();
		
	}
		
	
	


}









































