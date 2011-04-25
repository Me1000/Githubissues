@import "md5-min.js"

BASE_API = "/github/";
BASE_URL = "https://api.github.com/";

if (window.location && window.location.protocol === "file:")
    BASE_API = BASE_URL + "";

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


// This function creates and returns a string for which to
// make an API call
var APIURLWithString = function(/*CPString*/aString)
{
//    if ()
}

@implementation ISGithubAPIController : CPObject
{
    CPDictionary    repositoriesByIdentifier @accessors(readonly);

    CPString username @accessors;
    CPString email @accessors;
    CPString emailAddressHashed @accessors;

    // When we don't use OAuth we use the APIKey
    CPString password @accessors;

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

- (id)init
{
    self = [super init];

    repositoriesByIdentifier = [CPDictionary dictionary];

    return self;
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

/*!
    We use this to construct the API url since it can be complicated at times.
*/
- (CPString)_urlForAPICall:(CPString)aCall
{
    var isAuthenticated = [self isAuthenticated],
        urlForCall = "",
        startingArgument = aCall.indexOf("?") === CPNotFound ? "?" : "&";

    if (window.location && window.location.protocol === "file:")
    {
        if (isAuthenticated)
            urlForCall += "https://" + username + ":" + password + "@api.github.com/" + aCall;
        else
            urlForCall += "https://api.github.com/" + aCall;
    }
    else
    {
        if (isAuthenticated && oauthAccessToken)
        {
            urlForCall += "/github/" + aCall + + startingArgument +"access_token=" + oauthAccessToken;
            startingArgument = "&";
        }
    }

    urlForCall += startingArgument + "app_id=280issues";

    return urlForCall;
}

- (void)authenticateWithCallback:(Function)aCallback
{
    var request = new CFHTTPRequest();

    //github.com/users/technoweenie.json
    // Use V3 of the Github API
    request.setRequestHeader("accept", "application/vnd.github.v3+json");

    // FIX ME: this URL is wrong.
    request.open("GET", [self _urlForAPICall:"user.json"], true);

    request.oncomplete = function()
    {
        if (request.success())
        {
            var response = JSON.parse(request.responseText());

            username = response.login;
            emailAddress = response.email;
            emailAddressHashed = response.gravatar_id || (response.email ? hex_md5(emailAddress) : "");

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

        // FIX ME: make this awesome
        var user = prompt("Username: ");
        var pass = prompt("Password: ");

            var githubController = self;
            [githubController setUsername:user];
            [githubController setPassword:pass];
            
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

- (void)loadRepositoryWithIdentifier:(CPString)anIdentifier callback:(Function)aCallback
{
    var request = new CFHTTPRequest();

    // Use V3 of the Github API
    request.setRequestHeader("accept", "application/vnd.github.v3+json");
    request.open("GET", [self _urlForAPICall:"repos/"+anIdentifier+".json"], true);

    request.oncomplete = function()
    {
        var data = nil,
            newRepo = nil;

        if (request.success())
        {
            try {

                data = JSON.parse(request.responseText());

                newRepo = [repositoriesByIdentifier objectForKey:anIdentifier] || [[ISRepository alloc] init];

                [newRepo setName:data.name];
                [newRepo setIdentifier:anIdentifier];
                [newRepo setIsPrivate:data["private"]];
                [newRepo setNumberOfOpenIssues:data.open_issues];
                [newRepo setIssuesAssignedToCurrentUser:0];

                if (![repositoriesByIdentifier objectForKey:anIdentifier])
                    [repositoriesByIdentifier setObject:newRepo forKey:anIdentifier];
            }
            catch (e) {
                CPLog.error("Unable to load repositority with identifier: "+anIdentifier+" -- "+e);
            }
        }

        if (aCallback)
            aCallback(newRepo, request);

        if (newRepo)
            [self loadLabelsForRepository:newRepo];

        [[CPRunLoop currentRunLoop] performSelectors];
    }

    request.send("");
}

- (void)loadLabelsForRepository:(ISRepository)aRepo
{
    ///repos/:user/:repo/labels.json

    var request = new CFHTTPRequest();
    request.setRequestHeader("accept", "application/vnd.github.v3+json");

    request.open("GET", [self _urlForAPICall:"repos/"+[aRepo identifier]+"/labels.json"], true);

    request.oncomplete = function()
    {
        var labels = [];
        if (request.success())
        {
            try
            {
                labels = JSON.parse(request.responseText()) || [];
            }
            catch (e)
            {
                CPLog.error("Unable to load labels for issue: " + anIssue + @" -- " + e);
            }
        }

        aRepo.labels = labels;
        [[CPRunLoop currentRunLoop] performSelectors];
    };

    request.send("");
}

/*!
    Loads issues for a repo.
    The key is given to load open/closed issues
*/
- (void)loadIssuesForRepository:(ISRepository)aRepo state:(CPString)stateKey callback:(id)aCallback
{
    /*
        GET /repos/:user/:repo/issues.json
        ?milestone = (Fixnum)
        ?sort = (String)
        ?direction = (String)
        ?state = open, closed, default: open
        ?assignee = (String)
        ?mentioned = (String)
        ?labels = (String)

        With version 3 of the API we can only get 100 issues at a time...
    */

    // FIX ME WE NEED TO DO THIS FOR CLOSED ISSUES TOO :(
    var numberOfIssues = [aRepo numberOfOpenIssues],
        page = 1,
        requests = [];

    while((page * 100) <= numberOfIssues + 100)
    {
        (function(){
        var request = new CFHTTPRequest();
        
        request.setRequestHeader("accept", "application/vnd.github.v3+json");
        
        request.open("GET", [self _urlForAPICall:"repos/"+[aRepo identifier]+"/issues.json?per_page=100&page="+page+"&state="+stateKey], true);
        
        request.oncomplete = function()
        {
            if (request.success())
            {
                try
                {
                    request.MYData = JSON.parse(request.responseText());
                }
                catch (e)
                {
                    CPLog.error("Unable to load issues for repo: " + aRepo + @" -- " + e);
                }
            }

            // Check to make sure if all requests are done.
            // If this test passes on all object one hasn't completed yet.
            // 4 === CFHTTPRequest.CompleteState everything less than that is incomplete
            if ([requests indexOfObjectPassingTest:function(object, index){return object.readyState() < 4}] !== CPNotFound)
                return;
            else
            {
                for (var i = 0; i < requests.length; i++)
                    console.log("status",requests[0].readyState());

                var concatIssues = [];

                for (var i = 0; i < requests.length; i++)
                    [concatIssues addObjectsFromArray:requests[i].MYData];

                [aRepo setValue:concatIssues forKey:stateKey];

                if (aCallback)
                    aCallback(aRepo, requests);

                [[CPRunLoop currentRunLoop] performSelectors];
            }
        };
        
        request.send("");

        requests.push(request);
        console.log("page:", page)
        page++;
        })();
    }



    // There is a chance the user will want the issues in the other open/closed state
    // so if they don't exist we'll go ahead and download those too.

/*    var secStateKey = stateKey === "open" ? "open" : "closed";

    if ([aRepo valueForKey:secStateKey])
        return;

    var secRequest = new CFHTTPRequest();

    secRequest.setRequestHeader("accept", "application/vnd.github.v3+json");
    secRequest.open("GET", [self _urlForAPICall:"repos/"+[aRepo identifier]+"/issues.json?state="+secStateKey], true);

    secRequest.oncomplete = function()
    {
        var secData = nil;
        if (request.success())
        {
            try
            {
                secData = JSON.parse(secRequest.responseText());
            }
            catch (e)
            {
                CPLog.error("Unable to load issues: " + anIssue + @" -- " + e);
            }
        }

        [aRepo setValue:secData forKey:secStateKey];
    };

    request.send("");
}*/

@end