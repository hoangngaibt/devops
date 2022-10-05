organisation='belleai'
user='***************'    # User Name
pass='******************' # ADO PAT
project_lists='projects.txt'
repos_tmp='repos.csv'
repo_lists='repos_ado.csv'

#get the list of projects
curl -s --request GET -u $user:$pass  \
     --url "https://dev.azure.com/$organisation/_apis/projects?api-version=7.0" \
     -H "Content-Type: application/json" | jq -r .value[].name > $project_lists

echo "repo_url,repo_name" > $repos_tmp
#get the list of repositories
while read -r project;
do
    project=$(echo $project | jq -sRr @uri)
    project=$(echo $project | sed "s#%0A##g")
    curl -s --request GET -u $user:$pass  \
         --url "https://dev.azure.com/$organisation/$project/_apis/git/repositories?api-version=7.0" \
         -H "Content-Type: application/json" | jq -r '.value[] | (.remoteUrl)+","+(.name)' >> $repos_tmp
done < $project_lists

echo "repo_url,repo_name" > $repo_lists
#format list of repositories in csv format
while IFS="," read -r REPO_URL DIRECTORY
do
    repo_url=$(echo $REPO_URL | sed "s#https://$organisation@##")
    repo_name=$(echo $DIRECTORY | jq -sRr @uri)
    repo_name=$(echo $repo_name | sed "s#%0A##g")
    repo_info=$repo_url,$repo_name
    echo $repo_info >> $repo_lists
done < <(tail -n +2 $repos_tmp)

ONEDRIVE='onedrive:Repos_Backup'
LISTFILES='listfiles.txt'
#clone and push files to OneDrive
while IFS="," read -r REPO_URL DIRECTORY
do
  #clone repos
  git clone --mirror https://backup:$pass@$REPO_URL
  echo "Repo Name $DIRECTORY."
  #compress the file
  zip -r $DIRECTORY-$(date '+%d-%m-%Y').zip $DIRECTORY.git > /dev/null
  #copy to onedrive
  rclone copy $DIRECTORY-$(date '+%d-%m-%Y').zip $ONEDRIVE
  #list files
  rclone ls $ONEDRIVE | grep $DIRECTORY > $LISTFILES
  #delete old files
  while IFS=" " read -r filesize filename
  do
     rclone deletefile $ONEDRIVE/$LISTFILES
  done < <(tail -n +3 $listfiles)
  echo "#################################################################"
done < <(tail -n +2 $repo_lists)
