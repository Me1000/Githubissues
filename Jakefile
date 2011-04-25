/*
 * Jakefile
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts All rights reserved.
 */

var ENV = require("system").env,
    FILE = require("file"),
    JAKE = require("jake"),
    task = JAKE.task,
    FileList = JAKE.FileList,
    app = require("cappuccino/jake").app,
    configuration = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Debug",
    OS = require("os");

app ("GithubIssues", function(task)
{
    task.setBuildIntermediatesPath(FILE.join("Build", "GithubIssues.build", configuration));
    task.setBuildPath(FILE.join("Build", configuration));

    task.setProductName("GithubIssues");
    task.setIdentifier("com.yourcompany.GithubIssues");
    task.setVersion("1.0");
    task.setAuthor("Your Company");
    task.setEmail("feedback @nospam@ yourcompany.com");
    task.setSummary("GithubIssues");
    task.setSources((new FileList("**/*.{j,js}")).exclude(FILE.join("Build", "**")));
    task.setResources(new FileList("Resources/**"));
    task.setIndexFilePath("index.html");
    task.setInfoPlistPath("Info.plist");
    task.setNib2CibFlags("-R Resources/");

    if (configuration === "Debug")
        task.setCompilerFlags("-DDEBUG -g");
    else
        task.setCompilerFlags("-O");
});

task ("default", ["GithubIssues"], function()
{
    OS.system("cp *.js " + OS.enquote(FILE.join("Build", configuration, "GithubIssues", ".")));
    printResults(configuration);
});

task ("build", ["default"]);

task ("debug", function()
{
    ENV["CONFIGURATION"] = "Debug";
    JAKE.subjake(["."], "build", ENV);
});

task ("release", function()
{
    ENV["CONFIGURATION"] = "Release";
    JAKE.subjake(["."], "build", ENV);
});

task ("run", ["debug"], function()
{
    OS.system(["open", FILE.join("Build", "Debug", "GithubIssues", "index.html")]);
});

task ("run-release", ["release"], function()
{
    OS.system(["open", FILE.join("Build", "Release", "GithubIssues", "index.html")]);
});

task ("deploy", ["release"], function()
{
    FILE.mkdirs(FILE.join("Build", "Press", "GithubIssues"));
    OS.system(["press", "-f", FILE.join("Build", "Release", "GithubIssues"), FILE.join("Build", "Press", "GithubIssues")]);

    FILE.mkdirs(FILE.join("Build", "Deployment", "GithubIssues"));
    OS.system(["flatten", "-f", "--verbose", "--split", "3", "-c", "closure-compiler", FILE.join("Build", "Press", "GithubIssues"), FILE.join("Build", "Deployment", "GithubIssues")]);

    printResults("Deployment")
});

task ("desktop", ["release"], function()
{
    FILE.mkdirs(FILE.join("Build", "Desktop", "GithubIssues"));
    require("cappuccino/nativehost").buildNativeHost(FILE.join("Build", "Release", "GithubIssues"), FILE.join("Build", "Desktop", "GithubIssues", "GithubIssues.app"));
    printResults("Desktop")
});

task ("run-desktop", ["desktop"], function()
{
    OS.system([FILE.join("Build", "Desktop", "GithubIssues", "GithubIssues.app", "Contents", "MacOS", "NativeHost"), "-i"]);
});

function printResults(configuration)
{
    print("----------------------------");
    print(configuration+" app built at path: "+FILE.join("Build", configuration, "GithubIssues"));
    print("----------------------------");
}
