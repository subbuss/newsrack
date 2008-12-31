#!/bin/sh

cd ../global.news.archive/filtered
for i in `ls -p | grep '/'`
do
	echo $i
	cd $i
	for j in `ls`
	do
		ifile=$j/index/index.xml;
#		oldfile=$j/index/index.broken.xml;
		oldfile=$j/index/index.old.xml;
		fixedfile=$j/index/index.xml.fixed;
#		echo "looking for $fixedfile in `pwd`\n";
		if [ -f $fixedfile ]
#		if [ -f $oldfile ]
#		if [ -f $ifile ]
		then
			\mv $ifile $oldfile;
			\mv $fixedfile $ifile;
			echo "moving for $i/$j/index/index.xml.fixed\n";
#			\rm $ifile;
#			\mv $oldfile $ifile;
		fi
	done
	cd ..
done
