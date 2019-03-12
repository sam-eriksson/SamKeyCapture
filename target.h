//
//  target.h
//  SamKeyCapture
//
//  Created by Sam Eriksson on 2018-12-18.
//  Copyright © 2018 Sam Eriksson. All rights reserved.
//

#ifndef target_h
#define target_h

@interface TargetControl : NSObject {
    bool replayoff;
}

//-(IBAction)sendQKeyEventToChrome:(id)sender;
-(void)sendTestKeyEventToTarget:(NSString *)target;
-(void)sendKeyEventsToTarget:(NSString *)target events:(NSMutableArray *)events;
-(void)sendKeyEventToTarget:(NSString *)target keycode:(long)keycode keydown:(boolean_t)keydown;
-(void)sendKeyEventsToTargetTimed:(NSString *)target events:(NSMutableArray *)events;
-(void)stopReplay;
@end

#endif /* target_h */
