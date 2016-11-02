#!/usr/bin/perl -w
use strict;
my $a=`uname -r`;
if ($a=~m/2\.6/g) {
       my $num1=`free -m|grep Mem|awk '{print \$3}'`;
        system("sync");
        system("echo \"3\" > /proc/sys/vm/drop_caches");
       my $num2=`free -m|grep Mem|awk '{print \$3}'`;
       my $result=$num1-$num2;
        print "Successful release memory $result MB\n"
                    }
else {
        print "Not Support other than linux kernel version 2.6\n";
}
