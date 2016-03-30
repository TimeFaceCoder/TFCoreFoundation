//
//  TFFile.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFFile.h"
#import "TFResponseInfo.h"

@interface TFFile ()

@property (nonatomic, readonly) NSString *filepath;

@property (nonatomic) NSData *data;

@property (readonly)  int64_t fileSize;

@property (readonly)  int64_t fileModifyTime;

@property (nonatomic) NSFileHandle *file;

@end
@implementation TFFile

- (instancetype)init:(NSString *)path
               error:(NSError *__autoreleasing *)error {
    if (self = [super init]) {
        _filepath = path;
        NSError *error2 = nil;
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error2];
        if (error2 != nil) {
            if (error != nil) {
                *error = error2;
            }
            return self;
        }
        _fileSize = [fileAttr fileSize];
        NSDate *modifyTime = fileAttr[NSFileModificationDate];
        int64_t t = 0;
        if (modifyTime != nil) {
            t = [modifyTime timeIntervalSince1970];
        }
        _fileModifyTime = t;
        NSFileHandle *f = nil;
        NSData *d = nil;
        //[NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error] 不能用在大于 200M的文件上，改用filehandle
        // 参见 https://issues.apache.org/jira/browse/CB-5790
        if (_fileSize > 16*1024*1024) {
            f = [NSFileHandle fileHandleForReadingAtPath:path];
            if (f == nil) {
                if (error != nil) {
                    *error =[[NSError alloc] initWithDomain:path code:kTFFileError userInfo:nil];
                }
                return self;
            }
        }else{
            d = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error2];
            if (error2 != nil) {
                if (error != nil) {
                    *error = error2;
                }
                return self;
            }
        }
        _file = f;
        _data = d;
    }
    
    return self;
}

- (NSData *)read:(long)offset
            size:(long)size {
    if (_data != nil) {
        return [_data subdataWithRange:NSMakeRange(offset, (unsigned int)size)];
    }
    [_file seekToFileOffset:offset];
    return [_file readDataOfLength:size];
}

- (NSData *)readAll {
    return [self read:0 size:(long)_fileSize];
}

- (void)close {
    if (_file != nil) {
        [_file closeFile];
    }
}

-(NSString *)path {
    return _filepath;
}

- (NSString *)fileExtension {
    return [_filepath pathExtension];
}

- (int64_t)modifyTime {
    return _fileModifyTime;
}

- (NSString *)mimeType {
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)self.fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    
    NSString *mimeType = (__bridge NSString *)MIMEType;
    CFRelease(MIMEType);
    return mimeType;
}

- (int64_t)size {
    return _fileSize;
}

@end
