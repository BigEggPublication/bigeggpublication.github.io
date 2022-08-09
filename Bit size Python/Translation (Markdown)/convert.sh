#!/bin/bash
#
# convert - A script to convert markdown translate to word file

usage()
{
    echo "usage: bash ./convert.sh [id]"
}

##### Main

if [ $# -eq 0 ]
then
    echo "No parameter found"
    usage
    exit 1
fi

id=$1

echo "Convert start"

if [ "$id" -eq 0 ]
then
    echo "Convert preface"
    pandoc -o ../Translation\ \(Word\)/Preface.docx -f markdown-implicit_figures -t docx Preface.md
elif [ "$id" -eq "15" ]
then
    echo "Convert Appendix"
    pandoc -o ../Translation\ \(Word\)/Appendix\ Checkpoint\ Answers.docx -f markdown-implicit_figures -t docx Appendix\ Checkpoint\ Answers.md
else
    echo "Convert Chapter $id"
    pandoc -o ../Translation\ \(Word\)/Chapter\ "$id".docx -f markdown-implicit_figures -t docx Chapter\ $id.md
fi

echo "Convert completet"
