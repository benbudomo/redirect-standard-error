#!/bin/bash

# This script is similar to the add-new-local-user.sh script and creates a new user on a local machine. 
# Redirects error messages to to STDERR 

# Enforces root privileges 
if [[ "${UID}" -ne 0 ]]
then
    echo "Please run the script with root privileges." >&2
    exit 1
fi

# Provide usage statement if user does not supply an account name
if [[ "${#}" -lt 1 ]]
then
    echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
    echo "Create an account on the local system with the name of USER_NAME and a comments field of COMMENT." >&2
    exit 1
fi

# The first parameter is the user name
USER_NAME="${1}"

# The rest of the parameters are for the account comments
shift
COMMENT="${@}"

# Generate a password
PASSWORD=$(date +%s%N | sha256sum | head -c48)

# Create the user with the password
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

# Check to see if useradd command succeeded
if [[ "${?}" -ne 0 ]]
then 
    echo "The user could not be created" >&2
    exit 1
fi

# Set the password for the user
echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null

# Informs if the password was not created
if [[ "${?}" -ne 0 ]]
then
    echo "The password could not be created for the user" >&2
    exit 1
fi

# Force password change on first login
passwd -e ${USER_NAME} &> /dev/null

# Displays username, password, and host
HOST_NAME=$(hostname)
echo "Username: ${USER_NAME}"
echo
echo "Password: ${PASSWORD}"
echo
echo "Host: ${HOST_NAME}"

exit 0