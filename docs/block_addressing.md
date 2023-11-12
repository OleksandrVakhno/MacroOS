LBA - logical block addressing
CHS - Cylinder-head-sector


**From CHS to LBA**

CHS refers to cylinders, heads and sectors from the days when disks literally did access data that way - choosing a cylinder, head and sector to read.

LBA is a newish scheme which basically addresses the disk as a continually increasing number of blocks.

The conversion scheme essentially gets you from one to the other. Firstly, the equation gives you placeholders for some values you need to know - how many heads per cylinder, and how many sectors per head.

So, now imagine you have some data like this:

Cylinder number    Head Number     Sector Number   Data           LBA
================================================================================
       0               0                0          A              1
       0               0                1          B              2
       0               0                2          A              3
       0               1                0          B              4
       0               1                1          A              5
       0               1                2          B              6
This is a deliberately contrived scheme in which there are only three tracks per head. How, we've chosen to order the LBAs such that each track number we go up by increases the number. However, when we switch heads, we also need to increment the track number. Thus, we could say:

LBA = sectors per head * current head + current sector number
So now to find LBA 4, we know in CHS notation that equals (0,1,0). Wth three sectors per head, 3*1+0=4.

Note, we've deliberately missed off the -1 so you focus on the idea - that's used because LBAs are zero-offset.

Anyway, so this works fine for heads and sectors, but what about cylinders? Well, if the cylinder number goes up by one we have jumped number of heads per cylinder heads forward on the disk, which is number of heads per cylinder times number of sectors per head sectors on the disk. If we're given a cylinder, head, sector tuple we can work out how many sectors that might add up to:

LBA = (((cylinder number * heads per cylinder) + head number) *
      * sector per head) + sector number - 1
Working from left to right, the first part of the equation converts the cylinder number to the number of heads required to jump; the next part adds the current head number to that and converts it into a number of sector. Finally, you add the current sector number and subtract one from zero indexing.

We are sort of repeating ourselves here and for good reason - this is just one of those concepts. If it helps, draw a parallel - convert from hex to decimal. Assume we've given a FED and want to know what that is in decimal. Well, the conversion would be:

dec = (((15*16)+14)*16)+13
From left to right in FED, there are 16 "hundreds" per "ten" and we have the digit 15. To that we add the number of "tens", which is 14. This we multiply by 16 again because there are 16 "tens" per unit. Finally, we add on the extra 13 units.

The thing is, you do this kind of thing every day with decimal numbers - the only difficulty here is that the base, or radix is a number that isn't ten and therefore makes sense in our natural notation.

**From LBA to CHS**

Given an LBA address, we know that if we multiply tracks per head by heads per cylinder, that gives us the number of tracks a given cylinder number "covers" - all the remainders in this range use the same cylinder nunber. Practical example using the contrived table above: there are 3 tracks per head and let's say 6 heads per cylinder - so 6*3=18. Now take an LBA, say 5 - 5/18 = 0 remainder 5. So we take that quotient value to be the cylinder number, which it is.

So the next question takes the LBA number and divides that by the sectors per track you have - why? Well remember, our LBA counts "tracks". Dividing by this value and taking the floor (since each individual track accounts for all the possible remainders) converts us to heads. We then take that value modulo the number of heads per cylinder so that, for example, if we have 6 heads per cylinder and a head value of 8, we correctly report the head number as 2 (the cylinder number being 1, accounting for the first 6).

Finally, the sector number is a simple LBA divided by sectors per track (plus one to offset the zero indexing) remainder. Why? Well, each track can only contain a certain number of sectors before a different head/track is needed.

Sector = (LBA % sectors per track) + 1
Head = (LBA / sectors per track) % heads
Cylinder = (LBA/ sectors per track)/ heads