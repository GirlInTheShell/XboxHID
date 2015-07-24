//
// FPXboxHIDPrefsPane.m
// "Xbox HID"
//
// Created by Darrell Walisser <walisser@mac.com>
// Copyright (c)2007 Darrell Walisser. All Rights Reserved.
// http://sourceforge.net/projects/xhd
//
// Forked and Modifed by macman860 <email address unknown>
// https://macman860.wordpress.com
//
// Forked and Modified by Paige Marie DePol <pmd@fizzypopstudios.com>
// Copyright (c)2015 FizzyPop Studios. All Rights Reserved.
// http://xboxhid.fizzypopstudios.com
//
// =========================================================================================================================
// This file is part of the Xbox HID Driver, Daemon, and Preference Pane software (known as "Xbox HID").
//
// "Xbox HID" is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
//
// "Xbox HID" is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with "Xbox HID";
// if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
// =========================================================================================================================


#import <IOKit/hid/IOHIDUsageTables.h>

#import "FPXboxHIDPrefsPane.h"
#import "FPXboxHIDDriverInterface.h"
#import "FPXboxHIDPrefsLoader.h"
#import "FPHIDUtilities.h"
#import "FPTriggerView.h"
#import "FPAxisPairView.h"
#import "FPButtonView.h"
#import "FPDPadView.h"
#import "FPAnalogDigitalButton.h"
#import "FPImageView.h"
#import "FPAlertView.h"
#import "SMDoubleSlider.h"


#define kTriggerAxisIndex       0
#define kTriggerButtonIndex     1

#define kStickAsButtonAlert		15


@implementation FPXboxHIDPrefsPane

#pragma mark === NSPreferencesPane Methods ==========

- (id) initWithBundle: (NSBundle*)bundle
{
	self = [super initWithBundle: bundle];
	if (self != nil) {
		_appID = CFSTR("com.fizzypopstudios.XboxHIDPrefsPane");
	}
	return self;
}

- (void) mainViewDidLoad
{
	[_buttonBackView setMax: 1];
	[_buttonBackView setColor: XBOX_COLOR];
	[_buttonBackView showOverlayOnlyWhenActive];

	[_buttonStartView setMax: 1];
	[_buttonStartView setColor: XBOX_COLOR];
	[_buttonStartView showOverlayOnlyWhenActive];

	[_leftStickDeadzoneX setDeadzoneSlider: _leftStickDeadzoneXField];
	[_leftStickDeadzoneX setDeadzoneValue: 0];

	[_leftStickDeadzoneY setDeadzoneSlider: _leftStickDeadzoneYField];
	[_leftStickDeadzoneY setDeadzoneValue: 0];

	[_rightStickDeadzoneX setDeadzoneSlider: _rightStickDeadzoneXField];
	[_rightStickDeadzoneX setDeadzoneValue: 0];

	[_rightStickDeadzoneY setDeadzoneSlider: _rightStickDeadzoneYField];
	[_rightStickDeadzoneY setDeadzoneValue: 0];

	[_leftTriggerLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_leftTriggerMode setIsDigital: NO];

	[_rightTriggerLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_rightTriggerMode setIsDigital: NO];

	[_buttonWhiteLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_buttonWhiteView setColor: [NSColor whiteColor]];
	[_buttonWhiteMode setIsDigital: NO];

	[_buttonBlackLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_buttonBlackView setColor: [NSColor blackColor]];
	[_buttonBlackMode setIsDigital: NO];

	[_buttonBlueLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_buttonBlueView setColor: [NSColor colorWithCalibratedRed: 0.333 green: 0.750 blue: 1.0 alpha: 1.000]];
	[_buttonBlueMode setIsDigital: NO];

	[_buttonYellowLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_buttonYellowView setColor: [NSColor yellowColor]];
	[_buttonYellowMode setIsDigital: NO];

	[_buttonGreenLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_buttonGreenView setColor: [NSColor greenColor]];
	[_buttonGreenMode setIsDigital: NO];

	[_buttonRedLivezone setDoubleLoValue: 1 andHiValue: 255];
	[_buttonRedView setColor: [NSColor redColor]];
	[_buttonRedMode setIsDigital: NO];

	[_createText setDelegate: self];

	[_leftStickAlertX setHidden: YES];
	[_leftStickAlertX setAlertView: _alertView];

	[_leftStickAlertY setHidden: YES];
	[_leftStickAlertY setAlertView: _alertView ];

	[_rightStickAlertX setHidden: YES];
	[_rightStickAlertX setAlertView: _alertView];

	[_rightStickAlertY setHidden: YES];
	[_rightStickAlertY setAlertView: _alertView];

	[_actionEdit setTooltip: @"Edit Config Name" withTipControl: _actionTip andBaseControl: _actionBase];
	[_actionUndo setTooltip: @"Undo All Changes" withTipControl: _actionTip andBaseControl: _actionBase];
	[_actionApps setTooltip: @"Edit App Bindings" withTipControl: _actionTip andBaseControl: _actionBase];
	[_actionInfo setTooltip: @"View Pad Information" withTipControl: _actionTip andBaseControl: _actionBase];

	// Use menu item tags to store mapping information
	[[_menuAxisXbox itemAtIndex: kMenuAxisDisabled] setTag: kCookiePadDisabled];
	[[_menuAxisXbox itemAtIndex: kMenuAxisLeftStickH] setTag: kCookiePadLxAxis];
	[[_menuAxisXbox itemAtIndex: kMenuAxisLeftStickV] setTag: kCookiePadLyAxis];
	[[_menuAxisXbox itemAtIndex: kMenuAxisRightStickH] setTag: kCookiePadRxAxis];
	[[_menuAxisXbox itemAtIndex: kMenuAxisRightStickV] setTag: kCookiePadRyAxis];
	[[_menuAxisXbox itemAtIndex: kMenuAxisTriggers] setTag: kCookiePadTriggers];
	[[_menuAxisXbox itemAtIndex: kMenuAxisGreenRed] setTag: kCookiePadGreenRed];
	[[_menuAxisXbox itemAtIndex: kMenuAxisBlueYellow] setTag: kCookiePadBlueYellow];
	[[_menuAxisXbox itemAtIndex: kMenuAxisGreenYellow] setTag: kCookiePadGreenYellow];
	[[_menuAxisXbox itemAtIndex: kMenuAxisBlueRed] setTag: kCookiePadBlueRed];
	[[_menuAxisXbox itemAtIndex: kMenuAxisWhiteBlack] setTag: kCookiePadWhiteBlack];
	[[_menuAxisXbox itemAtIndex: kMenuAxisDPadUpDown] setTag: kCookiePadDPadUpDown];
	[[_menuAxisXbox itemAtIndex: kMenuAxisDPadLeftRight] setTag: kCookiePadDPadLeftRight];

	[[_menuButtonXbox itemAtIndex: kMenuButtonDisabled] setTag: kCookiePadDisabled];
	[[_menuButtonXbox itemAtIndex: kMenuButtonLeftTrigger] setTag: kCookiePadLeftTrigger];
	[[_menuButtonXbox itemAtIndex: kMenuButtonRightTrigger] setTag: kCookiePadRightTrigger];
	[[_menuButtonXbox itemAtIndex: kMenuButtonDPadUp] setTag: kCookiePadDPadUp];
	[[_menuButtonXbox itemAtIndex: kMenuButtonDPadDown] setTag: kCookiePadDPadDown];
	[[_menuButtonXbox itemAtIndex: kMenuButtonDPadLeft] setTag: kCookiePadDPadLeft];
	[[_menuButtonXbox itemAtIndex: kMenuButtonDPadRight] setTag: kCookiePadDPadRight];
	[[_menuButtonXbox itemAtIndex: kMenuButtonStart] setTag: kCookiePadButtonStart];
	[[_menuButtonXbox itemAtIndex: kMenuButtonBack] setTag: kCookiePadButtonBack];
	[[_menuButtonXbox itemAtIndex: kMenuButtonLeftClick] setTag: kCookiePadLeftClick];
	[[_menuButtonXbox itemAtIndex: kMenuButtonRightClick] setTag: kCookiePadRightClick];
	[[_menuButtonXbox itemAtIndex: kMenuButtonGreen] setTag: kCookiePadButtonGreen];
	[[_menuButtonXbox itemAtIndex: kMenuButtonRed] setTag: kCookiePadButtonRed];
	[[_menuButtonXbox itemAtIndex: kMenuButtonBlue] setTag: kCookiePadButtonBlue];
	[[_menuButtonXbox itemAtIndex: kMenuButtonYellow] setTag: kCookiePadButtonYellow];
	[[_menuButtonXbox itemAtIndex: kMenuButtonBlack] setTag: kCookiePadButtonBlack];
	[[_menuButtonXbox itemAtIndex: kMenuButtonWhite] setTag: kCookiePadButtonWhite];

	// copy tags from xbox menus into hid menus
	for (int i = 0; i < kMenuAxisCount; i++)
		if ([[_menuAxisHID itemAtIndex: i] isSeparatorItem] == NO)
			[[_menuAxisHID itemAtIndex: i] setTag: [[_menuAxisXbox itemAtIndex: i] tag]];
	for (int i = 0; i < kMenuButtonCount; i++)
		if ([[_menuButtonHID itemAtIndex: i] isSeparatorItem] == NO)
			[[_menuButtonHID itemAtIndex: i] setTag: [[_menuButtonXbox itemAtIndex: i] tag]];
}


- (void) dealloc
{
	[_devices autorelease];
	[super dealloc];
}


- (void) willSelect
{
	[self configureInterface];
	[self registerForNotifications];
	[self startHIDDeviceInput];
	[self getVersion];
}


- (void) willUnselect
{
	if (_devices) {
		[_devices release];
		_devices = nil;
	}
	[self deregisterForNotifications];
	[self stopHIDDeviceInput];
}


#pragma mark === Private Methods ==================

- (void) getVersion
{
	NSBundle* b = [NSBundle bundleWithPath: @"/System/Library/Extensions/XboxHIDDriver.kext"];
	NSString* version = [[b infoDictionary] objectForKey: @"CFBundleGetInfoString"];
	if (version == nil) version = @"Unknown Version";
	[_textVersion setStringValue: version];
}


#pragma mark --- Devices Popup ------------------------

- (void) buildDevicesPopUpButton
{
	int i;
	int numControllers = 0;
	int numRemotes = 0;

	[_devicePopUpButton setPullsDown: NO];
	[_devicePopUpButton removeAllItems];

	for (i = 0; i < [_devices count]; i++) {
		id obj;
		NSString* type;
		NSMenuItem* item;
		NSString* name;
		int deviceNum;
		obj = [_devices objectAtIndex: i];
		type = [obj deviceType];

		if ([type isEqualTo: NSSTR(kDeviceTypePadKey)]) {
			deviceNum = ++numControllers;
			name = @"Pad";
		} else if ([type isEqualTo: NSSTR(kDeviceTypeIRKey)]) {
			deviceNum = ++numRemotes;
			name = @"IR";
		} else
			deviceNum = 0;
		if (deviceNum) {
			name = [NSString stringWithFormat: @"(%@ #%d) %@", name, deviceNum, [obj productName]];
			[_devicePopUpButton addItemWithTitle: name];
			item = [_devicePopUpButton itemAtIndex: i];
		}
	}
}


- (void) clearDevicesPopUpButton
{
	[_devicePopUpButton removeAllItems];
	[_devicePopUpButton addItemWithTitle: @"No Devices Found"];
}


- (void) buildConfigurationPopUpButton
{
	id intf = [_devices objectAtIndex: [_devicePopUpButton indexOfSelectedItem]];

	NSArray* configs = [FPXboxHIDPrefsLoader configNamesForDeviceType: [intf deviceType]];
	configs = [configs sortedArrayUsingSelector: @selector(compare:)];

	[_configPopUp removeAllItems];
	[_configPopUp addItemWithTitle: kConfigNameDefault];
	if ([configs count] > 1)
		[[_configPopUp menu] addItem: [NSMenuItem separatorItem]];
	NSEnumerator* configNames = [configs objectEnumerator];
	NSString* configName;
	while (configName = [configNames nextObject]) {
		if ([configName isEqualTo: kConfigNameDefault] == NO)
			[_configPopUp addItemWithTitle: configName];
	}

	NSString* currentConfigName = [FPXboxHIDPrefsLoader configNameForDevice: intf];
	[_configPopUp selectItemWithTitle: currentConfigName];
}


#pragma mark --- Config PopUp / Actions -----------------

- (void) enableConfigPopUpButton
{
	[_configPopUp setEnabled: true];
	[_configButtons setEnabled: true];
}


- (void) disableConfigPopUpButton
{
	[_configPopUp setEnabled: false];
	[_configButtons setEnabled: false];
}


- (void) configCreate
{
	NSPoint buttonPoint = NSMakePoint(NSMidX([_configButtons frame]) - 19, NSMidY([_configButtons frame]));
	_popup = [[MAAttachedWindow alloc] initWithView: _createView
	          attachedToPoint: buttonPoint
	          inWindow: [_configButtons window]
	          onSide: MAPositionTop
	          atDistance: 4];
	[_createOK setEnabled: NO];
	[_createOK setKeyEquivalent: @"\r"];
	[_createText setStringValue: @""];
	[self fadeInAttachedWindow];
}


- (IBAction) configCreateEnd: (id)sender
{
	if (sender == _createOK) {
		id device = [_devices objectAtIndex: [_devicePopUpButton indexOfSelectedItem]];
		[FPXboxHIDPrefsLoader createConfigForDevice: device withName: [_createText stringValue]];
		[self buildConfigurationPopUpButton];
	}

	NSTimeInterval delay = [[NSAnimationContext currentContext] duration] + 0.1;
	[self performSelector: @selector(fadeOutAttachedWindow) withObject: nil afterDelay: delay];
	[[_popup animator] setAlphaValue: 0.0];
	[[_tabMask animator] setAlphaValue: 0.0];
	[[NSApplication sharedApplication] stopModal];
}

- (void) configDelete
{
	BOOL isDefault = [[_configPopUp titleOfSelectedItem] isEqualTo: kConfigNameDefault];
	NSPoint buttonPoint = NSMakePoint(NSMidX([_configButtons frame]), NSMidY([_configButtons frame]));
	_popup = [[MAAttachedWindow alloc] initWithView: (isDefault ? _defaultView : _deleteView)
	          attachedToPoint: buttonPoint
	          inWindow: [_configButtons window]
	          onSide: MAPositionTop
	          atDistance: 4];
	[(isDefault ? _defaultOK : _deleteOK) setKeyEquivalent: @"\r"];
	[self fadeInAttachedWindow];
}


- (IBAction) configDeleteEnd: (id)sender
{
	if (sender == _deleteOK) {
		// Delete configuration
		[FPXboxHIDPrefsLoader deleteConfigWithName: [_configPopUp titleOfSelectedItem]];
		[self buildConfigurationPopUpButton];

		// Load configuration now selected in popup
        id device = [_devices objectAtIndex: [_devicePopUpButton indexOfSelectedItem]];
        [FPXboxHIDPrefsLoader loadConfigForDevice: device withName: [_configPopUp titleOfSelectedItem]];
	}

	NSTimeInterval delay = [[NSAnimationContext currentContext] duration] + 0.1;
	[self performSelector: @selector(fadeOutAttachedWindow) withObject: nil afterDelay: delay];
	[[_popup animator] setAlphaValue: 0.0];
	[[_tabMask animator] setAlphaValue: 0.0];
	[[NSApplication sharedApplication] stopModal];
}


- (void) configActions
{
	NSPoint buttonPoint = NSMakePoint(NSMidX([_configButtons frame]) + 19, NSMidY([_configButtons frame]));
	_popup = [[MAAttachedWindow alloc] initWithView: _actionView
	          attachedToPoint: buttonPoint
	          inWindow: [_configButtons window]
	          onSide: MAPositionTop
	          atDistance: 4];
	[_actionEdit setEnabled: NO];
	[_actionUndo setEnabled: NO];
	[_actionApps setEnabled: NO];
	[self fadeInAttachedWindow];
}


- (IBAction) configActionsPick: (id)sender
{
	NSTimeInterval delay = [[NSAnimationContext currentContext] duration] + 0.1;
	[self performSelector: @selector(fadeOutAttachedWindow) withObject: nil afterDelay: delay];
	[[_popup animator] setAlphaValue: 0.0];
	[[_tabMask animator] setAlphaValue: 0.0];
	[[NSApplication sharedApplication] stopModal];
}



#pragma mark --- PopUp Window Support -----------------

- (void) fadeInAttachedWindow
{
	[_popup setBorderColor: [NSColor windowFrameColor]];
	[_popup setBackgroundColor: [NSColor controlColor]];
	[_popup setViewMargin: 1.0];
	[_popup setBorderWidth: 0.0];
	[_popup setHasArrow: NSOnState];
	[_popup setArrowBaseWidth: 17];
	[_popup setArrowHeight: 12];
	[_popup setAlphaValue: 0.0];
	[_tabMask setAlphaValue: 0.0];
	[_tabMask setHidden: NO];

	[[_configButtons window] addChildWindow: _popup ordered: NSWindowAbove];
	[_popup makeKeyAndOrderFront: self];
	[[_popup animator] setAlphaValue: 1.0];
	[[_tabMask animator] setAlphaValue: 1.0];
	[[NSApplication sharedApplication] runModalForWindow: _popup];
}


- (void) fadeOutAttachedWindow
{
	[[_configButtons window] removeChildWindow: _popup];
	[_popup orderOut: nil];
	[_popup release];
	_popup = nil;
}


- (void) controlTextDidChange: (NSNotification*)notify
{
	if ([notify object] == _createText) {
		NSString* text = [[_createText stringValue] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
		[_createOK setEnabled: [text length] > 0 && ![_configPopUp itemWithTitle: text]];
	}
}


#pragma mark --- Error Tab ----------------------------

- (void) showLargeError: (NSString*)errorMessage
{
	[_largeErrorMessage setStringValue: errorMessage];
	[_tabView selectTabViewItemAtIndex: 0];
}


#pragma mark --- Controller Tab ------------------------

- (void) initPadOptionsWithDevice: (id)device
{
	[_leftStickInvertX setState: [device leftStickHorizInvert]];
	[_leftStickDeadzoneX setDeadzoneValue: [device leftStickHorizDeadzone]];

	[_leftStickInvertY setState: [device leftStickVertInvert]];
	[_leftStickDeadzoneY setDeadzoneValue: [device leftStickVertDeadzone]];

	[_rightStickInvertX setState: [device rightStickHorizInvert]];
	[_rightStickDeadzoneX setDeadzoneValue: [device rightStickHorizDeadzone]];

	[_rightStickInvertY setState: [device rightStickVertInvert]];
	[_rightStickDeadzoneY setDeadzoneValue: [device rightStickVertDeadzone]];

	[_leftTriggerLivezone setIntegerLoValue: [device leftTriggerLowThreshold]];
	[_leftTriggerLivezone setIntegerHiValue: [device leftTriggerHighThreshold]];

	[_rightTriggerLivezone setIntegerLoValue: [device rightTriggerLowThreshold]];
	[_rightTriggerLivezone setIntegerHiValue: [device rightTriggerHighThreshold]];

	[_buttonGreenLivezone setIntegerLoValue: [device greenButtonLowThreshold]];
	[_buttonGreenLivezone setIntegerHiValue: [device greenButtonHighThreshold]];

	[_buttonRedLivezone setIntegerLoValue: [device redButtonLowThreshold]];
	[_buttonRedLivezone setIntegerHiValue: [device redButtonHighThreshold]];

	[_buttonBlueLivezone setIntegerLoValue: [device blueButtonLowThreshold]];
	[_buttonBlueLivezone setIntegerHiValue: [device blueButtonHighThreshold]];

	[_buttonYellowLivezone setIntegerLoValue: [device yellowButtonLowThreshold]];
	[_buttonYellowLivezone setIntegerHiValue: [device yellowButtonHighThreshold]];

	[_buttonBlackLivezone setIntegerLoValue: [device blackButtonLowThreshold]];
	[_buttonBlackLivezone setIntegerHiValue: [device blackButtonHighThreshold]];

	[_buttonWhiteLivezone setIntegerLoValue: [device whiteButtonLowThreshold]];
	[_buttonWhiteLivezone setIntegerHiValue: [device whiteButtonHighThreshold]];

	[self initPadPopUpButtons: device];
}


- (void) initPadAxisPopUpButton: (NSPopUpButton*)control withMapping: (int)map
{
	NSMenu* menu = [([_configMenus selectedSegment] == 0 ? _menuAxisXbox : _menuAxisHID) copy];
	[menu setAutoenablesItems: NO];
	[control setMenu: menu];
	[control selectItemWithTag: map];
}


- (void) initPadButtonPopUpButton: (NSPopUpButton*)control withMapping: (int)map
{
	NSMenu* menu = [([_configMenus selectedSegment] == 0 ? _menuButtonXbox : _menuButtonHID) copy];
	[menu setAutoenablesItems: NO];
	[control setMenu: menu];
	[control selectItemWithTag: map];
}


- (void) initPadPopUpButtons: (id)device
{
	[self initPadAxisPopUpButton: _leftStickMenuX withMapping: [device leftStickHorizMapping]];
	[self initPadAxisPopUpButton: _leftStickMenuY withMapping: [device leftStickVertMapping]];
	[self initPadAxisPopUpButton: _rightStickMenuX withMapping: [device rightStickHorizMapping]];
	[self initPadAxisPopUpButton: _rightStickMenuY withMapping: [device rightStickVertMapping]];
	[self checkStickMenus];

#define IS_DIGITAL(type)  (([device analogAsDigital] & BITMASK(kXboxAnalog ## type)) > 0)

	[_leftTriggerMode setIsDigital: IS_DIGITAL(LeftTrigger)];
	[self initPadButtonPopUpButton: _leftTriggerMenu withMapping: [device leftTriggerMapping]];
	[self checkAnalogDigitalMode: _leftTriggerMode withPopUpButton: _leftTriggerMenu];

	[_rightTriggerMode setIsDigital: IS_DIGITAL(RightTrigger)];
	[self initPadButtonPopUpButton: _rightTriggerMenu withMapping: [device rightTriggerMapping]];
	[self checkAnalogDigitalMode: _rightTriggerMode withPopUpButton: _rightTriggerMenu];

	[_buttonGreenMode setIsDigital: IS_DIGITAL(ButtonGreen)];
	[self initPadButtonPopUpButton: _buttonGreenMenu withMapping: [device greenButtonMapping]];
	[self checkAnalogDigitalMode: _buttonGreenMode withPopUpButton: _buttonGreenMenu];

	[_buttonRedMode setIsDigital: IS_DIGITAL(ButtonRed)];
	[self initPadButtonPopUpButton: _buttonRedMenu withMapping: [device redButtonMapping]];
	[self checkAnalogDigitalMode: _buttonRedMode withPopUpButton: _buttonRedMenu];

	[_buttonBlueMode setIsDigital: IS_DIGITAL(ButtonBlue)];
	[self initPadButtonPopUpButton: _buttonBlueMenu withMapping: [device blueButtonMapping]];
	[self checkAnalogDigitalMode: _buttonBlueMode withPopUpButton: _buttonBlueMenu];

	[_buttonYellowMode setIsDigital: IS_DIGITAL(ButtonYellow)];
	[self initPadButtonPopUpButton: _buttonYellowMenu withMapping: [device yellowButtonMapping]];
	[self checkAnalogDigitalMode: _buttonYellowMode withPopUpButton: _buttonYellowMenu];

	[_buttonWhiteMode setIsDigital: IS_DIGITAL(ButtonWhite)];
	[self initPadButtonPopUpButton: _buttonWhiteMenu withMapping: [device whiteButtonMapping]];
	[self checkAnalogDigitalMode: _buttonWhiteMode withPopUpButton: _buttonWhiteMenu];

	[_buttonBlackMode setIsDigital: IS_DIGITAL(ButtonBlack)];
	[self initPadButtonPopUpButton: _buttonBlackMenu withMapping: [device blackButtonMapping]];
	[self checkAnalogDigitalMode: _buttonBlackMode withPopUpButton: _buttonBlackMenu];

#undef IS_DIGITAL

	[self checkButtonMenus];

	[self setAnalogDigitalMax];

	[self initPadButtonPopUpButton: _dpadUpMenu withMapping: [device dpadUpMapping]];
	[self initPadButtonPopUpButton: _dpadDownMenu withMapping: [device dpadDownMapping]];
	[self initPadButtonPopUpButton: _dpadLeftMenu withMapping: [device dpadLeftMapping]];
	[self initPadButtonPopUpButton: _dpadRightMenu withMapping: [device dpadRightMapping]];

	[self initPadButtonPopUpButton: _buttonStartMenu withMapping: [device startButtonMapping]];
	[self initPadButtonPopUpButton: _buttonBackMenu withMapping: [device backButtonMapping]];

	[self initPadButtonPopUpButton: _leftStickMenuBtn withMapping: [device leftClickMapping]];
	[self initPadButtonPopUpButton: _rightStickMenuBtn withMapping: [device rightClickMapping]];
}


- (void) setAnalogDigitalMax
{
#define A2D_MAX(name, button) { \
	id name = [self analogToDigitalControlForPopUp: _ ## name ## Menu]; \
	if ([_ ## name ## Mode isLocked] == NO && [_ ## name ## Mode isDigital] == YES) \
		[name setMax: 1]; \
	else \
		[name setMax: 255]; \
}

	A2D_MAX(leftTrigger, LeftTrigger);
	A2D_MAX(rightTrigger, RightTrigger);
	A2D_MAX(buttonGreen, ButtonGreen);
	A2D_MAX(buttonRed, ButtonRed);
	A2D_MAX(buttonBlue, ButtonBlue);
	A2D_MAX(buttonYellow, ButtonYellow);
	A2D_MAX(buttonWhite, ButtonWhite);
	A2D_MAX(buttonBlack, ButtonBlack);

#undef A2D_MAX
}


- (int) analogDigitalMask
{
	int mask = 0;

#define A2D_MASK(name, button) { \
	if ([_ ## name ## Mode isLocked] == NO && [_ ## name ## Mode isDigital] == YES) \
		mask |= BITMASK(kXboxAnalog ## button); \
}

	A2D_MASK(leftTrigger, LeftTrigger);
	A2D_MASK(rightTrigger, RightTrigger);
	A2D_MASK(buttonGreen, ButtonGreen);
	A2D_MASK(buttonRed, ButtonRed);
	A2D_MASK(buttonBlue, ButtonBlue);
	A2D_MASK(buttonYellow, ButtonYellow);
	A2D_MASK(buttonWhite, ButtonWhite);
	A2D_MASK(buttonBlack, ButtonBlack);

#undef A2D_MASK

	return mask;
}


- (void) initOptionsInterface
{
	NSInteger deviceIndex;
	id device;
	BOOL error = YES;

	deviceIndex = [_devicePopUpButton indexOfSelectedItem];
	if (deviceIndex >= 0 && deviceIndex < [_devices count]) {
		device = [_devices objectAtIndex: deviceIndex];
		if (device && [device hasOptions]) {
			if ([device deviceIsPad]) {
				[_tabView selectTabViewItemAtIndex: 1];
				[self initPadOptionsWithDevice: device];
				[device enableRawReports];
				error = NO;
			}
		}
	}
	if (error) {
		[self showLargeError: @"No Configurable Options"];
		[self disableConfigPopUpButton];
	}
}


- (void) configureInterface
{
	if (_devices)
		[_devices release];
	_devices = [FPXboxHIDDriverInterface interfaces];

	if (_devices) {
		[_devices retain];
		[self buildDevicesPopUpButton];
		[self enableConfigPopUpButton];
		[self buildConfigurationPopUpButton];
		[self initOptionsInterface];
	} else {
		[self showLargeError: @"No Xbox Devices Found"];
		[self disableConfigPopUpButton];
		[self clearDevicesPopUpButton];
	}
}


- (id) analogToDigitalControlForPopUp: (NSPopUpButton*)popup
{
	switch([[popup selectedItem] tag]) {
		case kCookiePadLeftTrigger:
			return _leftTriggerView;

		case kCookiePadRightTrigger:
			return _rightTriggerView;

		case kCookiePadButtonGreen:
			return _buttonGreenView;

		case kCookiePadButtonRed:
			return _buttonRedView;

		case kCookiePadButtonBlue:
			return _buttonBlueView;

		case kCookiePadButtonYellow:
			return _buttonYellowView;

		case kCookiePadButtonWhite:
			return _buttonWhiteView;

		case kCookiePadButtonBlack:
			return _buttonBlackView;

		default:
			return nil;
	}
}


- (void) updateAnalogDigitalModeForDevice: (id)device
{
	[self setAnalogDigitalMax];
	[device setAnalogAsDigital: [self analogDigitalMask]];
}


- (BOOL) checkAnalogDigitalMode: (FPAnalogDigitalButton*)control withPopUpButton: (NSPopUpButton*)button
{
	NSInteger item = [button indexOfSelectedItem];
	if (item >= kMenuButtonDPadUp && item <= kMenuButtonRightClick) {
		[control setIsDigital: YES];
		[control setLocked: YES];
		[control setToolTip: @"Digital Only"];

	} else {
		[control setLocked: NO];
		[control setToolTip: @"Analog / Digital"];

	}

	[control setNeedsDisplay];

	return YES;     // padOptionChanged:withControl: will call updateAnalogDigitalModeForDevice:
}


- (void) checkButtonMenus
{
	NSInteger tag;

	for (int i = kMenuButtonSeparator1; i < kMenuButtonSeparator2; i++) {
		[[_buttonGreenMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonRedMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonBlueMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonYellowMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonWhiteMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonBlackMenu itemAtIndex: i] setEnabled: YES];
		[[_leftTriggerMenu itemAtIndex: i] setEnabled: YES];
		[[_rightTriggerMenu itemAtIndex: i] setEnabled: YES];
	}

	for (int i = kMenuButtonSeparator3; i < kMenuButtonCount; i++) {
		[[_buttonGreenMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonRedMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonBlueMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonYellowMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonWhiteMenu itemAtIndex: i] setEnabled: YES];
		[[_buttonBlackMenu itemAtIndex: i] setEnabled: YES];
		[[_leftTriggerMenu itemAtIndex: i] setEnabled: YES];
		[[_rightTriggerMenu itemAtIndex: i] setEnabled: YES];
	}

	tag = [[_buttonGreenMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonRedMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlueMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonYellowMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonWhiteMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlackMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_buttonRedMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonGreenMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlueMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonYellowMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonWhiteMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlackMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_buttonBlueMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonGreenMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonRedMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonYellowMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonWhiteMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlackMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_buttonYellowMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonGreenMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonRedMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlueMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonWhiteMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlackMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_buttonWhiteMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonGreenMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonRedMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlueMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonYellowMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlackMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_buttonBlackMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonGreenMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonRedMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlueMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonYellowMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonWhiteMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_leftTriggerMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonGreenMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonRedMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlueMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonYellowMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonWhiteMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlackMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_rightTriggerMenu selectedItem] tag];
	if (tag != kMenuButtonDisabled) {
		[[[_buttonGreenMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonRedMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlueMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonYellowMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonWhiteMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_buttonBlackMenu menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftTriggerMenu menu] itemWithTag: tag] setEnabled: NO];
	}
}


- (void) checkStickMenus
{
	NSInteger tag;

	for (int i = kMenuAxisSeparator1; i < kMenuAxisCount; i++) {
		[[_leftStickMenuX itemAtIndex: i] setEnabled: YES];
		[[_leftStickMenuY itemAtIndex: i] setEnabled: YES];
		[[_rightStickMenuX itemAtIndex: i] setEnabled: YES];
		[[_rightStickMenuY itemAtIndex: i] setEnabled: YES];
	}

	tag = [[_leftStickMenuX selectedItem] tag];
	if (tag != kMenuAxisDisabled) {
		[[[_leftStickMenuY menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightStickMenuX menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightStickMenuY menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_leftStickMenuY selectedItem] tag];
	if (tag != kMenuAxisDisabled) {
		[[[_leftStickMenuX menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightStickMenuX menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightStickMenuY menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_rightStickMenuX selectedItem] tag];
	if (tag != kMenuAxisDisabled) {
		[[[_leftStickMenuX menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftStickMenuY menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightStickMenuY menu] itemWithTag: tag] setEnabled: NO];
	}

	tag = [[_rightStickMenuY selectedItem] tag];
	if (tag != kMenuAxisDisabled) {
		[[[_leftStickMenuX menu] itemWithTag: tag] setEnabled: NO];
		[[[_leftStickMenuY menu] itemWithTag: tag] setEnabled: NO];
		[[[_rightStickMenuX menu] itemWithTag: tag] setEnabled: NO];
	}

	[self checkStickAlerts];
}


- (void) checkStickAlerts
{
	[_leftStickAlertX setHidden: !([_leftStickMenuX indexOfSelectedItem] > kMenuAxisSeparator2 &&
								   [_leftStickDeadzoneX deadzoneValue] < kStickAsButtonAlert)];

	[_leftStickAlertY setHidden: !([_leftStickMenuY indexOfSelectedItem] > kMenuAxisSeparator2 &&
								   [_leftStickDeadzoneY deadzoneValue] < kStickAsButtonAlert)];

	[_rightStickAlertX setHidden: !([_rightStickMenuX indexOfSelectedItem] > kMenuAxisSeparator2 &&
								    [_rightStickDeadzoneX deadzoneValue] < kStickAsButtonAlert)];

	[_rightStickAlertY setHidden: !([_rightStickMenuY indexOfSelectedItem] > kMenuAxisSeparator2 &&
								    [_rightStickDeadzoneY deadzoneValue] < kStickAsButtonAlert)];
}


- (void) padOptionChanged: (id)device withControl: (id)control
{
	BOOL updateAD = NO;

	// left stick
	if (control == _leftStickInvertX) {
		[device setLeftStickHorizInvert: [_leftStickInvertX state]];

	} else if (control == _leftStickDeadzoneX) {
		[device setLeftStickHorizDeadzone: [_leftStickDeadzoneX deadzoneValue]];
		[self checkStickAlerts];

	} else if (control == _leftStickMenuX) {
		[device setLeftStickHorizMapping: (int)[[_leftStickMenuX selectedItem] tag]];
		[self checkStickMenus];

	} else if (control == _leftStickInvertY) {
		[device setLeftStickVertInvert: [_leftStickInvertY state]];

	} else if (control == _leftStickDeadzoneY) {
		[device setLeftStickVertDeadzone: [_leftStickDeadzoneY deadzoneValue]];
		[self checkStickAlerts];

	} else if (control == _leftStickMenuY) {
		[device setLeftStickVertMapping: (int)[[_leftStickMenuY selectedItem] tag]];
		[self checkStickMenus];

	// right stick
	} else if (control == _rightStickInvertX) {
		[device setRightStickHorizInvert: [_rightStickInvertX state]];

	} else if (control == _rightStickDeadzoneX) {
		[device setRightStickHorizDeadzone: [_rightStickDeadzoneX deadzoneValue]];
		[self checkStickAlerts];

	} else if (control == _rightStickMenuX) {
		[device setRightStickHorizMapping: (int)[[_rightStickMenuX selectedItem] tag]];
		[self checkStickMenus];

	} else if (control == _rightStickInvertY) {
		[device setRightStickVertInvert: [_rightStickInvertY state]];

	} else if (control == _rightStickDeadzoneY) {
		[device setRightStickVertDeadzone: [_rightStickDeadzoneY deadzoneValue]];
		[self checkStickAlerts];

	} else if (control == _rightStickMenuY) {
		[device setRightStickVertMapping: (int)[[_rightStickMenuY selectedItem] tag]];
		[self checkStickMenus];

	// triggers
	} else if (control == _leftTriggerLivezone) {
		[device setLeftTriggerLow: [_leftTriggerLivezone doubleLoValue] andHighThreshold: [_leftTriggerLivezone doubleHiValue]];

	} else if (control == _leftTriggerMenu) {
		[device setLeftTriggerMapping: (int)[[_leftTriggerMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _leftTriggerMode withPopUpButton: _leftTriggerMenu];

	} else if (control == _rightTriggerLivezone) {
		[device setRightTriggerLow: [_rightTriggerLivezone doubleLoValue] andHighThreshold: [_rightTriggerLivezone doubleHiValue]];

	} else if (control == _rightTriggerMenu) {
		[device setRightTriggerMapping: (int)[[_rightTriggerMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _rightTriggerMode withPopUpButton: _rightTriggerMenu];

	// analog buttons
	} else if (control == _buttonGreenLivezone) {
		[device setGreenButtonLow: [_buttonGreenLivezone doubleLoValue] andHighThreshold: [_buttonGreenLivezone doubleHiValue]];

	} else if (control == _buttonGreenMenu) {
		[device setGreenButtonMapping: (int)[[_buttonGreenMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _buttonGreenMode withPopUpButton: _buttonGreenMenu];

	} else if (control == _buttonRedLivezone) {
		[device setRedButtonLow: [_buttonRedLivezone doubleLoValue] andHighThreshold: [_buttonRedLivezone doubleHiValue]];

	} else if (control == _buttonRedMenu) {
		[device setRedButtonMapping: (int)[[_buttonRedMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _buttonRedMode withPopUpButton: _buttonRedMenu];

	} else if (control == _buttonBlueLivezone) {
		[device setBlueButtonLow: [_buttonBlueLivezone doubleLoValue] andHighThreshold: [_buttonBlueLivezone doubleHiValue]];

	} else if (control == _buttonBlueMenu) {
		[device setBlueButtonMapping: (int)[[_buttonBlueMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _buttonBlueMode withPopUpButton: _buttonBlueMenu];

	} else if (control == _buttonYellowLivezone) {
		[device setYellowButtonLow: [_buttonYellowLivezone doubleLoValue] andHighThreshold: [_buttonYellowLivezone doubleHiValue]];

	} else if (control == _buttonYellowMenu) {
		[device setYellowButtonMapping: (int)[[_buttonYellowMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _buttonYellowMode withPopUpButton: _buttonYellowMenu];

	} else if (control == _buttonWhiteLivezone) {
		[device setWhiteButtonLow: [_buttonWhiteLivezone doubleLoValue] andHighThreshold: [_buttonWhiteLivezone doubleHiValue]];

	} else if (control == _buttonWhiteMenu) {
		[device setWhiteButtonMapping: (int)[[_buttonWhiteMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _buttonWhiteMode withPopUpButton: _buttonWhiteMenu];

	} else if (control == _buttonBlackLivezone) {
		[device setBlackButtonLow: [_buttonBlackLivezone doubleLoValue] andHighThreshold: [_buttonBlackLivezone doubleHiValue]];

	} else if (control == _buttonBlackMenu) {
		[device setBlackButtonMapping: (int)[[_buttonBlackMenu selectedItem] tag]];
		updateAD = [self checkAnalogDigitalMode: _buttonBlackMode withPopUpButton: _buttonBlackMenu];

	// digital buttons
	} else if (control == _dpadUpMenu) {
		[device setDpadUpMapping: (int)[[_dpadUpMenu selectedItem] tag]];

	} else if (control == _dpadDownMenu) {
		[device setDpadDownMapping: (int)[[_dpadDownMenu selectedItem] tag]];

	} else if (control == _dpadLeftMenu) {
		[device setDpadLeftMapping: (int)[[_dpadLeftMenu selectedItem] tag]];

	} else if (control == _dpadRightMenu) {
		[device setDpadRightMapping: (int)[[_dpadRightMenu selectedItem] tag]];

	} else if (control == _leftStickMenuBtn) {
		[device setLeftClickMapping: (int)[[_leftStickMenuBtn selectedItem] tag]];

	} else if (control == _rightStickMenuBtn) {
		[device setRightClickMapping: (int)[[_rightStickMenuBtn selectedItem] tag]];

	} else if (control == _buttonStartMenu) {
		[device setStartButtonMapping: (int)[[_buttonStartMenu selectedItem] tag]];

	} else if (control == _buttonBackMenu) {
		[device setBackButtonMapping: (int)[[_buttonBackMenu selectedItem] tag]];

	}

	// analog as digital buttons
	if (updateAD || control == _leftTriggerMode || control == _rightTriggerMode ||
	    control == _buttonGreenMode || control == _buttonRedMode    ||
	    control == _buttonBlueMode  || control == _buttonYellowMode ||
	    control == _buttonWhiteMode || control == _buttonBlackMode) {
		if (updateAD == NO) [control toggleMode];
		[self updateAnalogDigitalModeForDevice: device];
		[self checkButtonMenus];
	}
}


#pragma mark --- HID Interface -------------------------

- (void) hidDeviceInputPoller: (id)object
{
	FPXboxHID_JoystickUpdate(self);
}


- (void) hidUpdateElement: (int)deviceIndex cookie: (int)cookie value: (SInt32)value
{
	if (deviceIndex == [_devicePopUpButton indexOfSelectedItem] && [[_devices objectAtIndex: deviceIndex] deviceIsPad]) {
		switch (cookie) {
		case kCookiePadDPadUp:
			[(FPDPadView*)_dPadView setValue: value forDirection: kXboxDigitalDPadUp];
			break;

		case kCookiePadDPadDown:
			[(FPDPadView*)_dPadView setValue: value forDirection: kXboxDigitalDPadDown];
			break;

		case kCookiePadDPadLeft:
			[(FPDPadView*)_dPadView setValue: value forDirection: kXboxDigitalDPadLeft];
			break;

		case kCookiePadDPadRight:
			[(FPDPadView*)_dPadView setValue: value forDirection: kXboxDigitalDPadRight];
			break;

		case kCookiePadButtonStart:
			[(FPButtonView*)_buttonStartView setValue: value];
			break;

		case kCookiePadButtonBack:
			[(FPButtonView*)_buttonBackView setValue: value];
			break;

		case kCookiePadLeftClick:
			[(FPAxisPairView*)_leftStickView setPressed: value];
			break;

		case kCookiePadRightClick:
			[(FPAxisPairView*)_rightStickView setPressed: value];
			break;

		case kCookiePadButtonGreen:
			[(FPButtonView*)_buttonGreenView setValue: value];
			break;

		case kCookiePadButtonRed:
			[(FPButtonView*)_buttonRedView setValue: value];
			break;

		case kCookiePadButtonBlue:
			[(FPButtonView*)_buttonBlueView setValue: value];
			break;

		case kCookiePadButtonYellow:
			[(FPButtonView*)_buttonYellowView setValue: value];
			break;

		case kCookiePadButtonBlack:
			[(FPButtonView*)_buttonBlackView setValue: value];
			break;

		case kCookiePadButtonWhite:
			[(FPButtonView*)_buttonWhiteView setValue: value];
			break;

		case kCookiePadLeftTrigger:
			[(FPTriggerView*)_leftTriggerView setValue: value];
			break;

		case kCookiePadRightTrigger:
			[(FPTriggerView*)_rightTriggerView setValue: value];
			break;

		case kCookiePadLxAxis:
			[(FPAxisPairView*)_leftStickView setX: value];
			break;

		case kCookiePadLyAxis:
			[(FPAxisPairView*)_leftStickView setY: value];
			break;

		case kCookiePadRxAxis:
			[(FPAxisPairView*)_rightStickView setX: value];
			break;

		case kCookiePadRyAxis:
			[(FPAxisPairView*)_rightStickView setY: value];
			break;
		}
	}
}


- (void) updateRawReport
{
	FPXboxHIDDriverInterface* device = [_devices objectAtIndex: [_devicePopUpButton indexOfSelectedItem]];
	if (device && [device deviceIsPad] && [device rawReportsActive]) {
		SInt16 axis;

		[device copyRawReport: &_rawReport];

		[(SMDoubleSlider*)_buttonGreenLivezone setLiveValue: (_rawReport.a / 255.0)];
		[(SMDoubleSlider*)_buttonRedLivezone setLiveValue: (_rawReport.b / 255.0)];
		[(SMDoubleSlider*)_buttonBlueLivezone setLiveValue: (_rawReport.x / 255.0)];
		[(SMDoubleSlider*)_buttonYellowLivezone setLiveValue: (_rawReport.y / 255.0)];
		[(SMDoubleSlider*)_buttonBlackLivezone setLiveValue: (_rawReport.black / 255.0)];
		[(SMDoubleSlider*)_buttonWhiteLivezone setLiveValue: (_rawReport.white / 255.0)];
		[(SMDoubleSlider*)_leftTriggerLivezone setLiveValue: (_rawReport.lt / 255.0)];
		[(SMDoubleSlider*)_rightTriggerLivezone setLiveValue: (_rawReport.rt / 255.0)];

		axis = ((_rawReport.lxhi << 8) | _rawReport.lxlo);
		[_leftStickDeadzoneX setLiveValue: (axis + 32768) / 65535.0];
		[_leftStickView setLiveX: axis];

		axis = ((_rawReport.lyhi << 8) | _rawReport.lylo);
		[_leftStickDeadzoneY setLiveValue: (axis + 32768) / 65535.0];
		[_leftStickView setLiveY: axis];

		axis = ((_rawReport.rxhi << 8) | _rawReport.rxlo);
		[_rightStickDeadzoneX setLiveValue: (axis + 32768) / 65535.0];
		[_rightStickView setLiveX: axis];

		axis = ((_rawReport.ryhi << 8) | _rawReport.rylo);
		[_rightStickDeadzoneY setLiveValue: (axis + 32768) / 65535.0];
		[_rightStickView setLiveY: axis];
	}
}


- (void) startHIDDeviceInput
{
	FPXboxHID_JoystickInit();
	_timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/30.0 target: self selector: @selector(hidDeviceInputPoller:)
	          userInfo: nil repeats: YES];
}


- (void) stopHIDDeviceInput
{
	[_timer invalidate];
	FPXboxHID_JoystickQuit();
}


- (void) devicesPluggedOrUnplugged
{
	[self configureInterface];
	[self stopHIDDeviceInput];
	[self startHIDDeviceInput];
}


- (void) deviceConfigDidChange: (id)anObject
{
	[self buildConfigurationPopUpButton];
	[self configureInterface];
}


- (void) registerForNotifications
{
	_notifier = [FPXboxHIDNotifier notifier];
	if (_notifier) {
		[_notifier retain];
		[_notifier setMatchedSelector: @selector(devicesPluggedOrUnplugged) target: self];
		[_notifier setTerminatedSelector: @selector(devicesPluggedOrUnplugged) target: self];
	}
	// get notified when config changes out from under us (or when we change it ourselves)
	[[NSDistributedNotificationCenter defaultCenter] addObserver: self
	 selector: @selector(deviceConfigDidChange:)
	 name: kFPXboxHIDDeviceConfigurationDidChangeNotification
	 object: kFPDistributedNotificationsObject];
}


- (void) deregisterForNotifications
{
	if (_notifier) {
		[_notifier release];
		_notifier = nil;
	}
	[[NSDistributedNotificationCenter defaultCenter] removeObserver: self
	 name: kFPXboxHIDDeviceConfigurationDidChangeNotification
	 object: kFPDistributedNotificationsObject];
}


#pragma mark --- Actions ------------------------------

- (IBAction) selectDevice: (id)sender
{
	[self enableConfigPopUpButton];
	[self buildConfigurationPopUpButton];
	[self initOptionsInterface];
}


- (IBAction) changePadOption: (id)sender
{
	id device = [_devices objectAtIndex: [_devicePopUpButton indexOfSelectedItem]];
	if ([device deviceIsPad])
		[self padOptionChanged: device withControl: sender];
	[FPXboxHIDPrefsLoader saveConfigForDevice: device];
}


- (IBAction) clickConfigSegment: (id)sender
{
	switch ([sender selectedSegment]) {
	case 0:
		[self configCreate];
		break;
	case 1:
		[self configDelete];
		break;
	case 2:
		[self configActions];
		break;
	}
}


- (IBAction) clickMenuSegment: (id)sender
{
	[self initPadPopUpButtons: [_devices objectAtIndex: [_devicePopUpButton indexOfSelectedItem]]];
}


- (IBAction) selectConfig: (id)sender
{
	NSString* configName = [_configPopUp titleOfSelectedItem];
	id device = [_devices objectAtIndex: [_devicePopUpButton indexOfSelectedItem]];

	// first save the current config
	[FPXboxHIDPrefsLoader saveConfigForDevice: device];

	// now load the new config
	[FPXboxHIDPrefsLoader loadConfigForDevice: device withName: configName];

	// GUI update is handled in deviceConfigDidChange:
}

@end
