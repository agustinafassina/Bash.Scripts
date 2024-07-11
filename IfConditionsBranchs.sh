#!/bin/bash
#branchName= echo $(Build.SourceBranch)
branchName="refs/heads/feature/AF-01"

echo $branchName
if [ "$branchName" == "refs/heads/develop" ]; then
    sed -i 's/npm run build/npm run dev'/g Dockerfile
elif [ "$branchName" == "refs/heads/feature/master" ]; then
    echo "It is ok :)"
fi

cat Dockerfile