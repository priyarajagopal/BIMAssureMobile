//
//  INVStreamBasedCTMParser.h
//  INVBIMAssure
//
//  Created by Richard Ross on 12/8/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INVStreamBasedCTMParserChunk.h"

@class INVStreamBasedCTMParser;
@protocol INVStreamBasedCTMParserDelegate <NSObject>
@optional

-(void) streamBasedCTMParserDidStartLoad:(INVStreamBasedCTMParser *) parser;
-(void) streamBasedCTMParser:(INVStreamBasedCTMParser *) parser didCompleteChunk:(INVStreamBasedCTMParserChunk *) chunk shouldStop:(BOOL *) stop;
-(void) streamBasedCTMParserDidFinishLoad:(INVStreamBasedCTMParser *) parser;

@end

@interface INVStreamBasedCTMParser : NSObject

@property (weak) id<INVStreamBasedCTMParserDelegate> delegate;

-(void) process:(id) source;

@end
