### This is a singleton class that will help in configuring Texas Instruments Smart Config Devices (Specifcally CC3x).

This code was tested on *XCode 5.1.1* with *iPhone* and *TI CC3000* using Spark WiFi MCU module.

##### NOTE: LLSmartConfCenter and CC3x configuring in general only works on your device. NOT the SIMULATOR!


This is a wrapper singleton class that NEEDS the following TI Framework in your X-Code project:
 - libFTC_DEBUG.a
 - libFTC_RELEASE.a

 Download the framework files, along with TI combersome samples from :
 [http://www.ti.com/tool/smartconfig](http://www.ti.com/tool/smartconfig)

 Once in your computer, add the LLSmartConfCenter.h/m you got from this repo to your project.

 And also add the libFTC_DEBUG.a + libFTC_RELEASE.a you got from TI.com site to the
 Linked Frameworks section for your project, under the project's General tab inside
 your target. (ProjectName->Targets(Your Project)->General->Linked Frameworks)


The code will run but will not do anything except print an error msg to the console and call the
 completion block immediately after the beginConfigForSSID... method is called.

How to use:
- You get a singleton using the [LLSmartConfCenter sharedCenter]; method.
- Call :
```objective-c
[self.smartConfCenter beginConfigForSSID:ssid withPassword: andEncryptionKey:encKey completionBlock:^(LLSmartConfStatus status) {
            NSLog(@"---->SMART CONFIG STOPPED<---");
        }];
```
- The completion block will be called when process is complete or manually canceled.
- To manually cancel, call the -(void)stop method in the singleton.

*NOTE:* Spark.io devices use: "sparkdevices2013" as encryption password. This may change in the future. If you can't seem to configure your device, check the Spark.io website.

-----------------
 Sample Use in a UIViewController with a UIButton wired to configureWifiPress action method :

```objective-c
//(Conform the UIViewController to the UIAlertActionView protocol),

@property (strong, nonatomic) LLSmartConfCenter smartConfCenter;

 -(void)viewWillAppear:(BOOL)animated
 {
  [super viewWillAppear]
  self.smartConfCenter = [LLSmartConfCenter sharedCenter];
 }


//in a button action:
- (IBAction)configureWifiPress:(id)sender {

    if (self.smartConfCenter.status == LLSmartConfSending) {
        [self cancelSmartConfig];
        return;
    }

    NSString *ssid = [self.smartConfCenter ssidForConnectedNetwork];


    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"WiFi Configuration"
                                                 message:@"Please enter the WiFi accesspoint credentials for your device to connect to."
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Continue", nil];

    av.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;

    [[av textFieldAtIndex:0] setText:ssid];
    [[av textFieldAtIndex:0] setPlaceholder:@"WiFi SSID"];
    [[av textFieldAtIndex:1] setPlaceholder:@"Accesspoint Password"];

    [av show];
}


//UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{


    if (buttonIndex==0) return; //Cancel was pressed

    NSString *ssid = [[alertView textFieldAtIndex:0] text];
    NSString *password = [[alertView textFieldAtIndex:1] text];

     //Begin configuring... A callback will be triggered if canceled, failed or completed.
    [self.smartConfCenter beginConfigForSSID:ssid withPassword:password andEncryptionKey:@"sparkdevices2013" completionBlock:^(LLSmartConfStatus status) {


        [[[UIAlertView alloc] initWithTitle:@"WiFi Configuration"
                                   message:@"Process is complete."
                                  delegate:self
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil] show];

        NSLog(@"---->SMART CONFIG STOPPED<---");
    }];
}
```


###### Any suggestions welcomed. I wish I could do more with the callback, but TI (to my knowledge) does not provide a 'success' - 'fail' callback. Only a completed callback that is called regardless of what stopped the process.

