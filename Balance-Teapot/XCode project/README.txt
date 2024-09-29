Download the sample GLGravity XCode project from Apple's website.

Look for the "Download Sample Code" button on the top of the page.


Note: If you're running iOS 8 and Xcode 7 or newer, you'll need to make one change.

1. Load the GLGravity project in Xcode
2. Navigate to \Classes\GLGravityAppDelegate.m
3. Within applicationDidFinishLaunching(), add the following to the beginning of the function:

    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in windows) {
        NSLog(@"window: %@",window.description);
        if(window.rootViewController == nil){
            UIViewController* vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
            window.rootViewController = vc;
        }
    }

So, the beginning of the function should look like this:

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in windows) {
        NSLog(@"window: %@",window.description);
        if(window.rootViewController == nil){
            UIViewController* vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
            window.rootViewController = vc;
        }
    }

	[glView startAnimation];
	
	//Configure and start accelerometer
...