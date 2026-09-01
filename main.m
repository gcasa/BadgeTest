#import <AppKit/AppKit.h>
#import <AppKit/NSDockTile.h>

@interface NSApplication (BadgeTestDockTile)
- (NSDockTile *) dockTile;
@end

@interface BadgeTestDelegate : NSObject <NSApplicationDelegate>
{
  NSWindow *_window;
  NSTextField *_badgeField;
  NSTextField *_statusLabel;
  NSButton *_showsBadgeButton;
  NSInteger _badgeValue;
}
@end

@implementation BadgeTestDelegate

- (void) dealloc
{
  [_window release];
  [super dealloc];
}

- (NSTextField *) labelWithFrame: (NSRect)frame text: (NSString *)text
{
  NSTextField *label = [[[NSTextField alloc] initWithFrame: frame] autorelease];

  [label setStringValue: text];
  [label setBezeled: NO];
  [label setDrawsBackground: NO];
  [label setEditable: NO];
  [label setSelectable: NO];
  return label;
}

- (NSButton *) buttonWithFrame: (NSRect)frame
			 title: (NSString *)title
			action: (SEL)action
{
  NSButton *button = [[[NSButton alloc] initWithFrame: frame] autorelease];

  [button setTitle: title];
  [button setTarget: self];
  [button setAction: action];
  [button setBezelStyle: NSRoundedBezelStyle];
  return button;
}

- (void) updateStatusWithBadge: (NSString *)badge
{
  NSDockTile *tile = [NSApp dockTile];
  NSString *status;

  status = [NSString stringWithFormat:
    @"dockTile=%@  badgeLabel=%@  showsApplicationBadge=%@",
    tile ? @"yes" : @"no",
    [tile badgeLabel] ? [tile badgeLabel] : @"(nil)",
    [tile showsApplicationBadge] ? @"YES" : @"NO"];
  [_statusLabel setStringValue: status];

  NSLog(@"BadgeTest set NSDockTile badge label to %@",
    badge ? badge : @"(nil)");
}

- (void) applyBadge: (NSString *)badge
{
  NSDockTile *tile = [NSApp dockTile];

  [tile setShowsApplicationBadge: [_showsBadgeButton intValue] != 0];
  [tile setBadgeLabel: badge];
  [tile display];
  [self updateStatusWithBadge: badge];
}

- (void) applyBadgeFromField: (id)sender
{
  NSString *badge = [_badgeField stringValue];

  if ([badge length] == 0)
    {
      badge = nil;
    }
  [self applyBadge: badge];
}

- (void) incrementBadge: (id)sender
{
  _badgeValue++;
  [_badgeField setStringValue:
    [NSString stringWithFormat: @"%ld", (long)_badgeValue]];
  [self applyBadgeFromField: sender];
}

- (void) clearBadge: (id)sender
{
  [_badgeField setStringValue: @""];
  [self applyBadge: nil];
}

- (void) toggleShowsApplicationBadge: (id)sender
{
  [self applyBadgeFromField: sender];
}

- (void) createMenu
{
  NSMenu *mainMenu = [[[NSMenu alloc] initWithTitle: @"Main Menu"] autorelease];
  NSMenuItem *appMenuItem = [[[NSMenuItem alloc] initWithTitle: @"BadgeTest"
						       action: NULL
						keyEquivalent: @""]
    autorelease];
  NSMenu *appMenu = [[[NSMenu alloc] initWithTitle: @"BadgeTest"] autorelease];
  NSMenuItem *quitItem = [[[NSMenuItem alloc]
    initWithTitle: @"Quit BadgeTest"
	   action: @selector(terminate:)
    keyEquivalent: @"q"] autorelease];

  [mainMenu addItem: appMenuItem];
  [appMenu addItem: quitItem];
  [appMenuItem setSubmenu: appMenu];
  [NSApp setMainMenu: mainMenu];
}

- (void) createWindow
{
  NSView *content;
  NSButton *applyButton;
  NSButton *incrementButton;
  NSButton *clearButton;

  _window = [[NSWindow alloc]
    initWithContentRect: NSMakeRect(300, 300, 440, 190)
	      styleMask: (NSTitledWindowMask
			  | NSClosableWindowMask
			  | NSMiniaturizableWindowMask)
		backing: NSBackingStoreBuffered
		  defer: NO];
  [_window setTitle: @"NSDockTile Badge Test"];

  content = [_window contentView];
  [content addSubview: [self labelWithFrame: NSMakeRect(20, 140, 400, 24)
				       text: @"Badge label for the application NSDockTile"]];

  _badgeField = [[NSTextField alloc] initWithFrame: NSMakeRect(20, 105, 160, 28)];
  [_badgeField setTarget: self];
  [_badgeField setAction: @selector(applyBadgeFromField:)];
  [content addSubview: _badgeField];
  [_badgeField release];

  applyButton = [self buttonWithFrame: NSMakeRect(195, 104, 70, 30)
				title: @"Apply"
			       action: @selector(applyBadgeFromField:)];
  [content addSubview: applyButton];

  incrementButton = [self buttonWithFrame: NSMakeRect(275, 104, 80, 30)
				    title: @"+1"
				   action: @selector(incrementBadge:)];
  [content addSubview: incrementButton];

  clearButton = [self buttonWithFrame: NSMakeRect(365, 104, 55, 30)
				title: @"Clear"
			       action: @selector(clearBadge:)];
  [content addSubview: clearButton];

  _showsBadgeButton = [[NSButton alloc] initWithFrame: NSMakeRect(20, 70, 220, 24)];
  [_showsBadgeButton setButtonType: NSSwitchButton];
  [_showsBadgeButton setTitle: @"Shows application badge"];
  [_showsBadgeButton setState: NSOnState];
  [_showsBadgeButton setTarget: self];
  [_showsBadgeButton setAction: @selector(toggleShowsApplicationBadge:)];
  [content addSubview: _showsBadgeButton];
  [_showsBadgeButton release];

  _statusLabel = [[NSTextField alloc] initWithFrame: NSMakeRect(20, 25, 400, 24)];
  [_statusLabel setBezeled: NO];
  [_statusLabel setDrawsBackground: NO];
  [_statusLabel setEditable: NO];
  [_statusLabel setSelectable: YES];
  [content addSubview: _statusLabel];
  [_statusLabel release];

  [_window makeKeyAndOrderFront: nil];
}

- (void) applicationDidFinishLaunching: (NSNotification *)notification
{
  _badgeValue = 7;

  [self createMenu];
  [self createWindow];
  [_badgeField setStringValue: [NSString stringWithFormat: @"%ld", (long)_badgeValue]];
  [self applyBadgeFromField: self];
  [NSApp activateIgnoringOtherApps: YES];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)sender
{
  return YES;
}

@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  BadgeTestDelegate *delegate = [BadgeTestDelegate new];

  [[NSUserDefaults standardUserDefaults] registerDefaults:
    [NSDictionary dictionaryWithObject: [NSNumber numberWithBool: YES]
				forKey: @"GSUseIconManager"]];
  [NSApplication sharedApplication];
  [NSApp setDelegate: delegate];
  [NSApp run];

  [delegate release];
  [pool release];
  return 0;
}
