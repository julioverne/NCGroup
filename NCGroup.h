#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <notify.h>
#import <substrate.h>
#import <libactivator/libactivator.h>
#import <CommonCrypto/CommonCrypto.h>

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.ncgroup.plist"
#define PLIST_PATH_Section "/var/mobile/Library/Preferences/com.julioverne.ncgroup.section.plist"

@interface NCGroupTapGestureRecognizer : UITapGestureRecognizer
@end

@interface UITableView ()
- (id)_visibleHeaderViewForSection:(int)arg1;
@end

@interface SBNotificationsClearButton : UIControl
{
	UIImageView* _circleImageView;
	UIImageView* _xImageView;
	UIImageView* _compositeCircleXImageView;
}
@property(readonly, nonatomic) long long clearButtonState;
-(id)_xImage;
-(id)_circleImage;
@end


@interface SBNotificationCenterHeaderView : UITableViewHeaderFooterView
{
	SBNotificationsClearButton *_clearButton;
}
@property (nonatomic, retain) NCGroupTapGestureRecognizer *ShowHideGesture;
@property (nonatomic, assign) int Section;
@property(readonly, nonatomic) UILabel *titleLabel;
@property (nonatomic) UITableView *tableView;
- (void)setBackgroundView:(id)arg1;
@end

@interface SBBulletinListSection : NSObject
@property(copy, nonatomic) NSString *displayName;
@property (nonatomic,retain,readonly) NSArray * bulletins;
- (BOOL)isBulletinSection;
@end
@interface SBNotificationCenterSectionInfo : NSObject
@property(readonly, nonatomic) NSString *identifier;
@property(readonly, retain, nonatomic) SBBulletinListSection* representedObject;
@end

@interface SBBulletinViewController : UITableViewController <UITableViewDelegate>
{
	NSMutableArray *_orderedSections;
}
- (id)_sectionInfoAtIndexPath:(id)arg1;
- (BOOL)ncgroupIsSectionHidden:(NSIndexPath*)indexPath;
@end

@interface SBBulletinClass : SBBulletinViewController
@end
