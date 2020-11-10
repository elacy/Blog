---
title: Helm apiVersion Fix
layout: post
categories:
  - Technology
tags:
  - Kubernetes
  - Helm
---

In Kubernetes 1.16 deployment is no longer available in extensions/v1beta1, apps/v1beta1, and apps/v1beta2, if you are using a helm chart written for an earlier version there is a very simple fix to make it work for Kubernetes 1.16.<!-- more -->

You can see the full details on this update on the Kubernetes website [here](https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/). The solution as stated in that blog post is to run the `kubectl convert -f <file>` which will update the helm template to the latest version. You can hook that into helm using the `--post-renderer` option which executes the command provided in that argument with the template as input and then deploys the output.

To get that working with `kubectl` which doesn't take input through standard in you can just use the following script:
```
#!/bin/bash
tmpfile=$(mktemp /tmp/abc-script.XXXXXX)
cat <&0 > $tmpfile
kubectl convert -f $tmpfile
rm $tmpfile
```
I call it `update-api-version.sh` so you can use do `--post-renderer ./update-api-version.sh` as long as you `chmod +x update-api-version.sh`. If you are doing this in terraform you will want to add an argument to your `helm_release` like this:

```
resource "helm_release" "resource-name" {
  ....
  postrender{
    binary_path = "./update-api-version.sh"
  }
  ...
}
```

Comment if you found this useful!