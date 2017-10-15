---
title: Getting Chocolatey to work on Windows 10
layout: post
categories:
  - Technology
tags:
  - Chocolatey
  - OneGet
  - PowerShell
---
Windows 10 was released today and the first thing I did when I got it installed it try to get chocolatey working. Wasn't as easy as I'd hoped but it still integrates really nicely with Window's new packaging system.

OneGet is the new package manager for Windows 10. It's similar to apt-get, it treats Chocolatey is sort of a repo but also a plugin.

To get started open powershell with Admin permissions and run: `Set-ExecutionPolicy RemoteSigned`  
You'll need it to ensure that Choclately actually installs the packages and doesn't simply just fail without a warning.

Then run `Get-PackageProvider -name Chocolatey -ForceBootstrap`  
That will install the Chocolatey plugin/repo and you'll be able to install packages using `Install-Package <package-name>`  
If you have previously tried to install Chocolatey it may complain that the package exists in different sources, you'll have to use the Get-PackageProvider command to narrow down which package provider is the one you'd like to remove before you use the Unregister-PackageSource command

It would be nice of course if you could simple give it a file with a list of all the packages you want it to install but I couldn't see any such option in the [source][1] so I wrote this command

```
foreach($item in GetContent packages.txt) {
	Install-Package $item
}
```
</div>

Given a file called packages.txt that contains a list of Chocolatey package names all on separate lines it installs them one by one, very handy!

 [1]: https://github.com/OneGet/oneget/blob/master/PowerShell.Module/Cmdlets/InstallPackage.cs