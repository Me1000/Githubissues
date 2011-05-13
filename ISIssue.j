@implementation ISIssue : CPObject
{
    CPString     pullRequest @accessors;
    CPDate       closedAt @accessors;
    ISMilestone  milestone @accessors;
    CPString     body @accessors;
    CPArray      comments @accessors;
    unsigned     numberOfComments @accessors;
    CPString     url @accessors;
    CPDate       updatedAt @accessors;
    CPDate       createdAt @accessors;
    CPDictionary assignee @accessors;
    CPString     state @accessors;
    CPString     title @accessors;
    unsigned     number @accessors;
    CPDictionary user @accessors;
    CPArray      labels @accessors;
}

+ (id)issuesWithJSObject:(JSObject)anObject
{
    newIssues = [ISIssue new];

    newIssues.pullRequest = anObject.pullRequest || "";
    newIssues.closedAt    = [CPDate dateFromISO8601:anObject.closed_at] || nil;
    newIssues.milestone   = anObject.milestone;
    newIssues.body        = anObject.body || "";
    newIssues.numberOfComments = anObject.comments || 0;
    newIssues.comments    = []; //JSObject wont' have comments initially.
    newIssues.url         = anObject.URL || "";
    newIssues.updatedAt   = [CPDate dateFromISO8601:anObject.updated_at] || nil;
    newIssues.createdAt   = [CPDate dateFromISO8601:anObject.create_at] || nil;
    newIssues.assignee    = [CPDictionary dictionaryWithJSObject:anObject.assignee recursively:YES];
    newIssues.state       = anObject.state || "closed";
    newIssues.title       = anObject.title || "";
    newIssues.number      = anObject.number || CPNotFound; // maybe nil?
    newIssues.user        = [CPDictionary dictionaryWithJSObject:anObject.user recursively:YES];
    newIssues.labels      = [];

    for (var i = 0, c = anObject.labels.length; i < c; i++)
        newIssues.labels.push([ISLabel labelWithJSObject:anObject.labels[i]]);

    return newIssues;
}

@end

