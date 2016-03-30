//
//  TFAsyncRun.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

typedef void (^TFRun)(void);

void TFAsyncRun(TFRun run);

void TFAsyncRunInMain(TFRun run);
