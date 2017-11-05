---
title: How to get quality into your software
layout: post
categories:
  - Technology
tags:
  - Testing
  - Unit Testing
  - Integration Testing
  - Test Driven Development
---
As a software developer, the bane of my life is bugs, I hate them, I feel so stressed by them. Every time I see a bug in my work before someone else does I have to stop myself from wanting to hide it completely. It's so natural to want to hide or avoid the problem, but we as developers need to tackle it head on.

## Code Reviews

Quality needs to start in code reviews, anything you change in your team starts with code reviews. It's where you educate everyone on your team on what each part of the software does and where you communicate the standards that need to be followed.<!-- more -->

### How to do that right

Your team aren't robots, they aren't software libraries you can discard because they aren't working out, they aren't legacy systems you can hold at arms length until you can get rid of them, if you don't take care of them you will suffer for it.

Before you look at the code, find out what the ask is, that should be in a user story. Take a look at the commit title and make sure it's clear what the ask is. If the ask isn't clear and you don't know what to expect from the code you won't be able to do a good review. That might be ok for now, keep going regardless, things aren't perfect, ok let's move on.

Next let's learn from this code, what can it tell you about the user story. Maybe this developer is going to express in code some truth about the requirements you weren't aware of. We need to focus on this as developers because in reality.

Next thing, check out the code and start running it on your own system, yes I know this takes time but manually testing the code will save you lots of time in the future. Make sure it works well and note down any things that could be improved about the code. Yes, the developer should have caught all the bugs and shouldn't be wasting your time with stupid mistakes, but be kind. I can't emphasise this enough, be really kind with developers, if you want your team to grow quickly you need to be good about this.

If the code doesn't work, then you need to look into what lead to the bug, there aren't enough tests. That's the issue, if there were more tests this wouldn't have happened, automated is better. If your application is in a state that automated testing isn't an option, you need a written procedure on how to test your application.

If the code works, you need to start to start the feedback process, go through it carefully, if anything takes too much time for you to understand the code needs to be simplified or it needs more comments.

## Documentation

You need all of your features documented, and part of every task should include keeping the documentation up to date. You also need to document all your development processes. For God's sake make that easy to do. Do not at any point discourage people from documenting what they do. WYSIWYG editor is key for this. Part of the review should ensure the documentation matches the change, you also want to ensure readability.

You also need to document the technology you use and how you use it. It's likely to be not simple, make sure it's explained how it works and anything you do that's unique to that technology.

## Testing

There are several schools of thought on Unit testing, here is mine, I think it's the most pragmatic approach that gives the best cost/benefit

First of all the principals in order of importance:

- Consistent (There should never be intermittent failures)
- Not brittle (Your unit test should test at the highest level possible while satisfying all of the above conditions 
- Isolated (No test should impact on another test)
- Fast (millliseconds per test ideally)

I can't find any of the talks where I learned these principals but I did find something really similar here: [F.I.R.S.T Principles of Unit Testing](https://github.com/ghsukumar/SFDC_Best_Practices/wiki/F.I.R.S.T-Principles-of-Unit-Testing)

How I interpret these:
-	Pragmatism Reigns: Your unit tests will take longer to write than your system under test, but so will maintaining the system under test, make sure that the work you put in offsets the maintenance time and increase the quality of the code, that's the whole purpose of writing these tests
-	Unit doesn't mean one function or one code, it means one behavior, you aren't testing a function only used within one class, you are testing the API (where possible) or in MVC you are testing at the controller level ideally
-	External Dependencies are fine as long as they don't break consistency, test isolation and speed.
-	Speed is only important because it's pragmatic, you don't want your unit tests to take ages. If you have one test that takes 1 second and 1000 that take milliseconds, it's not a big deal. If your tests take half an hour to run, they won't be run very often so they aren't as useful to you
-	I've yet to see an effective code coverage metric, TDD is a pita but do your utmost to write tests show how each behaviour in your code is necessary. If you don't, someone may remove the behaviour and not realise the impact. All the time you put into your code could be lost!

Naming conventions we could use

-	Unit tests for mocked out dependencies
-	Local tests for dependencies which conform to unit test principals
-	Integration tests for full production like system test

The expected developer workflow for unit/integration tests

-	Write a change to the code
-	Unit Test
-	Repeat until ready to commit
-	Integration Test
-	Commit/Push

