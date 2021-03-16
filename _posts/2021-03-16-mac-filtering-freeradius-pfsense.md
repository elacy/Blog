---
title: Securing a VLAN with mac addresses
layout: post
categories:
  - Technology
tags:
  - PFsense
  - FreeRadius
  - EAP
  - Wifi
  - Security
  - Mac Filtering
---

![](/assets/images/2021/03/16/mac-filtering-freeradius-pfsense/macChanger.png "It's easy to change your mac address")

It's very easy to fake a mac address, however that doesn't mean that mac address filtering is useless. We can still add security through mac filtering but we do it by considering the mac address as a username rather than a password, the ability to use a given mac address on your network should be secured especially if you have different firewall rules for different IP addresses within the same VLAN. This post explains how that works. <!-- more -->

So I'm going to assume you have already split your network into a series of VLANs, and the only way to get on this particular VLAN is through a physical connection to a managed switch or through EAP.

You will need to put a mac filter on the ports that each devices that is physically connected connects through. That way it can't pretend to be a different mac address as it's traffic will be rejected at the entry point.

For your wireless devices they should each connect using EAP and you also want to set a filter in FreeRadius on the mac address so only that mac address can authenticate as that particular user. You can see what that configuration will look like in PFSense when you edit a FreeRadius user:

![](/assets/images/2021/03/16/mac-filtering-freeradius-pfsense/freeRadiusMacFilter.png "Configuration for FreeRadius in PFSense UI")

You can also do this directly through FreeRadius configuration:

```
"mylaptop" Cleartext-Password := "", Calling-Station-Id = "<INSERT MAC ADDRESS HERE>" 

	Tunnel-Type = VLAN,
	Tunnel-Medium-Type = IEEE-802,
	Tunnel-Private-Group-ID = "2002"
```

Identifying the actual MAC address and it's format is something you are going to have to get by looking at FreeRadius logs, it will depend on the device format sent to the FreeRadius server by the wifi access point. 

Once you have applied these rules to every device in your VLAN this that means that faking a mac address on your network will be as hard as cracking the EAP or changing your switch configuration. It is possible but it's a lot harder and security is all about making things harder.

The next step will be assigning an IP to the mac address, we can give it a static lease in DHCP but it's very possible for a someone to spoof a mapping between an IP address and a mac address. To address that issue you should enable static arp which will make it so that mappings between mac addresses and IP addresses cannot be updated once the ARP information has been cached by the client. You can find the documentation for how to do that in PFSense [here](https://docs.netgate.com/pfsense/en/latest/services/dhcp/ipv4.html#other-options). 

Static ARP mean that the arp table cannot be updated by an attacker, once the mapping is set between an IP and a mac address it will stay that way, it will also mean that traffic for that subnet will be rejected by the gateway at layer 2 if the static arp mapping it has doesn't match the arp mapping provided by the router.