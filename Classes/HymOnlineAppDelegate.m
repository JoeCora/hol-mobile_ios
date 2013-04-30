/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 1 Mar 2010
 Last revised on 29 Apr 2013
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of The Ohio State University nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SHALL THE OHIO STATE UNIVERSITY BE BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ////////////////////////////////////////////////////////////////////////*/

#import "HymOnlineAppDelegate.h"

@implementation HymOnlineAppDelegate

@synthesize window;
@synthesize tabController;
@synthesize taxonController;
@synthesize nearbyNaviController;
@synthesize searchNaviController;
@synthesize libraryNaviController;
@synthesize moreNaviController;
@synthesize loadingController;
@synthesize settings;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set Three20 library styles
    [TTStyleSheet setGlobalStyleSheet:[[[HOLCustomStyles alloc] init] autorelease]];
	
	// Create program settings and loading view
	NSString *szModel = [UIDevice currentDevice].model;
	BOOL bIsiPad = [szModel rangeOfString:@"iPad"].length > 0;
	
	HOLSettings *tempSettings = [[HOLSettings alloc] initWithiPad:bIsiPad];
	self.settings = tempSettings;
	[tempSettings release];
	
	HOLActivityIndicatorController *tempLoading = [[HOLActivityIndicatorController alloc] initWithiPad:bIsiPad];
	self.loadingController = tempLoading;
	[tempLoading release];
	
	// Create tab view controller
	UITabBarController *tempTabController = [[UITabBarController alloc] initWithNibName:@"UITabBarController" bundle:nil];
	self.tabController = tempTabController;
	[tempTabController release];
	
	// Create taxon navigation controller
	HOLTaxonBodyController *naviBodyNew = [[HOLTaxonBodyController alloc] initWithSettings:self.settings];
	UINavigationController *tempTaxonController = [[UINavigationController alloc] initWithRootViewController:naviBodyNew];
	self.taxonController = tempTaxonController;
	
	[tempTaxonController release];
	[naviBodyNew release];
	
	self.taxonController.title = @"Taxon";
	
	// Configure the taxon navigation bar
	self.taxonController.navigationBar.tintColor = UIColorFromRGB(0xCDCDC1); // For proper button colors
	
	HOLNaviBarViewController *taxonNaviBar = [[HOLNaviBarViewController alloc] initWithiPad:self.settings.isiPad];
	
	[self.taxonController.navigationBar addSubview:taxonNaviBar.view];
	
	self.settings.taxonNaviBar = taxonNaviBar;
	
	[taxonNaviBar release];
	
	// Create the tab bar item for the taxon navigation controller
	UIImage *tabTaxonImage = [UIImage imageNamed:@"HymOnlineTaxon_Icon.png"];
	UITabBarItem* newTaxonTab = [[UITabBarItem alloc] initWithTitle:@"Taxon" image:tabTaxonImage tag:HOLTABCONTROLLERTAXON];
	
	self.taxonController.tabBarItem = newTaxonTab;
	
	[newTaxonTab release];
	
	// Set the nearby collecting events controller
	HOLNearbyMapController *nearbyController = [[HOLNearbyMapController alloc] initWithSettings:self.settings];
	UINavigationController *tempNearbyController = [[UINavigationController alloc] initWithRootViewController:nearbyController];
	self.nearbyNaviController = tempNearbyController;
	
	[tempNearbyController release];
	
	// Configure the nearby collecting events navigation bar
	self.nearbyNaviController.navigationBar.tintColor = UIColorFromRGB(0xCDCDC1); // For proper button colors
	
	HOLNaviBarViewController *nearbyNaviBar = [[HOLNaviBarViewController alloc] initWithiPad:self.settings.isiPad];
	
	[self.nearbyNaviController.navigationBar addSubview:nearbyNaviBar.view];
	
	self.settings.nearbyNaviBar = nearbyNaviBar;
	
	[nearbyNaviBar release];
	
	// Create the tab bar item for the nearby collecting events controller
	UIImage *tabNearbyImage = [UIImage imageNamed:@"net-icon.png"];
	UITabBarItem *tempNearbyTab = [[UITabBarItem alloc] initWithTitle:@"Nearby" image:tabNearbyImage tag:HOLTABCONTROLLERNEARBY];
	nearbyController.tabBarItem = tempNearbyTab;
	
	[tempNearbyTab release];
	[nearbyController release];
	
	// Set the search controller
	HOLSearchController *searchController = [[HOLSearchController alloc] initWithSettings:self.settings];
	UINavigationController *tempNaviController = [[UINavigationController alloc] initWithRootViewController:searchController];
	self.searchNaviController = tempNaviController;
	
	[tempNaviController release];
	
	// Configure the search navigation bar
	self.searchNaviController.navigationBar.tintColor = UIColorFromRGB(0xCDCDC1); // For proper button colors
	
	HOLNaviBarViewController *searchNaviBar = [[HOLNaviBarViewController alloc] initWithiPad:self.settings.isiPad];
	
	[self.searchNaviController.navigationBar addSubview:searchNaviBar.view];
	
	self.settings.searchNaviBar = searchNaviBar;
	
	[searchNaviBar release];
	
	// Create the tab bar item for the search controller
	UITabBarItem *tempSearchTab = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:HOLTABCONTROLLERSEARCH];
	searchController.tabBarItem = tempSearchTab;
	
	[tempSearchTab release];
	[searchController release];
	
	// Set the library controller
	HOLLibraryController *libraryController = [[HOLLibraryController alloc] initWithSettings:self.settings];
	UINavigationController *tempLibraryController = [[UINavigationController alloc] initWithRootViewController:libraryController];
	self.libraryNaviController = tempLibraryController;
	
	[tempLibraryController release];
	
	// Configure the library navigation bar
	self.libraryNaviController.navigationBar.tintColor = UIColorFromRGB(0xCDCDC1); // For proper button colors
	
	HOLNaviBarViewController *libraryNaviBar = [[HOLNaviBarViewController alloc] initWithiPad:self.settings.isiPad];
	
	[self.libraryNaviController.navigationBar addSubview:libraryNaviBar.view];
	
	self.settings.libraryNaviBar = libraryNaviBar;
	
	[libraryNaviBar release];
	
	// Create the tab bar item for the library controller
	UIImage *tabLibraryImage = [UIImage imageNamed:@"library-icon.png"];
	UITabBarItem *tempLibraryTab = [[UITabBarItem alloc] initWithTitle:@"Library" image:tabLibraryImage tag:HOLTABCONTROLLERLIBRARY];
	libraryController.tabBarItem = tempLibraryTab;
	
	[tempLibraryTab release];
	[libraryController release];
	
	// Set the more controller
	HOLMoreController *moreController = [[HOLMoreController alloc] initWithSettings:self.settings];
	UINavigationController *tempMoreController = [[UINavigationController alloc] initWithRootViewController:moreController];
	self.moreNaviController = tempMoreController;
	
	[tempMoreController release];
	
	// Configure the more navigation bar
	self.moreNaviController.navigationBar.tintColor = UIColorFromRGB(0xCDCDC1); // For proper button colors
	
	HOLNaviBarViewController *moreNaviBar = [[HOLNaviBarViewController alloc] initWithiPad:self.settings.isiPad];
	
	[self.moreNaviController.navigationBar addSubview:moreNaviBar.view];
	
	self.settings.moreNaviBar = moreNaviBar;
	
	[moreNaviBar release];
	
	// Create the tab bar item for the more controller
	UITabBarItem *tempMoreTab = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:HOLTABCONTROLLERMORE];
	moreController.tabBarItem = tempMoreTab;
	
	[tempMoreTab release];
	[moreController release];
	
	// Create an array to hold view controllers for tabs
	NSArray *newTabControllers = [NSArray arrayWithObjects:self.taxonController, self.nearbyNaviController,
								  self.searchNaviController, self.libraryNaviController, self.moreNaviController, nil];
	[self.tabController setViewControllers:newTabControllers animated:YES];
	
	// If no internet is available, go to the library and disable internet-only tabs
	if (!self.settings.isInternetEnabled) {
		self.tabController.selectedIndex = HOLTABCONTROLLERLIBRARY;
	}
    
    // Override point for customization after app launch
    [self.window setRootViewController:self.tabController];
	[self.window addSubview:self.tabController.view];
    [self.window makeKeyAndVisible];
	
	// Check for notifications for taxon pages
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewTaxon) name:@"HOLLOADNEWTAXON" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonGeneralInfo) name:@"HOLSHOWTAXONGENERALINFO" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonIncludedTaxa) name:@"HOLSHOWTAXONINCLUDEDTAXA" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonSynonyms) name:@"HOLSHOWTAXONSYNONYMS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonLiterature) name:@"HOLSHOWTAXONLITERATURE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonMap) name:@"HOLSHOWTAXONMAP" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonImages) name:@"HOLSHOWTAXONIMAGES" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonCollections) name:@"HOLSHOWTAXONCOLLECTIONS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonAssociations) name:@"HOLSHOWTAXONASSOCS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonHabitats) name:@"HOLSHOWTAXONHABITATS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonTypes) name:@"HOLSHOWTAXONTYPES" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTaxonLitReference) name:@"HOLSHOWTAXONLITREFERENCE" object:nil];
	
	// Check for notifications for literature pages
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLitViewer) name:@"HOLSHOWLITVIEWER" object:nil];
	
	// Check for notifications for others
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLocInfo) name:@"HOLSHOWLOCINFO" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLibrary) name:@"HOLSHOWLIBRARY" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadIndicator) name:@"HOLUPDATELIBRARYINDICATOR" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoading) name:@"HOLSHOWLOADING" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoading) name:@"HOLHIDELOADING" object:nil];
	
	// Load the library list
	[self.settings loadLibraryList];
	
	// Add loading view but hide it
	[self.window addSubview:self.loadingController.view];
	
	[self hideLoading];
	
	return YES;
}

- (void)dealloc {
    [window release];
	[tabController release];
	[taxonController release];
	[nearbyNaviController release];
	[searchNaviController release];
	[libraryNaviController release];
	[moreNaviController release];
	[loadingController release];
	[settings release];
    [super dealloc];
}

// Public functions
- (void)loadNewTaxon {
	// Set to taxon tab
	self.tabController.selectedIndex = HOLTABCONTROLLERTAXON;
	
	// Reload taxon body controller's main view and pop any views above
	[self.taxonController popToRootViewControllerAnimated:YES];
	
	HOLTaxonBodyController* taxonBodyController = (HOLTaxonBodyController*)self.taxonController.topViewController;
	
	[taxonBodyController loadNewTaxon];
}

- (void)showTaxonGeneralInfo {
	HOLTaxonGeneralInfoController *taxonGeneralTable = [[HOLTaxonGeneralInfoController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonGeneralTable animated:YES];
	
	[taxonGeneralTable release];
}

- (void)showTaxonIncludedTaxa {
	HOLTaxonIncludedTaxaController *taxonIncludedTaxaTable = [[HOLTaxonIncludedTaxaController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonIncludedTaxaTable animated:YES];
	
	[taxonIncludedTaxaTable release];
}

- (void)showTaxonSynonyms {
	HOLTaxonSynonymsController *taxonSynonymsTable = [[HOLTaxonSynonymsController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonSynonymsTable animated:YES];
	
	[taxonSynonymsTable release];
}

- (void)showTaxonLiterature {
	HOLTaxonLiteratureController *taxonLiteratureTable = [[HOLTaxonLiteratureController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonLiteratureTable animated:YES];
	
	[taxonLiteratureTable release];
}

- (void)showTaxonMap {
	HOLTaxonMapController *taxonMap = [[HOLTaxonMapController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonMap animated:YES];
	
	[taxonMap release];
}

- (void)showTaxonImages {
	HOLTaxonImagesController *taxonImages = [[HOLTaxonImagesController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonImages animated:YES];
	
	[taxonImages release];
}

- (void)showTaxonCollections {
	HOLTaxonCollectionsController *taxonInsts = [[HOLTaxonCollectionsController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonInsts animated:YES];
	
	[taxonInsts release];
}

- (void)showTaxonAssociations {
	HOLTaxonAssociations *taxonAssocs = [[HOLTaxonAssociations alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonAssocs animated:YES];
	
	[taxonAssocs release];
}

- (void)showTaxonHabitats {
	HOLTaxonHabitats *taxonHabitats = [[HOLTaxonHabitats alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonHabitats animated:YES];
	
	[taxonHabitats release];
}

- (void)showTaxonTypes {
	HOLTaxonTypes *taxonTypes = [[HOLTaxonTypes alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:taxonTypes animated:YES];
	
	[taxonTypes release];
}

- (void)showTaxonLitReference {
	HOLLitReferenceController *litReference = [[HOLLitReferenceController alloc] initWithSettings:self.settings];
	
	[self.taxonController pushViewController:litReference animated:YES];
	
	[litReference release];
}

- (void)showLocInfo {
	HOLMapInfoController *locInfo;
	
	// Add locality info to the appropriate view (taxon or nearby)
	if (self.tabController.selectedIndex == HOLTABCONTROLLERTAXON) {
		locInfo = [[HOLMapInfoController alloc] initWithSettings:self.settings section:HOLTABCONTROLLERTAXON];
		locInfo.delegate = (HOLTaxonMapController *)self.taxonController.topViewController;
		
		[self.taxonController pushViewController:locInfo animated:YES];
	} else {
		locInfo = [[HOLMapInfoController alloc] initWithSettings:self.settings section:HOLTABCONTROLLERNEARBY];
		
		[self.nearbyNaviController pushViewController:locInfo animated:YES];
	}
	
	[locInfo release];
}

- (void)showLitViewer {
	HOLPDFViewController *litViewer;
	
	// Add literature viewer to the appropriate view (taxon or library)
	if (self.tabController.selectedIndex == HOLTABCONTROLLERTAXON) {
		litViewer = [[HOLPDFViewController alloc] initWithSettings:self.settings section:HOLTABCONTROLLERTAXON];
		
		[self.taxonController pushViewController:litViewer animated:YES];
	} else {
		litViewer = [[HOLPDFViewController alloc] initWithSettings:self.settings section:HOLTABCONTROLLERLIBRARY];
		
		[self.libraryNaviController pushViewController:litViewer animated:YES];
	}
	
	[litViewer release];
}

- (void)showLibrary {
	// Set to library tab
	self.tabController.selectedIndex = HOLTABCONTROLLERLIBRARY;
}

- (void)showMore {
	// Set to library tab
	self.tabController.selectedIndex = HOLTABCONTROLLERMORE;
}

- (void)showLoading {
	[self.loadingController show];
}

- (void)hideLoading {
	[self.loadingController hide];
}

- (void)updateDownloadIndicator {
	// Adjust the badge for the library to reflect current downloads
	UITabBarItem *libraryTab = (UITabBarItem *)[self.tabController.tabBar.items objectAtIndex:HOLTABCONTROLLERLIBRARY];
	
	if (self.settings.nNumDownloads > 0) {
		libraryTab.badgeValue = [NSString stringWithFormat:@"%d", self.settings.nNumDownloads];
	} else {
		libraryTab.badgeValue = nil;
	}
}

@end
