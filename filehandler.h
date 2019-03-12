//
//  filehandler.h
//  SamKeyCapture
//
//  Created by Sam Eriksson on 2018-12-18.
//  Copyright © 2018 Sam Eriksson. All rights reserved.
//

#ifndef filehandler_h
#define filehandler_h

@interface FileHandler : NSObject {
    
}

-(NSMutableArray *)loadKeyInformation:(NSString *)filepath;
-(void)saveKeyInformation:(NSMutableArray *)keyPressedArray pathname:(NSString *) path;
-(void)deleteAndCreateFileIfNeeded: (NSString*) path;

@end

#endif /* filehandler_h */
