#!/usr/bin/env awk -f
{ 
    sum += $1
    nums[NR] = $1  # We store the input records
}
END {
    asort(nums)
 
    #Let's beautify the output
    printf \
        "%s",\
        nums[NR]
}