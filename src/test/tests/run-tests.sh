#!/bin/bash

EXE="../test"
TMPVAL=`mktemp`

fail=0
success=0

for f in *.sc; do
    echo -n "Checking $f.... "

    args=`cat $f | awk '/^\/\/@/ { fn=$2; c=0; a=""; for (n=3;n<13 && $n!="";n++) {c++; a=a $n;}; printf("%s %s %s ", fn, c, a); }'`

    res="${f}.res"

    echo "#" $EXE "$f" $args  > "$TMPVAL"
    echo "" >> "$TMPVAL"
    $EXE "$f" $args 2> /dev/null | grep "^RESULT:" >> "$TMPVAL"

    if [ ! -f "$res" ]; then
	mv "$TMPVAL" "$res"
	echo " CREATE"
	continue;
    fi

    cmp "$res" "$TMPVAL" &> /dev/null

    if [ $? != 0 ]; then
	echo " FAIL"
	fail=$[ $fail + 1 ]
	continue;
    fi
    echo " OK"
    success=$[ $success + 1 ]
done

echo "Fail: $fail"
echo "Success: $success"

rm -f "$TMPVAL"

[ "$fail" == 0 ]
exit $?
