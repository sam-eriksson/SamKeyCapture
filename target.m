//
//  target.m
//  SamKeyCapture
//
//  Created by Sam Eriksson on 2018-12-18.
//  Copyright © 2018 Sam Eriksson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#import <CoreGraphics/CoreGraphics.h>
#import "target.h"


@implementation TargetControl
//-(IBAction)sendQKeyEventToChrome:(id)sender

-(void)sendTestKeyEventToTarget:(NSString *)target {
    // check if target is running
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:target] count])
    {
        // target ie @"com.google.Chrome"
        pid_t pid = [(NSRunningApplication*)[[NSRunningApplication runningApplicationsWithBundleIdentifier:target] objectAtIndex:0] processIdentifier];
        
        CGEventRef qKeyUpW;
        CGEventRef qKeyDownW;
        
        ProcessSerialNumber psn;
        
        // get target PSN
        OSStatus err = GetProcessForPID(pid, &psn);
        if (err == noErr)
        {
            qKeyDownW = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0x0D, true);
            //CGEventSetFlags(qKeyDownW, NX_COMMANDMASK);
            CGEventPostToPSN(&psn, qKeyDownW);
            
            qKeyUpW= CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0x0D, false);
            CGEventPostToPSN(&psn, qKeyUpW);
            
            
            CFRelease(qKeyDownW);
            CFRelease(qKeyUpW);
        }
    }
    
}

-(void)sendKeyEventsToTarget:(NSString *)target events:(NSMutableArray *)events {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:target] count])
    {
        // target ie @"com.google.Google" "com.apple.TextEdit"
        pid_t pid = [(NSRunningApplication*)[[NSRunningApplication runningApplicationsWithBundleIdentifier:target] objectAtIndex:0] processIdentifier];
        ProcessSerialNumber psn;
        
        // get target PSN
        OSStatus err = GetProcessForPID(pid, &psn);
        if (err == noErr)
        {
            for (NSArray * array in events) {
                CGEventRef qKeyUp;
                CGEventRef qKeyDown;
                long keycode = [array[0] longValue];
                qKeyDown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, true);
                CGEventPostToPSN(&psn, qKeyDown);
                CFRelease(qKeyDown);
                qKeyUp= CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, false);
                CGEventPostToPSN(&psn, qKeyUp);
                CFRelease(qKeyUp);
            }
        }
    }
}

-(void)sendKeyEventToTarget:(NSString *)target keycode:(long)keycode keydown:(boolean_t)keydown  {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:target] count])
    {
        // target ie @"com.google.Google" "com.apple.TextEdit"
        pid_t pid = [(NSRunningApplication*)[[NSRunningApplication runningApplicationsWithBundleIdentifier:target] objectAtIndex:0] processIdentifier];
        ProcessSerialNumber psn;
        
        // get target PSN
        OSStatus err = GetProcessForPID(pid, &psn);
        if (err == noErr)
        {
            //printf("got here");
            CGEventRef qKey;
            qKey= CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, keydown);
            CGEventPostToPSN(&psn, qKey);
            CFRelease(qKey);
        }
    }
}

-(void)sendKeyEventsToTargetTimed:(NSString *)target events:(NSMutableArray *)events {
    NSDate * starttime = [NSDate date];
    long countevents = 0;
    long totalevents = 2 * [events count];
    NSNumber * last = @((float)0);
    replayoff=false;
    while (countevents<totalevents) {
        NSTimeInterval timeInterval = -[starttime timeIntervalSinceNow];
        
        NSPredicate * startgreaterthan = [NSPredicate predicateWithFormat:@"SELF[1] > %@", last];
        NSPredicate * endgreaterthan = [NSPredicate predicateWithFormat:@"SELF[2] > %@", last];
        NSPredicate * startpredicate = [NSPredicate predicateWithFormat:@"SELF[1] <= %@", @(timeInterval) ];
        NSPredicate * endpredicate = [NSPredicate predicateWithFormat:@"SELF[2] <= %@", @(timeInterval) ];
        
        NSCompoundPredicate * startpredicatecomp = [NSCompoundPredicate andPredicateWithSubpredicates:
                                                    @[startgreaterthan, startpredicate]];
        NSCompoundPredicate * endpredicatecomp = [NSCompoundPredicate andPredicateWithSubpredicates:
                                                  @[endgreaterthan, endpredicate]];
        
        NSMutableArray * startfilteredArray = [[events filteredArrayUsingPredicate:startpredicatecomp] mutableCopy];
        NSMutableArray * endfilteredArray = [[events filteredArrayUsingPredicate:endpredicatecomp] mutableCopy];
        
        for (NSArray * array in startfilteredArray) {
            //printf("start %i \r\n", [array[0] intValue]);
            [self sendKeyEventToTarget:target keycode:[array[0] longValue] keydown:true];
            countevents++;
            last =@((float)timeInterval);
        }
        for (NSArray * array2 in endfilteredArray) {
            //printf("end %i \r\n", [array2[0] intValue]);
            [self sendKeyEventToTarget:target keycode:[array2[0] longValue] keydown:false];
            countevents++;
            last =@((float)timeInterval);
        }
        sleep(.01);
        last =@((float)timeInterval);
        if (replayoff) {
            return;
        }
    }
}

-(void)stopReplay {
    replayoff=true;
}

@end
