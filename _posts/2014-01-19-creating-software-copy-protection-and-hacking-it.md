---
title: Creating software copy protection and hacking it
layout: post
categories:
  - Technology
tags:
  - Copy Protection
  - Cracking
  - Deobfuscation
  - Hacking
  - Obfuscation
  - Software Licensing
---
An important part of monetizing your work is creating a situation where people are willing to give you money.

One of the ways, in desktop software, to create that situation is to prevent your software from being used or used fully without giving you (enough) money.

*This blog post is going to break down how that works into it's different parts and then provide you with some sample implementations of copy protection along with their weaknesses.*

Here are the some types of restrictions:

  * You do not get the software until you have paid (your website could prevent download of any software till you have paid for the product)
  * You cannot use the software in certain ways you have not paid for (the trial software could limit the use of the product, or you might buy a license for one machine)
  * You have a time limit on how long you can use the software (trial period)
  * Users cannot access the source code

Here are some ways you can tell if the user is a valid user

<!--more-->

  * License Key: String(s) that you might send them in an email or be attached to your physical product
  * License File: Probably something you email to them, they will have to browse to the file location
  * Activation: Your products checks your users access with a license server (over the internet or a local license server)

Here are some things that stop people from getting around your software protection

  * Legal concerns (user may be afraid that they will be arrested/sued/fired)
  * Ethical considerations: they see the value in what you do and want to pay for it to ensure you are willing to continue doing it
  * No one capable of getting around the software protection has had access to the software (if only those who paid for it can access the software)
  * Virus/Security considerations: It's not possible to get around your software protection without replacing the executable code with less secure code (warez sites are generally not very reliable)
  * You have made it extremely hard for people get access to your source code

Here are some things that motivate people to get around your software protections

  * Your software costs more money than the people who want to user your software can afford (Photoshop being a classic example, it's a product lots of people want to use but few can afford)
  * Your licensing system is restrictive in a way that prevents your users from using the software in the way they want to use it.
  * Your competitor would like their software to do the same thing

Here are some ways that people use to get around software protections

  * Convert your binary to code: If they can only access your binary, they could potentially use one of the many software packages available for turning them into source code
  * Copy a license key from one machine to another: even if you only want them to use the product on one computer, they could share with a friend post it on the internet

OK now that the problem is broken down into it's overall parts and before I go into the technical implementation of copy protection you need to keep the following things in mind.

  * You will never come up with an solution that can't be hacked
  * Any solution that you do come up with, attempt to hack it to see how hard it is, you aren't “done” until you do (Cracking software is easier than it probably looks)

### Implementations

#### License Key Validator

One way to solve this problem is to have a Username/ License Key pair. You generate the license key based on the username of the user, the product features they are able to access, how long they are able to access it etc. All of the code for validating this is a correct license is contained within the application that is stored on the user's computer. The user will be less willing to share this license as it will include their name. However they still can do that, if that's something you want to prevent you may want to look toward Activation.

If the user can access the code for generating the licenses they could make their own licenses. If the code for validating the licenses is available then it could be potentially more difficult to generate their own licenses. If the code is protected by compiling it and/or obfuscating (reducing it's readability) then this task ***might*** be a lot harder to complete. Read what I write about Obfuscation to see just how hard. Another option for the user is to remove the part of the application that checks if the license is valid, however this requires that the user understand how to do this themselves or is willing to trust an implementation from someone else who does.

#### License file Validator

In this solution you send the user a file/large bit of text that contains all the relevant information asymmetrically encrypted. This file cannot be faked. The only way get around this type of protection is to replace the component that validates the file. You can protect against this with compilation and obfuscation. You may not like this solution as it can be more awkward for the user to add the license file than a license key. The user will be less willing to share the license file if it could include their name. However they still can do that, if that's something you want to prevent you may want to look toward Activation.

#### Activation

Activation involves your product talking to a third party server that validates whether the user has access. Once the third party server validates the user then the desktop software can request a license from the third party server. You may not like this due to the fact that it requires connectivity to the license server. The advantage to this is that you can restrict the number of machines the product is activated on.

However this will only increase your security if you do the folowing:

  * The communication between your server and your program should be encrypted asymmetrically to prevent any sort of man in the middle attack
  * Any license file that is returned to your program from the server should include some information about the computer on which the program is being activated that uniquely identifies it.
  * Users cannot change anything on the license server

This is also vulnerable to the user/third party altering your program so that it doesn't validate the license properly or even try to activate at all, see obfuscation.

####  Obfuscation

Obfuscation takes your source code and/or compiled binary and makes it more difficult for someone to extract any meaningful information about what your program does. It's extremely useful for three reasons.

  * Your competitors can't find out how your program works easily
  * Someone attempting to crack your software can't generate their own license keys easily
  * Someone attempting to crack your software can't replace license validation components with their own as easily

Of course the problem with obfuscation, aside from debugging problems that occur and any potential issues that might arise if for some reason your code conflicts with the obfuscation method is that if you are using the program to obfuscate your code, chances are someone can write a program that deobfuscates your code.

A good example being <a href="https://bitbucket.org/0xd4d/de4dot" target="_blank">de4dot</a> which allows you to take a .Net binary and remove the obfuscation applied to it by 19 different products, some of which you actually have to pay quite a lot of money to use. So before you send your obfuscated product out make sure that it can't be deobfuscated by a tool someone can download online for free.

#### Code Signing

Code signing is when you use an asymmetric key to sign your binaries which prove that they haven't been altered. Your program is still vulnerable to having a component replaced however the person who replaces the component will also have to replace any components that won't run if any of the components aren't signed. This can also make it harder to crack if the operating system/what you plug in to doesn't allow non signed programs.

### Conclusion

Copy Protection is a non trivial problem with many potential pitfalls. However as long as you analyse the potential attack vectors (ways in which someone could get around your copy protection) by trying to circumvent it yourself you should get a more realistic picture of how secure your solution is. Of course software is only part of the solution, your pricing structure and relationship with the community can also affect how much money you lose to piracy, however that is the subject of another post.