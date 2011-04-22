@import "md5-min.js"

BASE_API = "/github/";
BASE_URL = "https://github.com/";

if (window.location && window.location.protocol === "file:")
    BASE_API = BASE_URL + "api/v2/json/";

var SharedController = nil,
    GravatarBaseURL = "http://www.gravatar.com/avatar/";

// Sent whenever an issue changes
GitHubAPIIssueDidChangeNotification = @"GitHubAPIIssueDidChangeNotification";

// Sent whenever a repo changes
GitHubAPIRepoDidChangeNotification  = "GitHubAPIRepoDidChangeNotification";


CFHTTPRequest.AuthenticationDelegate = function(aRequest)
{
    var controller = [ISGithubAPIController sharedController];

    if (![controller isAuthenticated])
        [controller promptForAuthentication:nil];
}

@implementation ISGithubAPIController : CPObject
{
    CPString username @accessors;
    CPString email @accessors;
    CPString emailAddressHashed @accessors;

    // When we don't use OAuth we use the APIKey
    CPString apiKey @accessors;

    CPString oauthAccessToken @accessors;

    CPImage  userImage;
    CPImage userThumbnailImage @accessors;
    
}

+ (id)sharedController
{
    if (!SharedController)
        SharedController = [[ISGithubAPIController alloc] init];

    return SharedController;
}

- (BOOL)isAuthenticated
{
    return [[CPUserSessionManager defaultManager] status] === CPUserSessionLoggedInStatus;
}

- (void)toggleAuthentication:(id)sender
{
    if ([self isAuthenticated])
        [self logout:sender];
    else
        [self promptForAuthentication:sender];
}

- (void)logoutPrompt:(id)sender
{
    // if we're not using OAuth it's a pain to find the
    // API token... so just ask them to make sure

    if (oauthAccessToken)
        return [self logout:nil];

    logoutWarn= [[CPAlert alloc] init];
    [logoutWarn setTitle:"Are You Sure?"];
    [logoutWarn setMessageText:"Are you sure you want to logout?"];
    [logoutWarn setInformativeText:text];
    [logoutWarn setAlertStyle:CPInformationalAlertStyle];
    [logoutWarn addButtonWithTitle:"Cancel"];
    [logoutWarn setDelegate:self];
    [logoutWarn addButtonWithTitle:"Logout"];

    [logoutWarn runModal];
}

- (void)logout:(id)sender
{
    username = nil;
    authenticationToken = nil;
    userImage = nil;
    userThumbnailImage = nil;
    oauthAccessToken = nil;
    [[CPUserSessionManager defaultManager] setStatus:CPUserSessionLoggedOutStatus];
}

- (CPString)_credentialsString
{
    var authString = "?app_id=280issues";
    if ([self isAuthenticated])
    {
        if (oauthAccessToken)
            authString += "&access_token="+encodeURIComponent(oauthAccessToken);
        else
            authString += "&login="+encodeURIComponent(username)+"&token="+encodeURIComponent(authenticationToken);
    }

    return authString;
}

- (void)authenticateWithCallback:(Function)aCallback
{
    var request = new CFHTTPRequest();

    if (oauthAccessToken)
        request.open("GET", BASE_API + "user/show?access_token=" + encodeURIComponent(oauthAccessToken), true);
    else
        request.open("GET", BASE_API + "user/show?login=" + encodeURIComponent(username) + "&token=" + encodeURIComponent(apiKey), true);

    request.oncomplete = function()
    {
        if (request.success())
        {
            var response = JSON.parse(request.responseText()).user;

            username = response.login;
            emailAddress = response.email;
            emailAddressHashed = response.gravatar_id || (response.email ? hex_md5(emailAddress) : "");

            var defaults = [CPUserDefaults standardUserDefaults];
            [defaults setObject:username forKey:"username"];
            [defaults setObject:apiKey forKey:"apikey"];

            if (emailAddressHashed)
            {
                var gravatarURL = GravatarBaseURL + emailAddressHashed;
                userImage = [[CPImage alloc] initWithContentsOfFile:gravatarURL + "?s=68&d=identicon"
                                                               size:CGSizeMake(68, 68)];
                userThumbnailImage = [[CPImage alloc] initWithContentsOfFile:gravatarURL + "?s=30&d=identicon"
                                                                        size:CGSizeMake(30, 30)];
            }

            [[CPUserSessionManager defaultManager] setStatus:CPUserSessionLoggedInStatus];
        }
        else
        {
            username = nil;
            emailAddress = nil;
            emailAddressHashed = nil;
            userImage = nil;
            oauthAccessToken = nil;
            apiKey = nil;

            [[CPUserSessionManager defaultManager] setStatus:CPUserSessionLoggedOutStatus];
            [CPUserDefaults resetStandardUserDefaults];
        }

        if (aCallback)
            aCallback(request.success());

        [[CPRunLoop currentRunLoop] performSelectors];
    }

    request.send("");
}

- (void)promptForAuthentication:(id)sender
{
    // because oauth relies on the server and multiple windows
    if ([CPPlatform isBrowser] && [CPPlatformWindow supportsMultipleInstances] && BASE_API === "/github/")
        loginController = [[OAuthController alloc] init];
    else
    {
        //var loginWindow = [LoginWindow sharedLoginWindow];
        //[loginWindow makeKeyAndOrderFront:self];

        var user = prompt("username: ");
        var token = prompt("API Key: ");



            var githubController = self;
            [githubController setUsername:user];
            [githubController setApiKey:token];
            
            [githubController authenticateWithCallback:function(success)
            {
//                [progressIndicator setHidden:YES];
//                [errorMessageField setHidden:success];
//                [defaultButton setEnabled:YES];
//                [cancelButton setEnabled:YES];
            
                if (success)
                {
//                    [[[NewRepoWindow sharedNewRepoWindow] errorMessageField] setHidden:YES];
//                    [self orderOut:self];
                }
            }];
            
//            [errorMessageField setHidden:YES];
//            [progressIndicator setHidden:NO];
//            [defaultButton setEnabled:NO];
//            [cancelButton setEnabled:NO];
            }
}


@end