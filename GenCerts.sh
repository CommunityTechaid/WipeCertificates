#!/usr/bin/bash
# options: 
#   -date: gen certs for all logs on a date
#   -device: gen cert for particular device id
#
# vars:
#   logFileLocation
#   certTemplateLocation
#   certFileNameTemplate
#
# # parse args
# if date
#     logs = findLogsByDate(date)
#     certs = []
#     for log in logs:
#         logInfo = parseLog(log)
#         logCert = generateCert(logInfo)
#         certs += logCert
#     "We've generated:"
#     for cert in certs:
#         "certFileName"
#
# elfi device
#     dodododod
#
# else
#     exit with info
#
# functions
#    # findLogsByDate(date)
#    #     return files
#
#    # findLogsByID(ID)
#    #     return files
#

parseLog() {
    #take first arg as filename
    fileName="$1"

    deviceID=$(grep -Po '(?<=_)([[:digit:]]{4})(?=.log)' <<< "$fileName")

    # head to only get first if multiple disks present
    wipeStart=$(grep "Starting round 1 of 1" "$fileName" | head -n 1 | cut -d \] -f 1 | tr -d \[)
    # datetime=$(grep completed "$fileName" | cut -d \] -f 1 | tr -d \[)

    # Gather Device information
    # grep to find line, cut to split on = and awk to trim whitespace
    manufacturer=$(grep system-manufacturer  "$fileName" | cut -d = -f 2 | awk '{$1=$1};1')
    product=$(grep system-product-name "$fileName" | cut -d = -f 2 | awk '{$1=$1};1')
    serialNumber=$(grep system-serial-number "$fileName" | cut -d = -f 2 | awk '{$1=$1};1')

    # Gather disks into an array
    # 1st grep to select disk lines, 2nd grep to get just info, sed to remove superfluous s/n= to leave just serial number
    readarray -t disks < <(grep "Found /dev/" "$fileName" | grep -Eo "/dev/.+" | sed 's/S\/N=//g')

    # Format disks into a markdown table
    printf -v "diskTable" "%s" "\
| Device | Connection | Model | Capacity | Serial Number |
|--------|------------|-------|----------|---------------|"

    for disk in "${disks[@]}"; do
        string=$(awk -F "," '{print "| "$1" | "$2" | "$3" | "$4" | "$5" |"}' <<< "$disk" | sed 's/\/dev\///g')
        # $diskTable+="$string"
        printf -v "diskTable" "%s\n%s" "$diskTable" "$string"
    done

    # Grab Erasure summary
    # rawErasureTable=$(grep -Po "(?s)(?<=Drive Status \*{33}\n)(!.*?)(?:\n[[])")
    # See https://stackoverflow.com/a/17988834/17368473 for explanation for awk syntax, head -n -1 is to drop last --- line 
    # so that both tables have same layout in raw form
    rawErasureTable=$(awk '/Drive Status/{flag=1;next}/Throughput/{flag=0}flag' "$fileName"| head -n -1)
    
    # Add pre / post |
    erasureTable=$(awk '{print"| "$0" |"}' <<< "$rawErasureTable")
    # Remove superfluous !
    erasureTable=${erasureTable//!}
    # Make erased green
    erasureTable=$(sed 's/Erased/\\textbf{\\textcolor{green}{Erased}}/' <<< "$erasureTable")
    # Make erased red
    erasureTable=$(sed 's/-FAILED/\\textbf{\\textcolor{red}{FAILED}}/' <<< "$erasureTable")

    # Fix underline (couldn't come up with more elegant solution)
    erasureTable=$(sed \
        's/| -------------------------------------------------------------------------------- |/|-----------|--------|----------|----------|---------------------|/g' <<< "$erasureTable")


    # Grab Error summary
    # rawErrorTable=$(grep -Po "(?s)(?<=Error Summary \*{33}\n)(!.*?)(?:\n[*])")
    rawErrorTable=$(awk '/Error Summary/{flag=1;next}/\*{80}/{flag=0}flag' "$fileName")
    # Add pre / post |
    errorTable=$(awk '{print"| "$0" |"}' <<< "$rawErrorTable")
    # Remove superfluous !
    errorTable=${errorTable//!}
    # Fix underline
    errorTable=$(sed \
        's/| -------------------------------------------------------------------------------- |/|-----------|-------------|----------------------|---------------------|/g' <<< "$errorTable")

    # Parse last line for ultimate outcome
    lastLine=$(tail -n 1 "$fileName")
    wipeEnd=$(cut -d \] -f 1 <<< "$lastLine" | tr -d \[)

    if [[ $lastLine == *"Nwipe successful"* ]]; then
        cert="We certify the drives were wiped and data erased successfully."
    elif [[ $lastLine == *"Storage devices not found"* ]]; then
        cert="Storage devices not found."
    elif [[ $lastLine == *"Nwipe was aborted"* ]]; then
        cert="The drive wipe was aborted so we cannot certify the data was erased."
    else cert="The drive wipe failed so we cannot certify the data was erased."
    fi


    printf -v "report" \
"# CTA Disk Wiping
**CTA Donation ID**: %s

**Erasure standard**: HMG Infosec Baseline Standard 5

**Wipe started**: %s

**Wipe ended**: %s

## Device Info[^1]
[^1]: These are the details of the devices used to wipe the disks. In situations where a computer is unable to power on these will differ to the machine donated.

**Device Make**: %s 

**Device Model**: %s 

**Device Serial Number**: %s 

## Disk Info

%s

## Erasure Summary

%s

## Error Summary

%s

# Cert
%s
" \
"$deviceID" \
"$wipeStart" \
"$wipeEnd" \
"$manufacturer" \
"$product" \
"$serialNumber" \
"$diskTable" \
"$erasureTable" \
"$errorTable" \
"$cert" 

pandoc -f markdown -H CTA.tex -s -o CTAWipeReport-"$deviceID".pdf <<< "$report"

}

parseLog "$1"
