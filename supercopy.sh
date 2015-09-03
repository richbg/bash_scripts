#!//bin/bash
# supercopy
# Usage: supercopy < list> <files...> 
file=$1 
shift
for a in `cat $file` ;do 
echo $a 
#echo " $* ads@$a:" 
scp $* ads@$a: 
done
