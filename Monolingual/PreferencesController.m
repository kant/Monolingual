//
//  PreferencesController.m
//  Monolingual
//
//  Created by Ingmar Stein on Mon Apr 19 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

- (id) init
{
	self = [self initWithWindowNibName:@"Preferences"];
	return self;
}

- (void) dealloc
{
	[roots release];
	[super dealloc];
}

- (void) awakeFromNib
{
	int i;
	int count;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[moveToTrash setState: [defaults boolForKey:@"Trash"]];

	NSTableColumn *enabledColumn = [rootDirView tableColumnWithIdentifier:@"Enabled"];
	[[enabledColumn dataCell] setImagePosition:NSImageOnly]; // Center the checkbox

	NSArray *rootsPref = [defaults arrayForKey:@"Roots"];
	count = [rootsPref count];
	roots = [[NSMutableArray alloc] initWithCapacity:count];
	for( i=0; i<count; ++i ) {
		[roots addObject: [[[rootsPref objectAtIndex:i] mutableCopy] autorelease]];
	}

	[self update];
}

- (int) numberOfRowsInTableView: (NSTableView *)aTableView
{
#pragma unused(aTableView)
	return( [roots count] );
}

- (id) tableView: (NSTableView *)aTableView objectValueForTableColumn: (NSTableColumn *)aTableColumn row: (int)rowIndex
{
#pragma unused(aTableView)
	return( [[roots objectAtIndex: rowIndex] objectForKey:[aTableColumn identifier]] );
}

- (void) tableView: (NSTableView *)aTableView setObjectValue: (id)anObject forTableColumn: (NSTableColumn *)aTableColumn row: (int)rowIndex
{
#pragma unused(aTableView)
	[[roots objectAtIndex: rowIndex] setObject:anObject forKey:[aTableColumn identifier]];
	[[NSUserDefaults standardUserDefaults] setObject:roots forKey:@"Roots"];
}

- (void) update
{
	[rootDirView reloadData];
	[removeButton setEnabled: ([roots count] > 0)];
	[[NSUserDefaults standardUserDefaults] setObject:roots forKey:@"Roots"];
}

- (IBAction) changeTrash: (id)sender
{
#pragma unused(sender)
	[[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:@"Trash"];
}

- (IBAction) add: (id)sender
{
#pragma unused(sender)
	int result;
	int i;
	int count;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];

    [oPanel setAllowsMultipleSelection:YES];
	[oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:NO];

    result = [oPanel runModalForDirectory:nil file:nil types:nil];
	if( NSOKButton == result ) {
		NSArray *filenames = [oPanel filenames];
		count = [filenames count];
		for( i=0; i<count; ++i ) {
			[roots addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:[filenames objectAtIndex: i], @"Path", [NSNumber numberWithBool: YES], @"Enabled", nil]];
		}
		[self update];
	}
}

- (IBAction) remove: (id)sender
{
#pragma unused(sender)
	int row = [rootDirView selectedRow];
	if( row != -1 ) {
		[roots removeObjectAtIndex: row];
		[self update];
	}
}

@end
