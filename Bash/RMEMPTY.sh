echo `date` INFO: remove sample files
find /media/data/TV  /media/moredata/MOVIES -iname "*sample*" -exec rm -f '{}' \;


echo `date` INFO: remove all files but what is in the whitelist \(DANGER DO NOT RUN THIS ON THE WRONG PATH\)
find /media/data/TV  /media/moredata/MOVIES -regextype egrep -type f ! -iregex '.*\.(avi|mpg|mov|flv|wmv|asf|mpeg|m4v|divx|mp4|mkv|sub|iso|264|vob|srt|img|sfv)$' -exec rm -Rf '{}' \;

echo `date` INFO: remove empty folders \(DANGER DO NOT RUN THIS ON THE WRONG PATH\)
find /media/data/TV  /media/moredata/MOVIES -depth -empty -type d -exec  rmdir {} \;

echo `date` INFO: display files likly to be random but dont delete them
find /media/data/TV  /media/moredata/MOVIES -regextype egrep -type f  -iregex '.*\.(avi|mpg|mov|flv|wmv|asf|mpeg|m4v|divx|mp4|mkv|iso|264|vob|img|sfv)$' -exec du -h '{}' \;  |  egrep '.*\/([A-Z])\w+\....$'

echo `date` INFO: fix random file names to parrent folder W00T sure there is a way to do this with regex/find but not sure ...
# fixed to escape to single quotes
# fixed to add  missing forward  slash
# needs to be fixed for random folders
find /media/moredata/MOVIES/ |grep -E "([A-Z|a-z|0-9]{17,30})" | sed -r 's/(\/media\/moredata\/MOVIES\/)(.*)(\/.*)(\....)/mv '\''\1\2\3\4'\''  '\''\1\2\/\2\4'\''/g'  > tmp
bash -x tmp

find /media/data/TV/ |grep -E "([A-Z|a-z|0-9]{17,30})" | sed -r 's/(\/media\/data\/TV\/)(.*)(\/.*)(\....)/mv '\''\1\2\3\4'\''  '\''\1\2\/\2\4'\''/g'  > tmp

bash -x tmp


echo `date` INFO: Showing  folders that never got moved and renamed to the right show likly to be deleted.....
find /media/data/TV -maxdepth 2 -type d  -regextype sed -regex ".*S[0-9].*" -exec du -sh '{}' \;

echo `date` INFO: any TV folders look like they need to be deleted

find /media/data/TV -maxdepth 1 -type d -exec du -h '{}' \;  | awk '{ print length, $0 }'  | sort -n -s | cut -d" " -f2- |  grep -v "Season [0-9]"|tail -n 30 | uniq
