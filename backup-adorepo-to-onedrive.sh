#! /bin/bash
PASS='*****************************'
LISTREPOS='repos_ado.csv'
ONEDRIVE='onedrive:Repos_Backup'
LISTFILES='listfiles.txt'

while IFS="," read -r REPO_URL DIRECTORY
do
  #clone repos
  git clone --mirror https://hoangngaibt:$PASS@$REPO_URL
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
done < <(tail -n +2 $LISTREPOS)
