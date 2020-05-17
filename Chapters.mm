//
//  Chapters.mm | Substrate hooks to get the tweak integrated cleanly.
//  Chapters
//
//  Add some clean labels to your pages
//
//  Created by _kritanta
//
//05

@import UIKit;

#include "include/SpringBoardHome.h"
#include "Chapters/CHPManager.h"

#import <objc/runtime.h>
#include "substrate.h"

@class SBRootFolderController;
@class SBRootIconListView;
@class SBHomeScreenPreviewView;
@class _UIStatusBar;
@class SBIconListView;

static void (*orig_UISB_setForegroundColor) (_UIStatusBar *, SEL, UIColor *);
static void hooked_UISB_setForegroundColor (_UIStatusBar *, SEL, UIColor *);

static struct CGPoint (*orig_12_SBRILV_originForIconAtCoordinate) (SBRootIconListView *, SEL, SBIconCoordinate, struct SBIconListLayoutMetrics);
static struct CGPoint hooked_12_SBRILV_originForIconAtCoordinate (SBRootIconListView *, SEL, SBIconCoordinate, struct SBIconListLayoutMetrics);

static void (*orig_SBILV_layoutIconsNow) (SBIconListView *, SEL);
static void hooked_SBILV_layoutIconsNow (SBIconListView *, SEL);

static struct CGPoint (*orig_SBILV_originForIconAtCoordinate$metrics) (SBIconListView *, SEL, SBIconCoordinate, struct SBIconListLayoutMetrics);
static struct CGPoint hooked_SBILV_originForIconAtCoordinate$metrics (SBIconListView *, SEL, SBIconCoordinate, struct SBIconListLayoutMetrics);

static void (*orig_SBRFC_viewWillAppear) (SBRootFolderController *, SEL, BOOL);
static void hooked_SBRFC_viewWillAppear (SBRootFolderController *, SEL, BOOL);

/**
 * [_UIStatusBar setForegroundColor:]
 *
 * iOS already has logic to detect a nice foreground color.
 * I can look at directly using it later, but for now, it's nice to just
 *      snipe the color when apple uses it.
 *
 * @param color Color for the status bar foreground text and glyphs
 * @return void
 */
static void hooked_UISB_setForegroundColor (_UIStatusBar *self, SEL cmd, UIColor *color)
{
    [[CHPManager sharedInstance] setLabelColor:color];
    orig_UISB_setForegroundColor(self, cmd, color);
    [[CHPManager sharedInstance] relayoutIfNeeded];
}

/**
 * -[SBRootIconListView originForIconAtCoordinate:metrics:]
 *
 * Handy little method for manually manipulating icon origin
 *
 * .iconLocation is an int on iOS 12, so this one needs its own hook
 *
 * @param coordinate Icon Coordinate
 * @param metrics Layout Metrics
 * @return CGPoint origin for icon specified
 */
static struct CGPoint hooked_12_SBRILV_originForIconAtCoordinate (SBRootIconListView *self, SEL cmd,
        SBIconCoordinate coordinate, struct SBIconListLayoutMetrics metrics)
{
    CGPoint o = orig_12_SBRILV_originForIconAtCoordinate(self, cmd, coordinate, metrics);

    o.y += 54;

    return o;
}

/**
 * -[SBIconListView layoutIconsNow]
 *
 * Convenience function added by apple that calls:
 *   [self setIconsNeedLayout];
 *   [self layoutIconsIfNeeded:0.0];
 *   
 * iOS doesn't use it much, but my layout editing tweaks do, and this lets us update with them dynamically.  
 *
 * @return void
 */
static void hooked_SBILV_layoutIconsNow (SBIconListView *self, SEL cmd)
{
    orig_SBILV_layoutIconsNow(self, cmd);

    if (kCFCoreFoundationVersionNumber < 1600 || [self.iconViewProvider class] == objc_getClass("SBHomeScreenPreviewView"))
    {
        return;
    }

    if ([self.iconLocation isEqualToString:@"SBIconLocationRoot"])
    {
        [[CHPManager sharedInstance] reloadLabelsForRootFolderController:self.iconViewProvider.rootFolderController
                                                                   index:-1];
    }
}

/**
 * -[SBIconListView originForIconAtCoordinate:metrics:]
 *
 * Handy little method for manually manipulating icon origin
 * 
 * Should probably perform modifications to self.layout instead, but I need to figure out how to pull that
 *      off without screwing up layout managers. 
 *
 * @param coordinate Icon Coordinate
 * @param metrics Layout Metrics
 * @return CGPoint origin for icon specified
 */
static struct CGPoint hooked_SBILV_originForIconAtCoordinate$metrics (SBIconListView *self, SEL cmd, SBIconCoordinate arg1, struct SBIconListLayoutMetrics arg2)
{
    CGPoint o = orig_SBILV_originForIconAtCoordinate$metrics(self, cmd, arg1, arg2);

    if ([self.iconViewProvider class] != objc_getClass("SBHomeScreenPreviewView")
            && [self.iconLocation isEqualToString:@"SBIconLocationRoot"]
            && kCFCoreFoundationVersionNumber > 1600)
    {
        o.y += 54;
    }

    return o;
}

/**
 * -[SBRootFolderController viewWillAppear:]
 * 
 * Load in our labels whenever the root folder controller appears.
 * 
 * @param yes 
 */
static void hooked_SBRFC_viewWillAppear (SBRootFolderController *self, SEL cmd, BOOL yes)
{
    orig_SBRFC_viewWillAppear(self, cmd, yes);

    @try
    {
        [[CHPManager sharedInstance] reloadLabelsForRootFolderController:self index:-1];
    }
    @catch (NSException *ex)
    {
        return;
    }
}

static __attribute__((constructor)) void ChaptersInit (int argc, char **argv, char **envp)
{
    NSLog(@"Chapters: Injected");

    MSHookMessageEx(objc_getClass("SBRootFolderController"),
            @selector(viewWillAppear:),
            (IMP) &hooked_SBRFC_viewWillAppear,
            (IMP *) &orig_SBRFC_viewWillAppear);

    MSHookMessageEx(objc_getClass("SBRootIconListView"),
            @selector(originForIconAtCoordinate:metrics:),
            (IMP) &hooked_12_SBRILV_originForIconAtCoordinate,
            (IMP *) &orig_12_SBRILV_originForIconAtCoordinate);

    MSHookMessageEx(objc_getClass("SBIconListView"),
            @selector(layoutIconsNow),
            (IMP) &hooked_SBILV_layoutIconsNow,
            (IMP *) &orig_SBILV_layoutIconsNow);

    MSHookMessageEx(objc_getClass("SBIconListView"),
            @selector(originForIconAtCoordinate:metrics:),
            (IMP) &hooked_SBILV_originForIconAtCoordinate$metrics,
            (IMP *) &orig_SBILV_originForIconAtCoordinate$metrics);

    MSHookMessageEx(objc_getClass("_UIStatusBar"),
            @selector(setForegroundColor:),
            (IMP) &hooked_UISB_setForegroundColor,
            (IMP *) &orig_UISB_setForegroundColor);

}
