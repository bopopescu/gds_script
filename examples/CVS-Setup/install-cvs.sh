#!/bin/sh
# $Id$
# vim: set filetype=sh foldmethod=indent autoindent shiftwidth=4 tabstop=8:
#******************************************************************************

echo "Please type the project ID, the topest module name, e.g vt3421"
echo -n "->"
read PROJECT

echo "Please type the CVSROOT directory, full absolute path"
echo -n "->"
read CVSROOT
eval "CVSROOT=$CVSROOT"
if expr $CVSROOT : '[^/]*' >& /dev/null; then
    CVSROOT="$PWD/$CVSROOT"
fi
export CVSROOT

echo "Please type the ASIC FLOW directories need to be created as the initial database ready"
echo -n "->"
read ASIC_FLOWS
ASIC_FLOWS="`echo $ASIC_FLOWS | tr  [a-z] [A-Z]`"

echo "Please specify the sub module design directories names"
read SUB_DESIGNS

echo "Please specify a full hostname the CVS Server will be running on,one project one server. e.g.  cpu0354"
echo -n "->"
read HOST




COLOR_GREEN="\e[01;32m"
COLOR_RED="\e[01;31m"
COLOR_NORMAL="\e[0m"







#ASIC_FLOWS="STA DOC ECO TEST SIM/model SIM/vec LINT SYN"
#SUB_DESIGNS="aes_des_sha busmux dma ecc ecc_rsa emc gpio hpi iic intc
#inter_memc lpc_host lpc_slv pmu rng scif sdramc serial_IRQ ssp
#timer top uart scan";

SUB_DESIGN_DIRS="src cons syn sim/vec"






#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#  Let me alonely...
#
#

PATH="/cad/cvs/linux/bin:/bin:/usr/bin:$PATH"

if [ "`uname -s`" != "Linux" ]; then
    echo " ERROR: Please running under Linux";
    exit 1;
fi

function prompt()
{
    :;
#    echo "Continues?"
#    read var
#    if [ "$var" != "y" ]; then exit 1; fi
}

function CreateMakefile()
{
cat > $1 <<EOF
# \$Id\$
# vim: set filetype=make foldmethod=indent autoindent shiftwidth=4 tabstop=8:
#/*****************************************************************************
# 
#              (c) Copyright 2001-2008,  VIA Technologies, Inc.       
#                            ALL RIGHTS RESERVED                            
#                                                                     
# This design and all of its related documentation constitutes valuable and
# confidential property of VIA Technologies, Inc.  No part of it may be
# reproduced in any form or by any means   used to make any transformation
# / adaptation / redistribution without the prior written permission from the
# copyright holders. 
# 
#------------------------------------------------------------------------------
#
# DESCRIPTIONS:
#  ${@:2}
#
#
#------------------------------------------------------------------------------
#                             REVISION HISTORY
#    \$Log\$
#
#*****************************************************************************/

EOF
}

TMPDIR=${TMPDIR:-/tmp}


# Change the working space to tmp dir
cd $TMPDIR;
rm -rf $CVSROOT

cvs init;
# Let group member share the privileges.
chown -R ${USER} $CVSROOT
chmod 2755 $CVSROOT
mkdir $CVSROOT/tmp
chmod 777 $CVSROOT/tmp

if [ -d "$PROJECT" ] ; then
    rm -rf $PROJECT;
fi
mkdir $PROJECT
cd $PROJECT;
CreateMakefile Makefile.defs "Project-wide Macros Settings"
for f in $SUB_DESIGNS ; do
    mkdir -p $f
    (
	cd $f
	for ff in $SUB_DESIGN_DIRS; do 
	    mkdir -p $ff
	done
    )
done

for f in  $ASIC_FLOWS; do
    (
    mkdir -p $f
    cd $f
    CreateMakefile Makefile
    )
done

cvs -Q import -m " Initial Importing" $PROJECT via init 
cd ..
rm -rf $PROJECT

prompt

if [ -d "CVSROOT" ] ; then
    rm -rf CVSROOT
fi

# Configures the CVS Administration database
cvs -Q co CVSROOT
cd CVSROOT

prompt

# Modify config
(echo '# $Id$'; echo "LockDir=$CVSROOT/tmp"; cat config) > .f
mv .f config
cvs -Q ci -m 'Change the LockDir to $CVSROOT/tmp' config



echo "Creating precommit.sh"
touch $CVSROOT/CVSROOT/precommit.sh
chmod 755 $CVSROOT/CVSROOT/precommit.sh
cat  > $CVSROOT/CVSROOT/precommit.sh <<EOF
#!/bin/sh
# \$Id\$
# vim: set ft=sh foldmethod=indent ts=8 sw=4 tw=78:
#******************************************************************************
# 
#              (c) Copyright 2001-2007,  VIA Technologies, Inc.       
#                            ALL RIGHTS RESERVED                            
#                                                                     
#                  VIA Technologies CPU, Inc. CONFIDENTIAL                   
#                                                                     
#   This design and all of its related documentation constitutes valuable and
#   confidential property of VIA Technologies, Inc.  No part of it may be
#   reproduced in any form or by any means   used to make any
#   transformation/adaptation/redistribution without the prior written
#   permission from the copyright holders. 
# 
#------------------------------------------------------------------------------
#
#  DESCRIPTION:
#    Performing pre-commiting checking: each text files should includes the
#    \$Id \$ Tag in the begining lines of the file
#
#  FEATURES:
#  
#  AUTHORS:
#    Alan Che (ext.2322)
#
#
#
#    
#------------------------------------------------------------------------------
#                             REVISION HISTORY
#
#
#******************************************************************************

# Make sure every commited files contains \$Id \$ as the first line in the
# check-in files 
#
shift;
for file in "\$@" ; do
    if [ ! -r \$file ]; then exit 0 ; fi
    # contains non-printable character
    if grep -q '[^[:print:]]+' \$file > /dev/null ; then
	exit 0
    elif ! head -n 10 \$file | grep -q '\$Id.*\$'  > /dev/null; then
	echo -e '
	Please includes \044Id\044 in the first 10 lines and as a parts of comment to allowed CVS to
	expand to the corresponding identification information for tracking revision' 
	exit 1;
    fi
done
exit 0;
EOF

echo "Creating logcommit.pl"
touch $CVSROOT/CVSROOT/logcommit.pl
chmod 755 $CVSROOT/CVSROOT/logcommit.pl
cat > $CVSROOT/CVSROOT/logcommit.pl <<.
#! /bin/env perl 
# \$Id\$
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
#   Send out an notification mail to all the team members
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
#   \$Log\$
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

my \$uniq_name = \$ENV{'PWD'};

\$uniq_name =~ s#.*cvs-serv(\d+).*#\$1#;
my \$logfile = '/cpuwrk/vcs_mail/vcs_mail-cvs_commit_log-'.\$uniq_name.'.eml';

my \$cvsroot = \$ENV{'CVSROOT'};
my \$cvsuser = \$ENV{'CVS_USER'};
my \$maillist = \$cvsroot.'/CVSROOT/access.conf';

return 0 if (\$ARGV[0] =~ /- New directory\$/);

my \$changes =  {};
my @Log;
my \$module;

my @param = split(/\s+/,\$ARGV[0]);
\$module = shift @param;

foreach (@param) {
    my @info = split(/,/,\$_);
    \$changes->{\$info[0]}->{preVersion}=\$info[1];
    \$changes->{\$info[0]}->{curVersion}=\$info[2];
}

my \$isLog = 0;
my \$action;
while (my \$l = <STDIN>) {
    next if (\$l =~ /^(Update of)|(In directory)/);
    next if (\$l =~ /^\s*\$/);
    if (\$l =~ /^\s*((Modified)|(Added)|(Removed)) Files:/) {
	\$action = \$1;
	next;
    } elsif (\$l =~ /^\s*Log Message:/) {
	\$isLog = 1;
	undef \$action;
	next;
    }
    if (defined(\$action) && ~\$isLog && \$l =~ /\w+/){
	\$l =~ s/^\s+//;
	my @files = split(/\s+/,\$l);
	foreach my \$f (@files) {
	    \$changes->{\$f}->{action}= \$action;
	}

    }
    if (\$isLog) {
	push @Log,\$l;
    }
}

my \$record ='';
foreach my \$item (keys %\$changes) {
	\$record .= qq#
	    <tr>
		<td> \$module/\$item </td>
		<td> \$changes->{\$item}->{action}</td>
		<td> \$changes->{\$item}->{preVersion}</td>
		<td> \$changes->{\$item}->{curVersion}</td>
	    </tr>
	#;
}

# Generates the final files
if ( -e \$logfile) {
	&mod_html;
} else {
	&gen_html;
}

# Generates the HTML E-mail
sub gen_html
{
	my \$mail_fh;
	open  \$mail_fh,"<\$maillist" or die "\$!";
	my @mail = <\$mail_fh>;
	my %mail_list = map { 
	    chomp \$_;
	    my @t = split(/:/,\$_);
	    \$t[0] =~ s/\s*//; 
	    \$t[2] =~ s/\s*//;
	    (/^\s*#/ || /^\s*\$/) ? () :(\$t[0]=>{"NAME",\$t[1],"EMAIL"=>\$t[2]}) } @mail;
	close \$mail_fh;

	my \$recipient = join(',',sort (map {\$mail_list{\$_}{EMAIL}} (keys %mail_list)));
	my \$sender = "\"\$mail_list{\$cvsuser}{NAME}\" <\$mail_list{\$cvsuser}{EMAIL}>" || '"CVS Admin" <CVSAdmin@viatech.com.cn>';
	
	my @mos = ('January','February','March','April','May','June','July',
	    'August','September','October','November','December');
	my @days = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
	my (\$sec,\$min,\$hour,\$mday,\$mon,\$year,\$wday,\$yday,\$isdst) = localtime;
	\$year += 1900;
	my \$timestamp = "\t\$days[\$wday] \$mos[\$mon] \$mday, \$year @ \$hour:" . sprintf("%02d", \$min) . "\n";

	\$Log[0] = " This Guy is too lazy, write nothing" unless @Log;

	my \$templates = <<EOF;
From:\$sender
To:\$recipient
Subject:[CVS] Notification: Repository has been updated by commit
Importance: low
Content-Type:text/html







EOF



	local \$"="<br>";
	\$templates .= <<EOF;
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

	&nbsp;&nbsp; Date:\$timestamp<br>
	&nbsp;&nbsp; By:\$mail_list{\$cvsuser}{NAME} <br>

	<table cellpadding="0" cellspacing="0">
	    <tr class="head">
		<td width="350px"> Files </td>
		<td width="100px"> Action </td>
		<td width="100px"> From Rev.</td>
		<td width="100px"> To Rev. </td>
	    </tr>
	    \$record
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

	my \$fh;
	open  \$fh ,">\$logfile" or die "\$!";
	print \$fh \$templates;
	close \$fh;
}


# Modified the existing files
sub mod_html 
{
    my @array;
    tie @array, 'Tie::File', \$logfile or die "\$!";
    foreach (@array) {
	s/<!-- records -->/\$record<!-- records -->/ && last;
    }
    untie @array;
}

.

echo "Creating checkperm.pl"
touch $CVSROOT/CVSROOT/checkperm.pl
chmod 755 $CVSROOT/CVSROOT/checkperm.pl
cat > $CVSROOT/CVSROOT/checkperm.pl <<EOF
#! /bin/env perl 
# \$Id\$
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
#   The permission control is disabled until the auth file \$CVSROOT/CVSROOT/is
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
#   \$Log\$
#
#****************************************************************************/
#
#
use warnings;
use strict;
use Term::ANSIColor;

my \$cvsroot = \$ENV{'CVSROOT'};
my \$cvsuser = \$ENV{'CVS_USER'};
my \$auth = \$cvsroot.'/CVSROOT/acess.conf';

defined (@ARGV) || exit 1;
defined (\$cvsroot) || exit 1;
 -r \$auth || exit 0;


# preparing the acessing directories
my \$repository = shift @ARGV;
\$repository =~ s#^\s*\$cvsroot/##;
my @access = map {\$repository."/".\$_} @ARGV;

my @dirs;
open  my \$auth_fh,"<\$auth" or die "\$!";
while (my \$l = <\$auth_fh>) {
    if (\$l =~ /^\s*\$cvsuser/) {
	\$l =~ s/\s*#.*\$//;
	my @t = split(/:/,\$l);
	&Error("ERROR Auth file format: Missing directories field") unless (\$#t == 3);
	\$t[3] =~ s/\s*//;
	@dirs = split(/,/,\$t[3]);
    }
}

# Globally denied unless specified
&Error("ERROR: Undefined Access directories for user \$cvsuser in Auth file") unless (@dirs); 


# Check The access permission
my \$deny = 1;
my \$errMsg = "";
foreach my \$p (@access) {
    \$deny = 1;
    foreach my \$d (@dirs) {
	\$deny = 0, last if (\$p =~ m#^\s*\$d .*#xi); 
    }
    \$errMsg .= "\$p\n" if \$deny;
}

if (\$errMsg =~ /^\S+/) {
    my \$msg = "ERROR: You(\$cvsuser) are not allowed to access:\n\$errMsg";
    local \$" ="\n";
    \$msg .= "\nYou are granted to access:\n";
    \$msg .= "@dirs";
    &Error(\$msg);
}


sub Error
{
    my \$msg = shift @_;
    print color 'bold red';
    print \$msg."\n";
    print color 'reset';
    exit 1;
}

exit 0;

EOF

echo "Creating the initial Authentication files: $CVSROOT/CVSROOT/passwd"

echo "$USER::$USER" > $CVSROOT/CVSROOT/passwd

NAME=`finger $USER | head -n 1 | sed -e 's@.*:\s*@@'`

echo "Create the initial Authentication files: $CVSROOT/CVSROOT/access.conf"
echo "
# This file performs the directoires access control
# Lines begin with # is comment
# Format:
#  ID:Name:Emailaddress: directories[,directories]
#
#  ID:the valid login name of a specific user
#  Name:the real name which will be displayed in the outLook
#  Email address: the full qualified email address of ID
#  directories:The directories path relative the CVSROOT which is accessible for
#  ID
#
#
# space in the field is ignored unless in Name field.
#
# Default, you are granted to acess all
$USER:$NAME:CVSAdmin-$PROJECT@viatech.com.cn:CVSROOT,$PROJECT
" > $CVSROOT/CVSROOT/access.conf


echo "Enable the trigger to hookup the CVS control"


# Modify the commit
sed -i -e '1i\
# $Id$
' commitinfo
echo 'ALL           $CVSROOT/CVSROOT/precommit.sh' >> commitinfo 
echo 'ALL	    $CVSROOT/CVSROOT/checkperm.pl' >> commitinfo
cvs ci -m " add precommit & permission control checking " commitinfo 

# Modify the loginfo
sed -i -e '1i\
# $Id$
' loginfo
echo "^$PROJECT   \$CVSROOT/CVSROOT/logcommit.pl %{sVv} > /dev/null 2>&1" >> loginfo

cvs ci -m "enable the logcommit trigger" loginfo

cd ..
rm -rf CVSROOT
# disable the accessing from other guys in the same group
chmod 2755 $CVSROOT/CVSROOT
find $CVSROOT/$PROJECT -type d -exec chmod 2755 {} \;




echo -n "Creating the User's CVS setting files ->"
echo " $CVSROOT/$PROJECT-cvs.cshrc"

cat > $CVSROOT/$PROJECT-cvs.cshrc <<EOF

#!/bin/csh
# \$Id$
# vim: set filetype=csh foldmethod=indent autoindent shiftwidth=4 tabstop=8:
#******************************************************************************
# 
#              (c) Copyright 2001-2007,  VIA Technologies, Inc.       
#                            ALL RIGHTS RESERVED                            
#                                                                     
#                  VIA Technologies CPU, Inc. CONFIDENTIAL                   
#                                                                     
#   This design and all of its related documentation constitutes valuable and
#   confidential property of VIA Technologies, Inc.  No part of it may be
#   reproduced in any form or by any means   used to make any
#   transformation/adaptation/redistribution without the prior written
#   permission from the copyright holders. 
# 
#------------------------------------------------------------------------------
#
#  DESCRIPTION:
#
#  FEATURES:
#  
#  AUTHORS:
#    Alan Che (ext.2322)
#
#
#
#    
#------------------------------------------------------------------------------
#                             REVISION HISTORY
#
#
#******************************************************************************
setenv CVSROOT :pserver:$HOST:$CVSROOT

if (\$?INFOPATH) then
    setenv INFOPATH "/cad/cvs/linux/info:\$INFOPATH"
else  
    setenv INFOPATH /cad/cvs/linux/info
endif

if (\$?MANPATH) then
    setenv MANPATH "/cad/cvs/linux/man:\$MANPATH"
else
    setenv MANPATH "/cad/cvs/linux/man"
endif


set _OS = \`uname -sp | sed 's, ,_,'\`
if (\${_OS} =~ SunOS* ) then
    set path = (/cad/cvs/solaris/bin \$path)
else if (\${_OS} =~ Linux* ) then
    set path = (/cad/cvs/linux/bin \$path )
endif
unset _OS

EOF

echo -n "Creating CVS Server configration file ->"
echo "$CVSROOT/$PROJECT-cvspserver.conf"


cat > $CVSROOT/$PROJECT-cvspserver.conf <<EOF
# vim: set ft=xinetd:
# 
# xinetd configuration files for CVSpserver of project $PROJECT
# 
# Alan Che Mon Oct  6 10:36:04 CST 2008
service cvspserver
{
    port	= 2401
    socket_type = stream
    protocol	= tcp
    wait	= no
    user	= $USER
    env		= CVSUMASK=022
    passenv	= PATH CVSUMASK
    server	= /cad/cvs/linux/bin/cvs
    server_args	= -f --allow-root=$CVSROOT pserver
}
EOF


echo -n "Creating CVS Server invoking script ->"
echo "$CVSROOT/$PROJECT-cvspserver.sh"

cat > $CVSROOT/$PROJECT-cvspserver.sh <<EOF
#!/bin/sh
# \$Id\$
# vim: set filetype=sh foldmethod=indent autoindent shiftwidth=4 tabstop=8:
#******************************************************************************
# 
#              (c) Copyright 2001-2007,  VIA Technologies, Inc.       
#                            ALL RIGHTS RESERVED                            
#                                                                     
#                  VIA Technologies CPU, Inc. CONFIDENTIAL                   
#                                                                     
#   This design and all of its related documentation constitutes valuable and
#   confidential property of VIA Technologies, Inc.  No part of it may be
#   reproduced in any form or by any means   used to make any
#   transformation/adaptation/redistribution without the prior written
#   permission from the copyright holders. 
# 
#------------------------------------------------------------------------------
#
#  DESCRIPTION:
#
#     CVS Server Invoking scripts ...
#
#  FEATURES:
#  
#  AUTHORS:
#    Alan Che (ext.2322)
#
#
#
#    
#------------------------------------------------------------------------------
#                             REVISION HISTORY
#
#
#******************************************************************************



HOSTS=$HOST
CONF_FILE="$CVSROOT/$PROJECT-cvspserver.conf"
PID_FILE="$CVSROOT/xinetd.pid"

prog="cvs pserver"

SERVER_ARGS=" -stayalive -f \$CONF_FILE -pidfile \$PID_FILE"

COLOR_GREEN="\e[01;32m"
COLOR_RED="\e[01;31m"
COLOR_NORMAL="\e[0m"
OK=" \${COLOR_GREEN}DONE\${COLOR_NORMAL} "
FAILED="\${COLOR_RED}FAILED\${COLOR_NORMAL} "
RETVAL=0

status() {

    pid=\`rsh \$HOSTS ps -u \$USER | grep xinetd | awk '{print \$1}'\`
    if [ -n "\$pid" ]; then
	echo "\${base} (pid \$pid @ \$HOSTS) is running..."
	return 0
    fi

    echo "cvs pserver is stopped"
    return 3
}



start() {
    echo -n \$"Starting \$prog: "
    pid=\`rsh \$HOSTS ps -u \$USER | grep xinetd | awk '{print \$1}'\`
    if [ -n "\$pid" ]; then
	echo "\$prog (pid \$pid @ \$HOSTS) is already running..."
	echo
	return 1
    fi
    rsh \$HOSTS xinetd \${SERVER_ARGS}
    RETVAL=\$?
    echo -e \$OK
    status
    return \$RETVAL
}

stop() {
    local pid=
    echo -n \$"Stopping \$prog: "
    pid=\`rsh \$HOSTS ps -u \$USER | grep xinetd | awk '{print \$1}'\`
    if [ -z "\$pid" ]; then
	if [ -f "\$PID_FILE" ]; then
	    pid=\`cat \$PID_FILE\`
	fi
    fi
    if [ -n "\$pid" ]; then
	rsh \$HOSTS kill -9 \$pid
    fi
    RETVAL=\$?
    rm -f \$PID_FILE
    echo -e \$OK
    return \$RETVAL
}




# See how we were called.
case "\$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
	status xinetd
	;;
  *)
	echo \$"Usage: \$0 {start|stop|status}"
	exit 1
esac

exit \$?
EOF
chmod 755 $CVSROOT/$PROJECT-cvspserver.sh


echo -e "
$COLOR_GREEN
  Congratulation! the CVS Database has been settle done!
  $COLOR_NORMAL


  CVSROOT=$CVSROOT

  1. Edit the $CVSROOT/CVSROOT/passwd
    to add the user which allowed to access the repository

  2. Edit the $CVSROOT/CVSROOT/access.conf
    to perform the permission control

  3. start the CVS Server on $HOST by:

    %$CVSROOT/$PROJECT-cvspserver.sh start

    stop the CVS Server on $HOST by:

    %$CVSROOT/$PROJECT-cvspserver.sh stop

  4. put the following line to  $HOME/.cshrc for who would like to access the repository

    source $CVSROOT/$PROJECT-cvs.cshrc

  5. create an empty cvspass file:

    %touch ~/.cvspass
    
  6. login to the remote cvs server, type enter when password prompted.
    
    %cvs login
  
  7. check out the copy from the repository start to work
    
    %cvs co $PROJECT
    

  8. you can check the directory structures by (optionally)

    %ls $CVSROOT/$PROJECT
    %ls $CVSROOT


  "
