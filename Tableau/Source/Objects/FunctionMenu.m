//
//  FunctionMenu.m
//  Tableau
//
//	Writeen by ian Ollmann.
//	Modified by Robert Murley Sep 2003.
//  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//

#import "FunctionMenu.h"
#import "Filters.h"
#import "ImageController.h"


#define FIRST_MENU_INDEX 	3

@implementation FunctionMenu

- (void)initObject
{
    NSMenuItem *vectorItem = [ self 	addItemWithTitle: @"Enable Vector"
                                        action: @selector( useVector: )
                                        keyEquivalent: @""	]; 
    NSMenuItem *traceItem = [ self	addItemWithTitle: @"Run Trace"
                                        action: @selector( doTrace: )
                                        keyEquivalent: @""	]; 
    NSMenuItem *separator =  [ NSMenuItem separatorItem ];
    int i, j;
        
    [ self addItem: separator ];
    [ vectorItem setTarget: self ];
    [ traceItem setTarget: self ];
    [ vectorItem setTag: -3 ];
    [ traceItem setTag: -2 ];
    [ separator setTag: -1 ];
    [ traceItem setEnabled: YES ];
    [ traceItem setState: NSOffState ];
    
    //Configure the AltiVec enabled menu item
    if( YES == [ imageController isVectorAvailable ] )
    {
        [vectorItem setState: NSOffState ];
        [vectorItem setEnabled: YES ];
        [imageController enableVectorUnit: NO ];
        [vectorItem setTitle: @"Use Vector Unit"];
    }
    else
    {
        [vectorItem setEnabled: NO ];
        [ imageController enableVectorUnit: NO ];
    }
        
    //Build the rest of the Function Menu
    for( i = 0; i < kListCount; i++ )
    {
        NSMenu		*menu = [ NSMenu alloc ];
        NSMenuItem	*item = [ self 	addItemWithTitle: filterLists[i].name
                                        action:  nil
                                        keyEquivalent: @""	]; 
        
                                        
        [ menu initWithTitle: filterLists[i].name ];
        [ menu setAutoenablesItems: filterLists[i].type == alphaComposite ];
        [ item setTarget:imageController ];
        [ self setSubmenu: menu forItem: item ];
        [ item setTag: i ];
    
        for( j = 0; j < filterLists[ i ].count; j++ )
        {
            item = (NSMenuItem*) [ menu 	addItemWithTitle: (filterLists[i].list[j].name)
                                                action:  @selector( setFilterType: )
                                                keyEquivalent:  @""	];
        
            [item setTarget:imageController ];
            [item setTag: ( i << 16 ) | j ]; 
        }
        
    }

    [ self enableMenuItems ];

    //Turn on the first enabled item
    [ self turnOnDefaultItem ];

}


- (void) enableMenuItems
{
    int i, j;
    int index = [ imageController dataType ];
    
    for( i = 0; i < kListCount; i++ )
    {
        NSMenu *menu = [ [ self itemAtIndex: FIRST_MENU_INDEX + i ] submenu ];
        int	menuItemCount = [ menu numberOfItems ];
    
        for( j = 0; j < filterLists[ i ].count && j < menuItemCount; j++ )
        {
            TestFunc f = (&filterLists[i].list[j].function)[ index ];
            NSMenuItem *item = [ menu itemAtIndex: j ];
        
            if( f == NULL )
                [ item setEnabled: NO ];
            else
                [ item setEnabled: YES ];
        }
    }

}


- (IBAction)useVector:(id)sender
{
    id item = [self currentFilterMenuItem ]; 
    
    if( NSOnState == [ sender state ] )
    {
        [ sender setState: NSOffState ];
        [imageController enableVectorUnit: NO ];
    }
    else
    {
        [ sender setState: NSOnState ];
        [imageController enableVectorUnit: YES ];
    }
    
    [self enableMenuItems];
    
    if( NO == [item isEnabled] )
        [ self turnOnDefaultItem ];
        
}

- (IBAction)doTrace:(id)sender
{    
    if( NSOnState == [ sender state ] )
    {
        [ sender setState: NSOffState ];
        [ imageController doTrace: NO ];
    }
    else
    {
        [ sender setState: NSOnState ];
        [ imageController doTrace: YES ];
    }
}


- (void)turnOnItem:(id)item
{
    int i, j;
    
    for( i = 0; i < kListCount; i++ )
    {
        NSMenu *menu = [ [ self itemAtIndex: FIRST_MENU_INDEX + i ] submenu ];
    
        for( j = 0; j < filterLists[ i ].count; j++ )
        {
            NSMenuItem *currentItem = [ menu itemAtIndex: j ];
            [ currentItem setState: NSOffState ];
        }
    }
    
    if( nil != item && [ item isEnabled ] )
        [ item setState: NSOnState ];
    
}

- (void)turnOnDefaultItem
{
    int i, j;
    id  newDefault = nil;
    
    //turn off everything
    for( i = 0; i < kListCount; i++ )
    {
        NSMenu *menu = [ [ self itemAtIndex: FIRST_MENU_INDEX + i ] submenu ];
    
        for( j = 0; j < filterLists[ i ].count; j++ )
            [[ menu itemAtIndex: j ] setState: NSOffState ];
    }

    //turn on the first enabled item
    for( i = 0; i < kListCount; i++ )
    {
        NSMenu *menu = [ [ self itemAtIndex: FIRST_MENU_INDEX + i ] submenu ];
    
        for( j = 0; j < filterLists[ i ].count; j++ )
        {
            NSMenuItem *item = [ menu itemAtIndex: j ];
        
            if( [ item isEnabled ] )
            {
				if (filterLists[ i ].list[ j ].flags & kInitFilter) {
					newDefault = item;
					break;
				}
				if (newDefault == nil)
					newDefault = item;
            }
        }
    }

    [ imageController setFilterType: newDefault ];    
}

- (id)currentFilterMenuItem
{
    id result = nil;
    int i,j;

    for( i = 0; i < kListCount; i++ )
    {
        NSMenu *menu = [ [ self itemAtIndex: FIRST_MENU_INDEX + i ] submenu ];
    
        for( j = 0; j < filterLists[ i ].count; j++ )
        {
            NSMenuItem *item = [ menu itemAtIndex: j ];
        
            if( NSOnState == [ item state ] )
            {
                result = (id) item;
                i = kListCount;
                break;
            }
        }
    }
    
    return result;
}

@end
