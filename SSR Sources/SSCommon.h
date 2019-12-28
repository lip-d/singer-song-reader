//
//  SSCommon.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSString+SSR.h"

//Debug ログ ON/OFF
//#define SS_DEBUG_START_SEARCHING_SEPARATOR
//#define SS_DEBUG_SEARCH_KEYWORD
//#define SS_DEBUG_JAPANESE_TYPE
//#define SS_DEBUG_JP_ROMAJI_DETECTED_LINE
//#define SS_DEBUG_MAKE_FIRST_RESPONDER
//#define SS_DEBUG_HTTP_REQUEST

//#define SS_DEBUG_HTTP_RESPONSE
//#define SS_DEBUG_RESULT_SUMMARY

//#define SS_DEBUG_ENCODING
//#define SS_DEBUG_FILTER
//#define SS_DEBUG_STORE_OFF
//#define SS_DEBUG_MATCH_RATIO
//#define SS_DEBUG_MATCH_RATIO_DISP
//#define SS_DEBUG_MATCH_RATIO_DETAIL
//#define SS_DEBUG_STORE

#define IS_OS10_10_LATER floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9

extern int contentsRefreshCount;

extern const NSTimeInterval SSFadeoutMessageDuration;
extern const NSTimeInterval SSFadeoutAlertDuration;
extern const NSTimeInterval SSFadeoutImageDuration;

extern NSString * const SSHomepageURL;
extern NSString * const SSFAQsURL;
extern NSString * const SSBBSURL;
extern NSString * const SSDonationPageURL;
extern NSString * const SMEmpty;
extern NSString * const SSEmpty;
extern NSString * const SSBlank;
extern NSString * const SSUnderbar;

extern const CGFloat SSPanelWhite;
extern const CGFloat SSPanelAlpha;

extern const NSInteger SSNormalMatchThreshold;
extern const NSInteger SSLooseMatchThreshold;

extern const NSInteger SSRomajiLineThreshold;
extern const NSInteger SSRomajiWordThreshold;

extern const NSInteger SSLyricsSentenceMax;
extern const NSInteger SSLyricsLengthMin;

// NSUserDefaults 格納キー "UD*"
extern NSString * const UDNumberOfColumns;
extern NSString * const UDAppearance;

extern NSString * const UDTextColor;
extern NSString * const UDBackgroundColor;
extern NSString * const UDFont;

extern NSString * const UDAutoSrchTimeout;
extern NSString * const UDManuSrchTimeout;
extern NSString * const UDJapaneseLyricsRomaji;
extern NSString * const UDJapaneseLyricsKanji;
extern NSString * const UDHideNoHits;
extern NSString * const UDHideLyricFooterURL;

extern NSString * const UDCountryCode;

extern NSString * const UDEnabledSites;
extern NSString * const UDDisabledSites;

extern NSString * const UDIncludeLyricHeader;
extern NSString * const UDIncludeLyricFooter;
extern NSString * const UDAskBeforeOverwrite;
extern NSString * const UDAutosave;
extern NSString * const UDAutosaveTx;

extern NSString * const UDArrowsLeftRight;
extern NSString * const UDArrowsUpDown;

extern NSString * const UDBatchInterval;

extern NSString * const UDLyricsFolder;
extern NSString * const UDSubFolderByArtist;

extern NSString * const UDShowDateModified;

extern NSString * const UDOpeniTunesAtLaunch;
extern NSString * const UDAlwaysOnTop;

// Window Appearance
typedef enum {
	SC_APPEARANCE_FULL    = 0,
	SC_APPEARANCE_MINIMUM = 1,
	SC_APPEARANCE_PANEL   = 2
} SCWindowAppearance;

// LEDランプ色
typedef enum {
	SC_STATE_GREEN           = 0,
	SC_STATE_YELLOW          = 1,
	SC_STATE_RED             = 2,
	SC_STATE_OFF             = 3,
	SC_STATE_GREEN_OFF_BLINK = 4,
    SC_STATE_CHECK           = 5
} SCStateIndex;

// Song/Artist ボタンランプ色
typedef enum {
	SC_IMAGE_ON       = 0,
	SC_IMAGE_OFF      = 1
} SCImageIndex;

// 検索タイプ
typedef enum {
	SC_AT_SEARCH      = 0,
	SC_MA_SEARCH_SAME = 1,
	SC_MA_SEARCH_EDIT = 2,
    SC_MA_OPEN_FILE   = 3
} SCSrchType;

// イベントタイプ
typedef enum {
	SC_EV_SEARCH_BUTTON = 0
} SCEventType;

// メディアタイプ
typedef enum {
    SC_MEDIA_NONE        = 0,
    SC_MEDIA_RADIO       = 1,
    SC_MEDIA_PODCAST     = 2,
    SC_MEDIA_ITUNESU     = 3,
    SC_MEDIA_VIDEO       = 4,
    SC_MEDIA_MUSIC       = 5 // ミュージックビデオを含む
} SCMediaType;

// 通知元アプリ
typedef enum {
    SC_NTF_NONE         = 0,
    SC_NTF_DEEZER       = 1
} SCNotification;

// 動作モード
typedef enum {
	SC_MODE_NONE  = 0,
	SC_MODE_LOCAL = 1,
	SC_MODE_SITE  = 2,
    SC_MODE_FILE  = 3
} SCMode;

// Lyrics 文字種別
typedef enum {
	SC_LYRICS_ROMAJI  = 0,
	SC_LYRICS_KANJI   = 1,
	SC_LYRICS_OTHER   = 2
} SCLyricsCharacter;


@interface SSCommon : NSObject {
    
	NSUserDefaults *userDefault;
	
	NSString *defaultCountryCode;
}

+ (NSColor *) panelBackgroundColor;

- (NSArray *)SC_STATE;
- (NSArray *)SC_SONG_IMAGE;
- (NSArray *)SC_ARTIST_IMAGE;
- (NSDictionary *) siteDict;

+ (NSString *) removeSpacesAtBothSides:(NSString *)aString;
+ (NSArray *)  separateBrackets:(NSString *)string;
+ (NSString *) removeSymbols:(NSString *)string removeSQuate:(BOOL)flag;
+ (NSString *) removeAccents:(NSString *)string;
+ (NSString *) convertRomanNumber:(NSString *)string;
+ (NSNumber *) convertToNumber:(NSString *)string;
+ (NSString *) joinString:(NSString *)string1 withString:(NSString *)string2 format:(NSString *)format;

+ (NSInteger) lengthOfArray:(NSArray *)array;
+ (NSInteger) lengthOfArrayArray:(NSArray *)array;
+ (NSInteger) countOfArrayArray:(NSArray *)array;

#pragma mark - UserDefault Access

- (NSInteger)userNumberOfColumns;
- (NSInteger)userAppearance;

- (NSFont *)userFont;
- (NSColor *)userTextColor;
- (NSColor *)userBackgroundColor;

- (NSInteger)userAutoSrchTimeout;
- (NSInteger)userManuSrchTimeout;
- (NSInteger)userJapaneseLyricsRomaji;
- (NSInteger)userJapaneseLyricsKanji;
- (NSInteger)userHideNoHits;
- (NSInteger)userHideLyricFooterURL;

- (NSString *)userCountryCode;

- (NSArray *)defaultSiteList;
- (NSArray *)defaultDisabledSiteList;
- (NSArray *)userEnabledSites;
- (NSArray *)userDisabledSites;

- (NSInteger)userIncludeLyricHeader;
- (NSInteger)userIncludeLyricFooter;
- (NSInteger)userAskBeforeOverwrite;
- (NSInteger)userAutosave;
- (NSInteger)userAutosaveTx;

- (NSInteger)userArrowsLeftRight;
- (NSInteger)userArrowsUpDown;

- (NSString *)userLyricsFolder;
- (NSInteger)userSubFolderByArtist;

- (NSInteger)userShowDateModified;

- (NSInteger)userBatchInterval;

- (NSInteger)userOpeniTunesAtLaunch;
- (NSInteger)userAlwaysOnTop;

- (void)clearAllUserDefaults;

#pragma mark - UD Utilities

- (NSData *)dataFromColor:(NSColor *)color;
- (NSColor *)colorFromData:(NSData *)data;

- (NSData *)dataFromFont:(NSFont *)font;
- (NSFont *)fontFromData:(NSData *)data;

- (NSData *)dataFromArray:(NSArray *)array;
- (NSArray *)arrayFromData:(NSData *)data;

- (NSData *)dataFromInteger:(NSInteger)integer;
- (NSInteger)integerFromData:(NSData *)data;

#pragma mark - Other Utilities

- (NSColor *) colorForPerfectMatch;
- (NSColor *) colorForHighMatch;
- (NSColor *) colorForGoodMatch;
- (NSColor *) colorForLowMatch;

+ (NSString *) urlEncode:(NSString *)aString;
+ (NSString *) urlEncode:(NSString *)aString targetEncoding:(CFStringEncoding)encoding;

+ (NSInteger) okAlertWithMessage:(NSString *)message info:(NSString *)info;
+ (NSInteger) yesOrNoAlertWithMessage:(NSString *)message info:(NSString *)info;

SCStateIndex statusForCode(NSInteger code);

@end