#import "NCGroup.h"

__strong NSMutableDictionary* sectionsStore;

static __strong NSString* kSection = @"section";
static __strong NSString* kHide = @"hide";
static __strong NSString* kTitleFormat = @"%@ (%d)";

static BOOL ncgroupEnabled;
static BOOL ncgroupHideDafault;
static BOOL ncgroupSaveState;
static BOOL ncgroupTitleBackgroundClear;
static BOOL ncgroupCountBulletin;
static BOOL ncgroupCountBulletinWhenVisible;
static BOOL ncgroupSplitLines;

static BOOL notFirstLoad;

@implementation NCGroupTapGestureRecognizer
@end

%group NCGroup
%hook SBNotificationCenterHeaderView
%property (nonatomic, retain) NCGroupTapGestureRecognizer *ShowHideGesture;
%property (nonatomic, assign) int Section;


%new
- (void)showHideSection:(NCGroupTapGestureRecognizer*)sender
{
	@try {
		if(!ncgroupEnabled) {
			return;
		}
		SBNotificationCenterHeaderView* viewTapped = self;//(SBNotificationCenterHeaderView*)[sender view];
		for (int i = 0; i < [viewTapped.tableView numberOfSections]; i++) {
			CGRect rect = [viewTapped.tableView rectForHeaderInSection:i];
			if (CGRectContainsPoint(rect, viewTapped.frame.origin)) {
				viewTapped.Section = i;
				break;
			}
		}		
		SBBulletinViewController* controll = (SBBulletinViewController*)viewTapped.tableView.delegate;
		if([controll respondsToSelector:@selector(_sectionInfoAtIndexPath:)]) {
			SBNotificationCenterSectionInfo* sectionInfo = [controll _sectionInfoAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:viewTapped.Section]];
			if(sectionInfo && [sectionInfo respondsToSelector:@selector(identifier)]) {
				NSString* bundleID = sectionInfo.identifier;
				BOOL isHidden = [[[sectionsStore objectForKey:bundleID]?:[NSDictionary dictionary] objectForKey:kHide]?:@(ncgroupHideDafault) boolValue]?NO:YES;
				[sectionsStore setObject:@{kHide: @(isHidden),} forKey:bundleID];
				[sectionsStore writeToFile:@PLIST_PATH_Section atomically:YES];
				
				
				[viewTapped.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(viewTapped.Section, 1)] withRowAnimation:UITableViewRowAnimationFade];
			}
		}		
	} @catch (NSException * e) {
		
	}
}
- (void)layoutSubviews
{
	@try {
		if(!self.ShowHideGesture) {
			self.ShowHideGesture = [[NCGroupTapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideSection:)];
			self.ShowHideGesture.numberOfTapsRequired = 1;
			[self addGestureRecognizer:self.ShowHideGesture];
		}
		if(ncgroupEnabled) {
			if(ncgroupSplitLines) {
				self.layer.cornerRadius = 8;
				self.layer.masksToBounds = YES;
				self.layer.borderColor = [UIColor whiteColor].CGColor;
				self.layer.borderWidth = 0.2f;
			}
		}
		for(UIView* bk1 in [self.contentView subviews]) {
			if([bk1 isKindOfClass:[UIView class]]) {
				bk1.hidden = ncgroupEnabled&&ncgroupTitleBackgroundClear;
				break;
			}
		}
		
	} @catch (NSException * e) {
		
	}
	%orig;
}
%end



%hook SBBulletinClass

%new
-(void)updateTitleWithSection:(SBNotificationCenterSectionInfo*)sectionInfo
{
	@try {
	@autoreleasepool {
	    if([self respondsToSelector:@selector(_sectionInfoAtIndexPath:)]) {
			SBBulletinViewController * SBBBC = (SBBulletinViewController *)self;
			NSMutableArray* orderedSections = (NSMutableArray *)object_getIvar(self, class_getInstanceVariable([self class], "_orderedSections"));			
			if(sectionInfo && [sectionInfo respondsToSelector:@selector(representedObject)]) {
				SBBulletinListSection* Represent = sectionInfo.representedObject;
				if(Represent && [sectionInfo respondsToSelector:@selector(identifier)] && [Represent respondsToSelector:@selector(isBulletinSection)] && [Represent respondsToSelector:@selector(bulletins)] && [Represent respondsToSelector:@selector(displayName)]) {
					if([Represent isBulletinSection]) {
						int section = [orderedSections indexOfObject:sectionInfo];
						int CountBB = [self tableView:SBBBC.tableView numberOfRowsInSection:section];
						if(CountBB > 0) {
							if(NSString* bundleID = sectionInfo.identifier) {
								NSDictionary* setting = (NSDictionary*)[sectionsStore objectForKey:bundleID]?:[NSDictionary dictionary];
								SBNotificationCenterHeaderView* headerVisible = (SBNotificationCenterHeaderView*)[SBBBC.tableView /*_visibleHeaderViewForSection*/headerViewForSection:section];
								UILabel* labelVisible = (UILabel *)object_getIvar(headerVisible, class_getInstanceVariable([headerVisible class], "_titleLabel"));
								NSString* TabName = [labelVisible.text componentsSeparatedByString:@" ("][0]?: labelVisible.text?:Represent.displayName;
								if(ncgroupEnabled && TabName && ([[setting objectForKey:kHide]?:@(ncgroupHideDafault) boolValue] || ncgroupCountBulletinWhenVisible) ) {
									NSString* titleNew = [NSString stringWithFormat:kTitleFormat, TabName, CountBB];
									if(![labelVisible.text isEqualToString:titleNew]) {
										[labelVisible setText:titleNew];
									}
								} else if(TabName) {
									labelVisible.text = TabName;
								}
							}								
						}
					}
				}
			}
		}
	}
	} @catch (NSException * e) {
	}
}

- (SBNotificationCenterHeaderView *)tableView:(UITableView *)tableView viewForHeaderInSection:(int)section
{
	SBNotificationCenterHeaderView* orig = %orig;
    @try {
	if(orig && ncgroupCountBulletin) {
		@autoreleasepool {
			if(NSMutableArray* orderedSections = (NSMutableArray *)object_getIvar(self, class_getInstanceVariable([self class], "_orderedSections"))) {
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTitleWithSection:) object:orderedSections[section]];
				[self performSelector:@selector(updateTitleWithSection:) withObject:orderedSections[section] afterDelay:0.2];
			}			
		}
	}
	} @catch (NSException * e) {
	}	
	return orig;
}

- (id)initWithStyle:(long long)arg1
{
	id orig = %orig;
	if(orig && [orig respondsToSelector:@selector(invalidateCachedLayoutData)]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateCachedLayoutData) name:@"com.julioverne.ncgroup/Settings/Table" object:nil];
	}
	return orig;
}

%new
- (BOOL)ncgroupIsSectionHidden:(NSIndexPath*)indexPath
{
	@try {
		if(ncgroupEnabled) {
			@autoreleasepool {
				SBBulletinViewController * SBBBC = (SBBulletinViewController *)self;
				if(indexPath.row == 0) {
					SBNotificationCenterHeaderView* HeaderView = (SBNotificationCenterHeaderView*)[SBBBC.tableView.delegate tableView:SBBBC.tableView viewForHeaderInSection:indexPath.section];
					HeaderView.Section = indexPath.section;
				}
				if(NSMutableArray* orderedSections = (NSMutableArray *)object_getIvar(SBBBC, class_getInstanceVariable([SBBBC class], "_orderedSections"))) {
					SBNotificationCenterSectionInfo* sectionInfo = orderedSections[indexPath.section];
					if(sectionInfo && [sectionInfo respondsToSelector:@selector(identifier)]) {
						if(NSDictionary* setting = (NSDictionary*)[sectionsStore objectForKey:sectionInfo.identifier]) {
							if([[setting objectForKey:kHide]?:@(ncgroupHideDafault) boolValue]) {
								return YES;
							}
						} else {
							if(ncgroupHideDafault) {
								return YES;
							}
						}
					}
				}
			}
		}
	} @catch (NSException * e) {
		return NO;
	}
	return NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if([self ncgroupIsSectionHidden:indexPath]) {
		return 0.0f;
	}
    return %orig;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	@try {
		if([self ncgroupIsSectionHidden:indexPath]) {
			static __strong NSString* simpleTableIdentifier = @"NCGroup";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
			if (cell == nil) {
				cell = (UITableViewCell *)[[%c(SBNotificationsBulletinCell) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
			}
			cell.hidden = YES;
			return cell;
		}
	} @catch (NSException * e) {
		return %orig;
	}
    return %orig;
}
%end

%end

static void settingsChangedNCGroup(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{	
	@autoreleasepool {
		NSDictionary *WidPlayerPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
		ncgroupEnabled = (BOOL)[[WidPlayerPrefs objectForKey:@"Enabled"]?:@YES boolValue];
		ncgroupHideDafault = (BOOL)[[WidPlayerPrefs objectForKey:@"HideDafault"]?:@YES boolValue];
		ncgroupSaveState = (BOOL)[[WidPlayerPrefs objectForKey:@"SaveState"]?:@YES boolValue];
		ncgroupTitleBackgroundClear = (BOOL)[[WidPlayerPrefs objectForKey:@"TitleBackgroundClear"]?:@NO boolValue];
		ncgroupCountBulletin = (BOOL)[[WidPlayerPrefs objectForKey:@"CountBulletin"]?:@YES boolValue];
		ncgroupCountBulletinWhenVisible = (BOOL)[[WidPlayerPrefs objectForKey:@"CountBulletinWhenVisible"]?:@YES boolValue];
		ncgroupSplitLines = (BOOL)[[WidPlayerPrefs objectForKey:@"SplitLines"]?:@YES boolValue];
		sectionsStore = ncgroupSaveState?[[[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Section] mutableCopy]?:[NSMutableDictionary dictionary]:[NSMutableDictionary dictionary];
		if(notFirstLoad) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.julioverne.ncgroup/Settings/Table" object:nil];
		} else {
			notFirstLoad = YES;
		}		
	}
}

__attribute__((constructor)) static void initialize_NCGroup()
{
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangedNCGroup, CFSTR("com.julioverne.ncgroup/Settings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		settingsChangedNCGroup(NULL, NULL, NULL, NULL, NULL);
        %init(NCGroup, SBBulletinClass = objc_getClass("SBNCTableViewController")?:objc_getClass("SBBulletinViewController"));
    }
}