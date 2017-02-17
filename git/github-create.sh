github-create() {
 repo_name=$1

 dir_name=`basename $(pwd)`

 if [ "$repo_name" = "" ]; then
 echo "Repo name (hit enter to use '$dir_name')?"
 read repo_name
 fi

 if [ "$repo_name" = "" ]; then
 repo_name=$dir_name
 fi

 username=`git config user.name` #`git config github.user`
 if [ "$username" = "" ]; then
 echo "Could not find username, run 'git config --global user.name <username>'"    #"Could not find username, run 'git config --global github.user <username>'"
 invalid_credentials=1
 fi

 token=`git config user.token`        #`git config github.token`
 if [ "$token" = "" ]; then
 echo "Could not find token, run 'git config --global user.token <token>'"    #"Could not find token, run 'git config --global github.token <token>'"
 invalid_credentials=1
 fi

 if [ "$invalid_credentials" == "1" ]; then
 return 1
 fi

 echo -n "Creating Github repository '$repo_name' ..."
 curl -u  "$username:$token" https://github.hpe.com/api/v3/user/repos -d '{"name":"'$repo_name'"}' > /dev/null 2>&1
 # curl -u "$username:$token" https://api.github.com/user/repos -d '{"name":"'$repo_name'"}' > /dev/null 2>&1
 echo " done."

 echo -n "Pushing local code to remote ..."
 git remote add origin https://github.hpe.com/$username/$repo_name.git
 #git remote add origin git@github.hpe.com:$username/$repo_name.git > /dev/null 2>&1
 git push -u origin master > /dev/null 2>&1
 echo " done."
}