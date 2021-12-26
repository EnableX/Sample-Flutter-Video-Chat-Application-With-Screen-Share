//
//  VCXServicesClass.m
//  EnxBroadCast
//
//  Created by jaykumar on 15/12/21.
//

#import "VCXServicesClass.h"
#import "VCXConstant.h"

@implementation VCXServicesClass

-(void)fetchCreateToken:(NSDictionary *)options result:(ServiceResult)result
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@createToken",kBasedURL]];
    NSURLSession * session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:options options:NSJSONWritingPrettyPrinted error:&error];
    if (!error)
    {
        [request setHTTPBody:postData];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        if(kTry){
            [request addValue:kAppId forHTTPHeaderField:@"x-app-id"];
            [request addValue:kAppkey forHTTPHeaderField:@"x-app-key"];
        }
    }
    else{
        return;
    }
    __block ServiceResult blockResult = result;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"The response is - %@",responseDictionary);
            NSInteger success = [[responseDictionary objectForKey:@"success"] integerValue];
            if(success == 0)
            {
                blockResult(data);
            }
            else
            {
                blockResult(error);
            }
        }
        else
        {
            NSLog(@"Error");
        }
    }];
    [dataTask resume];
    
}

@end
