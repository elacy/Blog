---
title: Things to do regarding authentication in web apps
layout: post
categories:
  - Technology
tags:
  - Passwords
  - Web Applications
---
### Links in emails you send me should log me in

As long as the only security you provide to reset my password is my email address stop sending me emails with links that don't automatically log me in. Particularly when it comes to “click to unsubscribe” and “verify your email” links. They make me think your application is made by people who hate me.
<!--more-->

### When I forget my password don't send me a new one

Instead of sending me a new password, send me a link that is a one time log-in that brings me to a screen that allows me to change my password. If you send me a long password I will forget that I have to change it to something I will remember and next time I visit your site I will have to reset it all over again.

### Allow multiple forms of third party authentication

It's so much faster and easier to click on a button then to type in my password, I'm probably logged in using 3 different services already. Also passwords are one of the worst forms of security, if I log-in with my google account which has two factor authentication set up then it's a lot safer than using your password system. Plus if you system gets hacked, you haven't salted my passwords correctly and I'm lazy and use one password for all my accounts then you won't need to worry about someone breaking into my internet banking.

### Hash and Salt all passwords

If your system gets hacked and someone looks at your user table they should not be able to pull out a list of plain text passwords. If they do there is quite a high probability they will try to get access to every email account on the list. You don't want that to happen, it hurts your reputation. It hurts the users' trust in you. Don't just hash it either, hash it and [salt ][1]it, otherwise someone will use [rainbow tables][2] and you are back to square one.

### If I want to use a 143 character password full of weird characters LET ME

There is no reason not to. If you are thinking that you have limited space for such a password then you clearly aren't hashing the password which actually worries me more.

### Don't use secret Question & Answer

I think [this post][3] explains it better than I could. If you require more security than just email verification then you need something better than secret Q&A because you are just reacting to a security hole by creating a bigger security hole.

 [1]: https://en.wikipedia.org/wiki/Salt_%28cryptography%29
 [2]: https://en.wikipedia.org/wiki/Rainbow_table
 [3]: http://www.computerweekly.com/opinion/Secret-questions-blow-a-hole-in-security