//
//  SMCommon.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SSCommon.h"
#import "RegexKitLite.h"

#import "SMLyricWiki.h"
//#import "SMSing365.h"
#import "SMSongLyrics.h"
#import "SMMetroLyrics.h"
#import "SMAlbumCancionLetra.h"
#import "SMLetsSingIt.h"
#import "SMLyricsMania.h"
//#import "SMLyricsTime.h"
#import "SMAZLyrics.h"
#import "SMJustSomeLyrics.h"
#import "SMSongMeanings.h"
#import "SMLetrasMusBr.h"
#import "SMLyrics.h"
#import "SMLoveCms.h"
#import "SMKGet.h"
#import "SMUtamap.h"
#import "SMAnimeLyrics.h"
#import "SMSpiritOfMetal.h"
#import "SMMetalArchives.h"
#import "SMGenius.h"

int contentsRefreshCount = 0;

const NSTimeInterval SSFadeoutMessageDuration = 1.5;
const NSTimeInterval SSFadeoutAlertDuration   = 3.0;
const NSTimeInterval SSFadeoutImageDuration   = 1.5;

NSString * const SSHomepageURL     = @"http://www.singer-song-reader.com";
NSString * const SSFAQsURL         = @"http://www.singer-song-reader.com/faqs";
NSString * const SSBBSURL          = @"http://www.singer-song-reader.com/comments";
NSString * const SSDonationPageURL = @"http://www.singer-song-reader.com/donation";
NSString * const SMEmpty           = @"";
NSString * const SSEmpty           = @"";
NSString * const SSBlank           = @" ";
NSString * const SSUnderbar        = @"_";
//                                  *\([\w"'&!\?\-:,\s]+\) *| *\[[\w"'&!\?\-:,\s]+\] *
NSString * const SSRegBraketed     = @" *\\([\\w\"'&!\\?\\-:,\\s]+\\) *| *\\[[\\w\"'&!\\?\\-:,\\s]+\\] *";

const CGFloat SSPanelWhite  = 0.12549;
const CGFloat SSPanelAlpha  = 0.86;

// "The" あり/なし、and/& の違いがあってもヒットするように、
// ヒットのしきい値は 100% ではなく 80% に緩めておく
const NSInteger SSNormalMatchThreshold  = 80; // Normal Match のしきい値
const NSInteger SSLooseMatchThreshold   = 40; // Loose Match  のしきい値 (20->40 V3.4)
const NSInteger SSRomajiLineThreshold   = 10; // Romaji 判定しきい値 (行数)
const NSInteger SSRomajiWordThreshold   = 3;  // Romaji 判定しきい値 (行ごとの単語数)


// Lyrics 改行有無チェック用しきい値
const NSInteger SSLyricsSentenceMax     = 256;
// Lyrics 最低文字数チェック用しきい値
const NSInteger SSLyricsLengthMin       = 128;

NSString * const SSSiteLyricWiki      = @"LWK";
//NSString * const SSSiteSing365        = @"S36"; // 削除(v4.5)
NSString * const SSSiteSongLyrics     = @"SNL";
NSString * const SSSiteMetroLyrics    = @"MTL";
NSString * const SSSiteAlbumCancion   = @"ALC";
NSString * const SSSiteLetsSingIt     = @"LSI";
NSString * const SSSiteLyricsMania    = @"LMN";
//NSString * const SSSiteLyricsTime     = @"LTM"; // 削除(v4.5)
NSString * const SSSiteAZLyrics       = @"AZL";
NSString * const SSSiteLetrasMusBr    = @"LMB";
NSString * const SSSiteKGet           = @"KGT";
NSString * const SSSiteLoveCms        = @"LCM";
NSString * const SSSiteSongMeanings   = @"SMN";
NSString * const SSSiteUtamap         = @"UMP";
NSString * const SSSiteAnimeLyrics    = @"ANL";
NSString * const SSSiteSpiritOfMetal  = @"SOM";
NSString * const SSSiteMetalArchives  = @"MAR";
NSString * const SSSiteGenius         = @"GEN";

// 追加候補サイト
NSString * const SSSiteAbsoluteLyrics = @"ABL";
NSString * const SSSiteOnlyLyrics     = @"ONL";
NSString * const SSSiteMaxiLyrics     = @"MXL";
NSString * const SSSiteLeosLyrics     = @"LOL";
NSString * const SSSiteLyricsMode     = @"LMD";
NSString * const SSSiteLyricsFreak    = @"LFR";
NSString * const SSSiteBatLyrics      = @"BTL";
NSString * const SSSiteLyricsnMusic   = @"LMS";
NSString * const SSSiteLyricsOnTop    = @"LOT";
NSString * const SSSiteAnySongLyrics  = @"ASL";

// 保留サイト
NSString * const SSSiteJustSomeLyrics = @"JSL"; // 連続アクセスで IP アドレスにブロックがかかる (画面からのコード入力による解除が必要)
NSString * const SSSiteLyrics         = @"LYC"; // POST メソッドのみ受付け

// 無効化サイト

// NSUserDefaults 格納キー
NSString * const UDNumberOfColumns    = @"UDNumberOfColumns3";
NSString * const UDAppearance         = @"UDAppearance3";

NSString * const UDTextColor          = @"UDTextColor3";
NSString * const UDBackgroundColor    = @"UDBackgroundColor3";
NSString * const UDFont               = @"UDFont3";

NSString * const UDAutoSrchTimeout    = @"UDAutoSrchTimeout3";
NSString * const UDManuSrchTimeout    = @"UDManuSrchTimeout3";
NSString * const UDJapaneseLyricsRomaji = @"UDJapaneseLyricsRomaji3";
NSString * const UDJapaneseLyricsKanji  = @"UDJapaneseLyricsKanji3";
NSString * const UDHideNoHits         = @"UDHideNoHits3";
NSString * const UDHideLyricFooterURL = @"UDHideLyricFooterURL3";

NSString * const UDCountryCode        = @"UDCountryCode3";

NSString * const UDEnabledSites       = @"UDEnabledSites3";
NSString * const UDDisabledSites      = @"UDDisabledSites3";

NSString * const UDIncludeLyricHeader = @"UDIncludeLyricHeader3";
NSString * const UDIncludeLyricFooter = @"UDIncludeLyricFooter3";
NSString * const UDAskBeforeOverwrite = @"UDAskBeforeOverwrite3";
NSString * const UDAutosave           = @"UDAutosave3";
NSString * const UDAutosaveTx         = @"UDAutosaveTx3";

NSString * const UDArrowsLeftRight    = @"UDArrowsLeftRight3";
NSString * const UDArrowsUpDown       = @"UDArrowsUpDown3";

NSString * const UDBatchInterval      = @"UDBatchInterval3";

NSString * const UDLyricsFolder       = @"UDLyricsFolder3";
NSString * const UDSubFolderByArtist  = @"UDSubFolderByArtist3";

NSString * const UDShowDateModified   = @"UDShowDateModified3";

NSString * const UDOpeniTunesAtLaunch = @"UDOpeniTunesAtLaunch";
NSString * const UDAlwaysOnTop        = @"UDAlwaysOnTop";

// ↑ 追加したら、clearAllUserDefaults にも処理を追加する

@implementation SSCommon

- (id)init {
    self = [super init];
    if (self) {
		
		// ユーザ設定 インスタンス
		userDefault = [NSUserDefaults standardUserDefaults];
		
		// ユーザの環境設定から国コードを取得
		NSLocale *locale = [NSLocale currentLocale];
		defaultCountryCode = [locale objectForKey: NSLocaleCountryCode];
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

+ (NSColor *) panelBackgroundColor {
    
    static NSColor *color = nil;

    if (!color) {
        
        color = [[NSColor colorWithCalibratedWhite:SSPanelWhite alpha:SSPanelAlpha] retain];
    }
    
    return color;
}

- (NSArray *)SC_STATE {
	
	static NSArray *_SC_STATE = nil;
	
	if (!_SC_STATE) {
		_SC_STATE = [[NSArray alloc] initWithObjects:
					 [NSImage imageNamed:@"indicator_green.png"],
					 [NSImage imageNamed:@"indicator_yellow.png"],
					 [NSImage imageNamed:@"indicator_red.png"],
					 [NSImage imageNamed:@"indicator_off.png"],
					 [NSImage imageNamed:@"indicator_green_off_blink.gif"],
					 [NSImage imageNamed:@"indicator_check.png"],
					 nil];
	}

	return _SC_STATE;
}

- (NSArray *)SC_SONG_IMAGE {

    static NSArray *_SC_IMAGE = nil;
	
	if (!_SC_IMAGE) {
		_SC_IMAGE = [[NSArray alloc] initWithObjects:
					 [NSImage imageNamed:@"song_button.png"],
					 [NSImage imageNamed:@"song_button_off.png"],

					 nil];
	}
    
	return _SC_IMAGE;

}
- (NSArray *)SC_ARTIST_IMAGE {
    
    static NSArray *_SC_IMAGE = nil;
	
	if (!_SC_IMAGE) {
		_SC_IMAGE = [[NSArray alloc] initWithObjects:
					 [NSImage imageNamed:@"artist_button.png"],
					 [NSImage imageNamed:@"artist_button_off.png"],
					 nil];
	}
    
	return _SC_IMAGE;

}


// Key   : サイトコード
// Value : {正式名称, サイトオブジェクト}
- (NSDictionary *) siteDict {

	static NSDictionary *_siteDict = nil;
	
	if (!_siteDict) {
		
		_siteDict = [[NSDictionary alloc] initWithObjectsAndKeys:

					 //                       {正式名称(Preference画面用),   サイトオブジェクト}                          サイトコード
					 [NSArray arrayWithObjects:@"LyricWiki",             [[SMLyricWiki          alloc] init], nil], SSSiteLyricWiki,
//					 [NSArray arrayWithObjects:@"Sing365",               [[SMSing365            alloc] init], nil], SSSiteSing365,
					 [NSArray arrayWithObjects:@"MetroLyrics",           [[SMMetroLyrics        alloc] init], nil], SSSiteMetroLyrics,
					 [NSArray arrayWithObjects:@"Album Cancion y Letra", [[SMAlbumCancionLetra  alloc] init], nil], SSSiteAlbumCancion,
					 [NSArray arrayWithObjects:@"SongLyrics",            [[SMSongLyrics         alloc] init], nil], SSSiteSongLyrics,
//					 [NSArray arrayWithObjects:@"LyricsTime",            [[SMLyricsTime         alloc] init], nil], SSSiteLyricsTime,
					 [NSArray arrayWithObjects:@"LetsSingIt",            [[SMLetsSingIt         alloc] init], nil], SSSiteLetsSingIt,
					 [NSArray arrayWithObjects:@"LyricsMania",           [[SMLyricsMania        alloc] init], nil], SSSiteLyricsMania,
					 [NSArray arrayWithObjects:@"A-Z Lyrics",            [[SMAZLyrics           alloc] init], nil], SSSiteAZLyrics,
					 [NSArray arrayWithObjects:@"Letras.mus.br",         [[SMLetrasMusBr        alloc] init], nil], SSSiteLetrasMusBr,
					 [NSArray arrayWithObjects:@"LoveCms",               [[SMLoveCms            alloc] init], nil], SSSiteLoveCms,
					 [NSArray arrayWithObjects:@"KashiGet",              [[SMKGet               alloc] init], nil], SSSiteKGet,
					 [NSArray arrayWithObjects:@"SongMeanings",          [[SMSongMeanings       alloc] init], nil], SSSiteSongMeanings,
					 [NSArray arrayWithObjects:@"Utamap",                [[SMUtamap             alloc] init], nil], SSSiteUtamap,
                     [NSArray arrayWithObjects:@"AnimeLyrics",           [[SMAnimeLyrics        alloc] init], nil], SSSiteAnimeLyrics,
                     [NSArray arrayWithObjects:@"Spirit of Metal",       [[SMSpiritOfMetal      alloc] init], nil], SSSiteSpiritOfMetal,
                     [NSArray arrayWithObjects:@"Metal Archives",        [[SMMetalArchives      alloc] init], nil], SSSiteMetalArchives,
                     [NSArray arrayWithObjects:@"Genius",                [[SMGenius             alloc] init], nil], SSSiteGenius,
					 //[NSArray arrayWithObjects:@"Lyrics",                [[SMLyrics             alloc] init], nil], SSSiteLyrics,
					 //[NSArray arrayWithObjects:@"Just Some Lyrics",      [[SMJustSomeLyrics        alloc] init], nil], SSSiteJustSomeLyrics,
					 
					 // サイト追加 1/3
					 nil];
	}
	
	return _siteDict;
}

- (NSArray *)defaultSiteList {
    
    NSArray *array = [[[NSArray alloc] initWithObjects:
                       SSSiteLyricWiki,
                       SSSiteLetsSingIt,
                       SSSiteMetroLyrics,
                       SSSiteSongMeanings,
                       SSSiteLoveCms,
                       SSSiteLetrasMusBr,
                       SSSiteSongLyrics,
//                       SSSiteSing365,
                       SSSiteLyricsMania,
                       SSSiteKGet,
                       SSSiteUtamap,
                       SSSiteAnimeLyrics,
                       SSSiteAZLyrics,
                       SSSiteAlbumCancion,
                       SSSiteSpiritOfMetal,
                       SSSiteMetalArchives,
                       SSSiteGenius,
                       // サイト追加 2/3
                       nil] autorelease];
    
    return array;
}

- (NSArray *)defaultDisabledSiteList {
    
    NSArray *array = [[[NSArray alloc] initWithObjects:
                       // v3.7
//                       SSSiteLyricsTime, // 削除(v4.5)
                       // サイト追加 3/3
                       nil] autorelease];
    
    return array;
}

#pragma mark - Commons

// 両端空白類削除
+ (NSString *) removeSpacesAtBothSides:(NSString *)aString {
    
	// 前後空白類 (改行も含む)
	static NSString * const regex = @"^\\s*|\\s*$";
    
	NSString *result = [aString stringByReplacingOccurrencesOfRegex:regex withString:SMEmpty];
    
	return result;
}

// メイン部分、末尾カッコ部分に分割
+ (NSArray *) separateBrackets:(NSString *)string {
    
    NSArray *array = nil;
    
    // 末尾の "(...)"
    if ([string hasSuffix:@")"]) {
        
        array = [self separateBrackets:string by:@"("];
    }
    // 末尾の "[...]"
    else if ([string hasSuffix:@"]"]) {
        
        array = [self separateBrackets:string by:@"["];
    }
    // 末尾のカッコなし
    else {
        
        array = [NSArray arrayWithObjects:string, @"", nil];
    }
    
    return array;
}

// 空白類削除
// 検索用正規化時：flag=NO  ("'" 残す)
// 比較用正規化時：flag=YES ("'" 削除)
+ (NSString *) removeSymbols:(NSString *)string removeSQuate:(BOOL)flag {

	NSMutableString *str = [NSMutableString stringWithCapacity:string.length];

    [str setString:string];
    
    // "_" 空白変換
    [str replaceOccurrencesOfString:SSUnderbar
                         withString:SSBlank
                            options:NSLiteralSearch
                              range:NSMakeRange(0, str.length)];

    // "'" 削除フラグ ON
    if (flag) {

        // V3.8 "/,!" 追加
        [str replaceOccurrencesOfRegex:@"['’/,!&$.?]"
                            withString:SSEmpty];
    }

    // 単語のみ抽出
    // V3.8 ",!" 追加
    NSArray *words = [str componentsMatchedByRegex:@"[\\w'/,!&$.?]+"];
    
	// 空白で再結合
	[str setString:[words componentsJoinedByString:SSBlank]];
        
    return str;
}

// アクセント削除＋小文字化
+ (NSString *) removeAccents:(NSString *)string {
	
	//---------------------------------------
	// アクセント記号などを取り除く、同時に小文字化
	//---------------------------------------
	
	static NSStringCompareOptions comparisonOptions =
	NSDiacriticInsensitiveSearch |
	NSWidthInsensitiveSearch     |
	NSCaseInsensitiveSearch;
    
	static NSLocale *localeEnglish = nil;
	
	if (!localeEnglish) {
		
		localeEnglish = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
	}
	
	return [string stringByFoldingWithOptions:comparisonOptions locale:localeEnglish];
}

// ローマ数字 -> 数字変換 (事前に小文字変換しておく必要あり)
+ (NSString *) convertRomanNumber:(NSString *)string {
    
    static NSArray *romans = nil;
    
    NSString *ret = string;
    
    if (!romans) {
        
        romans = [[NSArray alloc] initWithObjects:@"i", @"ii", @"iii", @"iv", @"v", @"vi", @"vii", @"viii", @"ix", @"x", nil];
    }
    
    if (string != nil && string.length <= 4) {
        int i = 1;
        for (NSString *rm in romans) {
            
            if ([string isEqualToString:rm]) {
                
                ret = [NSString stringWithFormat:@"%d", i];
                
                break;
            }
            
            i++;
        }
    }
    
    return ret;
}

// 1〜10の数字文字列を数値型に変換する
+ (NSNumber *) convertToNumber:(NSString *)string {
    
    static NSArray *numbers = nil;
    
    NSNumber *ret = nil;
    
    if (!numbers) {
        
        numbers = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    }
    
    if (string != nil && string.length <= 2) {
        int i = 1;
        for (NSString *nm in numbers) {
            
            if ([string isEqualToString:nm]) {
                
                ret = [NSNumber numberWithInt:i];
                
                break;
            }
            
            i++;
        }
    }
    
    return ret;
}

+ (NSString *) joinString:(NSString *)string1 withString:(NSString *)string2 format:(NSString *)format {
	
	NSString *len1 = [string1 length];
	NSString *len2 = [string2 length];
		
	NSString *term = nil;
	
	if (len1 && len2) {
		
		term = [NSString stringWithFormat:format, string1, string2];
	} else {
		
		if (len1) {
			term = [NSString stringWithString:string1];
		} else {
			term = [NSString stringWithString:string2];
		}
	}
	
	return term;
}

+ (NSInteger) lengthOfArray:(NSArray *)array {
    
    NSInteger len = 0;
    
    for (NSString *str in array) {
        
        len += [str length];
    }
    
    return len;
}

+ (NSInteger) lengthOfArrayArray:(NSArray *)array {
    
    NSInteger len = 0;
    
    for (NSArray *ary in array) {
        
        len += [self lengthOfArray:ary];
    }
    
    return len;
}

+ (NSInteger) countOfArrayArray:(NSArray *)array {
    
    NSInteger cnt = 0;
    
    for (NSArray *ary in array) {
        
        cnt += [ary count];
    }
    
    return cnt;
}

+ (NSArray *) separateBrackets:(NSString *)string by:(NSString *)bracket {
    
    NSString *main = nil;
    NSString *sub  = nil;
    
    NSRange range = [string rangeOfString:bracket options:NSBackwardsSearch];
    
    // 見つかった
    if (range.length) {
        
        // カッコ開始位置が文字列先頭
        if (range.location == 0) {
            
            main = [NSString stringWithString:string];
            sub  = @"";
        }
        else {
            
            main = [string substringToIndex  :range.location];
            main = [main   stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]];

            sub  = [string substringFromIndex:range.location];
        }
    }
    // 見つからない
    else {
        
        main = [NSString stringWithString:string];
        sub  = @"";
    }

    return [NSArray arrayWithObjects:main, sub, nil];
}

#pragma mark - UserDefault Access

// ユーザ設定全消去 - 主にデバッグ用
- (void)clearAllUserDefaults {

	[userDefault removeObjectForKey:UDNumberOfColumns];
	[userDefault removeObjectForKey:UDAppearance];

	[userDefault removeObjectForKey:UDTextColor];
	[userDefault removeObjectForKey:UDBackgroundColor];
	[userDefault removeObjectForKey:UDFont];

	[userDefault removeObjectForKey:UDAutoSrchTimeout];
	[userDefault removeObjectForKey:UDManuSrchTimeout];
	[userDefault removeObjectForKey:UDJapaneseLyricsRomaji];
	[userDefault removeObjectForKey:UDJapaneseLyricsKanji];
    [userDefault removeObjectForKey:UDHideNoHits];
    [userDefault removeObjectForKey:UDHideLyricFooterURL];

	[userDefault removeObjectForKey:UDCountryCode];

	[userDefault removeObjectForKey:UDEnabledSites];
	[userDefault removeObjectForKey:UDDisabledSites];
	
    [userDefault removeObjectForKey:UDIncludeLyricHeader];
	[userDefault removeObjectForKey:UDIncludeLyricFooter];
	[userDefault removeObjectForKey:UDAskBeforeOverwrite];
	[userDefault removeObjectForKey:UDAutosave];
	[userDefault removeObjectForKey:UDAutosaveTx];
    
    [userDefault removeObjectForKey:UDArrowsLeftRight];
    [userDefault removeObjectForKey:UDArrowsUpDown];
    
    [userDefault removeObjectForKey:UDBatchInterval];
    
    [userDefault removeObjectForKey:UDLyricsFolder];
    [userDefault removeObjectForKey:UDSubFolderByArtist];
    
    [userDefault removeObjectForKey:UDShowDateModified];
    
    [userDefault removeObjectForKey:UDOpeniTunesAtLaunch];
    [userDefault removeObjectForKey:UDAlwaysOnTop];
    
	[userDefault synchronize];
}

- (NSInteger)userNumberOfColumns {
	
	NSInteger cNum = [userDefault integerForKey:UDNumberOfColumns];
	if (cNum == 0) {
		
		// デフォルトカラム数
		cNum = 1;
	}
	return cNum;
}

- (NSInteger)userAppearance {
	
	NSInteger appearance = [userDefault integerForKey:UDAppearance];
	if (appearance == 0) {
		
		// デフォルト Appearance モード
		appearance = SC_APPEARANCE_FULL;
	}
	return appearance;
}

- (NSFont *)userFont {

	NSFont *font = [self fontFromData:[userDefault objectForKey:UDFont]];
	if (font == nil) {
		
		static NSString * const defaultFont = @"Lucida Grande";

		// デフォルトフォント
		font = [NSFont fontWithName:defaultFont size:13];
	}
	return font;
}

- (NSColor *)userTextColor {
	
	NSColor *color = [self colorFromData:[userDefault objectForKey:UDTextColor]];
	if (color == nil) {
		
		// デフォルト文字色
		color = [NSColor blackColor];
	}
	return color;
}

- (NSColor *)userBackgroundColor {
	
	NSColor *color = [self colorFromData:[userDefault objectForKey:UDBackgroundColor]];
	if (color == nil) {
		
		// デフォルト背景色
		color = [NSColor whiteColor];
	}
	return color;
}

- (NSInteger)userAutoSrchTimeout {
	
	NSInteger autoSrchTimeout = [userDefault integerForKey:UDAutoSrchTimeout];
	if (autoSrchTimeout == 0) {
		
		// デフォルト自動検索タイムアウト
		autoSrchTimeout = 3;
	}
	return autoSrchTimeout;	
}

- (NSInteger)userManuSrchTimeout {
	
	NSInteger manuSrchTimeout = [userDefault integerForKey:UDManuSrchTimeout];
	if (manuSrchTimeout == 0) {
		
		// デフォルト手動検索タイムアウト
		manuSrchTimeout = 5;
	}
	return manuSrchTimeout;	
}

- (NSInteger)userJapaneseLyricsRomaji {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDJapaneseLyricsRomaji]];
	if (value == -1) {
		
		// デフォルト
        if ([defaultCountryCode isEqualToString:@"JP"])
            value = NSOffState;
        else
            value = NSOnState;
	}
	return value;
}

- (NSInteger)userJapaneseLyricsKanji {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDJapaneseLyricsKanji]];
	if (value == -1) {
		
		// デフォルト
        if ([defaultCountryCode isEqualToString:@"JP"])
            value = NSOnState;
        else
            value = NSOffState;
	}
	return value;
}

- (NSInteger)userHideNoHits {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDHideNoHits]];
	if (value == -1) {
		
		// デフォルト
		value = NSOffState;
	}
	return value;
}

- (NSInteger)userHideLyricFooterURL {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDHideLyricFooterURL]];
	if (value == -1) {
		
		// デフォルト 変更 (Off -> On) (v4.0)
        value = NSOnState;
	}
	return value;
}

- (NSString *)userCountryCode {
	
	NSString *code = [userDefault stringForKey:UDCountryCode];
	if (code == nil) {
		
		// デフォルト国設定
		code = defaultCountryCode;
	}
	return code;	
}

- (NSArray *)userEnabledSites {

    NSArray *array = [self arrayFromData:[userDefault objectForKey:UDEnabledSites]];
	if (array == nil) {
		
		// デフォルト検索サイト
		array = [self defaultSiteList];
	}
	return array;
}

- (NSArray *)userDisabledSites {

	NSArray *array = [self arrayFromData:[userDefault objectForKey:UDDisabledSites]];
	if (array == nil) {

		// デフォルト検索サイト
        array = [self defaultDisabledSiteList];
	}
	 return array;
}

- (NSInteger)userIncludeLyricHeader {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDIncludeLyricHeader]];
	if (value == -1) {
		
		// デフォルト Lyric Header 埋込み
		value = NSOnState;
	}
	return value;
}

- (NSInteger)userIncludeLyricFooter {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDIncludeLyricFooter]];
	if (value == -1) {
		
		// デフォルト Lyric Footer 埋込み
		value = NSOnState;
	}
	return value;
}

- (NSInteger)userAskBeforeOverwrite {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDAskBeforeOverwrite]];
	if (value == -1) {
		
		// デフォルト 上書き確認
		value = NSOffState;
	}
	return value;
}

- (NSInteger)userAutosave {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDAutosave]];
	if (value == -1) {
		
		// デフォルト Autosave モード
		value = NSOffState;
	}
	return value;
}

- (NSInteger)userAutosaveTx {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDAutosaveTx]];
	if (value == -1) {
		
		// デフォルト AutosaveTx モード
		value = NSOffState;
	}
	return value;
}

- (NSInteger)userArrowsLeftRight {

    NSInteger value = [self integerFromData:[userDefault objectForKey:UDArrowsLeftRight]];
	if (value == -1) {
		
		// デフォルト
		value = NSOffState;
	}
	return value;
}

- (NSInteger)userArrowsUpDown {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDArrowsUpDown]];
	if (value == -1) {
		
		// デフォルト
		value = NSOffState;
	}
	return value;
}

- (NSString *)userLyricsFolder {
	
	NSString *value = [userDefault stringForKey:UDLyricsFolder];
	if (value == nil) {

		// ユーザの Documents ディレクトリ取得
        NSArray *ary = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *docDir;
        
        if (ary.count > 0) docDir = [ary objectAtIndex:0];
        else               docDir = @"/";
        
		// デフォルト設定 (書類ディレクトリ/SSR)
        value = [docDir stringByAppendingPathComponent:@"SSR"];
	}
    
	return value;
}

- (NSInteger)userSubFolderByArtist {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDSubFolderByArtist]];
	if (value == -1) {
		
		// デフォルト
		value = NSOnState;
	}
	return value;
}

- (NSInteger)userShowDateModified {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDShowDateModified]];
	if (value == -1) {
		
		// デフォルト
		value = NSOffState;
	}
	return value;
}

- (NSInteger)userBatchInterval {
	
	NSInteger batchInterval = [userDefault integerForKey:UDBatchInterval];
	if (batchInterval == 0) {
		
		// デフォルト Batch Interval
		batchInterval = 10;
	}
	return batchInterval;
}

- (NSInteger)userOpeniTunesAtLaunch {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDOpeniTunesAtLaunch]];
    if (value == -1) {
        
        // デフォルト
        value = NSOffState;
    }
    return value;
}

- (NSInteger)userAlwaysOnTop {
    
    NSInteger value = [self integerFromData:[userDefault objectForKey:UDAlwaysOnTop]];
    if (value == -1) {
        
        // デフォルト
        value = NSOffState;
    }
    return value;
}

#pragma  mark - UD Utilities

- (NSData *)dataFromColor:(NSColor *)color {
	return [NSArchiver archivedDataWithRootObject:color];
}

- (NSColor *)colorFromData:(NSData *)data {
	if (data == nil) {
		return nil;
	}
	return [NSUnarchiver unarchiveObjectWithData:data];
}



- (NSData *)dataFromFont:(NSFont *)font {
	return [NSArchiver archivedDataWithRootObject:font];
}

- (NSFont *)fontFromData:(NSData *)data {
	if (data == nil) {
		return nil;
	}
	return [NSUnarchiver unarchiveObjectWithData:data];
}



- (NSData *)dataFromArray:(NSArray *)array {
	return [NSArchiver archivedDataWithRootObject:array];
}

- (NSArray *)arrayFromData:(NSData *)data {
	if (data == nil) {
		return nil;
	}
	return [NSUnarchiver unarchiveObjectWithData:data];
}


// 格納用
- (NSData *)dataFromInteger:(NSInteger)integer {
    
    // NSNumber に変換
    NSNumber *number = [NSNumber numberWithInteger:integer];
    
	return [NSArchiver archivedDataWithRootObject:number];
}

// 取得用
- (NSInteger)integerFromData:(NSData *)data {
	if (data == nil) {
		return -1;
	}
    
    NSNumber *number = nil;

    @try {
        number = [NSUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        number = nil;
    }
    @finally {
        
    }
    
    if (number) {
        return [number integerValue];
    } else {
        return -1;
    }
}

#pragma mark - Other Utilities

- (NSColor *) colorForPerfectMatch {
	
	static NSColor *color = nil;
	
	if (!color) {
		// Turqoise (Blue)
		color = [NSColor colorWithCalibratedRed:0.0 
										  green:1.0 
										   blue:1.0 alpha:0.5];
		[color retain];
	}
	
	return color;
}

- (NSColor *) colorForHighMatch {
	
	static NSColor *color = nil;
	
	if (!color) {
		// Lime (Green)
		color = [NSColor colorWithCalibratedRed:0.3 
										  green:1.0 
										   blue:0.0 alpha:0.5];
		[color retain];
	}
	
	return color;
}

- (NSColor *) colorForGoodMatch {
	
	static NSColor *color = nil;
	
	if (!color) {
		// Lemon (Yellow)
		color = [NSColor colorWithCalibratedRed:1.0 
										  green:1.0 
										   blue:0.1 alpha:0.5];
		[color retain];
	}
	
	return color;
}

- (NSColor *) colorForLowMatch {
	
	static NSColor *color = nil;
	
	if (!color) {
		// Tangerine (Orange)
		color = [NSColor colorWithCalibratedRed:1.0 
										  green:0.6 
										   blue:0.3 alpha:0.5];
		[color retain];
	}
	
	return color;
}

+ (NSString *) urlEncode:(NSString *)aString {
    
    return [self urlEncode:aString targetEncoding:kCFStringEncodingUTF8];
}

+ (NSString *) urlEncode:(NSString *)aString targetEncoding:(CFStringEncoding)encoding {
    
	static NSString * const characters = @"!*'();:@&=+$,/?%#[]";
	
	NSString *encoded = (NSString*)CFURLCreateStringByAddingPercentEscapes(
                            kCFAllocatorDefault,
                            (CFStringRef)aString,
                            NULL,
                            (CFStringRef)characters,
                            encoding);
    
	return [encoded autorelease];
}

+ (NSInteger) okAlertWithMessage:(NSString *)message info:(NSString *)info {
    
    NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", info];

    return [alert runModal];
}

+ (NSInteger) yesOrNoAlertWithMessage:(NSString *)message info:(NSString *)info {
    
    NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"%@", info];
    
    return [alert runModal];
}

SCStateIndex statusForCode(NSInteger code) {
    
    SCStateIndex sts = 0;
    
    if      (code == 1)     sts = SC_STATE_GREEN;
    else if (code == 0)     sts = SC_STATE_OFF;
    else if (code == -1)    sts = SC_STATE_RED;
    else if (code == -2)    sts = SC_STATE_YELLOW;
    else if (code == -10)   sts = SC_STATE_YELLOW;
    else if (code == -1000) sts = SC_STATE_OFF;
    else                    sts = SC_STATE_YELLOW;
    
    return sts;
}

@end


