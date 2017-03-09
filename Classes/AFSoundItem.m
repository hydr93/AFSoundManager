//
//  AFSoundItem.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 20/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import "AFSoundItem.h"
#import "AFSoundManager.h"

@implementation AFSoundItem

-(id)initWithLocalResource:(NSString *)name atPath:(NSString *)path {
    
    if (self == [super init]) {
        
        _type = AFSoundItemTypeLocal;
        
        NSString *itemPath;
        
        if (!path) {
            
            NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
            itemPath = [resourcePath stringByAppendingPathComponent:name];
        } else {
            
            itemPath = [path stringByAppendingPathComponent:name];
        }
        
        _URL = [NSURL fileURLWithPath:itemPath];
        
        [self fetchMetadata];
    }
    
    return self;
}

-(id)initWithStreamingURL:(NSURL *)URL {
    
    if (self == [super init]) {
        
        _type = AFSoundItemTypeStreaming;
        
        _URL = URL;
        
        [self fetchMetadata];
    }
    
    return self;
}

-(void)fetchMetadata {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_URL options:nil];
    NSArray *keys = [NSArray arrayWithObject:@"playable"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^(){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
            _avplayeritem = playerItem;
            NSArray *metadata = [playerItem.asset commonMetadata];
            
            for (AVMetadataItem *metadataItem in metadata) {
                
                [metadataItem loadValuesAsynchronouslyForKeys:@[AVMetadataKeySpaceCommon] completionHandler:^{
                    
                    if ([metadataItem.commonKey isEqualToString:@"title"]) {
                        
                        _title = (NSString *)metadataItem.value;
                    } else if ([metadataItem.commonKey isEqualToString:@"albumName"]) {
                        
                        _album = (NSString *)metadataItem.value;
                    } else if ([metadataItem.commonKey isEqualToString:@"artist"]) {
                        
                        _artist = (NSString *)metadataItem.value;
                    } else if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                        
                        if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                            
                            _artwork = [UIImage imageWithData:[[metadataItem.value copyWithZone:nil] objectForKey:@"data"]];
                        } else if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                            
                            _artwork = [UIImage imageWithData:[metadataItem.value copyWithZone:nil]];
                        }
                    }
                }];
            }
        });
    }];
}

-(void)setInfoFromItem:(AVPlayerItem *)item {
    
    _duration = CMTimeGetSeconds(item.duration);
    _timePlayed = CMTimeGetSeconds(item.currentTime);
}

@end
