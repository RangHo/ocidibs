# OCI Dibs

Dibs on the OCI Standard.A1 instances.

Oracle Cloud Infrastructure offers a fairly powerful instances utilizing ARM processors.
This configuration provides more cores (up to 4 cores) and more RAM (up to 24GB), enough to run a pretty busy Minecraft server.
(In fact, they already have a [dedicated blog article](https://blogs.oracle.com/developers/post/how-to-set-up-and-run-a-really-powerful-free-minecraft-server-in-the-cloud) explaining how to do this.)

Sounds amazing, right?

## Out of Capacity, until the end of time

......except it seems there is no capacity available on virtually all regions.
I've been trying making instances by hand for more than a month, and never succeeded.

Making the same request from time to time until the request succeeds...
It desperately calls for a li'l automation, no? I would rather have that checked by a script, instead.
So, this simple Ruby script does exactly that. Checking if instance creation is available, then firing one up.

## Acknowledgement

This repository is based on [Hitrov's PHP script](https://github.com/hitrov/oci-arm-host-capacity) which I couldn't use because AWS-provided PHP is so ancient that even Composer sometimes fails on it.
