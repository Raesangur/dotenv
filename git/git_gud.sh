git add -A

if [ $# -eq 0 ] ; then
    echo 'Enter the commit message:'
    read commitMessage
else
    commitMessage=$1
fi


git commit -S -m "$commitMessage"

git push

read
