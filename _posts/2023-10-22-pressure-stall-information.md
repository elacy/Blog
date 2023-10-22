---
title: Pressure Stall Information in Linux
layout: post
categories:
  - Technology
tags:
  - Resilience
---

![](/assets/images/2023/10/22/pressure-gauge.png "Pressure Gauge on a circuit board")

Pressure Stall Information (PSI) is a feature of the Linux kernel that allows a user to measure the total amount of time that user threads spent waiting on system resources. When enabled it allows you to determine how long threads have been waiting on CPU cores, IO bandwidth available, Memory to be allocated and interrupts. You can also have it send you a notification when it crosses a threshold.  Please keep in mind this is the amount of time waiting not the amount of time working. <!-- more -->

WARNING: I'm not a kernel programmer, so this explanation may have faults which is why I'll be linking to the code to show you where I'm pulling this from except where it's explicitly stated in the [kernel documentation](https://docs.kernel.org/accounting/psi.html). If you find a flaw in this doc please add a comment. This information was valid as of v6.6-rc6.

## How do I enable it?
It's enabled by default on most modern Linux versions, if you run `cat /proc/pressure/io` and it returns a value like below then you know it's enabled:
```
some avg10=0.00 avg60=0.00 avg300=0.00 total=0
full avg10=0.00 avg60=0.00 avg300=0.00 total=0
```
(I'll explain what all this means below)

If not then check that you have a Linux kernel later than 4.20 with `uname -r`. If it's not up to date then you'll need to upgrade your kernel before you can use it.

If your kernel is up to date then you'll need to add `psi=1` to kernel boot parameters (via GRUB) or recompile the kernel with PSI enabled by default using `CONFIG_PSI=y`.

## Does Enabling It Have a Significant Impact on overall performance?
TL;DR the computation overhead is negligable for the vast majority of workloads unless you are querying the data more than once every 50ms.

By default when enabled it monitors for the following events:
- [Thread state change](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n908)
- [Thread moved between CPUs](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n927)
- [Thread irq time](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1005) (only in 6.1 or later if CONFIG_IRQ_TIME_ACCOUNTING is enabled)
- Thread memstall [starts](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1037)/[ends](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1069)
- CGroup [created](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1100)/[deleted](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1119)/[restarts](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1198)

When any of these events happens it [updates the number of threads in each state on each cgroup/CPU combination](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n778). If this is a nested cgroup then it has to be [updated for each parent](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n922). Then it [records the various stall times since the last update](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n749).

Then every 2 seconds it [calculates the stall time as a percentage of wall clock time](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n563).

The work involved in doing this is low enough that most moden linux distributions come with this enabled by default.

However if you read from `/proc/pressure/whatever` it will call [psi_show](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1233) which will recalculate the total stall time by pulling data from each cpu for the current CGroup and update the averages before returning the result.

Additionally if you have configured notifications, then it will peform the calculation 10 times whatever you have set the window length to.

Given that there [used to be a minimum window size of 500ms](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/kernel/sched/psi.c?id=519fabc7aaba3f0847cf37d5f9a5740c370eb777) which was removed in version 6.5 because it wasn't enforceable it's worth considering carefully before you use a window that is smaller or read from `/proc/pressure/whatever` more than once every 50ms. 

## How is stall time calculated?
PSI calculates a different stall time for each resource, so if you have 12 threads and 10 cores then you are 2/10 stalled until at least one core becomes free. So you are experiencing 20% stall and if it takes 100ms then for that period you are stalled by 20ms. However this stall time will only apply to the CPU. For there to be memory stall time there must be threads waiting on memory to be allocated.

Keep in mind that because stall time is relative to the number of cores being used a single thread stuck on a single core which is currently occupied while every other core is not being used will produce stall time at the same rate as if there were a thread waiting on every CPU.

You can find a comment in the code that explains this [here](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n20).

## How do I get the stall time for each resource?
Here are the files that capture the stall time by the thing the thread is stalled waiting for
- CPU Cores: /proc/pressure/cpu
- Memory Allocation: /proc/pressure/memory
- Network and Disk IO: /proc/pressure/io
- Interupts: /proc/pressure/irq (only in 6.1 or later if CONFIG_IRQ_TIME_ACCOUNTING is enabled)

## What's the difference between SOME and FULL?
Full is stall time measured while no user threads are running on the CPU. This could occur if the the kernel is paging memory to the disk. Some is stall time regardless of whether there are running threads on the CPU.

Full isn't available for CPU until you are running in a cgroup with a limitation on CPU usage. Keep in mind that a single thread on a single core can trigger the some value.

Interupts only have FULL because interrupt time only applies to the current thread.

## What's the total?
You will see the total value when you read from `/proc/pressure/whatever` and see `some avg10=0.00 avg60=0.00 avg300=0.00 total=0`
It's an int 64 which represents the stall time in microseconds since the machine started

## How are the averages calculated?
[Every 2 seconds](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n157) the average percentage of stall time is calculated for that two seconds, this is then used to calculate an decaying average for each avgNN where NN is the number of seconds this average is supposed to represent. Code for that is [here](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n510).

[This is also calculated every time](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n1247) the `/proc/pressure/whatever` is read.

So if that's `avg10=20.00` then it would mean that there is approximately 2 seconds of stall time in the last 10 seconds.

## What happens if I run this in a docker container or cgroup
If you do this in a docker container it will only consider the threads inside that container or cgroup for calculating stall time but it will consider the non idle time avaialble on all CPUs. 

## How do I create notifications for stall time?
You write text in the below format into `/proc/pressure/whatever`:
```
<some|full> <stall amount in microseconds> <time window in microseconds>
```

So if you wanted to create a notification that would alert you if the stall time exceeded 150ms in a window of 1s for memory then you would write the following to `/proc/pressure/memory` then poll for changes:
`some 150000 1000000`

Then every 100 milliseconds (10 times within a 1 second window) [it will update the recorded stall time for the current window](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n401). Then if the total stall time exceeds your threshold it will [send an interrupt](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?id=752182b24bf4ffda1c5a8025515d53122d930bd8#n495) to notify your poll that there are changes to the file. 

The maximum window size is 10 seconds, and if you have kernel version less than 6.5 then the minimum window size is 500ms.