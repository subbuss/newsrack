#!/bin/tcsh

cd ../news.archive/orig
find 2007 -name "*news4.php*" -exec grep -i -L konabody {} \; > /tmp/bad.newkerala.files
cd ../../users
find . -name "news.xml" > /tmp/user.index.files
cd ../news.archive/filtered
../../scripts/remove.localcopyrefs.pl /tmp/bad.newkerala.files /tmp/user.index.files > /tmp/script.log
find 2007 -name "index.xml.FIXED" > /tmp/a
find ../../users -name "news.xml.FIXED" >> /tmp/a
cat /tmp/a | sed 's/.FIXED//g;' > /tmp/b
paste /tmp/b /tmp/a | sed 's/^/mv /g;s/.FIXED/.UNFIXED/g;' > /tmp/c1
paste /tmp/a /tmp/b | sed 's/^/mv /g;' > /tmp/c2

#sudo /etc/init.d/tomcat5.5 stop
#sh /tmp/c1
#sh /tmp/c2
#cd ..
#mv cache.xml.FIXED cache.xml
#sudo /etc/init.d/tomcat5.5 start
