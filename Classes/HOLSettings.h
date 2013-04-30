/*////////////////////////////////////////////////////////////////////////
 Copyright (c) 2010-2013, The Ohio State University
 All rights reserved.
 
 Created by Joe Cora on 13 May 2010
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

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "HOLNaviBarViewController.h"

// Constants ///////////
#define ROOTVIEWTITLETEXT "Hymenoptera Online"
#define HOL_BASE_URL @"http://hol.osu.edu/hymDB/OJ_Break."
#define UIColorFromRGB(rgbValue) [UIColor \
	colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
	green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
	blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define LIBRARY_LIST_FILENAME @"libraryList.dat"

// Enumerations ///////
typedef enum HOLTABCONTROLLERTYPE {
	HOLTABCONTROLLERTAXON,
	HOLTABCONTROLLERNEARBY,
	HOLTABCONTROLLERSEARCH,
	HOLTABCONTROLLERLIBRARY,
	HOLTABCONTROLLERMORE,
} HOLTABCONTROLLERTYPE;

@interface HOLSettings : NSObject {
	HOLNaviBarViewController *taxonNaviBar;
	HOLNaviBarViewController *nearbyNaviBar;
	HOLNaviBarViewController *searchNaviBar;
	HOLNaviBarViewController *libraryNaviBar;
	HOLNaviBarViewController *moreNaviBar;
	NSString *currentTNUID;
	NSString *currentPubID;
	NSString *currentLocID;
	NSURL *currentPDFURL;
	NSArray *libraryList;
	BOOL isiPad;
	BOOL isInternetEnabled;
	BOOL isPortraitLocked;
	NSInteger nNumDownloads;
}

@property (nonatomic, retain) HOLNaviBarViewController *taxonNaviBar;
@property (nonatomic, retain) HOLNaviBarViewController *nearbyNaviBar;
@property (nonatomic, retain) HOLNaviBarViewController *searchNaviBar;
@property (nonatomic, retain) HOLNaviBarViewController *libraryNaviBar;
@property (nonatomic, retain) HOLNaviBarViewController *moreNaviBar;
@property (nonatomic, retain) NSString *currentTNUID;
@property (nonatomic, retain) NSString *currentPubID;
@property (nonatomic, retain) NSString *currentLocID;
@property (nonatomic, retain) NSURL *currentPDFURL;
@property (nonatomic, retain) NSArray *libraryList;
@property (nonatomic, readonly) BOOL isiPad;
@property (nonatomic, readwrite) BOOL isInternetEnabled;
@property (nonatomic, readwrite) BOOL isPortraitLocked;
@property (nonatomic, readwrite) NSInteger nNumDownloads;

// Public function declarations
- (id)initWithiPad:(BOOL)isiPadDevice;
- (void)loadLibraryList;
- (NSString *)getTNUID;
- (void)updateTNUID:(NSString *)tnuid;
- (NSString *)getPubID;
- (void)updatePubID:(NSString *)pub_id;
- (NSURL *)getPDFURL;
- (void)updatePDFURL:(NSString *)pdf_url isLocal:(BOOL)local;
- (NSString *)getLocID;
- (void)updateLocID:(NSString *)loc_id;
- (NSArray *)getLibraryList;
- (NSInteger)isPubInLibrary:(NSInteger)pub_id;
- (void)addToLibrary:(NSDictionary *)pub_info;
- (void)removeFromLibrary:(NSInteger)pub_pos;
- (BOOL)allowRotateToOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)enablePortraitLock;
- (void)disablePortraitLock;
- (BOOL)isDocDownloadAvailable;
- (NSString *)getFilenameFromURL:(NSString *)url;

@end
