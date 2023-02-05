scp -r scripts spice@mac.svnx.dev:reports/
scp .htaccess spice@mac.svnx.dev:reports/
#cat README.md | pandoc --from gfm --to html --standalone --output index.html --metadata title="Spice Mac Builds"
grip README.md --export index.html
scp index.html spice@mac.svnx.dev:reports/

