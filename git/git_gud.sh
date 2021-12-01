git add *

if [ $# -eq 0 ] ; then
    echo 'Enter the commit message:'
    read commitMessage
else
    commitMessage=$1
fi


git commit -m "$commitMessage"

git push

read
