#!/bin/bash
#branch_name= echo $(Build.SourceBranch)
branch_name="refs/heads/feature/AF-01"

echo $branch_name
if [ "$branch_name" == "refs/heads/develop" ]; then
    sed -i 's/npm run build/npm run dev'/g Dockerfile
elif [ "$branch_name" == "refs/heads/feature/master" ]; then
    echo "It is ok :)"
fi

cat Dockerfile