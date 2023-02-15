scp -r scripts spice:reports/
scp -r css spice:reports/
scp .htaccess spice:reports/
source ./env
export GH_TOKEN
content_line=$(grep CONTENT template.html -n | cut -f1 -d:)
gh api --method POST -H "Accept: application/vnd.github+json" /markdown -F 'text=@README.md' >content.html
head -n $(( content_line - 1)) template.html >index.html
cat content.html >>index.html
tail -n +$(( content_line + 1)) template.html >>index.html
scp index.html spice:reports/

