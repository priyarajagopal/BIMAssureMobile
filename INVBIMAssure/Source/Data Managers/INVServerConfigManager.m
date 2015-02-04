//
//  INVServerConfigManager.m
//  INVBIMAssure
//
//  Created by Richard Ross on 12/23/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVServerConfigManager.h"

#import <AFNetworking/AFNetworking.h>
#import "INVServerConfigCertsEqualSecurityPolicy.h"

#define LOCAL_CACHE_FILE_NAME @"Startup.json"
#define CONFIG_CACHE_FILE_PATH                                                                                                 \
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]                               \
        stringByAppendingPathComponent:LOCAL_CACHE_FILE_NAME]

#define _STRINGIFY(str) #str
#define STRINGIFY(str) _STRINGIFY(str)

#ifndef INV_DEPLOYMENT_NAME
#warning Deployment name not set!
#define INV_DEPLOYMENT_NAME nil
#endif

/**** Sample JSON startup file
 {
	"defaultdeploy": "development",
	"deploys": [
	{
 "name": "development",
 "servers": [
 {"server": "xospassport", "url": "http://54.149.63.51:8080"},
 {"server": "empiremanage", "url": "http://54.149.7.76:8080"},
 {"server": "empireweb", "url": "http://54.69.37.246"}
 ]
	},
	{
 "name": "developmentOld",
 "servers": [
 {"server": "xospassport", "url": "http://54.68.220.238:8080"},
 {"server": "empiremanage", "url": "http://54.68.220.238:8080"},
 {"server": "empireweb", "url": "http://localhost"}
 ]
	}
	]
 }
 
 
 ************/

@interface INVServerConfigManager ()

@property NSURL *passportServerURL;
@property NSURL *empireManageServerURL;

@end

@implementation INVServerConfigManager

+ (id)instance
{
    static INVServerConfigManager *configManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configManager = [INVServerConfigManager new];
    });

    return configManager;
}

- (BOOL)_loadConfigNamed:(NSString *)configName fromUrl:(NSURLRequest *)url configData:(NSData *__autoreleasing *)data
{
    __block NSData *configData = nil;
    dispatch_semaphore_t completionSemaphore = dispatch_semaphore_create(0);

    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    INVServerConfigCertsEqualSecurityPolicy *secPolicy = [INVServerConfigCertsEqualSecurityPolicy new];
    secPolicy.requiredCertificateData =
        [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"invicara_config_server" ofType:@"cer"]];

    requestManager.securityPolicy = (AFSecurityPolicy *) secPolicy;

    requestManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

    [[requestManager HTTPRequestOperationWithRequest:url
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            configData = responseObject;

            dispatch_semaphore_signal(completionSemaphore);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            INVLogError(@"Config HTTP error: %@", error);
            INVLogError(@"Config error: %@",
                [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"]
                                      encoding:NSUTF8StringEncoding]);

            dispatch_semaphore_signal(completionSemaphore);
        }] start];

    dispatch_semaphore_wait(completionSemaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 60));

    if (configData == nil) {
        return NO;
    }

    NSDictionary *jsonConfig = [NSJSONSerialization JSONObjectWithData:configData options:0 error:NULL];

    NSString *deployName = @STRINGIFY(INV_DEPLOYMENT_NAME);
    NSString *defaultDeployName = jsonConfig[@"defaultdeploy"];

    NSDictionary *defaultDeploy = nil;
    NSDictionary *selectedDeploy = nil;

    for (NSDictionary *deploy in jsonConfig[@"deploys"]) {
        if ([deployName isEqual:deploy[@"name"]]) {
            selectedDeploy = deploy;
        }

        if ([defaultDeployName isEqual:deploy[@"name"]]) {
            defaultDeploy = deploy;
        }
    }

    if (selectedDeploy == nil) {
        if (defaultDeploy == nil) {
            return NO;
        }

        selectedDeploy = defaultDeploy;
    }

    _passportServerURL = nil;
    _empireManageServerURL = nil;
    for (NSDictionary *server in selectedDeploy[@"servers"]) {
        NSString *serverName = server[@"server"];

        if ([serverName isEqual:@"xospassport"]) {
            _passportServerURL = [NSURL URLWithString:server[@"url"]];
        }

        if ([serverName isEqualToString:@"empiremanage"]) {
            _empireManageServerURL = [NSURL URLWithString:server[@"url"]];

        }
    }

    if (data) {
        *data = configData;
    }

    return YES;
}

- (void)loadConfigNamed:(NSString *)configName
{
    NSURLRequest *configURL = [INVEmpireMobileClient requestToFetchSystemConfiguration];
    NSData *configData = nil;

    if ([self _loadConfigNamed:configName fromUrl:configURL configData:&configData]) {
        // TODO: Encrypt file
        [configData writeToFile:CONFIG_CACHE_FILE_PATH atomically:YES];
        return;
    }

    configURL = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:CONFIG_CACHE_FILE_PATH]];
    if ([self _loadConfigNamed:configName fromUrl:configURL configData:nil]) {
        return;
    }

    configURL =
        [NSURLRequest requestWithURL:[[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:LOCAL_CACHE_FILE_NAME]];
    if ([self _loadConfigNamed:configName fromUrl:configURL configData:nil]) {
        return;
    }

    INVLogCritical(@"Failed to load from config in application bundle! Trouble ahead.");
}

- (void)loadDefaultConfig
{
    [self loadConfigNamed:@STRINGIFY(INV_DEPLOYMENT_NAME)];
}

- (NSString *)passportServerHost
{
    return [_passportServerURL host];
}

- (NSString *)passportServerPort
{
    return [[_passportServerURL port] stringValue];
}

- (NSString *)empireManageHost
{
    return [_empireManageServerURL host];
}

- (NSString *)empireManagePort
{
    return [[_empireManageServerURL port] stringValue];
}

- (NSString *)passportPasswordVerificationRegex
{
    return _passportPasswordVerificationRegex ?: @"";
}

- (NSString *)passportPasswordVerificationText
{
    return _passportPasswordVerificationText ?: @"";
}

@end
