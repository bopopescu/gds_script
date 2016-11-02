#! /bin/env perl 
# $Id: logcommit.pl,v 1.8 2008/12/10 01:41:11 alanc Exp $
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
# FEATURES:
#
# TODO
#
# AUTHORS:
#    Alan Che
#
#   
#-----------------------------------------------------------------------------
#                            REVISION HISTORY
#   $Log: logcommit.pl,v $
#   Revision 1.8  2008/12/10 01:41:11  alanc
#    Bug Fixed for checking the input command line arguments
#
#   Revision 1.7  2008/12/10 01:35:41  alanc
#    Ignores the directory adding
#
#   Revision 1.6  2008/12/09 06:55:10  alanc
#    Bug Fixed: generate one file for one session
#
#   Revision 1.5  2008/12/09 02:12:42  alanc
#    Updates the mailist to support the sender name
#
#   Revision 1.4  2008/12/09 01:31:49  alanc
#    bold display the table header lines.
#
#   Revision 1.3  2008/12/08 02:35:30  alanc
#    update for better printing..
#
#   Revision 1.2  2008/12/08 02:28:22  alanc
#    Changed the target written file name
#
#   Revision 1.1  2008/12/08 01:58:43  alanc
#    add logcommit.pl and maillist to administration database
#
#
#****************************************************************************/
#
#
use strict;
use warnings;
use IO::File;
use Data::Dumper;
use Tie::File;

my $uniq_name = $ENV{'PWD'};

$uniq_name =~ s#.*cvs-serv(\d+).*#$1#;
my $logfile = '/cpuwrk/vcs_mail/vcs_mail-cvs_commit_log-'.$uniq_name.'.eml';

my $cvsroot = $ENV{'CVSROOT'};
my $cvsuser = $ENV{'CVS_USER'};
my $maillist = $cvsroot.'/CVSROOT/maillist';

return 0 if ($ARGV[0] =~ /- New directory$/);

my $changes =  {};
my @Log;
my $module;

my @param = split(/\s+/,$ARGV[0]);
$module = shift @param;

foreach (@param) {
    my @info = split(/,/,$_);
    $changes->{$info[0]}->{preVersion}=$info[1];
    $changes->{$info[0]}->{curVersion}=$info[2];
}

my $isLog = 0;
my $action;
while (my $l = <STDIN>) {
    next if ($l =~ /^(Update of)|(In directory)/);
    next if ($l =~ /^\s*$/);
    if ($l =~ /^\s*((Modified)|(Added)|(Removed)) Files:/) {
	$action = $1;
	next;
    } elsif ($l =~ /^\s*Log Message:/) {
	$isLog = 1;
	undef $action;
	next;
    }
    if (defined($action) && ~$isLog && $l =~ /\w+/){
	$l =~ s/^\s+//;
	my @files = split(/\s+/,$l);
	foreach my $f (@files) {
	    $changes->{$f}->{action}= $action;
	}

    }
    if ($isLog) {
	push @Log,$l;
    }
}

my $record ='';
foreach my $item (keys %$changes) {
	$record .= qq#
	    <tr>
		<td> $module/$item </td>
		<td> $changes->{$item}->{action}</td>
		<td> $changes->{$item}->{preVersion}</td>
		<td> $changes->{$item}->{curVersion}</td>
	    </tr>
	#;
}

# Generates the final files
if ( -e $logfile) {
	&mod_html;
} else {
	&gen_html;
}

# Generates the HTML E-mail
sub gen_html
{
	my $mail_fh;
	open  $mail_fh,"<$maillist" or die "$!";
	my @mail = <$mail_fh>;
	my %mail_list = map { chomp $_;my @t = split(/:/,$_); (/^\s*#/ || /^\s*$/) ? () :($t[0]=>{"NAME",$t[1],"EMAIL"=>$t[2]}) } @mail;
	close $mail_fh;

	my $recipient = join(',',sort (map {$mail_list{$_}{EMAIL}} (keys %mail_list)));
	my $sender = "\"$mail_list{$cvsuser}{NAME}\" <$mail_list{$cvsuser}{EMAIL}>" || '"CVS Admin" <CVSAdmin@viatech.com.cn>';
	
	my @mos = ('January','February','March','April','May','June','July',
	    'August','September','October','November','December');
	my @days = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	$year += 1900;
	my $timestamp = "\t$days[$wday] $mos[$mon] $mday, $year @ $hour:" . sprintf("%02d", $min) . "\n";

	$Log[0] = " This Guy is too lazy, write nothing" unless @Log;

	my $templates = <<EOF;
From:$sender
To:$recipient
Subject:[CVS] Notification: Repository has been updated by commit
Importance: low
Content-Type:text/html







EOF



	local $"="<br>";
	$templates .= <<EOF;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
    <head>
	<style type="text/css">
	    body {
		font-family: 'Times New Roman';
		font-size: 20px;
	    }
	    table {
		margin-top: 20px;
		border-left: 1pt solid #336699;
		border-bottom:1pt solid #336699;
		margin-left: 50px;
		color: #003366;
	    }
	    td {
		border-top: 1pt solid #336699;
		border-right: 1pt solid #336699;
		padding: 5pt;
	    }
	    .head {
		font-weight:bold;
	    }

	    div.note {
		margin-top:20px;
		color:gray;
		font-size:10px;
	    }
	</style>
    </head>
    <body>
	Hi all:<br>
	&nbsp;&nbsp; I've updated the CVS Repository. please check the following information for details.
	<br>
	<br>
	<br>

	&nbsp;&nbsp; Date:$timestamp<br>
	&nbsp;&nbsp; By:$mail_list{$cvsuser}{NAME} <br>

	<table cellpadding="0" cellspacing="0">
	    <tr class="head">
		<td width="350px"> Files </td>
		<td width="100px"> Action </td>
		<td width="100px"> From Rev.</td>
		<td width="100px"> To Rev. </td>
	    </tr>
	    $record
	    <!-- records -->
	    <tr>
		<td colspan="4">
		    Log Messages:<br>

		    @Log

		</td>
	    </tr>
	</table>
	<div class="note">
	    Powered by: Alan Che @ Mon Dec  8 08:56:48 CST 2008
	</div>
    </body>
</html>
EOF

	my $fh;
	open  $fh ,">$logfile" or die "$!";
	print $fh $templates;
	close $fh;
}


# Modified the existing files
sub mod_html 
{
    my @array;
    tie @array, 'Tie::File', $logfile or die "$!";
    foreach (@array) {
	s/<!-- records -->/$record<!-- records -->/ && last;
    }
    untie @array;
}


