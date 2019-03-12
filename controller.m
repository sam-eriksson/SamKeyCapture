//
//  controller.m
//  SamKeyCapture
//
//  Created by Sam Eriksson on 2018-12-18.
//  Copyright © 2018 Sam Eriksson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "filehandler.h"
#import "target.h"
#include "controller.h"

NSDate *start;
NSMutableDictionary *keyPressed;
NSMutableArray *keyPressedArray;
FileHandler * filehandler;
NSString * path;
CFRunLoopRef rl;
long arraysize=0;
TargetControl * targetcontrol;

void stop() {
    CFRunLoopStop(rl);
}

void save() {
    [filehandler saveKeyInformation:keyPressedArray pathname:path];
}

void setpath(char * inpath) {
    path = [NSString stringWithUTF8String:inpath];
}

keypressedstr * getSet() {
    long sizeofarray = [keyPressedArray count];
    keypressedstr * returnvalue;
    returnvalue = malloc(sizeofarray * sizeof(keypressedstr));
    
    for (long x=0; x<sizeofarray; x++) {
        NSArray * array = [keyPressedArray objectAtIndex:x];
        NSNumber  *key = array[0];
        NSNumber *start = array[1];
        NSNumber *end = array[2];
        (returnvalue+x)->keycode = [key intValue];
        (returnvalue+x)->starttime = [start floatValue];
        (returnvalue+x)->endtime = [end floatValue];
    }
    return  returnvalue;
}

long getSetSize() {
    return arraysize;
}

void savetoSet(NSNumber * keycode, NSNumber * timepressed, NSNumber * timereleased) {
    NSArray *array = [NSArray arrayWithObjects:keycode, timepressed, timereleased, nil];
    [keyPressedArray addObject: array];
    printf("save:%i %f %f \r\n", [keycode intValue] , [timepressed floatValue], [timereleased floatValue]);
}

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type,  CGEventRef event, void *refcon) {
    if (type==kCGEventKeyDown) {
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        int64_t  keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        //printf("%f:", -timeInterval);
        //printf("DOWN:%u\n", (uint32_t)keycode);
        
        if (keycode == 53) {
            //@"/Users/sameriksson/Desktop/myfile.txt"
            [filehandler saveKeyInformation:keyPressedArray pathname:path];
            CFRunLoopStop(rl);
        }
        else {
            NSNumber * timevalue = [NSNumber numberWithFloat: -timeInterval];
            NSNumber * keycodevalue = [NSNumber numberWithLong:keycode];
            if ([keyPressed[keycodevalue] intValue ] == 0) {
                [keyPressed setObject: timevalue forKey: keycodevalue];
            }
        }
        
    }
    if (type==kCGEventKeyUp) {
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        int64_t  keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        //printf("%f:", -timeInterval);
        //printf("UP: %u\n", (uint32_t)keycode);
        if (keycode != 53) {
            
            NSNumber * timevalue = [NSNumber numberWithFloat: -timeInterval];
            NSNumber * nulltimevalue = [NSNumber numberWithFloat: 0];
            NSNumber * keycodevalue = [NSNumber numberWithLong:keycode];
            savetoSet(keycodevalue, keyPressed[keycodevalue], timevalue); // keycode, time pressed down, time released
            [keyPressed setObject: nulltimevalue forKey: keycodevalue];
        }
        
    }
    
    return event;
}

void replay(char * targ)  {
    @autoreleasepool {
        NSString * target = [NSString stringWithUTF8String:targ];
        filehandler  = [[FileHandler alloc]init];
        NSMutableArray * ar = [filehandler loadKeyInformation:path];
        targetcontrol = [TargetControl alloc];
        //[targetcontrol sendKeyEventsToTarget:target events:ar];
        //[targetcontrol sendTestKeyEventToTarget:@"com.apple.TextEdit"];
        [targetcontrol sendKeyEventsToTargetTimed:target events:ar];
    }
}

void stopReplay() {
    [targetcontrol stopReplay];
}
                
void record() {
    @autoreleasepool {
        filehandler  = [[FileHandler alloc]init];
        start = [NSDate date];
        keyPressed =  [NSMutableDictionary dictionaryWithCapacity:1];
        keyPressedArray = [NSMutableArray arrayWithCapacity:5];
        CFMachPortRef eventTap;
        CFRunLoopSourceRef runLoopSource;
        eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, kCGEventMaskForAllEvents, myCGEventCallback, NULL);
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

        rl = CFRunLoopGetCurrent();

        CFRunLoopAddSource(rl, runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(eventTap, true);
        CFRunLoopRun();
    }
}

void deleteAndCreateFileIfNeeded(char * path) {
    @autoreleasepool {
        filehandler  = [[FileHandler alloc]init];
        [filehandler deleteAndCreateFileIfNeeded:[NSString stringWithUTF8String:path]];
    }
}
