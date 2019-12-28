//
//  SMSite.h
//  Singer Song Reader
//
//  Created by Developer on 13/09/28.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

/* メモ: 文字コード
 
 NSStringEncoding 値
 
 enum {
 NSASCIIStringEncoding = 1,
 NSNEXTSTEPStringEncoding = 2,
 NSJapaneseEUCStringEncoding = 3,
 NSUTF8StringEncoding = 4,
 NSISOLatin1StringEncoding = 5,
 NSSymbolStringEncoding = 6,
 NSNonLossyASCIIStringEncoding = 7,
 NSShiftJISStringEncoding = 8,
 NSISOLatin2StringEncoding = 9,
 NSUnicodeStringEncoding = 10,
 NSWindowsCP1251StringEncoding = 11,
 NSWindowsCP1252StringEncoding = 12,
 NSWindowsCP1253StringEncoding = 13,
 NSWindowsCP1254StringEncoding = 14,
 NSWindowsCP1250StringEncoding = 15,
 NSISO2022JPStringEncoding = 21,
 NSMacOSRomanStringEncoding = 30,
 NSUTF16StringEncoding = NSUnicodeStringEncoding,
 NSUTF16BigEndianStringEncoding = 0x90000100,
 NSUTF16LittleEndianStringEncoding = 0x94000100,
 NSUTF32StringEncoding = 0x8c000100,
 NSUTF32BigEndianStringEncoding = 0x98000100,
 NSUTF32LittleEndianStringEncoding = 0x9c000100,
 NSProprietaryStringEncoding = 65536
 };
 */

#import <Cocoa/Cocoa.h>
#import "SMSrchResult.h"
#import "SMSrchSelector.h"
#import "SMTrack.h"
#import "SMPrefs.h"
#import "SMResultScore.h"
#import "SSCommon.h"
#import "SBJson.h"
#import "SMSrchResultProtocol.h"
#import "RegexKitLite.h"
#import "SMSiteHtmlChildProtocol.h"
#import "SMSiteJsonChildProtocol.h"
#import "SMAnimeLyricsSrchResult.h"

#define SS_ENC_AUTO_DETECT     0
#define SS_ENC_NOT_DETECTED    0

@interface SMSite : NSObject {

@public 
	
	NSInteger siteIndex; // サイトタブ番号 (0 〜 N)
    NSString *siteKey;   // 3桁サイト識別キー 例:LWK
    NSString *siteFullName;
    NSInteger sitePriority;  // Preferences の設定順 (0 〜 N)

    NSString *taggedLyrics;
	
	id delegate;

	// 検索キーワード
	SMTrack *track;
    
    // 検索設定
    SMPrefs *prefs;

	// 性能測定測定関連
	NSDate *startDate;
	NSDate *endDate;

@protected

    // サイト名 (サイトタブ表示用)
	NSString *siteName;
	
	// 検索動作設定
	SMSrchSelector *srchSelector;

	// 検索結果関連
	id <SMSrchResultProtocol, NSObject> srchResult;
	SMResultScore *resultScore;
    
	NSInteger resultCode;
    
	id <SMSiteChildProtocol> child;
    
    NSMutableArray  *encodingSetting;
	NSStringEncoding encodingDetected;
    
    NSInteger loopMax;
    
@private

	SEL SEDidFinish;
	
	BOOL isFinished;
}

@property NSInteger           siteIndex;
@property (retain) NSString  *siteKey;
@property (retain) NSString  *siteFullName;
@property (retain) NSString  *siteName;
@property (readonly) BOOL isFinished;
@property NSInteger sitePriority;

@property (assign) SMPrefs   *prefs;

@property (retain) NSString  *taggedLyrics;

@property (readonly) NSStringEncoding currentEncodingSetting;
@property (readonly) NSStringEncoding encodingDetermined;

- (void) setDelegate:(id)aDelegate;

- (SMTrack *)track;
- (void) setTrack:(SMTrack *)aTrack;

- (SMSrchResult *) srchResult;
- (SMResultScore *) resultScore;
- (NSInteger) resultCode;

- (BOOL) isHit;
- (void) markAsNoHit;
- (void) markAsHit;
- (void) clearResult;
- (void) startTimer;
- (void) stopTimer;
- (void) resetTimer;
- (NSString*) searchTime;

- (SMSrchSelector *) srchSelector;

- (void) addSearch:(id)aChild urlMethod:(NSString *)aUrlMethod analyzeMethod:(NSString *)aAnalyzeMethod;
- (void) addSearch:(id)aChild urlMethod:(NSString *)aUrlMethod analyzeMethod:(NSString *)aAnalyzeMethod frameName:(NSString *)aFrameName elementMethod:(NSString *)aElementMethod;

- (void) search;
- (void) cancel;
- (void) timeout;

- (NSString *) lyricHeader;
- (NSString *) lyricFooter:(BOOL)withURL;
- (NSString *) contents:(BOOL)withFooterURL;

- (void) _search;

- (void) didFinishSearching:(id)aData encoding:(NSString *)aEncoding;
- (void) didFailSearching:(id)aError;

- (NSInteger) matchTitle:(NSString *)aTitle andArtist:(NSString *)aArtist;
- (NSInteger) matchTitle:(NSString *)aTitle;
- (NSInteger) matchArtist:(NSString *)aArtist;

- (BOOL) useWebView;
- (NSInteger) webViewLoopCount;

- (NSXMLElement *) getDocRootElement:(NSData *)aData dataType:(NSUInteger)aDataType;
- (NSXMLElement *) getDocRootElement:(NSData *)aData;
- (NSDictionary *) getJsonRootElement:(NSData *)aData;
- (NSString *) utf8StringFromData:(NSData *)aData;

- (void) removeNodeByXPath:(NSString *)aXPath baseNode:(NSXMLNode *)aNode;
- (NSXMLNode *) firstNodeForXPath:(NSString *)aXPath baseNode:(NSXMLNode *)aNode;

- (void) setHtmlChild:(id <SMSiteHtmlChildProtocol>)aChild siteName:(NSString *)name;
- (void) setJsonChild:(id <SMSiteJsonChildProtocol>)aChild siteName:(NSString *)name;
- (NSString *) url1;
- (NSString *) url2;
- (NSNumber *) analyze1:(id)aData;
- (NSNumber *) analyze2:(id)aData;

@end
