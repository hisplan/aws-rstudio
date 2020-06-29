# aws-rstudio

Running RStudio on AWS.

## Requirements

- AWS CLI
- Python 3+
- Bash Terminal

Note that the scripts are:

- only tested on Mac (probably not working well for Windows and others).
- designed to run with the Dana Pe'er Lab AWS environment.

## How to Run

```bash
./start.sh -k dpeerlab-chunj -i t2.medium
```

where
- `-k` : Your keypair name
- `-i` : EC2 instance type

If everything goes right, you will see the RStudio login page in your local browser.

Use the following credentials:

- user name: `rstudio`
- password: `--------`

Your EC2 instance ID (e.g. `i-0011233aa`) is your initial password.

Once you're into RStudio, you might want to change your password by running the following commands:

```R
library("RStudioAMI")
passwd()
```

# References

RStudio AMI is based on this: https://www.louisaslett.com/RStudio_AMI/
