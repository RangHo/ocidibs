# OCI Dibs

Dibs on the OCI Standard.A1 instances.

Oracle Cloud Infrastructure offers fairly powerful instances utilizing ARM processors.
This configuration provides more cores (up to 4 cores) and more RAM (up to 24GB), enough to run a pretty busy Minecraft server.
(In fact, they already have a [dedicated blog article](https://blogs.oracle.com/developers/post/how-to-set-up-and-run-a-really-powerful-free-minecraft-server-in-the-cloud) explaining how to do this.)

Sounds amazing, right?


## Out of Capacity, until the end of time

......except it seems there is no capacity available on virtually all regions.
I've been trying making instances by hand for more than a month, and never succeeded.

Making the same request from time to time until the request succeeds...
It desperately calls for a li'l automation, no? I would rather have that checked by a script, instead.
So, this simple Ruby script does exactly that. Checking if instance creation is available, then firing one up.


## How to use the darn thing

This program gets all necessary information to launch an instance via command line arguments.
See the help message below:
```
$ ruby ocidibs.rb --help
Usage: ocidibs.rb [options]                                        
    --availability-domain DOMAIN The ID of the Availability Domain of the region.
    --compartment-id COMPARTMENT The compartment ID of the instance.
    --display-name NAME          The name of your instance. A random name will be created if none specified.
    --image-id ID                The OCID of the image to use.
    --shape SHAPE                The shape of the instance. Default is VM.Standard.A1.Flex.
    --ocpus COUNT                Number of OCPU cores. Default is 4.
    --memory-in-gbs SIZE         Size of the RAM, in GBs. Default is 24.
    --subnet-id ID               The OCID of the subnet to use. You may need to create a subnet first.
    --ssh-public-key KEYFILE     The SSH public key file to use when connecting to the new instance.
    --dry-run                    Don't actually send a request to Oracle Cloud.
    --retry SECONDS              Automatically retry the same request
```

From the arguments above, you need to provide `--availability-domain`, `--compartment-id`, `--image-id`, `--subnet-id`, and `--ssh-public-key` to construct a valid request.
The first four arguments must be OCID strings, and the last one is the path to your SSH public key file that you will use to access the instance.

Getting OCID string is quite of a hassle if you're not familiar with OCI CLI.
Since your browser uses the same API endpoint to create an instance, the easiest way to grab these values would be to copy-paste it from the browser's request body:

1. Access your OCI Compute Dashboard.
2. Click "Create instance" button.
3. Configure the instance, but do not create one yet.
4. Open up your browser's developer console (usually by pressing F12), access the `Network` tab and start recording traffic.
5. Now try creating the instance. Most likely it will throw an error saying "out of capacity" or similar. (If it doesn't, good for you! You don't need this tool.)
6. Go to the developer console and stop recording the traffic. There should be a request with HTTP error code 500.
7. Click on said request and inspect its request body. There should be a JSON document with all the OCIDs needed to launch an instance!

Once finished copying, run the script with `--dry-run` flag to see if the setting is correct.

To continuously request for an instance, set the `--retry` option.
This option takes a number in seconds, representing the time to wait in between each request. **I recommend 15sec to 60sec, and nothing below.**

Cool! Now put this script in a server or something to grab an instance for us, and have some beer!

### Note

Sometimes the script dies for some mysterious reason; at least it did in my case.
To prevent this, wrap this script with a while loop as the following `fish` shell script:
```fish
while not ruby ocidibs.rb \
    --availability-domain "..." \
    --compartment-id "..." \
    --display-name "cool-server-name" \
    --image-id "..." \
    --subnet-id "..." \
    --ssh-public-key "$HOME/.ssh/id_oraclecloud.pub" \
    --retry 15
        echo "======== OOPS! ========"
        echo "The bruteforcer had a stroke and gave up."
        echo "Spawing one again..."
        sleep 1
end
```


## Acknowledgement

This repository is based on [Hitrov's PHP script](https://github.com/hitrov/oci-arm-host-capacity) which I couldn't use because AWS-provided PHP is so ancient that even Composer sometimes fails on it.
