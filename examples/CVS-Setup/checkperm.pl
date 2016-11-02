#! /bin/env perl 
# $Id$
# vim: set ft=perl sw=4 ts=8 tw=78:
#*****************************************************************************
#
#             (c) Copyright 2001-2008,  VIA Technologies, Inc.       
#                           ALL RIGHTS RESERVED                            
#                                                                    
#                                                                    
#  This design and all of its related documentation constitutes valuable and
#  confidential property of VIA Technologies, Inc.  No part of it may be
#  reproduced in any form or by any means   used to make any transformation
#  /adaptation / redistribution without the prior written permission from the
#  copyright holders. 
#
#-----------------------------------------------------------------------------
#
# DESCRIPTION:
#
#   CVS Repository access permission control
#
# FEATURES:
#   The permission control is disabled until the auth file $CVSROOT/CVSROOT/is
#   readable
#
#   Globally denied: User could not commit to any directories until specified
#   explicitly
#
#   AUTH Files Format:
#
#   Account:True Name: Email: dir1, dir2, dir3, file1, file2
#
# TODO
#
# AUTHORS:
#    Alan Che
#
#   
#-----------------------------------------------------------------------------
#                            REVISION HISTORY
#   $Log$
#
#****************************************************************************/
#
#
use warnings;
use strict;
use Term::ANSIColor;

my $cvsroot = $ENV{'CVSROOT'};
my $cvsuser = $ENV{'CVS_USER'};
my $auth = $cvsroot.'/CVSROOT/maillist';

defined (@ARGV) || exit 1;
defined ($cvsroot) || exit 1;
 -r $auth || exit 0;


# preparing the acessing directories
my $repository = shift @ARGV;
$repository =~ s#^\s*$cvsroot/##;
my @access = map {$repository."/".$_} @ARGV;

my @dirs;
open  my $auth_fh,"<$auth" or die "$!";
while (my $l = <$auth_fh>) {
    if ($l =~ /^\s*$cvsuser/) {
	$l =~ s/\s*#.*$//;
	my @t = split(/:/,$l);
	&Error("ERROR Auth file format: Missing directories field") unless ($#t == 3);
	$t[3] =~ s/\s*//;
	@dirs = split(/,/,$t[3]);
    }
}

# Globally denied unless specified
&Error("ERROR: Undefined Access directories for user $cvsuser in Auth file") unless (@dirs); 


# Check The access permission
my $deny = 1;
my $errMsg = "";
foreach my $p (@access) {
    $deny = 1;
    foreach my $d (@dirs) {
	$deny = 0, last if ($p =~ m#^\s*$d .*#xi); 
    }
    $errMsg .= "$p\n" if $deny;
}

if ($errMsg =~ /^\S+/) {
    my $msg = "ERROR: You($cvsuser) are not allowed to access:\n$errMsg";
    local $" ="\n";
    $msg .= "\nYou are granted to access:\n";
    $msg .= "@dirs";
    &Error($msg);
}


sub Error
{
    my $msg = shift @_;
    print color 'bold red';
    print $msg."\n";
    print color 'reset';
    exit 1;
}

exit 0;
