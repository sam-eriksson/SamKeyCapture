//
//  controller.h
//  SamKeyCapture
//
//  Created by Sam Eriksson on 2018-12-19.
//  Copyright © 2018 Sam Eriksson. All rights reserved.
//

#ifndef controller_h
#define controller_h

typedef struct keypressed {
    int keycode;
    float starttime;
    float endtime;
} keypressedstr;

keypressedstr * getSet(void);
long getSetSize(void);
void replay(char * targ);
void record(void);
void setpath(char * inpath);
void save(void);
void stop(void);
void stopReplay(void);
void deleteAndCreateFileIfNeeded(char * path);

#endif /* controller_h */
