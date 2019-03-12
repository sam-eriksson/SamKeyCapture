//
//  filehandler.m
//  SamKeyCapture
//
//  Created by Sam Eriksson on 2018-12-18.
//  Copyright © 2018 Sam Eriksson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "filehandler.h"

@implementation FileHandler

-(NSMutableArray *)loadKeyInformation:(NSString *)filepath {
    NSMutableArray * returnarray = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filepath];
    if (fileHandle)
    {
        // Get the total file length
        [fileHandle seekToEndOfFile];
        unsigned long long fileLength = [fileHandle offsetInFile];
        // Set file offset to start of file
        unsigned long long currentOffset = 0ULL;
        // Read the data and append it to the file
        while (currentOffset < fileLength) {
            [fileHandle seekToFileOffset:currentOffset];
            NSData *chunkOfData = [fileHandle readDataOfLength:32768];
            
            NSString * newStr = [NSString stringWithUTF8String:[chunkOfData bytes]];
            NSArray * array = [newStr  componentsSeparatedByString:@"\r\n"];
            for (NSString * str in array) {
                NSArray * innerarray = [str componentsSeparatedByString:@","];
                if(innerarray.count >2) {
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    f.numberStyle = NSNumberFormatterDecimalStyle;
                    NSNumber * keypressed = [f numberFromString:innerarray[0]];
                    NSNumber * starttime = [f numberFromString:innerarray[1]];
                    NSNumber * endtime = [f numberFromString:innerarray[2]];
                    NSMutableArray * numarray = [[NSMutableArray alloc] initWithCapacity:3];
                    [numarray addObject:keypressed];
                    [numarray addObject:starttime];
                    [numarray addObject:endtime];
                    [returnarray addObject:numarray];
                }
            }
            currentOffset += chunkOfData.length;
        }
        // Release the file handle
        [fileHandle closeFile];
    }
    
    return returnarray;
}

-(void)saveKeyInformation:(NSMutableArray *)keyPressedArray pathname:(NSString *) path {
    NSFileHandle *file;

    file = [NSFileHandle fileHandleForUpdatingAtPath: path];
    
    if (file == nil)
        NSLog(@"Failed to open file");
    
    NSLog (@"Offset = %llu", [file offsetInFile]);
    
    [file seekToEndOfFile];
    
    NSLog (@"Offset = %llu", [file offsetInFile]);
    
    NSMutableData *data;
    NSMutableString *values = [[NSMutableString alloc]init];
    
    for (int x=0; x<[keyPressedArray count];x++) {
        NSArray * array = [keyPressedArray objectAtIndex:x];
        if ([array count]==3) {
        NSNumber  *key = array[0];
        NSNumber *start = array[1];
        NSNumber *end = array[2];
        
        [values appendString:[key stringValue] ];
        [values appendString:@","];
        [values appendString:[start stringValue] ];
        [values appendString:@","];
        [values appendString:[end stringValue] ];
        [values appendString:@"\r\n"];
        }
    }
    const char *bytestring = [values UTF8String];
    
    data = [NSMutableData dataWithBytes:bytestring length:strlen(bytestring)];
    
    [file writeData: data];
    
    [file closeFile];
}

-(void)deleteAndCreateFileIfNeeded: (NSString*) path {
    NSFileManager *filemgr;
    NSError * error;
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: path ] == YES)
        [filemgr removeItemAtPath:path error:&error];
    
    [filemgr createFileAtPath:path contents:nil attributes:nil];
    
    //if ([filemgr isWritableFileAtPath: path]  == YES)
        //NSLog (@"File is writable");
    
}

@end

