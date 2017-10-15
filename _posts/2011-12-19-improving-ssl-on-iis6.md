---
title: Improving SSL on IIS6
layout: post
categories:
  - Technology
tags:
  - IIS6
  - MD5
  - PCI Compliance
  - SSL
---
[![](/assets/images/2011/12/before-ssl.png "before-ssl")]

IIS 6 by default uses MD5 hashing and low security encryption.  
if you put the following into a reg file and run it it should remove some of the less secure cipher suites used by IIS.

Update 1 : Go to <http://support.microsoft.com/kb/948963> to enable AES 256 (requires restart)

Update 2: If you install the above update or turn on FIPs compliance in your local security policy this will make you vulnerable to the beast attack.

<!--more-->

> REGEDIT4  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128]  
> “Enabled”=dword:ffffffff  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128]  
> “Enabled”=dword:ffffffff  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168]  
> “Enabled”=dword:ffffffff  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5]  
> “Enabled”=dword:00000000  
> [HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\SHA]  
> “Enabled”=dword:ffffffff