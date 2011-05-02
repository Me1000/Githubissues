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

    // This will prevent us from having to make more API calls for repo searching if we have a username given
    CPString _cachedFirstSearchTerm;
    CPArray  _cachedFirstSearchTermResults;

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
            urlForCall += "/github/v3/" + aCall + + startingArgument +"access_token=" + oauthAccessToken;
            startingArgument = "&";
        }
    }

    urlForCall += startingArgument + "app_id=280issues";

    return urlForCall;
}

/*!
    We sometimes fall back to V2 of the API since V3 is still a work in progress.

    If we're on the server 
*/
- (CPString)_urlForV2APICall:(CPString)aCall
{
    var isAuthenticated = [self isAuthenticated],
        urlForCall = "",
        startingArgument = aCall.indexOf("?") === CPNotFound ? "?" : "&";

    if (window.location && window.location.protocol === "file:")
    {
        if (isAuthenticated)
            urlForCall += "https://" + username + ":" + password + "@github.com/api/v2/json/" + aCall;
        else
            urlForCall += "https://github.com/api/v2/json/" + aCall;
    }
    else
    {
        if (isAuthenticated && oauthAccessToken)
        {
            urlForCall += "/github/v2/" + aCall + + startingArgument +"access_token=" + oauthAccessToken;
            startingArgument = "&";
        }
    }

    urlForCall += startingArgument + "app_id=280issues";

    return urlForCall;
}

/*!
    The auto suggest API call
*/
- (void)repoSuggestWithSearchString:(CPString)aSearchString callback:(Function)aCallback
{
    // This gets a little tricky because we want to reccoment both repos and users...
    // we first need to parse the string. If There is a slash, we will just do a search
    // on a single user's repo.
    // Otherwise we search both.. I guess

    var indexOfSlash = aSearchString.indexOf("/");

    if (indexOfSlash !== CPNotFound)
    {
        var firstTerm = [aSearchString substringToIndex:indexOfSlash],
            secondTerm = [aSearchString substringFromIndex:indexOfSlash+1],
            filter = function() {
                var reply = [];
  
                for (var i = 0, c = _cachedFirstSearchTermResults.length; i < c; i++)
                {
                    if (!secondTerm || [[_cachedFirstSearchTermResults[i].name uppercaseString] hasPrefix:[secondTerm uppercaseString]])
                        reply.push([ISRepository repositoryWithJSObject:_cachedFirstSearchTermResults[i]]);
                }

                if (aCallback)
                    aCallback(reply);
            }

        // If only the 2nd term changed, we have it cached already! YAY!! :D
        if (firstTerm === _cachedFirstSearchTerm && _cachedFirstSearchTermResults)
            filter();
        else
        {
            // at this point we know we have a username, so we're only searching one user's issues
            var request = new CFHTTPRequest();
            //        request.setRequestHeader("accept", "application/vnd.github.v3+json");
    
            // We don't have a V3 for searching yet...
            // V2 look like:
            // http://github.com/api/v2/json/repos/show/[:USERNAME]
    
            request.open("GET", [self _urlForV2APICall:"repos/show/"+ encodeURIComponent(firstTerm)], true);
    
            // FIX ME: time stamp this request
    
            request.oncomplete = function()
            {
                if (request.success())
                {
                    try
                    {
                       _cachedFirstSearchTermResults = JSON.parse(request.responseText()).repositories;
                    }
                    catch(e)
                    {
                        console.log("unable to parse", e);
                    }

                    filter();
                }
            }
            request.send("");
        }

        // CACHE IT!!!!
        _cachedFirstSearchTerm = firstTerm;
    }
    else
    {
        // Just use aSearchString
    }
}

- (void)authenticateWithCallback:(Function)aCallback
{
    var request = new CFHTTPRequest();

    //github.com/users/technoweenie.json
    // Use V3 of the Github API
    request.setRequestHeader("accept", "application/vnd.github.v3+json");

    // FIX ME: github is broked
    if (window.location && window.location.protocol === "file:" && username && password)
        request.setRequestHeader("Authorization", "Basic "+CFData.encodeBase64String(username +":" + password));

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
                userThumbnailImage = [[CPImage alloc] initWithContentsOfFile:gravatarURL + "?s=34&d=identicon"
                                                                        size:CGSizeMake(34, 34)];
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

- (void)loadAllReposForUser:(CPString)aUserLogin callback:(Function)aCallback
{
    // at this point we know we have a username, so we're only searching one user's issues
    var request = new CFHTTPRequest();
    //request.setRequestHeader("accept", "application/vnd.github.v3+json");
    
    // We don't have a V3 for searching yet...
    // V2 look like:
    // http://github.com/api/v2/json/repos/show/[:USERNAME]
    
    request.open("GET", [self _urlForV2APICall:"repos/show/"+ encodeURIComponent(aUserLogin)], true);
    
    request.oncomplete = function()
    {
        if (request.success())
        {
            try
            {
                var results = JSON.parse(request.responseText()).repositories,
                    i = 0,
                    c = results.length;

                for (; i < c; i++)
                    [self loadRepositoryWithIdentifier:results[i].owner +"/"+results[i].name callback:aCallback];
            }
            catch(e){console.log("oops", e);}
        }
    }
    request.send("");
}

- (void)loadRepositoryWithIdentifier:(CPString)anIdentifier callback:(Function)aCallback
{
    var request = new CFHTTPRequest();

    // Use V3 of the Github API
    request.setRequestHeader("accept", "application/vnd.github.v3+json");

    var parts = anIdentifier.split("/");
    if ([parts count] > 2)
        anIdentifier = parts.slice(0, 2).join("/");

    request.open("GET", [self _urlForAPICall:"repos/"+anIdentifier+".json"], true);

    request.oncomplete = function()
    {
        var data = nil,
            newRepo = nil;

        if (request.success())
        {
            try {

                data = JSON.parse(request.responseText());

                newRepo = [repositoriesByIdentifier objectForKey:anIdentifier] || [ISRepository repositoryWithJSObject:data];

                if (![repositoriesByIdentifier objectForKey:anIdentifier])
                    [repositoriesByIdentifier setObject:newRepo forKey:anIdentifier];
                else
                    [newRepo updateWithJSObject:data];
            }
            catch (e) {
                CPLog.error("Unable to load repositority with identifier: "+anIdentifier+" -- "+e);
            }
        }
        else
            console.log("fail");

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
        requests = [],
        totalAssigned = 0;

    while((page * 100) <= numberOfIssues + 100)
    {
        (function(){
        var request = new CFHTTPRequest();

//        request.setRequestHeader("accept", "application/vnd.github.v3+json");

        request.open("GET", [self _urlForAPICall:"repos/"+[aRepo identifier]+"/issues.json?per_page=100&page="+page+"&state="+stateKey], true);

        request.oncomplete = function()
        {
            if (request.success())
            {
                try
                {
                    var responseData = JSON.parse(request.responseText()),
                        c = responseData.length,
                        i = 0;

                    request.MYData = [];

                    // Reversing them
                    while(c--)
                    {
                        var obj = [CPDictionary dictionaryWithJSObject:responseData[c] recursively:YES];

                        if (stateKey === "open")
                            if ([obj objectForKey:"assignee"] !== [CPNull null])
                                if ([[obj objectForKey:"assignee"] objectForKey:"login"] !== [CPNull null])
                                    totalAssigned++;

                        request.MYData.push(obj);
                    }
                }
                catch (e)
                {
                    // FIX ME: make this more descriptivate I guess...
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
                var concatIssues = [],
                    count = requests.length;

                // reversing them making sure it increments as you go down...
                while(count--)
                    [concatIssues addObjectsFromArray:requests[count].MYData];

                [aRepo setValue:concatIssues forKey:stateKey];
                [aRepo setValue:totalAssigned forKey:"issuesAssignedToCurrentUser"];
                [aRepo setIssuesAssignedToCurrentUser:totalAssigned];

                if (aCallback)
                    aCallback(aRepo, requests);

                [[CPRunLoop currentRunLoop] performSelectors];
            }
        };

        request.send("");

        requests.push(request);
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

    request.send("");*/
}


- (void)createIssue:(CPDictionary)anIssue withCallback:(id)aCallback
{
    /*POST https://Me1000:icu81234@api.github.com/repos/:user/:repo/issues
           https://Me1000:icu81234@api.github.com/repos/Me1000/Githubissues/issues.json?app_id=280issues
    INPUT

    {"title"=>"String",
     "body"=>"String",
     "assignee"=>"String User login",
     "milestone"=>"Integer Milestone number",
     "labels"=>["Label1", "Label2"]}*/

 var request = new CFHTTPRequest();

// FIX ME: github is broked
    if (window.location && window.location.protocol === "file:" && username && password)
        request.setRequestHeader("Authorization", "Basic "+CFData.encodeBase64String(username +":" + password));
    // Use V3 of the Github API
    request.setRequestHeader("accept", "application/vnd.github.v3+json");

    request.open("POST", [self _urlForAPICall:"repos/" + [anIssue objectForKey:"repo"] + "/issues"], true);

    request.oncomplete = function()
    {
        var newIssue = nil;

        if (request.success())
        {
            try
            {
                var responseData = JSON.parse(request.responseText());

                newIssue = [CPDictionary dictionaryWithJSObject:responseData recursively:YES];

                [[repositoriesByIdentifier objectForKey:[anIssue objectForKey:"repo"]] addIssue:newIssue];
            }
            catch(e){}
        }

        if (aCallback)
            aCallback(newIssue, request);
    }

    var obj = {
        title:[anIssue objectForKey:"title"],
        body: [anIssue objectForKey:"body"]
    }

    request.send(JSON.stringify(obj));
}
@end






