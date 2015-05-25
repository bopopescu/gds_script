for i in `awk '{print $1}' users.list`;do userdel $i;done
